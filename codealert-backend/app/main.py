from fastapi import FastAPI
import asyncio
from contextlib import asynccontextmanager
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from fastapi.middleware.cors import CORSMiddleware
from app.routers import codechef, codeforces, contests, dashboard, leetcode, reminders, auth
from app.routers import users
from app.routers import admin
from app.auth.auth_handler import setup_refresh_token_indexes
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.limiter import limiter
from app.database.database import lc_profile_collection
from app.routers.leetcode import update_all_profiles

@asynccontextmanager
async def lifespan(app:FastAPI):
    scheduler  =AsyncIOScheduler()
    scheduler.add_job(update_all_profiles,'interval',hours=3)
    scheduler.start()
    yield
    scheduler.shutdown()

app = FastAPI(
    title="CodeAlert API",
    description="Backend for the CodeAlert Flutter app",
    version="1.0.0",
    lifespan=lifespan
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows any web page to connect during testing
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.state.limiter=limiter
app.add_exception_handler(RateLimitExceeded,_rate_limit_exceeded_handler)
app.include_router(admin.router)
app.include_router(users.router)
app.include_router(contests.router)
app.include_router(reminders.router)
app.include_router(codeforces.router)
app.include_router(leetcode.router)
app.include_router(codechef.router)
app.include_router(dashboard.router)     
app.include_router(auth.router)

@app.on_event("startup")
async def startup():
    await setup_refresh_token_indexes()

@app.get("/")
def root():
    return {"message": "CodeAlert API is running with MongoDB!"}

