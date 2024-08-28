#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000 ))

WELCOME() {
  echo "Enter your username: "
  read USERNAME

  USER=$($PSQL "SELECT username FROM users_games WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users_games WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users_games WHERE username='$USERNAME'")
  
  if [[ -z $USER ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else 
    echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi



}

WELCOME