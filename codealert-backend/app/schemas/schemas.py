from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List # Ensure Optional is here
from pydantic import BaseModel

class UserUpdatePassword(BaseModel):
    old_password:str
    new_password:str

class AdminChangePassword(BaseModel):
    new_password:str
# ---- REMINDER SCHEMAS ----
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
    rating: float          # LeetCode uses decimals for ratings
    global_ranking: int
    problems_solved: int
    

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    is_admin:bool=False

class UserLogin(BaseModel):
    email: EmailStr
    password: str
    is_admin:bool =False

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
# ---- USER SCHEMAS ----

