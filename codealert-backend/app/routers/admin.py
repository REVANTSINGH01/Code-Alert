from fastapi import APIRouter,HTTPException,Depends,status
from fastapi.security import HTTPAuthorizationCredentials
from bson import ObjectId
from typing import List
from app.auth.auth_handler import verify_access_token,security,get_password_hash
from app.database.database import user_collection,reminder_collection
from app.schemas.schemas import UserResponse

router=APIRouter(tags=["Admin"])

async def get_admin_user(credentials:HTTPAuthorizationCredentials=Depends(security)):
    token=credentials.credentials
    payload=verify_access_token(token)
    if payload is None:
        raise HTTPException(status_code=401,detail="Invalid token")
    user_id=payload["user_id"]
    user=await user_collection.find_one({"_id":ObjectId(user_id)})
    if not user or not user.get("is_admin",False):
        raise HTTPException(status_code=404,detail="Page not found")
    return user_id

@router.get("/admin/users",response_model=List[UserResponse])
async def get_all_users(admin_id:str=Depends(get_admin_user)):
    cursor=user_collection.find({})
    users=await cursor.to_list(length=100)
    formatted_users=[]
    for u in users:
        u["id"]=str(u["_id"])
        del u["_id"]
        formatted_users.append(u)
    return formatted_users

@router.delete("/admin/users/{target_id}",status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(target_id:str,admin_id:str=Depends(get_admin_user)):
    res=await user_collection.delete_one({"_id":ObjectId(target_id)})
    if res.deleted_count==0:
        raise HTTPException(status_code=404,detail="User not found")
    # Cascade delete for related user data
    await reminder_collection.delete_many({"user_id":target_id})
    return {"message":"User deleted"}

@router.patch("/admin/users/{target_id}/role")
async def toggle_admin_role(target_id:str,make_admin:bool,admin_id:str=Depends(get_admin_user)):
    res=await user_collection.update_one(
        {"_id":ObjectId(target_id)},
        {"$set":{"is_admin":make_admin}}
    )
    if res.matched_count==0:
        raise HTTPException(status_code=404,detail="User not found")
    return {"message":"User role updated"}
