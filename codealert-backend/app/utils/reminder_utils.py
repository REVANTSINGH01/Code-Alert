from datetime import datetime, timezone
from app.database.database import reminder_collection

async def cleanup_expired_reminders(user_id: str):
    now = datetime.now(timezone.utc)

    result = await reminder_collection.delete_many({
        "user_id": user_id,
        "reminder_time": {
            "$lte": now
        }
    })

    return result.deleted_count