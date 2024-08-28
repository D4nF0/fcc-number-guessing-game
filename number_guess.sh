#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$((1 + $RANDOM % 1000 ))
NUMBER_OF_GUESSES=0;

WELCOME() {
  echo "Enter your username: "
  read USERNAME

  USER=$($PSQL "SELECT username FROM users_games WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users_games WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users_games WHERE username='$USERNAME'")
  USER_ID=$($PSQL "SELECT user_id FROM users_games WHERE username='$USERNAME'")

  if [[ -z $USER ]]
  then
    FIRST_TIME=1
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else 
    FIRST_TIME=0
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  GUESSER
}

GUESSER() {
  if [[ -z $1 ]]
  then 
    echo "Guess the secret number between 1 and 1000:"
    read GUESS
    let NUMBER_OF_GUESSES+=1
    GUESSER $GUESS

  else
    if [[ ! $1 =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
      GUESSER $GUESS

    else
      if [[ $1 -eq $SECRET_NUMBER ]]
      then

        if [[ $FIRST_TIME -eq 1 ]]
        then
          DATABASE_RESULT=$($PSQL "INSERT INTO users_games( username, games_played, best_game) VALUES( '$USERNAME', 1, $NUMBER_OF_GUESSES);")

        else
          let GAMES_PLAYED+=1
          DATABASE_RESULT=$($PSQL "UPDATE users_games SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID;")

          if [[ $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
          then
            DATABASE_RESULT=$($PSQL "UPDATE users_games SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID;")

          fi

        fi

        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

      elif [[ $1 -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        read GUESS
        let NUMBER_OF_GUESSES+=1
        GUESSER $GUESS

      else
        echo "It's higher than that, guess again:"
        read GUESS
        let NUMBER_OF_GUESSES+=1
        GUESSER $GUESS

      fi

    fi

  fi
}


WELCOME