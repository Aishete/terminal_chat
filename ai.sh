#!/usr/bin/env bash

ENV_FILE="env.txt"

# API endpoint (default to Gemini 1.5 Flash since it fast and free hehe )
API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
# but you can change to other models if you want. or local ai if you have power gpu

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

show_spinner() {
  local pid=$1
  local delay=0.1
  local spinstr=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r %s " "${spinstr[i]}"
    i=$(((i + 1) % ${#spinstr[@]}))
    sleep "$delay"
  done
  printf "\r    \r"
}

check_dependencies() {
  if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}Error: 'jq' is required but not installed. Please install jq.${NC}"
    exit 1
  fi
}

read_token() {
  if [[ -f "$ENV_FILE" ]]; then
    token=$(head -n 1 "$ENV_FILE" | tr -d '[:space:]')
    if [[ -z "$token" ]]; then
      echo -e "${RED}Error: Token is empty in $ENV_FILE.${NC}"
      return 1
    fi
    return 0
  else
    echo -e "${RED}Error: $ENV_FILE does not exist.${NC}"
    return 1
  fi
}

setup_env_file() {
  echo -e "${GREEN}Do you want to create or update $ENV_FILE now? [y/n]${NC}"
  read -r choice
  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -e "${GREEN}Please visit https://aistudio.google.com/ to get your Gemini API token.${NC}"
    echo -n "Enter your API token: "
    read -r token
    if [[ -n "$token" ]]; then
      echo "$token" >"$ENV_FILE"
      if [[ $? -eq 0 ]]; then
        chmod 600 "$ENV_FILE"
        echo -e "${GREEN}Token successfully saved to $ENV_FILE.${NC}"
        return 0
      else
        echo -e "${RED}Error: Failed to write token to $ENV_FILE.${NC}"
        return 1
      fi
    else
      echo -e "${RED}Error: No token provided.${NC}"
      return 1
    fi
  else
    echo -e "${RED}You need to create $ENV_FILE with a valid token from https://aistudio.google.com/.${NC}"
    return 1
  fi
}

api_call() {
  local text="$1"
  curl -s "$API_URL" \
    -H "x-goog-api-key: $token" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{
      "contents": [
        {
          "parts": [
            {
              "text": "'"$text"'"
            }
          ]
        }
      ]
    }'
}

main() {
  check_dependencies

  if [[ $# -eq 0 ]]; then
    echo -e "${RED}Error: Please provide text as an argument.${NC}"
    echo "Usage: $0 <text>"
    exit 1
  fi

  local text="$*"

  if ! read_token; then
    if ! setup_env_file; then
      exit 1
    fi
    read_token || exit 1
  fi

  api_call "$text" >response.json &
  local api_pid=$!
  show_spinner "$api_pid"
  wait "$api_pid"

  if [[ $? -eq 0 && -s response.json ]]; then
    local text_output
    text_output=$(jq -r '.candidates[0].content.parts[0].text // empty' response.json)
    rm -f response.json
    if [[ -n "$text_output" ]]; then
      echo -e "$text_output"
    else
      echo -e "${RED}Error: No text found in the API response.${NC}"
      exit 1
    fi
  else
    echo -e "${RED}Error: API call failed or returned empty response.${NC}"
    rm -f response.json
    exit 1
  fi
}

trap 'echo -e "${RED}Script interrupted.${NC}"; rm -f response.json; exit 1' INT TERM

main "$@"
