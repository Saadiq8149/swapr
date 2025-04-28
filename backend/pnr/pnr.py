import requests
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(name)s - %(message)s'
)
logger = logging.getLogger(__name__)

CONFIRMTKT_API_URL_TEMPLATE = "https://cttrainsapi.confirmtkt.com/api/v2/ctpro/mweb/{pnr}"
PRO_PLAN_PAYLOAD = {"proPlanName": "CP1"}

def fetchPNRDetails(pnr):
    if not pnr or not isinstance(pnr, str) or not pnr.isdigit() or len(pnr) != 10:
        logger.error(f"Invalid PNR provided: '{pnr}'. Must be a 10-digit string.")
        return None

    url = CONFIRMTKT_API_URL_TEMPLATE.format(pnr=pnr)
    response = None
    try:
        response = requests.post(url, json=PRO_PLAN_PAYLOAD, timeout=10)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        logger.error(f"Network error fetching PNR '{pnr}': {e}", exc_info=True)
        if response is not None:
            logger.error(f"Response status: {response.status_code}, Response text: {response.text[:500]}...")
        return None
    except Exception as e:
        logger.error(f"Unexpected error during request for PNR '{pnr}': {e}", exc_info=True)
        return None

    try:
        raw_data = response.json()
        pnr_response_data = raw_data.get('data', {}).get('pnrResponse')

        if not pnr_response_data:
            error_message = raw_data.get('data', {}).get('errorMessage', 'pnrResponse key missing or null in API response.')
            logger.warning(f"API indicated no PNR data found for '{pnr}'. Message: {error_message}")
            api_internal_error = pnr_response_data.get('error') if isinstance(pnr_response_data, dict) else None
            if api_internal_error:
                logger.warning(f"API internal error message for PNR '{pnr}': {api_internal_error}")
            return None

        cleaned_data = {
            "trainNo": pnr_response_data.get('trainNo'),
            "trainName": pnr_response_data.get('trainName'),
            "dateOfJourney": pnr_response_data.get('doj'),
            "fromStation": pnr_response_data.get('boardingStationName'),
            "toStation": pnr_response_data.get('reservationUptoName'),
            "passengerCount": pnr_response_data.get('passengerCount'),
            "chartPrepared": pnr_response_data.get('chartPrepared', False),
            "error": pnr_response_data.get('error'),
            "passengerDetails": [],
            "coaches": []
        }

        passenger_status_list = pnr_response_data.get('passengerStatus', [])
        if isinstance(passenger_status_list, list):
            for idx, passenger in enumerate(passenger_status_list):
                if not isinstance(passenger, dict):
                    continue
                confirmed = False
                current_status = passenger.get('currentStatus', '')
                if isinstance(current_status, str) and current_status.strip():
                    try:
                        confirmed = current_status.split()[0].upper() == "CNF"
                    except IndexError:
                        confirmed = False
                passenger_data = {
                    "confirmed": confirmed,
                    "coach": passenger.get('coach'),
                    "seat": passenger.get('berth'),
                    "berth": passenger.get('currentBerthCode')
                }
                cleaned_data["passengerDetails"].append(passenger_data)

        coach_position_str = pnr_response_data.get('coachPosition')
        if isinstance(coach_position_str, str) and coach_position_str.strip():
            try:
                cleaned_data["coaches"] = sorted(list(set(coach_position_str.split())))
            except Exception:
                cleaned_data["coaches"] = []

        if cleaned_data["error"] is not None:
            logger.warning(f"API returned an error for PNR '{pnr}': {cleaned_data['error']}")
            return None
        return cleaned_data

    except Exception as e:
        logger.error(f"Error processing data for PNR '{pnr}': {e}", exc_info=True)
        return None
