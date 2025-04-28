from pydantic import BaseModel, EmailStr
from typing import Optional

class UserBase(BaseModel):
    # username: str
    email: EmailStr
    phone_number: str
    trial_uses: int = 2

class UserCreate(UserBase):
    password: str
    name: str

class UserUpdate(UserBase):
    password: Optional[str] = None
    username: Optional[str] = None
