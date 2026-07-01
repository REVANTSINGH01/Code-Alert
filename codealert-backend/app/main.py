from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import codechef, codeforces, contests, dashboard, leetcode, reminders, auth
from app.routers import users
from app.routers import admin
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.limiter import limiter

app = FastAPI(
    title="CodeAlert API",
    description="Backend for the CodeAlert Flutter app",
    version="1.0.0"
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows any web page to connect during testing
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app=FastAPI()
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

@app.get("/")
def root():
    return {"message": "CodeAlert API is running with MongoDB!"}