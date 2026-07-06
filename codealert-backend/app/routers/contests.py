from fastapi import APIRouter, HTTPException
from app.schemas.schemas import ContestResponse
from typing import List
import httpx
import asyncio
import datetime

router = APIRouter(tags=["Contests"])

@router.get("/contests", response_model=List[ContestResponse])
async def get_contest():
    contests=[]
    async with httpx.AsyncClient(timeout=10.0) as client:    
        cf, cc, lc = await asyncio.gather(
        get_cf_contests(client),
        get_cc_contests(client),
        get_lc_contests(client),
        )
    contests.extend(cf)
    contests.extend(cc)
    contests.extend(lc)

    contests.sort(
        key=lambda x:
        x["start_time"]
    )
    return contests



async def get_cf_contests(client: httpx.AsyncClient):
    url = "https://codeforces.com/api/contest.list"
    
    try:
        # Fetch data from Codeforces
        async with httpx.AsyncClient(timeout=10) as client:
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
        raise HTTPException(status_code=500, detail=str(e))
    
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
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.post(url,json={"query": query})
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
        raise HTTPException (status_code=500,detail=str(e))
    
async def get_cc_contests(client: httpx.AsyncClient):
    url="https://www.codechef.com/api/list/contests/all"
    try: 
        async with httpx.AsyncClient(timeout=10) as client:
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
    except Exception as e:
        raise HTTPException (status_code=500,detail=str(e))