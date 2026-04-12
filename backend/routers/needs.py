from fastapi import APIRouter
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

router = APIRouter()

# Temporary in-memory storage (replace with Firestore later)
needs_db = []

class Need(BaseModel):
    title: str
    description: str
    skills_required: List[str]
    location: str
    urgency: str  # low, medium, high, critical
    category: str
    volunteers_needed: int

@router.get("/")
def get_all_needs():
    return {"needs": needs_db}

@router.post("/")
def create_need(need: Need):
    need_dict = need.dict()
    need_dict["id"] = str(len(needs_db) + 1)
    need_dict["created_at"] = datetime.now().isoformat()
    need_dict["status"] = "open"
    needs_db.append(need_dict)
    return {"message": "Need created!", "need": need_dict}

@router.get("/{need_id}")
def get_need(need_id: str):
    for need in needs_db:
        if need["id"] == need_id:
            return need
    return {"error": "Need not found"}