#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
SERVICES=$($PSQL "SELECT service_id, name FROM services")

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    # display message accordingly
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
  then 
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      APPOINTMENT_MENU
    fi
  else
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
}

APPOINTMENT_MENU() {
  # get customer info
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
  echo -e "\nWhat's your phone number?"
  fi

  read CUSTOMER_PHONE

  if [[ ! $CUSTOMER_PHONE =~ ^[0-9-]+$ ]]
  then
    read CUSTOMER_PHONE
  fi
  # check if already a customer
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if not a customer
  if [[ -z $CUSTOMER_NAME ]]
  then
    # Get the name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Add it into cutomer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  # get the time
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ *| *&//g'), $(echo $CUSTOMER_NAME | sed 's/^ *| *&//g')?"
  read SERVICE_TIME

  # Insert into appointments
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ *| *&//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *| *&//g')."
  exit

}

MAIN_MENU