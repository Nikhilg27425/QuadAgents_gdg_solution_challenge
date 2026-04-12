from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

# Simple in-memory store (replace with Firestore later)
users_db = []

class LoginRequest(BaseModel):
    email: str
    password: str

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    role: str  # "volunteer" or "ngo"

@router.post("/register")
def register(request: RegisterRequest):
    # Check if user exists
    existing = next((u for u in users_db if u["email"] == request.email), None)
    if existing:
        return {"error": "User already exists"}
    
    user = {
        "id": str(len(users_db) + 1),
        "name": request.name,
        "email": request.email,
        "password": request.password,  # hash this in production!
        "role": request.role
    }
    users_db.append(user)
    return {
        "message": "Registered successfully!",
        "user": {"id": user["id"], "name": user["name"], "email": user["email"], "role": user["role"]}
    }

@router.post("/login")
def login(request: LoginRequest):
    user = next((u for u in users_db if u["email"] == request.email and u["password"] == request.password), None)
    if not user:
        return {"error": "Invalid email or password"}
    
    return {
        "message": "Login successful!",
        "user": {"id": user["id"], "name": user["name"], "email": user["email"], "role": user["role"]}
    }