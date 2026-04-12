from fastapi import APIRouter
from routers.needs import needs_db
from routers.volunteers import volunteers_db

router = APIRouter()

@router.get("/")
def get_analytics():
    total_needs = len(needs_db)
    open_needs = len([n for n in needs_db if n["status"] == "open"])
    total_volunteers = len(volunteers_db)
    
    skills = {}
    for v in volunteers_db:
        for skill in v.get("skills", []):
            skills[skill] = skills.get(skill, 0) + 1

    return {
        "total_needs": total_needs,
        "open_needs": open_needs,
        "total_volunteers": total_volunteers,
        "top_skills": sorted(skills.items(), key=lambda x: x[1], reverse=True)[:5],
        "fulfillment_rate": f"{((total_needs - open_needs) / total_needs * 100):.1f}%" if total_needs > 0 else "0%"
    }