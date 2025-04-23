from db.model import SwapRequest, WillingSwapRequest, Payment
from db.database import SessionDependency

def addSwapRequestToDB(session: SessionDependency, swap_request: SwapRequest) -> SwapRequest:
    swap_request = SwapRequest(**swap_request.dict())
    if swapRequestsAlreadyExists(session, swap_request):
        return None
    session.add(swap_request)
    session.commit()
    session.refresh(swap_request)
    return swap_request

def deleteSwapRequestTable(session: SessionDependency) -> None:
    session.query(SwapRequest).delete()
    session.commit()

def swapRequestsAlreadyExists(session: SessionDependency, swap_request: SwapRequest) -> bool:
    return session.query(SwapRequest).filter_by(
        user_id=swap_request.user_id,
        pnr=swap_request.pnr,
        status=swap_request.status,
        train_name=swap_request.train_name,
        train_number=swap_request.train_number,
        from_station=swap_request.from_station,
        to_station=swap_request.to_station,
        date_of_journey=swap_request.date_of_journey,
        coach=swap_request.coach,
        berth=swap_request.berth,
        seat=swap_request.seat,
    ).first() is not None

def addWillingswapRequestToDB(session: SessionDependency, swap_request: SwapRequest) -> SwapRequest:
    swap_request = WillingSwapRequest(**swap_request.dict())
    if willingSwapRequestsAlreadyExists(session, swap_request):
        return None
    session.add(swap_request)
    session.commit()
    session.refresh(swap_request)
    return swap_request

def willingSwapRequestsAlreadyExists(session: SessionDependency, swap_request: WillingSwapRequest) -> bool:
    return session.query(WillingSwapRequest).filter_by(
        user_id=swap_request.user_id,
        pnr=swap_request.pnr,
        status=swap_request.status,
        train_name=swap_request.train_name,
        train_number=swap_request.train_number,
        from_station=swap_request.from_station,
        to_station=swap_request.to_station,
        date_of_journey=swap_request.date_of_journey,
        coach=swap_request.coach,
        berth=swap_request.berth,
        seat=swap_request.seat,
    ).first() is not None

def addPaymentToDB(session: SessionDependency, payment: Payment) -> Payment:
    payment = Payment(**payment.dict())
    session.add(payment)
    session.commit()
    session.refresh(payment)
    return payment
