import os
import random
import smtplib
import uuid
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from fastapi import APIRouter, BackgroundTasks, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
from passlib.context import CryptContext
from database import user_collection, otp_collection, tokens_collection

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
async def forgot_password(request: ForgotPasswordRequest, background_tasks: BackgroundTasks):

    user = await user_collection.find_one({"email": request.email})
    if not user:
        return {"message": "If that email exists, an OTP has been sent."}


    await otp_collection.delete_many({"email": request.email})

    otp_code = str(random.randint(100000, 999999))
    new_otp = {
        "email": request.email,
        "otp": otp_code,
        "expires_at": datetime.now() + timedelta(minutes=10)
    }
    await otp_collection.insert_one(new_otp)
    background_tasks.add_task(send_otp_email, request.email, otp_code)
    
    return {"message": "If that email exists, an OTP has been sent."}

@router.post("/verify-otp")
async def verify_otp(request: VerifyOTPRequest):

    record = await otp_collection.find_one({
        "email": request.email,
        "otp": request.otp
    })

    if not record:
        raise HTTPException(status_code=400, detail="Invalid OTP.")
    
    if datetime.now() > record["expires_at"]:
        await otp_collection.delete_one({"_id": record["_id"]})
        raise HTTPException(status_code=400, detail="OTP has expired.")

    reset_token = str(uuid.uuid4())
    new_token_record = {
        "token": reset_token,
        "email": request.email,
        "expires_at": datetime.now() + timedelta(minutes=15)
    }
    await tokens_collection.insert_one(new_token_record)
    
    await otp_collection.delete_one({"_id": record["_id"]})

    return {"access_token": reset_token, "message": "OTP Verified"}

@router.post("/reset-password")
async def reset_password(request: ResetPasswordRequest):
    record = await tokens_collection.find_one({"token": request.token})

    if not record:
        raise HTTPException(status_code=400, detail="Invalid or expired reset token.")
    
    if datetime.now() > record["expires_at"]:
        await tokens_collection.delete_one({"_id": record["_id"]})
        raise HTTPException(status_code=400, detail="Reset token has expired.")

    new_hashed_password = get_password_hash(request.new_password)
    
    update_result = await user_collection.update_one(
        {"email": record["email"]}, 
        {"$set": {"hashed_password": new_hashed_password}}
    )

    if update_result.modified_count == 0:
        raise HTTPException(status_code=404, detail="User not found or password unchanged.")

    await tokens_collection.delete_one({"_id": record["_id"]})

    return {"message": "Password successfully reset! You can now log in."}