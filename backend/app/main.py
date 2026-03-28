from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import tasks
from app.db.database import engine, Base

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Flodo Task Manager API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tasks.router, prefix="/api/tasks", tags=["tasks"])


@app.get("/")
def root():
    return {"message": "Flodo Task Manager API is running"}