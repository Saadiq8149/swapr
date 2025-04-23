from db.model import UserCreate, User
from db.database import SessionDependency

def createUser(session: SessionDependency, user: UserCreate) -> User:
    user = User(**user.dict())
    session.add(user)
    session.commit()
    session.refresh(user)
    return user

def getUserByEmail(session: SessionDependency, email: str) -> User:
    user = session.query(User).filter(User.email == email).first()
    return user

def getUserByUsername(session: SessionDependency, username: str) -> User:
    user = session.query(User).filter(User.username == username).first()
    return user

def getUserByToken(session: SessionDependency, token: str) -> User:
    user = session.query(User).filter(User.token == token).first()
    return user
