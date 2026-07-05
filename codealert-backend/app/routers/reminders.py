from fastapi import APIRouter, HTTPException, status,Depends
from fastapi.security import HTTPAuthorizationCredentials
from app.auth.auth_handler import (
    verify_access_token,
    security
)
from typing import List
from bson import ObjectId
from app.database.database import reminder_collection
from app.schemas.schemas import ReminderCreate, ReminderResponse

router = APIRouter(tags=["Reminders"])

@router.post("/reminder", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
async def create_reminder(reminder: ReminderCreate,credentials :HTTPAuthorizationCredentials=Depends(security)):
    token =credentials.credentials
    payload=verify_access_token(token)
    if payload is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid token"
        )

    user_id = payload["user_id"]
    reminder_dict = reminder.model_dump()
    reminder_dict["user_id"] = user_id
    
    # Insert into database 
    result = await reminder_collection.insert_one(reminder_dict)
    
    # Fetch and format the created reminder
    new_reminder = await reminder_collection.find_one({"_id": result.inserted_id})
    new_reminder["id"] = str(new_reminder["_id"])
    del new_reminder["_id"]
    
    return new_reminder

# Get all reminders for a specific user
@router.get("/reminders/", response_model=List[ReminderResponse])
async def get_user_reminders(credentials:HTTPAuthorizationCredentials=Depends(security)):
    token=credentials.credentials
    payload=verify_access_token(token)
    if payload is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid token"
        )
    user_id=payload["user_id"]
    # Find all reminders matching this user_id
    cursor = reminder_collection.find({"user_id": user_id})
    reminders = await cursor.to_list(length=100) # Limit to 100 for safety
    
    formatted_reminders = []
    for r in reminders:
        r["id"] = str(r["_id"])
        del r["_id"]
        formatted_reminders.append(r)
        
    return formatted_reminders

# Delete a reminder
@router.delete("/reminder/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_reminder(reminder_id: str,credentials:HTTPAuthorizationCredentials=Depends(security)):
    # Check if the ID format is valid for MongoDB
    token = credentials.credentials
    payload = verify_access_token(token)

    if payload is None:
        raise HTTPException(status_code=401, detail="Invalid token")

    user_id = payload["user_id"]
        
    # Delete from database
    result = await reminder_collection.delete_one({"_id": ObjectId(reminder_id),"user_id":user_id})
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Reminder not found")
        
    return {"message": "Reminder deleted"}