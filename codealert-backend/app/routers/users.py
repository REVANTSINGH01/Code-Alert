from fastapi import APIRouter,HTTPException,status,Depends,Request
from app.database.database import user_collection
from app.schemas.schemas import UserCreate,UserResponse,UserLogin,PlatformHandles,UserUpdatePassword
from bson import ObjectId
from app.auth.auth_handler import create_access_token
from fastapi.security import HTTPAuthorizationCredentials
from app.limiter import limiter

from app.auth.auth_handler import(
    verify_token,
    security,
    get_password_hash,
    verify_password
)
router=APIRouter(tags=["Users"])
router = APIRouter(tags=["Users"])

# 1️⃣ SIGNUP: Create a new user
@router.post("/signup",status_code=status.HTTP_201_CREATED)
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
    
    # Initialize an empty handles dictionary for brand new users
    user_dict["handles"]=None 

    result=await user_collection.insert_one(user_dict)
    new_user=await user_collection.find_one({"_id":result.inserted_id})
    
    user_id=str(new_user["_id"])
    token=create_access_token({
        "user_id":user_id,
        "email":new_user["email"]
    })    
    return{
        "access_token":token,
        "token_type":"bearer",
        "user":{
            "id":user_id,
            "name":new_user["name"],
            "email":new_user["email"]
        }
    }

# 2️⃣ LOGIN: Authenticate and return user info + handles
@router.post("/login",status_code=status.HTTP_200_CREATED)
@limiter.limit("10/minute")
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
    
        
    token=create_access_token({
        "user_id":user_id,
        "email":existing_user["email"]
    })
    return {
        "access_token":token,
        "token_type": "bearer",
        "user":{
            "id":user_id,
            "name":existing_user["name"],
            "email":existing_user["email"],
            "is_admin":existing_user.get("is_admin",False)   
        }
    }

# UPDATE HANDLES: Save the coding platform usernames
@router.put("/update_user",status_code=status.HTTP_201_CREATED)
@limiter.limit("5/minute")
async def update_user_handles(request:Request,handles: PlatformHandles,credentials:HTTPAuthorizationCredentials=Depends(security)):
    # Convert incoming handles to a dictionary, ignoring any that were left blank
    token= credentials.credentials
    payload=verify_token(token)
    if payload is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid token"
        )
    user_id=payload["user_id"]
    handles_dict={k:v 
                  for k,v in handles.model_dump().items()
                  if v is not None
    }
    
    if not handles_dict:
        raise HTTPException(status_code=400,detail="No handles provided")

    # Update the user's document in MongoDB
    result=await user_collection.update_one(
        {"_id":ObjectId(user_id)},
        {"$set":{"handles":handles_dict}}
    )

    if result.matched_count==0:
        raise HTTPException(status_code=404,detail="User not found")

    return {"message":"Platform handles saved successfully!","handles":handles_dict}

# UPDATE PASSWORD: Change password from old to new
@router.patch("/update-password",status_code=status.HTTP_200_OK)
@limiter.limit("5/minute")
async def update_user_password(request:Request,data:UserUpdatePassword,credentials:HTTPAuthorizationCredentials=Depends(security)):
    token=credentials.credentials
    payload=verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401,detail="Invalid token")
    user_id=payload["user_id"]

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
    
    return {"message":"Password updated successfully"}
