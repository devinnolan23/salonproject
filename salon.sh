#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"



MAIN_MENU() {
   if [[ $1 ]]
   then 
    echo -e "\n$1"
   fi
    echo -e "\nWelcome to My Salon, how can I help you?"

    SERVICE_SELECTION=$($PSQL "SELECT * FROM services ORDER BY service_id")
    
    echo "$SERVICE_SELECTION" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
    
    read SERVICE_ID_SELECTED
    
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] #If not a number
    then
        MAIN_MENU "I could not find that service. What would you like today?"
    else
        SERVICE_CHECK=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

        if [[ -z $SERVICE_CHECK ]]
        then
        MAIN_MENU "I could not find that service. What would you like today?"
        else
            echo -e "\nWhat's your phone numer?"
            read CUSTOMER_PHONE

            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")

            if [[ -z $CUSTOMER_NAME ]]
              then
                echo -e "\nI don't have a record for that phone number,\nwhat's your name?"
                read CUSTOMER_NAME

                #insert new customer and phone 
                INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE') ")
            fi

            echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
            read SERVICE_TIME
            
             #get customer id
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
            #insert into apts
            INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
            #format response
            echo -e "\nI have put you down for a$SERVICE_CHECK at $SERVICE_TIME, $CUSTOMER_NAME."
            
            
        
          
        fi
    fi
}

MAIN_MENU
