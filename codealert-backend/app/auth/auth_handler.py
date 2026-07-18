import uuid
from jose import jwt,JWTError
from datetime import datetime,timedelta,timezone
import secrets
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer,HTTPAuthorizationCredentials
from passlib.context import CryptContext
from typing import Optional
import os
from dotenv import load_dotenv
from app.database.database import database
load_dotenv()
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM="HS256" 
ACCESS_TOKEN_EXPIRY_MINUTES=int(os.getenv("ACCESS_EXPIRY"))
REFRESH_TOKEN_EXPIRY_DAYS=int(os.getenv("REFRESH_EXPIRY"))

security=HTTPBearer()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def refresh_col():
    return database["refresh_tokens"]

def get_password_hash(password: str) -> str:
    """Hashes a plain-text password."""
    truncated_password = password[:72] 
    return pwd_context.hash(truncated_password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Checks if a plain password matches the hashed version."""
    truncated_password = plain_password[:72]
    return pwd_context.verify(truncated_password, hashed_password)


def create_access_token(user_id:str) ->str:
    expire=datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRY_MINUTES)
    payload={
        "sub":user_id,
        "exp":expire,
        "iat":datetime.now(timezone.utc),
        "type":"access",
    }
    return jwt.encode(payload,SECRET_KEY,algorithm=ALGORITHM)

def  verify_access_token(token:str):
    try:
        payload=jwt.decode(token,SECRET_KEY,algorithms=[ALGORITHM])
        if(payload.get("type"))!="access":
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Invalid token type")
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,detail="Access token is invalid or expired",headers={"WWW-Authenticate":"Bearer"},
        )

async def create_refresh_token(user_id:str,device_hint: Optional[str]=None):
    token=str(uuid.uuid4())
    expires_at=datetime.now(timezone.utc)+timedelta(days=REFRESH_TOKEN_EXPIRY_DAYS)

    doc={
        "token":token,
        "user_id":user_id,
        "expires_at":expires_at,
        "revoked":False,
        "created_at":datetime.now(timezone.utc),
        "device_hint":device_hint,
    }
    await refresh_col().insert_one(doc)
    return token

async def validate_refresh_token(token:str):
    doc=await refresh_col().find_one({"token":token})

    if not doc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Refresh token not found")
    if doc["revoked"]:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Refresh token has been revoked")
    expires_at=doc["expires_at"]
    if expires_at.tzinfo is None:
        expires_at=expires_at.replace(tzinfo=timezone.utc)
    
    if expires_at<datetime.now(timezone.utc):
        await refresh_col().delete_one({"token":token})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Refresh token has expired, please log in again")
    return doc["user_id"]

async def rotate_refresh_token(old_token:str,device_hint: Optional[str]=None):
    await refresh_col().update_one(
        {"token":old_token},
        {"$set":{"revoked":True,"revoked_at":datetime.now(timezone.utc)}}
    )

    old_doc=await refresh_col().find_one({"token":old_token})
    user_id=old_doc["user_id"]

    new_token=await create_refresh_token(user_id,device_hint)
    return new_token
async def revoke_refresh_token(token:str):
    result= await refresh_col().update_one(
        {"token":token},
        {"$set": {"revoked": True, "revoked_at": datetime.now(timezone.utc)}}
    )

async def revoke_all_refresh_tokens(user_id: str) -> int:
    
    result = await refresh_col().update_many(
        {"user_id": user_id, "revoked": False},
        {"$set": {"revoked": True, "revoked_at": datetime.now(timezone.utc)}}
    )
    return result.modified_count

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security),) -> str:
    token = credentials.credentials
    payload = verify_access_token(token)
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token payload missing user id",
        )
    return user_id

async def setup_refresh_token_indexes():
    col = refresh_col()
    await col.create_index("expires_at", expireAfterSeconds=0)
    await col.create_index("token",unique=True)
    await col.create_index("user_id")