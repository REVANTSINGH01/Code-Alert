from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPAuthorizationCredentials
from app.auth.auth_handler import verify_access_token, security
from app.schemas.schemas import DashboardResponse
from app.database.database import (
    user_collection,
    cf_profile_collection,
    lc_profile_collection,
    cc_profile_collection
)

from bson import ObjectId
import asyncio

from app.routers.codeforces import get_cf_profile
from app.routers.leetcode import get_lc_profile
from app.routers.codechef import get_cc_profile

router = APIRouter(tags=["Dashboard"])


@router.post("/dashboard/sync/", response_model=DashboardResponse)
async def sync_user_dashboard(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    try:

        token = credentials.credentials
        payload = verify_access_token(token)

        if payload is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token"
            )

        user_id = payload["user_id"]

        user = await user_collection.find_one({
            "_id": ObjectId(user_id)
        })

        if not user:
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )

        handles = user.get("handles", {})

        if not handles:
            raise HTTPException(
                status_code=400,
                detail="No handles saved"
            )

        tasks = []

        if handles.get("cf_handle"):
            tasks.append(
                get_cf_profile(
                    user_id,
                    handles["cf_handle"]
                )
            )

        if handles.get("lc_handle"):
            tasks.append(
                get_lc_profile(
                    user_id,
                    handles["lc_handle"]
                )
            )

        if handles.get("cc_handle"):
            tasks.append(
                get_cc_profile(
                    user_id,
                    handles["cc_handle"]
                )
            )

        results = await asyncio.gather(
            *tasks,
            return_exceptions=True
        )
        print(results)
        for r in results:
            if isinstance(r, Exception):
                print("SYNC ERROR:", r)

        cf_data = await cf_profile_collection.find_one(
            {"user_id": user_id}
        ) if handles.get("cf_handle") else None

        lc_data = await lc_profile_collection.find_one(
            {"user_id": user_id}
        ) if handles.get("lc_handle") else None

        cc_data = await cc_profile_collection.find_one(
            {"user_id": user_id}
        ) if handles.get("cc_handle") else None

        for d in [cf_data, lc_data, cc_data]:
            if d:
                d.pop("_id", None)

        return {
            "codeforces": cf_data,
            "leetcode": lc_data,
            "codechef": cc_data
        }

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )