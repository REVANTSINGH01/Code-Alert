from jose import jwt,JWTError
from datetime import datetime,timedelta
import secrets
from fastapi.security import HTTPBearer
from passlib.context import CryptContext
import os
from dotenv import load_dotenv

load_dotenv()

security=HTTPBearer()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    """Hashes a plain-text password."""
    truncated_password = password[:72] 
    return pwd_context.hash(truncated_password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Checks if a plain password matches the hashed version."""
    truncated_password = plain_password[:72]
    return pwd_context.verify(truncated_password, hashed_password)


SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM="HS256" 
ACCESS_TOKEN_EXPIRY=60


def create_access_token(data:dict):
    to_encode=data.copy();
    expire=datetime.utcnow() + timedelta(
        minutes=ACCESS_TOKEN_EXPIRY
    )
    to_encode.update({"exp":expire})
    encoded_jwt=jwt.encode(
        to_encode,
        SECRET_KEY,
        algorithm=ALGORITHM
    )
    return encoded_jwt

def  verify_token(token:str):
    try:
        payload=jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM]
        )
        return payload
    except JWTError:
        return None
