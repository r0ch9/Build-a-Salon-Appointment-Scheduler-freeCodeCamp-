#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\nWelcome to My Salon, how can I help you?\n"

display_services() {
  # Retrieve services and format the output correctly
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  while IFS='|' read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done <<< "$SERVICES"
}


# Prompt for a valid service
while true
do
  display_services
  read SERVICE_ID_SELECTED

  # Check if the service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
  else
    break
  fi
done

# Prompt for customer phone
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if the customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_ID ]]
then
  # New customer: get their name and insert into customers table
  echo -e "\nIt seems you are new here. What's your name?"
  read CUSTOMER_NAME
  INSERT_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")
fi

# Prompt for appointment time
echo -e "\nAt what time would you like to schedule your $SERVICE_NAME?"
read SERVICE_TIME

# Insert the appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

# Confirm the appointment
if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
else
  echo -e "\nSorry, there was an error scheduling your appointment. Please try again."
fi