from db.database import SessionDependency
from db.model import SwapRequest, WillingSwapRequest
import requests
from fastapi import HTTPException

def updateSwapRequestStatus(session: SessionDependency, swap_request, user_id) -> None:
    matches = session.query(WillingSwapRequest).filter_by(train_number=swap_request.train_number, to_station=swap_request.to_station, date_of_journey=swap_request.date_of_journey).all()
    # print(matches)
    swap_request_id = session.query(SwapRequest).filter_by(user_id=user_id, train_number=swap_request.train_number, to_station=swap_request.to_station, date_of_journey=swap_request.date_of_journey, seat=swap_request.seat, berth=swap_request.berth, coach=swap_request.coach).first().id
    if matches:
        for match in matches:
            if match.coach[0] == swap_request.coach[0] and match.user_id != user_id:
                if match.preferred_berth == "[]":
                    restrictions = match.preferred_berth.strip("[]")
                else:
                    restrictions = [x.strip() for x in match.preferred_berth.strip("[]").split(",")]
                if match.blacklist == "[]":
                    blacklist = []
                else:
                    blacklist = [x.strip() for x in match.blacklist.strip("[]").split(",")]
                restrictions = [x.split()[-1] for x in restrictions]
                requested_berth = [x.strip() for x in swap_request.preferred_berth.strip("[]").split(",")]
                print(restrictions, blacklist, requested_berth)
                if swap_request.berth not in restrictions and match.berth in requested_berth and match.status == "Pending" and swap_request.status == "Pending" and swap_request_id not in blacklist:
                    session.query(WillingSwapRequest).filter_by(id=match.id).update({"status": "Awaiting Confirmation", "swap_request_id": swap_request_id, "swap_request_berth": swap_request.berth, "swap_request_coach": swap_request.coach, "swap_request_seat": swap_request.seat})
                    session.commit()
                    session.query(SwapRequest).filter_by(id=swap_request_id).update({"status": "Awaiting Confirmation"})
                    session.commit()
                    return

def updateWillingSwapRequestStatus(session: SessionDependency, swap_request, user_id) -> None:
    matches = session.query(SwapRequest).filter_by(train_number=swap_request.train_number, to_station=swap_request.to_station, date_of_journey=swap_request.date_of_journey).all()
    swap_request_id = session.query(WillingSwapRequest).filter_by(user_id=user_id, train_number=swap_request.train_number, to_station=swap_request.to_station, date_of_journey=swap_request.date_of_journey, seat=swap_request.seat, berth=swap_request.berth, coach=swap_request.coach).first().id
    if matches:
        if swap_request.preferred_berth == "[]":
            restrictions = swap_request.preferred_berth.strip("[]")
        else:
            restrictions = [x.strip() for x in swap_request.preferred_berth.strip("[]").split(",")]
        if swap_request.blacklist == "[]":
            blacklist = []
        else:
            blacklist = [x.strip() for x in swap_request.blacklist.strip("[]").split(",")]
        restrictions = [x.split()[-1] for x in restrictions]

        for match in matches:
            if match.coach[0] == swap_request.coach[0] and match.user_id != user_id:
                requested_berth = [x.strip() for x in match.preferred_berth.strip("[]").split(",")]
                if match.berth not in restrictions and swap_request.berth in requested_berth and match.status == "Pending" and swap_request.status == "Pending" and match.id not in blacklist:
                    session.query(WillingSwapRequest).filter_by(id=swap_request_id).update({"status": "Awaiting Confirmation","swap_request_id": match.id, "swap_request_berth": match.berth, "swap_request_coach": match.coach, "swap_request_seat": match.seat})
                    session.commit()
                    session.query(SwapRequest).filter_by(id=match.id).update({"status": "Awaiting Confirmation"})
                    session.commit()
                    return

def updateStatus(session: SessionDependency, user_id) -> None:
    from datetime import datetime, timedelta
    swap_requests = session.query(SwapRequest).filter_by(user_id=user_id).all()
    for swap_request in swap_requests:
        updateSwapRequestStatus(session, swap_request, user_id)
        date_of_journey = datetime.strptime(swap_request.date_of_journey, "%d-%m-%Y")
        if swap_request.status == "Pending" and datetime.now() + timedelta(days=2) > date_of_journey:
            session.query(SwapRequest).filter_by(id=swap_request.id).update({"status": "Expired"})
            session.commit()

    willing_swap_requests = session.query(WillingSwapRequest).filter_by(user_id=user_id).all()
    for willing_swap_request in willing_swap_requests:
        updateWillingSwapRequestStatus(session, willing_swap_request, user_id)
    session.commit()
