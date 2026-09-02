#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1 to 1000
NUMBER_TO_GUESS=$(( RANDOM % 1000 + 1 ))

# ASk user for their name
echo "Enter your username:"
read USERNAME

# Check if user exist
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# if not
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Add user to users
  ADD_USERNAME_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")

  # Get user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

else
  # Get user's game info
  GAME_DATA=$($PSQL "SELECT COUNT(game_id), MIN(number_of_guesses) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $(echo $GAME_DATA | sed 's/|.*$//') games, and your best game took $(echo $GAME_DATA | sed 's/^.*|//') guesses." 
fi

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

GUESS=1

while (( USER_GUESS != NUMBER_TO_GUESS ))
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif (( USER_GUESS > NUMBER_TO_GUESS ))
  then
    echo "It's lower than that, guess again:"
  elif (( USER_GUESS < NUMBER_TO_GUESS ))
  then
    echo "It's higher than that, guess again:"
  fi
  read USER_GUESS
  (( GUESS += 1 ))
done

ADD_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, number_of_guesses) VALUES ($USER_ID, $GUESS)")
echo "You guessed it in $GUESS tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
exit