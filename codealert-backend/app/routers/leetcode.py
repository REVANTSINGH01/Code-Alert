from fastapi import APIRouter, HTTPException,Depends
from fastapi.security import HTTPAuthorizationCredentials
from app.schemas.schemas import LCProfileResponse
from app.database.database import lc_profile_collection
import httpx
from app.auth.auth_handler import (
    verify_token,
    security
)

router = APIRouter(tags=["LeetCode Profile"])

@router.get("/profile/lc/{lc_handle}", response_model=LCProfileResponse)
async def get_lc_profile(user_id:str,
    lc_handle:str,):
    url = "https://leetcode.com/graphql"
    
    # This is the GraphQL query. It asks LeetCode for specific fields.
    query = """
    query getUserProfile($username: String!) {
        matchedUser(username: $username) {
            submitStats {
                acSubmissionNum {
                    difficulty
                    count
                }
            }
        }
        userContestRanking(username: $username) {
            rating
            globalRanking
        }
    }
    """
    
    # We pass the username into the query variables
    variables = {"username": lc_handle}
    
    try:
        async with httpx.AsyncClient() as client:
            # Send the POST request to LeetCode's GraphQL API
            response =await client.post(url, json={"query": query, "variables": variables})
            data = response.json()
            
            # 1. Check if the user actually exists
            if "errors" in data or not data["data"]["matchedUser"]:
                raise HTTPException(status_code=404, detail="LeetCode handle not found")
                
            user_data = data["data"]
            
            # 2. Extract Problems Solved
            # LeetCode returns an array (All, Easy, Medium, Hard). We want "All".
            solved_count = 0
            submissions = user_data["matchedUser"]["submitStats"]["acSubmissionNum"]
            for sub in submissions:
                if sub["difficulty"] == "All":
                    solved_count = sub["count"]
                    break
                    
            # 3. Extract Rating & Ranking
            # Note: If a user has never done a contest, this will be None
            contest_data = user_data.get("userContestRanking")
            rating = 0.0
            global_ranking = 0
            
            if contest_data:
                rating = contest_data.get("rating", 0.0)
                global_ranking = contest_data.get("globalRanking", 0)
                print("EXTRACTED")

                print(
                "rating:",
                rating
                )

                print(
                "solved:",
                solved_count
                )

                print(
                "rank:",
                global_ranking
                )
            
        # 4. Prepare data for our database
        lc_data = {
            "user_id": user_id,
            "lc_handle": lc_handle,
            "rating": round(rating, 2), # Round to 2 decimal places
            "global_ranking": global_ranking,
            "problems_solved": solved_count
        }
          
        # 5. Save/Update it in MongoDB
        await lc_profile_collection.update_one(
            {"user_id": user_id}, 
            {"$set": lc_data}, 
            upsert=True 
        )

        return lc_data

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
    )