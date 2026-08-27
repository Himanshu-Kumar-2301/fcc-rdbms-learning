#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
TRUNCATE_RESULT=$($PSQL "TRUNCATE table teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    # If not Found
    if [[ -z $WINNER_ID ]]
    then
      # Insert winner team
      ADD_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $ADD_WINNER_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted $WINNER
      fi

      # Get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi
    
    # Get Opponent Id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # If not found
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert opponent team
      ADD_OPPONENT_STATUS=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $ADD_OPPONENT_STATUS == 'INSERT 0 1' ]]
      then
        echo Inserted $OPPONENT
      fi

      # Get new opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi

    # Insert into Games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, winner_id, opponent_id, winner_goals, opponent_goals, round) VALUES ($YEAR, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND')")
    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
      echo "Inserted $YEAR - $WINNER_ID - $OPPONENT_ID - $WINNER_GOALS - $OPPONENT_GOALS - $ROUND"
    fi
  fi
done