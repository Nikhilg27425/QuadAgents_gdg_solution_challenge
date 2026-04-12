from fastapi import APIRouter
from pydantic import BaseModel
from typing import List

router = APIRouter()

volunteers_db = []

class Volunteer(BaseModel):
    name: str
    email: str
    skills: List[str]
    availability: str
    location: str

@router.get("/")
def get_volunteers():
    return {"volunteers": volunteers_db}

@router.post("/")
def register_volunteer(volunteer: Volunteer):
    v = volunteer.dict()
    v["id"] = str(len(volunteers_db) + 1)
    volunteers_db.append(v)
    return {"message": "Volunteer registered!", "volunteer": v}