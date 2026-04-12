from google import genai
from dotenv import load_dotenv
import os

load_dotenv()

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

async def match_volunteer_to_needs(volunteer: dict, needs: list) -> list:
    import json
    prompt = f"""
    You are a smart volunteer coordinator for NGOs.
    Volunteer profile:
    - Skills: {volunteer['skills']}
    - Availability: {volunteer['availability']}
    - Location: {volunteer['location']}
    
    Open needs from NGOs:
    {json.dumps(needs, indent=2)}
    
    Rank top 3 most suitable needs for this volunteer.
    Return ONLY valid JSON: [{{"need_id": "...", "score": 0-100, "reason": "..."}}]
    """
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )
    text = response.text.replace("```json", "").replace("```", "").strip()
    return json.loads(text)