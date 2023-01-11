#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e '\n ~~~~~ MY SALON ~~~~~ \n'
echo -e '\nWelcome to My Salon, how can I help you?\n'
echo -e "$($PSQL "SELECT * FROM services;") \n"

SERVICE_MENU() {

# get list of services
SERVICES=$($PSQL "SELECT service_id, name  FROM services ORDER BY service_id;")
echo -e "Please select one of our services:"
echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
do
  echo "$SERVICE_ID) $NAME"
done

read SERVICE_ID_SELECTED
EXISTING_SERVICE_MAX_ID=$($PSQL "SELECT MAX(service_id) FROM services;")

# checking if entered service is incorrectly 
if [[ ! $SERVICE_ID_SELECTED =~ [1-$EXISTING_SERVICE_MAX_ID] ]]
  then
  # pick a service that doesn't exist
  SERVICE_MENU
  else
  # pick a service that exist 
  
  # get service name by service id
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # get customer phone number
  echo -e "Please enter your phone number:"
  read CUSTOMER_PHONE
  
  # check if the customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
    then 
    # get new customer name
    echo -e "Please enter your name:"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    # else
  fi

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # get service time
  echo -e "Please enter service time:"
  read SERVICE_TIME

  # inserting a appointment info into the db
  INSERT_APPOINTMENT_INFO=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  echo $INSERT_APPOINTMENT_INFO
    
  # if appointment insert is correct
  if [[ ! -z $INSERT_APPOINTMENT_INFO ]]
  then 
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi
}

SERVICE_MENU

