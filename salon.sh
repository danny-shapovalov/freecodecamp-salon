#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "Welcome to my salon! How can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "$($PSQL "SELECT * FROM services")" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Invalid input, please try again."
  else
    read ID BAR NAME <<< $($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $ID ]]
    then
      MAIN_MENU "That service doesn't exist, please pick from the services below:"
    else
      SCHEDULE $ID $NAME
    fi
  fi
}

SCHEDULE() {
  SERVICE_ID=$1
  SERVICE_NAME=$2
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  read CUST_ID BAR CUSTOMER_NAME <<< $($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUST_ID ]]
  then
    echo -e "\nThere's no record for that number, so let's create one. What's your name?"
    read CUSTOMER_NAME
    RES=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    read CUST_ID BAR CUSTOMER_NAME <<< $($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  RES=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
