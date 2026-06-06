from fastapi import APIRouter,HTTPException,Depends
from fastapi.security import HTTPAuthorizationCredentials
import httpx
from bs4 import BeautifulSoup
from app.database.database import cc_profile_collection
from app.schemas.schemas import CCProfileResponse
import re # <-- We are using Regex now!
from app.auth.auth_handler import (
    verify_token,
    security
)

router = APIRouter(tags=["CodeChef"])

@router.get("/profile/cc/{cc_handle}", response_model=CCProfileResponse)
async def get_cc_profile(user_id:str,cc_handle: str,):
    url = f"https://www.codechef.com/users/{cc_handle}"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    }

    try:
        async with httpx.AsyncClient() as client: 
            response =await client.get(url, headers=headers, timeout=10)
            if response.status_code != 200:
                return None

            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Extract ALL text from the webpage, ignoring HTML tags
            page_text = soup.get_text()

            # --- RATING & STARS ---
            rating_div = soup.find('div', class_='rating-number')
            rating = int("".join(filter(str.isdigit, rating_div.text))) if rating_div else 0
            
            stars_span = soup.find('span', class_='rating')
            stars = stars_span.text.strip() if stars_span else "0★"

            # --- GLOBAL RANK ---
            global_rank = 0
            rank_header = soup.find('div', class_='rating-ranks')
            if rank_header:
                rank_list = rank_header.find_all('li')
                if rank_list:
                    global_rank = int("".join(filter(str.isdigit, rank_list[0].text)))

            # --- BULLETPROOF PROBLEMS SOLVED LOGIC ---
            problems_solved = 0
            
            # Regex searches the entire page for "Fully Solved (123)" or "Total Problems Solved: 123"
            fully_solved_matches = re.findall(r'Fully Solved\s*\(\s*(\d+)\s*\)', page_text, re.IGNORECASE)
            
            if fully_solved_matches:
                # CodeChef sometimes lists "Fully Solved" multiple times for different categories. We add them up.
                problems_solved = sum(int(m) for m in fully_solved_matches)
            else:
                # Fallback just in case they use the older wording
                total_matches = re.findall(r'Total Problems Solved\s*:\s*(\d+)', page_text, re.IGNORECASE)
                if total_matches:
                    problems_solved = int(total_matches[0])

        profile_data = {
            "user_id": user_id,
            "cc_handle": cc_handle,
            "rating": rating,
            "stars": stars,
            "global_ranking": global_rank,
            "problems_solved": problems_solved
        }

        await cc_profile_collection.update_one(
            {"user_id": user_id},
            {"$set": profile_data},
            upsert=True
        )
        return profile_data

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
    )