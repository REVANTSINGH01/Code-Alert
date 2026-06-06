from fastapi import APIRouter, HTTPException,Depends
from fastapi.security import HTTPAuthorizationCredentials
from app.schemas.schemas import CFProfileResponse
from app.database.database import cf_profile_collection
import httpx
from app.auth.auth_handler import (
    verify_token,
    security
)

router = APIRouter(tags=["Codeforces Profile"])

@router.get("/profile/cf/{cf_handle}", response_model=CFProfileResponse)
async def get_cf_profile(user_id:str,
cf_handle:str):
    try:  
        async with httpx.AsyncClient() as client:
        # 1. Fetch basic info (Rating, Rank) from Codeforces
            info_url = f"https://codeforces.com/api/user.info?handles={cf_handle}"
            info_res = await client.get(info_url)
            info_data = info_res.json()
            
            if info_data["status"] != "OK":
                raise HTTPException(status_code=404, detail="Codeforces handle not found")
                
            user_info = info_data["result"][0]
            rating = user_info.get("rating", 0)
            max_rating = user_info.get("maxRating", 0)
            rank = user_info.get("rank", "Unrated")

            # 2. Fetch all submissions to calculate unique "Problems Solved"
            status_url = f"https://codeforces.com/api/user.status?handle={cf_handle}"
            status_res =await client.get(status_url)
            status_data = status_res.json()
            
            solved_count = 0
            if status_data["status"] == "OK":
                solved_problems = set() # We use a set so we don't count the same problem twice
                for sub in status_data["result"]:
                    if sub.get("verdict") == "OK": # Only count accepted answers
                        prob = sub["problem"]
                        # Combine contest ID and problem index to make a unique ID (e.g., "1500A")
                        prob_id = f"{prob.get('contestId')}{prob.get('index')}"
                        solved_problems.add(prob_id)
                solved_count = len(solved_problems)

        # 3. Prepare the data
        cf_data = {
            "user_id": user_id,
            "cf_handle": cf_handle,
            "rating": rating,
            "max_rating": max_rating,
            "rank": rank,
            "problems_solved": solved_count
        }

        # 4. Save/Update it in your MongoDB database
        # This searches for the user_id. If found, it updates it. If not, it creates it.
        await cf_profile_collection.update_one(
            {"user_id": user_id}, 
            {"$set": cf_data}, 
            upsert=True 
        )

        return cf_data

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
    )