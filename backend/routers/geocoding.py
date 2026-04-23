from fastapi import APIRouter
import httpx

router = APIRouter()

@router.get("/geocode")
async def geocode(q: str):
    """Geocode an address using Photon (OSM-based, free, no API key)."""
    if not q or not q.strip():
        return {"results": []}

    async with httpx.AsyncClient() as client:
        resp = await client.get(
            "https://photon.komoot.io/api/",
            params={"q": q.strip(), "limit": 1, "lang": "en"},
            headers={"User-Agent": "NGOConnectApp/1.0"},
            timeout=10,
        )

    if resp.status_code != 200:
        return {"results": []}

    data = resp.json()
    features = data.get("features", [])
    if not features:
        return {"results": []}

    # Normalize to Nominatim-style response for Flutter compatibility
    results = []
    for f in features:
        coords = f.get("geometry", {}).get("coordinates", [])
        props = f.get("properties", {})
        if len(coords) >= 2:
            results.append({
                "lat": str(coords[1]),
                "lon": str(coords[0]),
                "display_name": ", ".join(filter(None, [
                    props.get("name"),
                    props.get("city") or props.get("town") or props.get("village"),
                    props.get("state"),
                    props.get("country"),
                ])),
            })

    return {"results": results}
