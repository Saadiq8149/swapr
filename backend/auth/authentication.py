from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from auth.model import UserCreate
from passlib.context import CryptContext
from dotenv import load_dotenv
import os

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES"))

# GOOGLE_CLIENT_ID = "your_google_client_id"
# GOOGLE_CLIENT_SECRET = "your_google_client_secret"
# GOOGLE_REDIRECT_URI = "http://localhost:8000/login/google/callback"

oauth_2_scheme = OAuth2PasswordBearer(tokenUrl="token")
pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")

def createAccessToken(data: UserCreate):
    toEncode = data.copy()
    encodedJwt = jwt.encode(toEncode, SECRET_KEY, algorithm=ALGORITHM)
    return encodedJwt

def getCurrentUser(token: str = Depends(oauth_2_scheme)):
    credentialsException = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"}
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentialsException
        return username
    except JWTError:
        raise credentialsException

def getHashedPassword(password: str):
    return pwd_context.hash(password)

def verifyPassword(plainPassword, hashedPassword):
    return pwd_context.verify(plainPassword, hashedPassword)

def getGoogleLoginUrl():
    return f"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id={GOOGLE_CLIENT_ID}&redirect_uri={GOOGLE_REDIRECT_URI}&scope=openid%20profile%20email&access_type=offline"
