from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.config import settings
from src.api.mail import router as mail_router

app = FastAPI(title="Seat Selection Backend")

# Include routers
app.include_router(mail_router)

# Set up CORS
origins = settings.CORS_ORIGINS.split(",") if settings.CORS_ORIGINS else ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_headers=["*"],
    allow_methods=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Seat Selection Backend is running"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
