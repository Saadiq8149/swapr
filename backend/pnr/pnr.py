import requests, json

def fetchPNRDetails(pnr):
    url = f"https://cttrainsapi.confirmtkt.com/api/v2/ctpro/mweb/{pnr}"
    payload = {"proPlanName": "CP1"}

    response = requests.post(url,json=payload)
    if response.status_code != 200:
        # print(f"Error: {response.status_code}")
        return None

    data = response.json()['data']['pnrResponse']

    if data:
        data = {
            "trainNo": data['trainNo'],
            "trainName": data['trainName'],
            "dateOfJourney": data['doj'],
            "fromStation": data['boardingStationName'],
            "toStation": data['reservationUptoName'],
            "passengerCount": data['passengerCount'],
            "chartPrepared": data['chartPrepared'],
            "passengerDetails": [
                {
                    "confirmed": passenger['currentStatus'].split()[0] == "CNF",
                    "coach": passenger['coach'],
                    "seat": passenger['berth'],
                    "berth": passenger['currentBerthCode'],
                }
                for passenger in data['passengerStatus']
            ],
            "coaches": sorted(list(set(data['coachPosition'].split()))),
            "error": data['error'],
        }
        with open('pnrDetails.json', 'w') as f:
            json.dump(data, f, indent=4)
    else:
        return None

    return data

# # print(fetchPNRDetails("6923345817"))
# import requests
# import json
# import logging
# import traceback # For detailed exception logging

# # --- Configure Logging (Best Practice) ---
# # In a real application, configure logging once at the application entry point.
# # For this standalone function, basic config is shown here.
# logging.basicConfig(
#     level=logging.DEBUG, # Capture DEBUG, INFO, WARNING, ERROR, CRITICAL
#     format='%(asctime)s - %(levelname)s - %(name)s - %(message)s'
# )
# logger = logging.getLogger(__name__) # Get a logger specific to this module

# # --- Constants (Optional but good practice) ---
# CONFIRMTKT_API_URL_TEMPLATE = "https://cttrainsapi.confirmtkt.com/api/v2/ctpro/mweb/{pnr}"
# PRO_PLAN_PAYLOAD = {"proPlanName": "CP1"}

# def fetchPNRDetails(pnr):
#     """
#     Fetches PNR details from the ConfirmTkt API with extensive error handling.

#     Args:
#         pnr (str): The PNR number to query.

#     Returns:
#         dict: A dictionary containing formatted PNR details if successful.
#         None: If any error occurs during fetching or processing.
#     """
#     if not pnr or not isinstance(pnr, str) or not pnr.isdigit() or len(pnr) != 10:
#         logger.error(f"Invalid PNR provided: '{pnr}'. Must be a 10-digit string.")
#         return None

#     url = CONFIRMTKT_API_URL_TEMPLATE.format(pnr=pnr)
#     logger.debug(f"Attempting to fetch PNR details for '{pnr}' from URL: {url}")

#     response = None
#     try:
#         # --- Network Request ---
#         response = requests.post(url, json=PRO_PLAN_PAYLOAD, timeout=10) # Added timeout
#         logger.debug(f"Received response for PNR '{pnr}' with status code: {response.status_code}")

#         # --- Check HTTP Status Code ---
#         # Use raise_for_status() for standard HTTP errors or check manually
#         response.raise_for_status() # Raises HTTPError for 4xx/5xx responses

#     except requests.exceptions.Timeout:
#         logger.error(f"Request timed out while fetching PNR '{pnr}' from {url}.")
#         return None
#     except requests.exceptions.RequestException as e:
#         # Catches connection errors, DNS errors, too many redirects, etc.
#         logger.error(f"Network error fetching PNR '{pnr}': {e}", exc_info=True) # exc_info adds traceback
#         # Log response content if available, might contain useful info even on error
#         if response is not None:
#             logger.error(f"Response status: {response.status_code}, Response text: {response.text[:500]}...") # Log snippet
#         return None
#     except Exception as e: # Catch unexpected errors during request phase
#          logger.error(f"Unexpected error during request for PNR '{pnr}': {e}", exc_info=True)
#          return None

#     # --- Process Successful Response (Status Code 2xx) ---
#     try:
#         # --- JSON Parsing ---
#         raw_data = response.json()
#         logger.debug(f"Successfully parsed JSON response for PNR '{pnr}'.")
#         # logger.debug(f"Raw response data snippet: {str(raw_data)[:500]}...") # Optional: Log raw data snippet

#         # --- Data Extraction and Validation ---
#         # Use .get() extensively to avoid KeyError if keys are missing
#         pnr_response_data = raw_data.get('data', {}).get('pnrResponse')

#         if not pnr_response_data:
#             error_message = raw_data.get('data', {}).get('errorMessage', 'pnrResponse key missing or null in API response.')
#             logger.warning(f"API indicated no PNR data found for '{pnr}'. Message: {error_message}")
#             # Check if the API itself signals an error within pnrResponse
#             api_internal_error = pnr_response_data.get('error') if isinstance(pnr_response_data, dict) else None
#             if api_internal_error:
#                  logger.warning(f"API internal error message for PNR '{pnr}': {api_internal_error}")
#             return None # Return None if 'pnrResponse' is missing, empty, or explicitly errored by API

#         # --- Constructing the Cleaned Data Dictionary ---
#         cleaned_data = {}

#         # Safely get basic train info
#         cleaned_data["trainNo"] = pnr_response_data.get('trainNo')
#         cleaned_data["trainName"] = pnr_response_data.get('trainName')
#         cleaned_data["dateOfJourney"] = pnr_response_data.get('doj')
#         cleaned_data["fromStation"] = pnr_response_data.get('boardingStationName')
#         cleaned_data["toStation"] = pnr_response_data.get('reservationUptoName')
#         cleaned_data["passengerCount"] = pnr_response_data.get('passengerCount')
#         cleaned_data["chartPrepared"] = pnr_response_data.get('chartPrepared', False) # Default to False
#         cleaned_data["error"] = pnr_response_data.get('error') # Include API's error field if present

#         # Safely process passenger details
#         cleaned_data["passengerDetails"] = []
#         passenger_status_list = pnr_response_data.get('passengerStatus', [])
#         if isinstance(passenger_status_list, list): # Ensure it's a list
#             for idx, passenger in enumerate(passenger_status_list):
#                 if not isinstance(passenger, dict): # Ensure passenger is a dict
#                      logger.warning(f"Passenger item at index {idx} for PNR '{pnr}' is not a dictionary: {passenger}")
#                      continue # Skip this passenger

#                 # Determine confirmation status safely
#                 confirmed = False
#                 current_status = passenger.get('currentStatus', '')
#                 if isinstance(current_status, str) and current_status.strip(): # Check if string and not empty
#                     try:
#                         confirmed = current_status.split()[0].upper() == "CNF"
#                     except IndexError:
#                         logger.warning(f"Could not parse currentStatus '{current_status}' for PNR '{pnr}', passenger {idx+1}.")
#                         confirmed = False # Default if split fails

#                 passenger_data = {
#                     "confirmed": confirmed,
#                     "coach": passenger.get('coach'),       # Get coach, default None if missing
#                     "seat": passenger.get('berth'),        # Get seat, default None if missing
#                     "berth": passenger.get('currentBerthCode') # Get berth type, default None if missing
#                 }
#                 cleaned_data["passengerDetails"].append(passenger_data)
#         else:
#             logger.warning(f"'passengerStatus' field for PNR '{pnr}' is not a list: {passenger_status_list}")


#         # Safely process coach positions
#         cleaned_data["coaches"] = []
#         coach_position_str = pnr_response_data.get('coachPosition')
#         if isinstance(coach_position_str, str) and coach_position_str.strip():
#             try:
#                 # Split, remove duplicates (via set), and sort
#                 cleaned_data["coaches"] = sorted(list(set(coach_position_str.split())))
#             except Exception as e:
#                 logger.warning(f"Could not parse coachPosition '{coach_position_str}' for PNR '{pnr}': {e}")
#                 cleaned_data["coaches"] = [] # Default to empty list on error
#         elif coach_position_str is not None and not isinstance(coach_position_str, str) :
#              logger.warning(f"'coachPosition' field for PNR '{pnr}' is not a string: {coach_position_str}")

#         logger.info(f"Successfully processed PNR details for '{pnr}'.")
#         return cleaned_data

#     except json.JSONDecodeError as e:
#         logger.error(f"Failed to decode JSON response for PNR '{pnr}': {e}", exc_info=True)
#         logger.error(f"Response text snippet causing JSON error: {response.text[:500]}...")
#         return None
#     except (KeyError, TypeError, AttributeError, IndexError) as e:
#         # Catch errors during data extraction/processing if .get wasn't used or types mismatch
#         logger.error(f"Error processing structure of API response for PNR '{pnr}': {e}", exc_info=True)
#         logger.debug(f"Problematic pnr_response_data snippet: {str(pnr_response_data)[:500]}...") # Log data causing error
#         return None
#     except Exception as e:
#         # Catch-all for any other unexpected error during processing
#         logger.error(f"Unexpected error processing data for PNR '{pnr}': {e}", exc_info=True)
#         logger.debug(f"Raw response data snippet during unexpected error: {str(raw_data)[:500]}...")
#         return None
