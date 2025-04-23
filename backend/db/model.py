from sqlmodel import Field, SQLModel
from typing import Optional

class UserBaseModel(SQLModel):
    username: str = Field(index=True)
    email: str = Field(index=True, unique=True)
    phone_number: str = Field(index=True, unique=True)
    name: str

class UserCreate(UserBaseModel):
    hashed_password: str

class User(UserBaseModel, table=True):
    id: int = Field(default=None, primary_key=True)
    hashed_password: str

class SwapRequest(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    pnr: str
    status: str = "Pending"
    train_name: str
    train_number: str
    from_station: str
    to_station: str
    date_of_journey: str
    coach: str
    berth: str
    seat: str
    preferred_coach: str
    preferred_berth: str
    reason: str
    willing_swap_id: Optional[int] = Field(foreign_key="willingswaprequest.id")
    willing_swap_berth: Optional[str]
    willing_swap_coach: Optional[str]
    willing_swap_seat: Optional[str]
    payment_id: Optional[int] = Field(foreign_key="payment.id")
    payment_status: Optional[str]

class WillingSwapRequest(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    pnr: str
    status: str = "Pending"
    train_name: str
    train_number: str
    from_station: str
    to_station: str
    date_of_journey: str
    coach: str
    berth: str
    seat: str
    preferred_berth: str
    swap_request_id: Optional[int] = Field(foreign_key="swaprequest.id")
    blacklist: str = "[]"
    swap_request_berth: Optional[str]
    swap_request_coach: Optional[str]
    swap_request_seat: Optional[str]
    cashgram_link: Optional[str]

class Payment(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    payment_id: str
    user_id: int = Field(foreign_key="user.id")
    swap_request_id: Optional[int] = Field(foreign_key="swaprequest.id")
    amount: float = 10
    status: str = "Paid"
    refund_id: Optional[str] = None
