import os
import random
import smtplib
import uuid
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from fastapi import APIRouter, BackgroundTasks, HTTPException, Request
from pydantic import BaseModel
from dotenv import load_dotenv
from passlib.context import CryptContext
from app.database.database import user_collection, otp_collection, tokens_collection
from app.limiter import limiter 

load_dotenv()
router = APIRouter(tags=["Authentication"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str):
    return pwd_context.hash(password)

class ForgotPasswordRequest(BaseModel):
    email: str

class VerifyOTPRequest(BaseModel):
    email: str
    otp: str

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

def send_otp_email(email_to: str, otp: str):
    sender_email = os.getenv("SENDER_EMAIL")
    sender_password = os.getenv("SENDER_PASSWORD")
    
    if not sender_email or not sender_password:
        print("Wrong email or password")
        return 
    
    msg = MIMEText(f"Your CodeAlert password reset code is: {otp}\n\nThis code will expire in 10 minutes.")
    msg['Subject'] = 'CodeAlert Password Reset'
    msg['From'] = sender_email
    msg['To'] = email_to
    
    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(sender_email, sender_password)
            server.send_message(msg)
            print(f"OTP email successfully sent to {email_to}")
    except Exception as e:
        print(f"Failed to send email: {e}")

@router.post("/forgot-password")
@limiter.limit("3/minute")
async def forgot_password(request: Request, payload: ForgotPasswordRequest, background_tasks: BackgroundTasks):

    user = await user_collection.find_one({"email": payload.email})
    if not user:
        return {"message": "If that email exists, an OTP has been sent."}

    await otp_collection.delete_many({"email": payload.email})

    otp_code = str(random.randint(100000, 999999))
    new_otp = {
        "email": payload.email,
        "otp": otp_code,
        "expires_at": datetime.now() + timedelta(minutes=10)
    }
    await otp_collection.insert_one(new_otp)
    background_tasks.add_task(send_otp_email, payload.email, otp_code)
    
    return {"message": "If that email exists, an OTP has been sent."}

@router.post("/verify-otp")
@limiter.limit("5/minute")
async def verify_otp(request: Request, payload: VerifyOTPRequest):

    record = await otp_collection.find_one({
        "email": payload.email,
        "otp": payload.otp
    })

    if not record:
        raise HTTPException(status_code=400, detail="Invalid OTP.")
    
    if datetime.now() > record["expires_at"]:
        await otp_collection.delete_one({"_id": record["_id"]})
        raise HTTPException(status_code=400, detail="OTP has expired.")

    reset_token = str(uuid.uuid4())
    new_token_record = {
        "token": reset_token,
        "email": payload.email,
        "expires_at": datetime.now() + timedelta(minutes=15)
    }
    await tokens_collection.insert_one(new_token_record)
    
    await otp_collection.delete_one({"_id": record["_id"]})

    return {"access_token": reset_token, "message": "OTP Verified"}

@router.post("/reset-password")
@limiter.limit("3/minute")
async def reset_password(request: Request, payload: ResetPasswordRequest):
    record = await tokens_collection.find_one({"token": payload.token})

    if not record:
        raise HTTPException(status_code=400, detail="Invalid or expired reset token.")
    
    if datetime.now() > record["expires_at"]:
        await tokens_collection.delete_one({"_id": record["_id"]})
        raise HTTPException(status_code=400, detail="Reset token has expired.")

    new_hashed_password = get_password_hash(payload.new_password)
    
    update_result = await user_collection.update_one(
        {"email": record["email"]}, 
        {"$set": {"password": new_hashed_password}}
    )

    if update_result.modified_count == 0:
        raise HTTPException(status_code=404, detail="User not found or password unchanged.")

    await tokens_collection.delete_one({"_id": record["_id"]})

    return {"message": "Password successfully reset! You can now log in."}