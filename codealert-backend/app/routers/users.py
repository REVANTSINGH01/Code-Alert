from fastapi import APIRouter,HTTPException,status,Depends,Request
from app.database.database import user_collection
import os 
from dotenv import load_dotenv
from app.schemas.schemas import(
    UserCreate,
    UserResponse,
    UserLogin,
    PlatformHandles,
    UserUpdatePassword,
    UserLoginResponse,
    RefreshRequest,
    TokenResponse,
    LogoutRequest,
)
from bson import ObjectId
from fastapi.security import HTTPAuthorizationCredentials
from app.limiter import limiter

from app.auth.auth_handler import(
    create_access_token,
    create_refresh_token,
    verify_access_token,
    security,
    get_password_hash,
    verify_password,
    revoke_refresh_token,
    revoke_all_refresh_tokens,
    get_current_user,
    validate_refresh_token,
    rotate_refresh_token
)
router=APIRouter(tags=["Users"])
router = APIRouter(tags=["Users"])
load_dotenv()
# 1️⃣ SIGNUP: Create a new user
@router.post("/signup",response_model=UserLoginResponse)
@limiter.limit("5/minute")
async def create_user(request:Request,user:UserCreate):
    existing_user=await user_collection.find_one({"email":user.email})
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is already registered"
        )

    user_dict=user.model_dump(mode="json")
    user_dict["password"]=get_password_hash(user.password)
    user_dict["is_admin"] = False
    # Initialize an empty handles dictionary for brand new users
    user_dict["handles"]={}

    result=await user_collection.insert_one(user_dict)
    new_user=await user_collection.find_one({"_id":result.inserted_id})
    
    user_id=str(new_user["_id"])
    access_token = create_access_token(user_id)  
    refresh_token = await create_refresh_token(user_id,device_hint="Flutter") 
    return {
        "user": {
            "id": user_id,
            "name": new_user["name"],
            "email": new_user["email"],
        },
        "tokens": {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
    }

# 2️⃣ LOGIN: Authenticate and return user info + handles
@router.post("/login",response_model=UserLoginResponse)
@limiter.limit("5/minute")
async def login_user(request:Request,user: UserLogin):
    existing_user = await user_collection.find_one({
        "email": user.email, 
    }) 
    
    if not existing_user or not verify_password(user.password, existing_user["password"]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid email or password"
        )
      
    user_id= str(existing_user["_id"])
    
        
    access_token=create_access_token(user_id)
    refresh_token = await create_refresh_token(user_id,device_hint="Flutter")
    return {
    "user": {
        "id": user_id,
        "name": existing_user["name"],
        "email": existing_user["email"],
        "is_admin": existing_user.get("is_admin", False)
    },
    "tokens": {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }
}

@router.post("/auth/logout")
async def logout(data: LogoutRequest,):
    await revoke_refresh_token(data.refresh_token)
    return {
        "message": "Logged out successfully"
    }

@router.post("/auth/logout-all")
async def logout_all(user_id: str = Depends(get_current_user),):
    revoked_count = await revoke_all_refresh_tokens(user_id)
    return {
        "message": "Logged out from all devices successfully",
        "revoked_sessions": revoked_count,
    }

@router.post("/auth/refresh",response_model=TokenResponse)
async def refresh_access_token(data:RefreshRequest,):
    user_id = await validate_refresh_token(data.refresh_token)
    access_token=create_access_token(user_id)
    refresh_token = await rotate_refresh_token(data.refresh_token,device_hint="Flutter",)
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        access_expires_in=int(os.getenv("ACCESS_EXPIRY") )* 60,
        refresh_expires_in=int(os.getenv("REFRESH_EXPIRY")) * 24 * 60 * 60,
    )
# UPDATE HANDLES: Save the coding platform usernames
@router.put("/handles",status_code=status.HTTP_201_CREATED)
@limiter.limit("5/minute")
async def update_user_handles(request:Request,handles: PlatformHandles,user_id: str = Depends(get_current_user),):
    # Convert incoming handles to a dictionary, ignoring any that were left blank
    
    handles_dict={f"handles.{k}":v 
                for k,v in handles.model_dump().items()
                if v is not None
    }
    
    if not handles_dict:
        raise HTTPException(status_code=400,detail="No handles provided")

    # Update the user's document in MongoDB
    result=await user_collection.update_one(
        {"_id":ObjectId(user_id)},
        {"$set":handles_dict}
    )

    if result.matched_count==0:
        raise HTTPException(status_code=404,detail="User not found")

    return {"message":"Platform handles saved successfully!","handles":handles_dict}

# UPDATE PASSWORD: Change password from old to new
@router.patch("/update-password",status_code=status.HTTP_200_OK)
@limiter.limit("5/minute")
async def update_user_password(request:Request,data:UserUpdatePassword,credentials:HTTPAuthorizationCredentials=Depends(security)):
    token=credentials.credentials
    payload=verify_access_token(token)
    user_id=payload["sub"]

    user=await user_collection.find_one({"_id":ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=404,detail="User not found")
    
    if not verify_password(data.old_password,user["password"]):
        raise HTTPException(status_code=400,detail="Incorrect old password")
        
    hashed_pwd=get_password_hash(data.new_password)
    await user_collection.update_one(
        {"_id":ObjectId(user_id)},
        {"$set":{"password":hashed_pwd}}
    )
    await revoke_all_refresh_tokens(user_id)
    return {"message":"Password updated successfully"}
