from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordRequestForm
from auth.model import UserCreate
from auth.authentication import createAccessToken, getCurrentUser, verifyPassword, getHashedPassword
from db.database import create_database, SessionDependency
from db.users import createUser, getUserByEmail, getUserByUsername
from db.model import User, Payment, SwapRequest, WillingSwapRequest, UserCreate as UserCreateDB
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
async def login(session: SessionDependency, data: dict):
    try:
        print(f"--- Debug: Starting login process for email: {data['email']} ---")
        user = getUserByEmail(session, data['email'])
        if user is None:
            print(f"--- Debug: User with email {data['email']} not found ---")
            raise HTTPException(status_code=400, detail="Incorrect username or password")

        if not verifyPassword(data['password'], user.hashed_password):
            print(f"--- Debug: Password verification failed for user {data['email']} ---")
            raise HTTPException(status_code=400, detail="Incorrect username or password")

        print(f"--- Debug: Password verified for user {data['email']} ---")
        accessToken = createAccessToken(data={"sub": user.email})
        print(f"--- Debug: Access token created for user {data['email']} ---")
        return {"access_token": accessToken, "token_type": "bearer"}

    except HTTPException as http_exc:
        print(f"--- Debug: HTTPException occurred: {http_exc.detail} ---")
        raise http_exc
    except Exception as e:
        print(f"--- Debug: Unexpected error occurred during login: {str(e)} ---")
        raise HTTPException(status_code=500, detail="Internal server error")

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
        # print(f"--- Debug: Entering /register endpoint for user: {data.username} ---")

        # 1. Check for existing user (more efficient checks)
        print(f"--- Debug: Checking for existing email {data.email}... ---")
        existing_email_user = getUserByEmail(session, data.email)
        if existing_email_user is not None:
            print(f"--- Debug: Email {data.email} already registered. ---")
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

        # print(f"--- Debug: Checking for existing username {data.username}... ---")
        # existing_username_user = getUserByUsername(session, data.username)
        # if existing_username_user is not None:
        #     print(f"--- Debug: Username {data.username} already exists. ---")
        #     raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already exists")

        # 2. Hash the password
        # print(f"--- Debug: Hashing password for {data.username}... ---")
        hashedPassword = getHashedPassword(data.password) # Using your function from auth.authentication
        print("--- Debug: Password hashed.")

        # 3. Create user data for DB
        # Ensure UserCreateDB (imported from db.model) matches structure needed by createUser
        print("--- Debug: Preparing user data for DB save...")
        user_db_data = UserCreateDB(
            # username=data.username,
            hashed_password=hashedPassword, # Use the hashed password
            email=data.email,
            name=data.name,
            phone_number=data.phone_number
        )

        # 4. Save the user to the database
        # print(f"--- Debug: Attempting to save user {data.username} to DB... ---")
        # Assuming createUser (from db.users) takes session and the DB model object
        db_user = createUser(session, user_db_data) # <-- Potential point of failure
        # print(f"--- Debug: User {db_user.username} presumably saved. ---") # Assuming createUser returns the user or similar

        # 5. Create access token AFTER user is successfully created
        # print(f"--- Debug: Creating access token for {data.username}... ---")
        accessToken = createAccessToken(data={"sub": data.email}) # Using your function from auth.authentication
        print("--- Debug: Access token created.")

        # print(f"--- Debug: Registration successful for {data.username}. Returning response. ---")
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
async def addSwapRequest(session: SessionDependency, request: dict):
    if request:
        try:
            print(f"--- Debug: Received swap request data: {request} ---")
            # Validate the request data here if needed

            email = getCurrentUser(request['token'])
            user = getUserByEmail(session, email)
            user_id = user.id if user else None

            request['user_id'] = user_id
            request.pop('token')

            print(request)
            swapRequest = SwapRequest(**request)

            result = addSwapRequestToDB(session, swapRequest)
            if result is None:
                # Properly handle the case where the request already exists
                # by returning a 410 error, not letting it fall to the exception handler
                raise HTTPException(status_code=410, detail="Swap Request Already Exists")

            updateSwapRequestStatus(session, swapRequest, user_id)

            return {"message": "Swap request added successfully", "data": request}

        except HTTPException as e:
            # Re-raise HTTP exceptions to preserve their status code and detail
            raise e
        except Exception as e:
            print(f"Error occurred: {e}")
            raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")
    else:
        raise HTTPException(status_code=400, detail="Invalid data")

@app.post("/getswaprequest")
async def getSwapRequest( session: SessionDependency, request: dict):
    if request:
        email = getCurrentUser(request['token'])
        user = getUserByEmail(session, email)
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
        email = getCurrentUser(request['token'])
        user = getUserByEmail(session, email)
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
    try:
        print("--- Debug: Starting deleteSwapRequest process ---")
        email = getCurrentUser(token)
        user = getUserByEmail(session, email)
        print(f"--- Debug: Retrieved user: {user} ---")
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")

        swapRequest = session.query(SwapRequest).filter_by(id=id).first()

        print(f"--- Debug: Retrieved swapRequest: {swapRequest} ---")
        if swapRequest is None:
            raise HTTPException(status_code=404, detail="Swap request not found")

        # First update any willing swap requests associated with this request
        print("--- Debug: Updating associated willing swap requests ---")
        session.query(WillingSwapRequest).filter_by(swap_request_id=id).update(
            {"status": "Pending", "swap_request_id": None}
        )
        session.commit()

        # Handle free requests differently - no refund needed
        if swapRequest.payment_status == "Free":
            print("--- Debug: Handling free request ---")
            session.delete(swapRequest)
            session.commit()
            swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
            print(f"--- Debug: Remaining swapRequests: {swapRequests} ---")
            return {"swap_requests": swapRequests}

        # If it has a payment, handle the refund
        payment_id = swapRequest.payment_id
        print(f"--- Debug: Payment ID: {payment_id} ---")
        if payment_id is not None:
            payment_record = session.query(Payment).filter_by(id=payment_id).first()
            print(f"--- Debug: Payment record: {payment_record} ---")
            if not payment_record:
                # No payment record found, just delete the swap request
                print("--- Debug: No payment record found, deleting swapRequest ---")
                session.delete(swapRequest)
                session.commit()
                swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
                print(f"--- Debug: Remaining swapRequests: {swapRequests} ---")
                return {"swap_requests": swapRequests}

            transaction_id = payment_record.payment_id
            print(f"--- Debug: Transaction ID: {transaction_id} ---")

            # Set a default refund amount (₹10) - adjust as needed based on your pricing
            refund_amount = 800  # Amount in paise (₹10.00)
            print(f"--- Debug: Refund amount: {refund_amount} ---")

            # Call Razorpay API
            url = f"https://api.razorpay.com/v1/payments/{transaction_id}/refund"
            headers = {
                'Content-Type': 'application/json',
            }
            body = {
                'amount': refund_amount,  # Make sure this matches what you charged
                'speed': 'optimum',
            }

            try:
                print("--- Debug: Sending refund request to Razorpay API ---")
                response = requests.post(
                    url,
                    headers=headers,
                    json=body,
                    auth=("rzp_test_0QuTw1JoWDwGlp", 'A5LJ9c7D8oXHH5QZ7T2tGozs')
                )

                response_data = response.json()
                print(f"--- Debug: Razorpay API response: {response_data} ---")
                if response.status_code == 200:
                    # Successful refund - record the refund ID
                    refund_id = response_data.get('id')
                    print(f"--- Debug: Refund successful, refund ID: {refund_id} ---")

                    # Update payment status and save refund ID
                    session.query(Payment).filter_by(id=payment_id).update({
                        "status": "Refunded",
                        "refund_id": refund_id,
                        "swap_request_id": None
                    })

                    # Delete the swap request
                    session.delete(swapRequest)
                    session.commit()

                    swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
                    print(f"--- Debug: Remaining swapRequests: {swapRequests} ---")
                    return {"swap_requests": swapRequests, "refund": "success"}
                else:
                    # Failed refund - extract error message
                    error_message = response_data.get('error', {}).get('description', 'Unknown error')
                    print(f"--- Debug: Refund failed: {error_message} ---")

                    # Update payment record to show refund failed
                    session.query(Payment).filter_by(id=payment_id).update({
                        "status": "Refund Failed"
                    })
                    session.commit()

                    raise HTTPException(status_code=400, detail=f"Refund failed: {error_message}")

            except Exception as e:
                print(f"--- Debug: Refund process error: {str(e)} ---")
                session.rollback()
                raise HTTPException(status_code=500, detail=f"Error processing refund: {str(e)}")
        else:
            print("--- Debug: No payment ID associated with swap request ---")
            session.delete(swapRequest)
            session.commit()
            swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
            print(f"--- Debug: Remaining swapRequests: {swapRequests} ---")
            return {"swap_requests": swapRequests}

    except HTTPException as http_exc:
        print(f"--- Debug: HTTPException occurred: {http_exc.detail} ---")
        raise http_exc
    except Exception as e:
        print(f"--- Debug: Unexpected error occurred: {str(e)} ---")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

    # # If no payment ID is associated, just delete the request
    # else:
    #     session.delete(swapRequest)
    #     session.commit()
    #     swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
    #     return {"swap_requests": swapRequests}

@app.get("/deleteswapsubmission")
async def deleteSwapSubmission(session: SessionDependency, id: int, token: str):
    email = getCurrentUser(token)
    user = getUserByEmail(session, email)
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
    email = getCurrentUser(token)
    user = getUserByEmail(session, email)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    updateStatus(session, user.id)
    swapRequests = session.query(SwapRequest).filter_by(user_id=user.id).all()
    return {"swap_requests": swapRequests}

@app.get("/getswapsubmissions")
async def getSwapSubmissions(session: SessionDependency, token: str):
    email = getCurrentUser(token)
    user = getUserByEmail(session, email)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    updateStatus(session, user.id)
    swapRequests = session.query(WillingSwapRequest).filter_by(user_id=user.id).all()
    return {"swap_requests": swapRequests}

import time as time_time
import base64
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_v1_5, PKCS1_OAEP
from Crypto.Hash import SHA1

@app.get("/acceptswap")
async def acceptSwap(session: SessionDependency, id: int, token: str):
    try:
        print(f"--- Debug: Starting acceptSwap process for ID: {id} ---")
        email = getCurrentUser(token)
        user = getUserByEmail(session, email)
        print(f"--- Debug: Retrieved user: {user} ---")
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")

        swapRequest = session.query(WillingSwapRequest).filter_by(id=id).first()
        print(f"--- Debug: Retrieved swapRequest: {swapRequest} ---")
        if swapRequest is None:
            raise HTTPException(status_code=404, detail="Swap request not found")
        if swapRequest.status != "Awaiting Confirmation":
            raise HTTPException(status_code=400, detail="Swap request not in Awaiting Confirmation status")

        swap_request_id = session.query(WillingSwapRequest).filter_by(id=id).first().swap_request_id
        print(f"--- Debug: Retrieved swap_request_id: {swap_request_id} ---")

        # Get Cashfree credentials
        clientID = os.getenv("CASHFREE_CLIENT_ID")
        clientSecret = os.getenv("CASHFREE_CLIENT_SECRET")
        publicKey = os.getenv("CASHFREE_PUBLIC_KEY")  # Make sure this is set in your .env file
        environment = "TEST"

        # Generate timestamp for signature
        current_timestamp = int(time_time.time())
        print(f"--- Debug: Current timestamp: {current_timestamp} ---")

        try:
            # Generate signature
            data_to_sign = f"{clientID}.{current_timestamp}"
            print(f"--- Debug: Data to sign: {data_to_sign} ---")
            print(f"DEBUG: Public Key: {publicKey} ---")
            # Load public key
            public_key = RSA.import_key(publicKey)
            cipher = PKCS1_OAEP.new(public_key, hashAlgo=SHA1)

            # Encrypt the data to create signature
            encrypted_data = cipher.encrypt(data_to_sign.encode())
            signature = base64.b64encode(encrypted_data)
            print(f"--- Debug: Generated signature: {signature} ---")

            # Make API request with proper headers
            tokenResponse = requests.post(
                "https://payout-gamma.cashfree.com/payout/v1/authorize",
                headers={
                    "Content-Type": "application/json",
                    "X-Client-Id": clientID,
                    "X-Client-Secret": clientSecret,
                    "X-Cf-Signature": signature,
                    "X-Cf-Timestamp": str(current_timestamp),
                    "cache-control": "no-cache",
                },
            )

            print(f"--- Debug: Token response status: {tokenResponse.status_code}, Response: {tokenResponse.json() if tokenResponse.status_code == 200 else tokenResponse.text} ---")

            if tokenResponse.status_code != 200:
                raise HTTPException(status_code=400, detail=f"Token generation failed: {tokenResponse.text}")

            token = tokenResponse.json()["data"]["token"]
            print(f"--- Debug: Retrieved token: {token} ---")
            # Rest of your cashgram creation code remains the same
            cashgram = {
                "cashgramId": datetime.now().strftime("%Y%m%d%H%M%S"),
                "amount": "10.00",
                "name": user.name,
                "email": user.email,
                "phone": user.phone_number,
                "linkExpiry": (datetime.now() + timedelta(days=7)).date().strftime("%Y/%m/%d"),
                "notifyCustomer": 1
            }

            print(f"--- Debug: Cashgram payload: {cashgram} ---")

            try:
                cashgramResponse = requests.post(
                    "https://payout-gamma.cashfree.com/payout/v1/createCashgram",
                    headers={
                        "Accept": "*/*",
                        "Authorization": f"Bearer {token}",
                        "Content-Type": "application/json",
                    },
                    json=cashgram,
                )

                print(f"--- Debug: Cashgram API response status: {cashgramResponse.status_code} ---")
                print(f"--- Debug: Cashgram API response body: {cashgramResponse.text} ---")

                if cashgramResponse.status_code != 200:
                    raise HTTPException(status_code=400, detail="Cashgram creation failed")

                cashgramResponse = cashgramResponse.json()
                cashgramLink = cashgramResponse["data"]["cashgramLink"]

                print(f"--- Debug: Cashgram link created: {cashgramLink} ---")

                session.query(WillingSwapRequest).filter_by(id=id).update({"status": "Confirmed", "cashgram_link": cashgramLink})
                session.query(SwapRequest).filter_by(id=swap_request_id).update({"status": "Confirmed", "willing_swap_id": id, "willing_swap_berth": swapRequest.berth, "willing_swap_coach": swapRequest.coach, "willing_swap_seat": swapRequest.seat})
                session.commit()

                print(f"--- Debug: Database updated successfully for swapRequest ID: {swap_request_id} and willingSwapRequest ID: {id} ---")

                return {"link": cashgramLink}

            except Exception as e:
                print(f"--- Debug: Exception occurred during Cashgram creation: {str(e)} ---")
                raise HTTPException(status_code=500, detail=f"Error creating Cashgram: {str(e)}")

        except Exception as e:
            print(f"--- Debug: Error in signature generation or API call: {str(e)} ---")
            raise HTTPException(status_code=500, detail=f"Error in API authentication: {str(e)}")

        # Rest of your code remains the same...

    except HTTPException as http_exc:
        print(f"--- Debug: HTTPException occurred: {http_exc.detail} ---")
        raise http_exc
    except Exception as e:
        print(f"--- Debug: Unexpected error occurred: {str(e)} ---")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/declineswap")
async def declineSwap(session: SessionDependency, id: int, token: str):
    email = getCurrentUser(token)
    user = getUserByEmail(session, email)
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
    email = getCurrentUser(token)
    user = getUserByEmail(session, email)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"user": user}

@app.post("/addpayment")
async def add_payment(session: SessionDependency, data: dict):
    print("--- Debug: Entering add_payment endpoint ---")
    print(f"--- Debug: Received data: {data} ---")
    if data:
        try:
            email = getCurrentUser(data['token'])
            user = getUserByEmail(session, email)
            print(f"--- Debug: Retrieved user: {user} ---")
            user_id = user.id if user else None
            payment_id = data['payment_id']
            print(f"--- Debug: Payment ID: {payment_id} ---")
            data.pop('payment_id')

            # Validate the request data here if needed
            data['user_id'] = user_id
            data.pop('token')

            print(f"--- Debug: Creating SwapRequest with data: {data} ---")
            swapRequest = SwapRequest(**data)

            result = addSwapRequestToDB(session, swapRequest)
            if result is None:
                print("--- Debug: Swap Request already exists ---")
                raise HTTPException(status_code=410, detail="Swap Request Already Exists")

            print("--- Debug: Updating SwapRequest status ---")
            updateSwapRequestStatus(session, swapRequest, user_id)

        except HTTPException as e:
            print(f"--- Debug: HTTPException occurred: {e.detail} ---")
            raise e
        except Exception as e:
            print(f"--- Debug: Unexpected error occurred: {e} ---")
            raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

        try:
            print("--- Debug: Querying for existing SwapRequest ---")
            swap_request = session.query(SwapRequest).filter_by(
                user_id=user_id,
                train_name=data['train_name'],
                train_number=data['train_number'],
                date_of_journey=data['date_of_journey'],
                seat=str(data['seat']),
                coach=data['coach'],
                berth=data['berth']
            ).first()

            if not swap_request:
                print("--- Debug: Swap request not found ---")
                raise HTTPException(status_code=404, detail="Swap request not found")

            swap_request_id = swap_request.id
            print(f"--- Debug: Found SwapRequest ID: {swap_request_id} ---")

            # Create payment record
            print("--- Debug: Creating Payment record ---")
            payment = Payment(
                payment_id=payment_id,
                user_id=user_id,
                swap_request_id=swap_request_id
            )

            result = addPaymentToDB(session, payment)
            if result is None:
                print("--- Debug: Payment already exists ---")
                raise HTTPException(status_code=410, detail="Payment Already Exists")

            payment_id = session.query(Payment).filter_by(
                user_id=user_id,
                swap_request_id=swap_request_id
            ).first().id

            # Update the swap request with payment info
            print(f"--- Debug: Updating SwapRequest ID {swap_request_id} with payment info ---")
            session.query(SwapRequest).filter_by(id=swap_request_id).update({
                "payment_status": "Paid",
                "payment_id": payment_id,
            })
            session.commit()

            print("--- Debug: Payment added successfully ---")
            return {"message": "Payment added successfully"}

        except HTTPException as e:
            print(f"--- Debug: HTTPException occurred: {e.detail} ---")
            raise e
        except Exception as e:
            print(f"--- Debug: Unexpected error in add_payment: {e} ---")
            raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    else:
        print("--- Debug: Invalid data received ---")
        raise HTTPException(status_code=400, detail="Invalid data")

@app.get("/capturepayment")
async def capture_payment(payment_id):
    try:
        print(f"--- Debug: Starting capture_payment for payment_id: {payment_id} ---")
        url = f"https://api.razorpay.com/v1/payments/{payment_id}/capture"
        auth = ("rzp_test_0QuTw1JoWDwGlp", 'A5LJ9c7D8oXHH5QZ7T2tGozs')
        data = {"amount": 1500}

        print(f"--- Debug: Sending POST request to {url} with data: {data} ---")
        response = requests.post(url, auth=auth, data=data)

        print(f"--- Debug: Received response with status code: {response.status_code} ---")
        response_data = response.json()
        print(f"--- Debug: Response JSON: {response_data} ---")

        return response_data
    except Exception as e:
        print(f"--- Debug: Exception occurred in capture_payment: {str(e)} ---")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/gettrialuses")
async def getTrialUses(session: SessionDependency, token: str):
    email = getCurrentUser(token)
    user = getUserByEmail(session, email)
    print(user)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    trial_uses = user.trial_uses
    return {"trial_uses": trial_uses}

@app.get("/decreasetrialuses")
async def decerasetrialuses(session: SessionDependency, token: str):
    email = getCurrentUser(token)
    user = getUserByEmail(session, email)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    trial_uses = user.trial_uses
    if trial_uses > 0:
        session.query(User).filter_by(id=user.id).update({"trial_uses": trial_uses - 1})
        session.commit()
        return {"message": "Trial uses decremented"}
    else:
        raise HTTPException(status_code=400, detail="Trial uses not enough")

@app.get("/restoretrialuses")
async def restoretrialuses(session: SessionDependency, token: str):
    email = getCurrentUser(token)
    user = getUserByEmail(session, email)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    trial_uses = user.trial_uses
    if trial_uses > 0:
        session.query(User).filter_by(id=user.id).update({"trial_uses": trial_uses + 1})
        session.commit()
        return {"message": "Trial uses decremented"}
    else:
        raise HTTPException(status_code=400, detail="Trial uses not enough")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
