#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Beauty salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

 AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id") 
 
 if [[ -z $AVAILABLE_SERVICES ]]
    then 
    MAIN_MENU "\nNo more services available try again later"
    else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done
    echo -e "\nWhich service would you like?"
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
      then
       MAIN_MENU "That is not a valid number."
      else
      # get bike availability
      SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      # if not available
      if [[ -z $SERVICE_AVAILABILITY ]]
      then
        # send to main menu
        MAIN_MENU "That bike is not available."
        else
        echo -e "\nYou have taken $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')."
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      
        if [[ -z $CUSTOMER_NAME ]]
        then      
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME        
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
              
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        echo -e "\nAt what time would you like to come?"
        read SERVICE_TIME
        
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id,time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED','$SERVICE_TIME')")
        if [[ $INSERT_APPOINTMENT ]]
        then
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
          
        fi 
      fi
    fi
    
 fi

}
MAIN_MENU
