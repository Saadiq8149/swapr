from typing import Annotated
from fastapi import Depends
from sqlmodel import SQLModel, create_engine, Session
from dotenv import load_dotenv
import os

load_dotenv()

sqlite_db_name = "database.db"
neon_url = os.getenv("NEON_URL")
engine = create_engine(neon_url, echo=True)

def create_database():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session

SessionDependency = Annotated[Session, Depends(get_session)]
