from fastapi import APIRouter, UploadFile, File
from pydantic import BaseModel
from services.gemini_service import match_volunteer_to_needs, extract_needs_from_text, prioritize_needs
import io

router = APIRouter()

from routers.needs import needs_db
from routers.volunteers import volunteers_db

class MatchRequest(BaseModel):
    volunteer_id: str

class ParseTextRequest(BaseModel):
    text: str

@router.post("/volunteer")
async def match_volunteer(request: MatchRequest):
    volunteer = next((v for v in volunteers_db if v["id"] == request.volunteer_id), None)
    if not volunteer:
        return {"error": "Volunteer not found"}
    if not needs_db:
        return {"error": "No needs available"}
    matches = await match_volunteer_to_needs(volunteer, needs_db)
    return {"volunteer": volunteer["name"], "matches": matches}

@router.get("/prioritize-needs")
async def prioritize_needs_route():
    if not needs_db:
        return {"error": "No needs available"}
    ranked = await prioritize_needs(needs_db)
    return {"ranked_needs": ranked}

@router.post("/parse-text")
async def parse_text(request: ParseTextRequest):
    needs = await extract_needs_from_text(request.text)
    return {"needs": needs}

@router.post("/extract-file")
async def extract_file(file: UploadFile = File(...)):
    """Extract needs from an uploaded PDF or CSV file."""
    content = await file.read()
    filename = file.filename or ""
    raw_text = ""

    if filename.lower().endswith(".pdf"):
        try:
            from pypdf import PdfReader
            reader = PdfReader(io.BytesIO(content))
            pages = [page.extract_text() or "" for page in reader.pages]
            raw_text = "\n".join(pages).strip()
        except Exception as e:
            return {"needs": [], "error": f"PDF read error: {e}"}
    else:
        try:
            raw_text = content.decode("utf-8", errors="ignore")
        except Exception:
            raw_text = content.decode("latin-1", errors="ignore")

    if not raw_text:
        return {"needs": [], "error": "Could not extract text from file."}

    needs = await extract_needs_from_text(raw_text[:6000])
    return {"needs": needs}
