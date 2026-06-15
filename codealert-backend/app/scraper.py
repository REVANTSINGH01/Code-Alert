import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
load_dotenv()
MONGO_URI=os.getenv("MONGO_DETAILS")
client=AsyncIOMotorClient(MONGO_URI)
db=client.codealert_database
contests_collection=db.contests

async def sync_database():
    print("Starting Sync")
    