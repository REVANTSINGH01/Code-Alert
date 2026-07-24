from fastapi import APIRouter, HTTPException
from app.schemas.schemas import ContestResponse
from typing import List
import httpx
import asyncio
import datetime
import logging
from app.database.database import contest_collection

router = APIRouter(tags=["Contests"])
logger = logging.getLogger(__name__)

@router.get("/contests", response_model=List[ContestResponse])
async def get_contest():
    
    contests= await contest_collection.find().sort(
        "start_time", 1
    ).to_list(length=None)

    for contest in contests:
        contest.pop("_id", None)

    return contests

async def update_contests():
    contests=[]
    async with httpx.AsyncClient(timeout=10.0) as client:
        results= await asyncio.gather(
            get_cf_contests(client),
            get_cc_contests(client),
            get_lc_contests(client),
            return_exceptions=True
        )
    for result in results:
        if isinstance(result, Exception):
            logger.exception("Failed to fetch contests", exc_info=result)
        else:
            contests.extend(result)
    if contests:
        contests.sort(key=lambda x: x["start_time"])
        await contest_collection.delete_many({})
        await contest_collection.insert_many(contests)


async def get_cf_contests(client: httpx.AsyncClient):
    url = "https://codeforces.com/api/contest.list"
    
    try:
        # Fetch data from Codeforces
        response = await client.get(url)
        data = response.json()
        
        if data["status"] != "OK":
            raise HTTPException(status_code=400, detail="Failed to fetch from Codeforces")
            
        contests = []
        now =datetime.datetime.now(
            datetime.timezone.utc
        )
        three_days=(now+datetime.timedelta(days=7))
        
        # Loop through the results (limiting to the first 10 for speed)
        for c in data["result"]:                               
            # We only want upcoming contests (phase = "BEFORE")
            if c["phase"] == "BEFORE":
                # Convert Unix timestamp to ISO 8601 string format
                start_time = datetime.datetime.fromtimestamp(
                    c["startTimeSeconds"], datetime.timezone.utc
                )
                
                # Format to match our Pydantic schema
                if now<=start_time<=three_days:
                    contest_info = {
                        "name": c["name"],
                        "platform": "Codeforces",
                        "start_time": start_time.isoformat(),
                        "duration": c["durationSeconds"]
                    }
                    contests.append(contest_info)
                
        return contests
        
    except Exception as e:
        logger.exception("Failed to fetch Codeforces contests")
        raise HTTPException(status_code=500, detail="Failed to fetch Codeforces contests")
    
async def get_lc_contests(client: httpx.AsyncClient):
    url= "https://leetcode.com/graphql"

    query = """
    query {

      upcomingContests {

        title

        startTime

        duration
      }
    }
    """

    try:
        
        response = await client.post(url,json={"query": query})
        if response.status_code != 200:
            logger.error(
                "LeetCode returned %s: %s",
                response.status_code,
                response.text[:300],
            )
            return []
        data=response.json()
        now =datetime.datetime.now(datetime.timezone.utc)
        three_days=(now+datetime.timedelta(days=7))
        contests=[]
        for c in data["data"]["upcomingContests"]:
            start_time=(datetime.datetime.fromtimestamp(
                c["startTime"],datetime.timezone.utc)
            )
            if(now<=start_time<=three_days):
                contests.append({
                    "name":
                    c["title"],

                    "platform":
                    "LeetCode",

                    "start_time":
                    start_time.isoformat(),

                    "duration":
                    c["duration"]
                })
        return contests
        
    except Exception as e:
        logger.exception("Failed to fetch Leetcode contests")
        raise HTTPException (status_code=500,detail="Failed to fetch Leetcode contests")
    
async def get_cc_contests(client: httpx.AsyncClient):
    url="https://www.codechef.com/api/list/contests/all"
    try: 
        
        response = await client.get(url)
        data=response.json()
        if data["status"] != "success":
            raise HTTPException(status_code=400, detail="Failed to fetch from CodeChef")
        contests = []
        now =datetime.datetime.now(
            datetime.timezone.utc
        )
        three_days=(now+datetime.timedelta(days=7))
        for c in data["future_contests"]:
            start_time = datetime.datetime.fromisoformat(
                    c["contest_start_date_iso"]
                )
            if(now<=start_time<=three_days):
                contests.append({
                    "name":
                    c["contest_name"],

                    "platform":
                    "CodeChef",
                    
                    "start_time":
                    start_time.isoformat(),

                    "duration":
                    c["contest_duration"]
                })
        return contests
    except httpx.HTTPError as e:
        logger.warning("Failed to connect to LeetCode: %s", e)
        return []

    except Exception:
        logger.exception("Unexpected error while fetching LeetCode contests.")
        return []