import os    
from dotenv import  load_dotenv
from pathlib import Path
import certifi
from motor.motor_asyncio import AsyncIOMotorClient

base_dir = Path(__file__).resolve().parent.parent
env_path = base_dir / ".env"
load_dotenv(dotenv_path=env_path)   
MONGO_DETAILS=os.getenv("MONGO_DETAILS")
if not MONGO_DETAILS:
    print("❌ ERROR: MONGO_URI is None! .env file wasn't loaded properly.")
else:
    print("✅ MONGO_URI successfully loaded!")

client = AsyncIOMotorClient(MONGO_DETAILS, tlsCAFile=certifi.where())

database = client.codealert

# Create/Connect to specific collections
user_collection = database.get_collection("users")
reminder_collection = database.get_collection("reminders")
cf_profile_collection = database.get_collection("cf_profiles")
lc_profile_collection = database.get_collection("lc_profiles")
cc_profile_collection = database.get_collection("cc_profiles")
otp_collection = database.get_collection("otps")
tokens_collection = database.get_collection("reset_tokens")
