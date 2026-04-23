from groq import Groq
from dotenv import load_dotenv
import os

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

client = Groq(api_key=os.getenv("GROQ_API_KEY"))
MODEL = "llama-3.3-70b-versatile"

def _chat(prompt: str) -> str:
    response = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3,
    )
    return response.choices[0].message.content.replace("```json", "").replace("```", "").strip()

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
    return json.loads(_chat(prompt))

async def extract_needs_from_text(raw_text: str) -> list:
    import json
    prompt = f"""
    Extract volunteer needs from this community survey/report text.
    For each need found, extract: title, description, skills, urgency, location.

    Text: "{raw_text}"

    Return ONLY valid JSON array:
    [{{"title":"...", "description":"...", "skills":[], "urgency":"Medium", "location":"..."}}]
    If no needs found, return [].
    """
    return json.loads(_chat(prompt))

async def prioritize_needs(needs: list) -> list:
    import json
    prompt = f"""
    Analyze these NGO needs and assign urgency scores 1-100.
    Consider: people affected, deadline, skill scarcity, social impact.

    Needs: {json.dumps(needs, indent=2)}

    Return ONLY valid JSON:
    [{{"need_id":"...", "urgency_score":0-100, "priority_reason":"..."}}]
    """
    return json.loads(_chat(prompt))
