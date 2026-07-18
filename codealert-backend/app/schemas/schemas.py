from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
import os 
from dotenv import load_dotenv
load_dotenv()
class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    access_expires_in: int = int(os.getenv("ACCESS_EXPIRY"))*60         
    refresh_expires_in: int =int(os.getenv("REFRESH_EXPIRY"))* 24*60*60

class RefreshRequest(BaseModel):
    refresh_token: str

class LogoutRequest(BaseModel):
    refresh_token: str

class UserUpdatePassword(BaseModel):
    old_password:str
    new_password:str

class AdminChangePassword(BaseModel):
    new_password:str

class OTPRecordDB(BaseModel):
    email: str
    otp: str
    expires_at: datetime

class ResetTokenRecordDB(BaseModel):
    token: str
    email: str
    expires_at: datetime

class ReminderCreate(BaseModel):
    contest_name: str
    reminder_time: str

class ReminderResponse(BaseModel):
    id: str
    user_id: str
    contest_name: str
    reminder_time: str

class ContestResponse(BaseModel):
    name: str
    platform: str
    start_time: str
    duration: int  # Duration in 
    
class CFProfileResponse(BaseModel):
    cf_handle: str
    rating: int
    max_rating: int
    rank: str
    problems_solved: int

class LCProfileResponse(BaseModel):
    lc_handle: str
    rating: float
    global_ranking: int
    problems_solved: int
    

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class PlatformHandles(BaseModel):
    cf_handle: Optional[str] = None
    lc_handle: Optional[str] = None
    cc_handle: Optional[str] = None

class UserResponse(BaseModel):
    id:str
    name:str
    email:EmailStr
    handles:Optional[PlatformHandles]=None
    is_admin:bool=False

class UserLoginResponse(BaseModel):
    user: UserResponse
    tokens: TokenResponse

class CCProfileResponse(BaseModel):
    cc_handle: str
    rating: int
    stars: str
    global_ranking: int
    problems_solved: int
    
class DashboardResponse(BaseModel):
    codeforces: Optional[CFProfileResponse] = None
    leetcode: Optional[LCProfileResponse] = None
    codechef: Optional[CCProfileResponse] = None

class UserUpdate(BaseModel):
    name:Optional[str]=None
    password:Optional[str]=None
    handles: Optional[PlatformHandles] = None

