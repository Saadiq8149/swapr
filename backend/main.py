from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordRequestForm
from auth.model import UserCreate
from auth.authentication import createAccessToken, getCurrentUser, verifyPassword, getHashedPassword
from db.database import create_database, SessionDependency
from db.users import createUser, getUserByEmail, getUserByUsername
from db.model import Payment, SwapRequest, WillingSwapRequest, UserCreate as UserCreateDB
from db.swap_request import addSwapRequestToDB, addWillingswapRequestToDB, addPaymentToDB
from pnr.pnr import fetchPNRDetails
from db.status import updateSwapRequestStatus, updateWillingSwapRequestStatus, updateStatus
import uvicorn, os, requests
from datetime import datetime, time, timedelta
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

@app.on_event("startup")
def startup_event():
    create_database()

@app.post("/login", name="token")
async def login(session: SessionDependency, data: OAuth2PasswordRequestForm = Depends()):
    user = getUserByUsername(session, data.username)
    if user is None or (not verifyPassword(data.password, user.hashed_password)):
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    accessToken = createAccessToken(data={"sub": user.username})
    return {"access_token": accessToken, "token_type": "bearer"}

# @app.post("/register")
# async def register(data: UserCreate, session: SessionDependency):
#     if getUserByEmail(session, data.email) is not None and data.email == getUserByEmail(session, data.email).email:
#         raise HTTPException(status_code=400, detail="Email already registered")
#     elif getUserByUsername(session, data.username) is not None and data.username == getUserByUsername(session, data.username).username:
#         raise HTTPException(status_code=400, detail="Username already exists")

#     hashedPassword = getHashedPassword(data.password)
#     accessToken = createAccessToken(data={"sub": data.username})
#     user = UserCreateDB(username=data.username, hashed_password=hashedPassword, email=data.email, name=data.name, phone_number=data.phone_number)
#     createUser(session, user)
#     return {"access_token": accessToken, "token_type": "bearer"}

import traceback
from fastapi import status # Make sure 'status' is imported

# ... (keep all other imports and existing code like app definition, startup event, other routes)

# --- MODIFIED /register ROUTE ---
@app.post("/register")
async def register(data: UserCreate, session: SessionDependency):
    # --- Start of the try block ---
    try:
        print(f"--- Debug: Entering /register endpoint for user: {data.username} ---")

        # 1. Check for existing user (more efficient checks)
        print(f"--- Debug: Checking for existing email {data.email}... ---")
        existing_email_user = getUserByEmail(session, data.email)
        if existing_email_user is not None:
            print(f"--- Debug: Email {data.email} already registered. ---")
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

        print(f"--- Debug: Checking for existing username {data.username}... ---")
        existing_username_user = getUserByUsername(session, data.username)
        if existing_username_user is not None:
            print(f"--- Debug: Username {data.username} already exists. ---")
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already exists")

        # 2. Hash the password
        print(f"--- Debug: Hashing password for {data.username}... ---")
        hashedPassword = getHashedPassword(data.password) # Using your function from auth.authentication
        print("--- Debug: Password hashed.")

        # 3. Create user data for DB
        # Ensure UserCreateDB (imported from db.model) matches structure needed by createUser
        print("--- Debug: Preparing user data for DB save...")
        user_db_data = UserCreateDB(
            username=data.username,
            hashed_password=hashedPassword, # Use the hashed password
            email=data.email,
            name=data.name,
            phone_number=data.phone_number
        )

        # 4. Save the user to the database
        print(f"--- Debug: Attempting to save user {data.username} to DB... ---")
        # Assuming createUser (from db.users) takes session and the DB model object
        db_user = createUser(session, user_db_data) # <-- Potential point of failure
        print(f"--- Debug: User {db_user.username} presumably saved. ---") # Assuming createUser returns the user or similar

        # 5. Create access token AFTER user is successfully created
        print(f"--- Debug: Creating access token for {data.username}... ---")
        accessToken = createAccessToken(data={"sub": data.username}) # Using your function from auth.authentication
        print("--- Debug: Access token created.")

        print(f"--- Debug: Registration successful for {data.username}. Returning response. ---")
        # Return token
        return {"access_token": accessToken, "token_type": "bearer"}

    # --- Specific exception handling first ---
    except HTTPException as http_exc:
        # If we explicitly raised an HTTPException (like user exists), re-raise it
        print(f"--- Debug: Caught known HTTPException: {http_exc.status_code} - {http_exc.detail}")
        raise http_exc
    # --- Catch-all for any other unexpected errors ---
    except Exception as e:
        print(f"--- Error: Caught UNEXPECTED Exception in /register endpoint! ---")
        print(f"Exception Type: {type(e).__name__}")
        print(f"Exception Details: {e}")
        print("--- Full Traceback ---")
        # Print the detailed traceback to the Vercel logs
        print(traceback.format_exc())
        print("--- End Traceback ---")

        # Return a generic 500 error to the client
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An internal server error occurred during registration."
        )

@app.get("/pnr")
async def getPnrDetails(pnr: str):
    now = datetime.now().time()
    start_time = time(23, 30)
    end_time = time(0, 30)

# Check if current time is between 11:30 PM and 12:30 AM
    if (now >= start_time) or (now <= end_time):
        raise HTTPException(status_code=404, detail="PNR service is not available at this time")
    data = fetchPNRDetails(pnr)
    if data is None:
        raise HTTPException(status_code=404, detail="PNR not found")
    return data

@app.post("/addswaprequest")
async def addSwapRequest( session: SessionDependency, request: dict):
    if request:
        username = getCurrentUser(request['token'])
        user = getUserByUsername(session, username)
        user_id = user.id if user else None

        request['user_id'] = user_id
        request.pop('token')

        swapRequest = SwapRequest(**request)

        result = addSwapRequestToDB(session, swapRequest)
        if result is None:
            raise HTTPException(status_code=410, detail="Swap Request Already Exists")

        updateSwapRequestStatus(session, swapRequest, user_id)

        return {"message": "Swap request added successfully", "data": request}
    else:
        raise HTTPException(status_code=400, detail="Invalid data")

@app.post("/getswaprequest")
async def getSwapRequest( session: SessionDependency, request: dict):
    if request:
        username = getCurrentUser(request['token'])
        user = getUserByUsername(session, username)
        user_id = user.id if user else None

        request['user_id'] = user_id
        request.pop('token')

        swapRequest = SwapRequest(**request)

        result = session.query(SwapRequest).filter_by(
            user_id=user_id, berth=swapRequest.berth, coach=swapRequest.coach, seat=swapRequest.seat).first()
        if result:
            return {"data": result}
        else:
            raise HTTPException(status_code=410, detail="Swap Request Doesnt Exists")
    else:
        raise HTTPException(status_code=400, detail="Invalid data")

@app.post("/addwillingswaprequest")
async def addWillingswapRequest(session: SessionDependency, request: dict):
    if request:
        username = getCurrentUser(request['token'])
        user = getUserByUsername(session, username)
        user_id = user.id if user else None

        request['user_id'] = int(user_id)
        request.pop('token')

        swapRequest = WillingSwapRequest(**request)

        result = addWillingswapRequestToDB(session, swapRequest)
        if result is None:
            raise HTTPException(status_code=410, detail="Swap Request Already Exists")

        updateWillingSwapRequestStatus(session, swapRequest, user_id)

        return {"message": "Swap request added successfully", "data": request}
    else:
        raise HTTPException(status_code=400, detail="Invalid data")

@app.get("/deleteswaprequest")
async def deleteSwapRequest(session: SessionDependency, id: int, token: str):
    username = getCurrentUser(token)
    user = getUserByUsername(session, username)
    # print(username, user)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    swapRequest = session.query(SwapRequest).filter_by(id=id).first()
    if swapRequest is None:
        raise HTTPException(status_code=404, detail="Swap request not found")
    session.query(WillingSwapRequest).filter_by(swap_request_id=id).update({"status": "Pending", "swap_request_id": None})
    payment_id = session.query(SwapRequest).filter_by(id=id).first().payment_id
    if payment_id is not None:
        transaction_id = session.query(Payment).filter_by(id=payment_id).first().payment_id
        url = f"https://api.razorpay.com/v1/payments/{transaction_id}/refund"
        headers = {
            'Content-Type': 'application/json',
        }
        body = {
            'amount': 500,
            'speed': 'optimum',
        }
        response = requests.post(url, headers=headers, json=body, auth=("rzp_test_0QuTw1JoWDwGlp", 'A5LJ9c7D8oXHH5QZ7T2tGozs'))
        if response.status_code == 200:
            session.delete(swapRequest)
            session.commit()
            swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
            session.query(Payment).filter_by(id=payment_id).update({"status": "Refunded"})
            session.commit()
            return {"swap_requests": swapRequests}
        else:
            print("Refund failed")
            raise HTTPException(status_code=400, detail="Refund failed")
    # else:
    #     raise HTTPException(status_code=400, detail="Payment not found")
    else:
        session.delete(swapRequest)
        session.commit()
        swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
        return {"swap_requests": swapRequests}


@app.get("/deleteswapsubmission")
async def deleteSwapSubmission(session: SessionDependency, id: int, token: str):
    username = getCurrentUser(token)
    user = getUserByUsername(session, username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    swapRequest = session.query(WillingSwapRequest).filter_by(id=id).first()
    if swapRequest is None:
        raise HTTPException(status_code=404, detail="Swap request not found")
    session.delete(swapRequest)
    session.commit()
    swapRequests = session.query(WillingSwapRequest).filter_by(user_id=user.id).all()

    return {"swap_requests": swapRequests}

@app.get("/getswaprequests")
async def getSwapRequest(session:  SessionDependency, token: str):
    username = getCurrentUser(token)
    user = getUserByUsername(session, username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    updateStatus(session, user.id)
    swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
    return {"swap_requests": swapRequests}

@app.get("/getswapsubmissions")
async def getSwapSubmissions(session: SessionDependency, token: str):
    username = getCurrentUser(token)
    user = getUserByUsername(session, username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    updateStatus(session, user.id)
    swapRequests = session.query(WillingSwapRequest).filter_by(user_id=user.id).all()
    return {"swap_requests": swapRequests}

@app.get("/acceptswap")
async def acceptSwap(session: SessionDependency, id: int, token: str):
    username = getCurrentUser(token)
    user = getUserByUsername(session, username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    swapRequest = session.query(WillingSwapRequest).filter_by(id=id).first()
    if swapRequest is None:
        raise HTTPException(status_code=404, detail="Swap request not found")
    if swapRequest.status != "Awaiting Confirmation":
        raise HTTPException(status_code=400, detail="Swap request not in Awaiting Confirmation status")
    swap_request_id = session.query(WillingSwapRequest).filter_by(id=id).first().swap_request_id

    clientID = os.getenv("CASHFREE_CLIENT_ID")
    clientSecret = os.getenv("CASHFREE_CLIENT_SECRET")
    environment = "TEST"

    tokenResponse = requests.post(
        "https://payout-gamma.cashfree.com/payout/v1/authorize",
        headers={
            "Content-Type": "application/json",
            "X-Client-Id": clientID,
            "X-Client-Secret": clientSecret,
            # 'X-Cf-Signature': encrypted_b64,
            "cache-control": "no-cache",
        },
    )

    if tokenResponse.status_code != 200:
        raise HTTPException(status_code=400, detail="Token generation failed")
    token = tokenResponse.json()["data"]["token"]

    print(token)
    cashgram = {
        "cashgramId": datetime.now().strftime("%Y%m%d%H%M%S"),
        "amount": "5.00",
        "name": user.name,
        "email": user.email,
        "phone": user.phone_number,
        "linkExpiry": (datetime.now() + timedelta(days=7)).date().strftime("%Y/%m/%d"),
        "notifyCustomer": 1
    }

    cashgramResponse = requests.post(
        "https://payout-gamma.cashfree.com/payout/v1/createCashgram",
        headers={
            "Accept": "*/*",
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
        json=cashgram,
    )

    if cashgramResponse.status_code != 200:
        raise HTTPException(status_code=400, detail="Cashgram creation failed")
    cashgramResponse = cashgramResponse.json()
    cashgramLink = cashgramResponse["data"]["cashgramLink"]

    session.query(WillingSwapRequest).filter_by(id=id).update({"status": "Confirmed", "cashgram_link": cashgramLink})
    session.query(SwapRequest).filter_by(id=swap_request_id).update({"status": "Confirmed", "willing_swap_id": id, "willing_swap_berth": swapRequest.berth, "willing_swap_coach": swapRequest.coach, "willing_swap_seat": swapRequest.seat})
    session.commit()

    return {"link": cashgramLink}

@app.get("/declineswap")
async def declineSwap(session: SessionDependency, id: int, token: str):
    username = getCurrentUser(token)
    user = getUserByUsername(session, username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    swapRequest = session.query(WillingSwapRequest).filter_by(id=id).first()
    if swapRequest is None:
        raise HTTPException(status_code=404, detail="Swap request not found")
    if swapRequest.status != "Awaiting Confirmation":
        raise HTTPException(status_code=400, detail="Swap request not in Awaiting Confirmation status")
    swap_request_id = session.query(WillingSwapRequest).filter_by(id=id).first().swap_request_id
    blacklist = swapRequest.blacklist
    if blacklist == "[]":
        blacklist = []
    else:
        blacklist = swapRequest.blacklist.strip("[]").split(",")
    if swapRequest.id not in blacklist:
        blacklist.append(swapRequest.id)
    blacklist = str(blacklist)
    session.query(WillingSwapRequest).filter_by(id=id).update({"status": "Pending", "blacklist": blacklist})
    session.query(SwapRequest).filter_by(id=swap_request_id).update({"status": "Pending"})

    session.commit()
    return {"message": "Swap request declined"}

@app.get("/getuser")
async def get_user(session: SessionDependency, token: str):
    username = getCurrentUser(token)
    user = getUserByUsername(session, username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"user": user}

@app.post("/addpayment")
async def add_payment(session: SessionDependency, data: dict):
    if data:
        username = getCurrentUser(data['token'])
        user = getUserByUsername(session, username)
        user_id = user.id if user else None
        swap_request_id = session.query(SwapRequest).filter_by(id=user_id, train_name=data['train_name'], train_number=data['train_number'], date_of_journey=data['date_of_journey'], seat=data['seat'], coach=data['coach'], berth=data['berth']).first().id

        data['user_id'] = int(user_id)
        data.pop('token')

        payment = Payment(payment_id=data['payment_id'], user_id=user_id, swap_request_id=swap_request_id)

        result = addPaymentToDB(session, payment)
        payment_id = session.query(Payment).filter_by(payment_id=data['payment_id']).first().id
        session.query(SwapRequest).filter_by(id=swap_request_id).update({"payment_status": "Paid", "payment_id": payment_id})
        session.commit()
        if result is None:
            raise HTTPException(status_code=410, detail="Payment Already Exists")

        return {"message": "Payment added successfully"}
    else:
        raise HTTPException(status_code=400, detail="Invalid data")

@app.get("/protected")
async def protected_route( session: SessionDependency, current_user: str = Depends(getCurrentUser),):
    if current_user != getUserByUsername(session, current_user).username:
        raise HTTPException(status_code=403, detail="Not authorized")
    return {"message": "Authorized", "user": current_user}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
