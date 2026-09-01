#!/bin/bash


PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ $1 ]]
then
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_FOUND=$($PSQL "SELECT atomic_number, symbol, name, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) LEFT JOIN types USING (type_id) WHERE atomic_number = $1")
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
  then
    ELEMENT_FOUND=$($PSQL "SELECT atomic_number, symbol, name, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) LEFT JOIN types USING (type_id) WHERE symbol = '$1'")
  elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
  then
    ELEMENT_FOUND=$($PSQL "SELECT atomic_number, symbol, name, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) LEFT JOIN types USING (type_id) WHERE name = '$1'")
  fi
else
  echo "Please provide an element as an argument."
  exit
fi

if [[ -z $ELEMENT_FOUND ]]
then
  echo "I could not find that element in the database."
else
  echo "$ELEMENT_FOUND" | while IFS='|' read ATOMIC_NUMBER SYMBOL ELEMENT_NAME ELEMENT_TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  done
fi
