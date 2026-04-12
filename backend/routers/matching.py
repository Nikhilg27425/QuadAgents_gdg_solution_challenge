from fastapi import APIRouter
from pydantic import BaseModel
from typing import List
from google import genai
from dotenv import load_dotenv
import json, os

load_dotenv()
router = APIRouter()
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

# Same in-memory DBs (will connect to Firestore later)
from routers.needs import needs_db
from routers.volunteers import volunteers_db

class MatchRequest(BaseModel):
    volunteer_id: str

@router.post("/volunteer")
async def match_volunteer(request: MatchRequest):
    # Find volunteer
    volunteer = next((v for v in volunteers_db if v["id"] == request.volunteer_id), None)
    if not volunteer:
        return {"error": "Volunteer not found"}
    
    if not needs_db:
        return {"error": "No needs available"}

    prompt = f"""
    You are a smart NGO volunteer coordinator.
    
    Volunteer profile:
    - Name: {volunteer['name']}
    - Skills: {volunteer['skills']}
    - Availability: {volunteer['availability']}
    - Location: {volunteer['location']}
    
    Available NGO needs:
    {json.dumps(needs_db, indent=2)}
    
    Rank the top 3 most suitable needs for this volunteer.
    Consider skill match, location, and urgency.
    Return ONLY valid JSON array:
    [{{"need_id": "1", "score": 95, "reason": "Perfect skill match"}}]
    """
    
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )
    
    text = response.text.replace("```json", "").replace("```", "").strip()
    matches = json.loads(text)
    return {"volunteer": volunteer["name"], "matches": matches}

@router.get("/prioritize-needs")
async def prioritize_needs():
    if not needs_db:
        return {"error": "No needs available"}

    prompt = f"""
    Analyze these NGO needs and assign urgency scores.
    Consider: people affected, deadline urgency, skill scarcity.
    
    Needs: {json.dumps(needs_db, indent=2)}
    
    Return ONLY valid JSON:
    [{{"need_id": "1", "urgency_score": 95, "reason": "..."}}]
    """
    
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )
    
    text = response.text.replace("```json", "").replace("```", "").strip()
    ranked = json.loads(text)
    return {"ranked_needs": ranked}