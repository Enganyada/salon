#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"

MAIN_MENU(){
  MENU=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "Welcome to my salon.  Here are the services we offer.  How may I help you?"
  # List avaiable services
  echo "$MENU" | while read SERVICE BAR NAME
    do
      echo -e "$SERVICE) $NAME"
    done

  # Get info
  read SERVICE_ID_SELECTED
  # Make sure it's a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "That is not a valid selection."
  else
  # Check to see if it's a real service
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id= $SERVICE_ID_SELECTED")
  # If you pick a service that doesn't exist
    if [[ -z $SERVICE_NAME ]]
    then
    # Send to main menu
    MAIN_MENU "The service you requested is not valid.  Please, choose again."
    else 
      # If you pick a service that does exist
      echo -e "\nWhat is your telephone number?"
      read CUSTOMER_PHONE
      # Find the customer
      CUSTOMER_PHONE_CHECK=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # If customer does not exist
        if [[ -z $CUSTOMER_PHONE_CHECK ]]
        then
          # Create a new customer
          echo -e "\nWhat is your name?"
          read CUSTOMER_NAME
          ADD_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          # Get appointment time
          echo -e "\nAt what time would you like to set your appointment?"
          read SERVICE_TIME
          # Add Appointment
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        else
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          echo -e "\nWelcome back, $CUSTOMER_NAME.  At what time would you like to set your appointment?"
          read SERVICE_TIME
          ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
    fi
  fi
}

MAIN_MENU
