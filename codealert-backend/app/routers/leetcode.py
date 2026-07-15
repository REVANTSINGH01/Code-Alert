from fastapi import APIRouter, HTTPException,Depends
from fastapi.security import HTTPAuthorizationCredentials
from app.schemas.schemas import LCProfileResponse
from app.database.database import lc_profile_collection
import asyncio
from datetime import datetime, timedelta
import httpx
from datetime import datetime, timezone
from app.database.database import lc_profile_collection
from app.auth.auth_handler import (
    verify_access_token,
    security
)


router = APIRouter(tags=["LeetCode Profile"])

@router.get("/profile/lc/{lc_handle}", response_model=LCProfileResponse)
async def get_lc_profile(user_id:str,lc_handle:str,force_refresh: bool = False):
    if not force_refresh:
        existing_profile = await lc_profile_collection.find_one({
            "user_id": user_id, 
            "lc_handle": lc_handle
        })
        
        if existing_profile and "last_updated" in existing_profile:
            last_updated = existing_profile["last_updated"]
            if last_updated.tzinfo is None:
                last_updated = last_updated.replace(tzinfo=timezone.utc)
                
            # If less than 1 hour old, return cached data
            if datetime.now(timezone.utc) - last_updated < timedelta(hours=1):
                return existing_profile
    profile = await lc_profile_collection.find_one({"user_id": user_id,"lc_handle": lc_handle})
    
    if profile:
        return profile
        
    raise HTTPException(
        status_code=404, 
        detail="Profile data not found. It will be updated by the next background sync."
    )

async def update_all_profiles():

    print("Starting background update of all LeetCode profiles...")

    cursor = lc_profile_collection.find({})
    users = await cursor.to_list(length=None)

    for user in users:
        lc_handle = user.get("lc_handle")
        user_id = user.get("user_id")

        if not lc_handle:
            continue

        try:
            url = "https://leetcode.com/graphql"
            query = """
            query getUserProfile($username: String!) {
                matchedUser(username: $username) {
                    submitStatsGlobal {
                        acSubmissionNum { difficulty count }
                    }
                }
                userContestRanking(username: $username) { rating globalRanking }
            }

            """

            async with httpx.AsyncClient() as client:
                response = await client.post(url, json={"query": query, "variables": {"username": lc_handle}})
                data = response.json() 

                if "errors" in data or not data.get("data", {}).get("matchedUser"):
                    continue # Skip if user not found

                user_data = data["data"]

                solved_count = 0
                for sub in user_data["matchedUser"]["submitStatsGlobal"]["acSubmissionNum"]:
                    if sub["difficulty"] == "All":
                        solved_count = sub["count"]
                        break

                contest_data = user_data.get("userContestRanking")
                rating = contest_data.get("rating", 0.0) if contest_data else 0.0
                global_ranking = contest_data.get("globalRanking", 0) if contest_data else 0

            lc_data = {
                "user_id": user_id,
                "lc_handle": lc_handle,
                "rating": round(rating, 2),
                "global_ranking": global_ranking,
                "problems_solved": solved_count,
                "last_updated": datetime.now(timezone.utc)
            }

            await lc_profile_collection.update_one(
                {"user_id": user_id},{"$set": lc_data}
            )
            print(f"Successfully updated {lc_handle}")
            await asyncio.sleep(3) 
        except Exception as e:
            print(f"Failed to update {lc_handle}: {e}")