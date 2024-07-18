#!/bin/bash

# Replace :owner with the owner of the repository and :repo with the repository name
OWNER="Opentrons"
REPO="opentrons"

TEAM_NAMES="sw-protocol-execution"

# Optional: Uncomment the next line and replace :your_token_here with your GitHub Personal Access Token if you need to authenticate
#TOKEN=":your_token_here"

# Base URL for GitHub API
GITHUB_API_URL="https://api.github.com/repos/$OWNER/$REPO/pulls?state=all"

# Convert TEAM_NAMES to an array
IFS=' ' read -r -a TEAM_NAMES_ARRAY <<< "$TEAM_NAMES"

# Prepare jq filter for team names
JQ_FILTER=$(printf '.name == "%s"' "${TEAM_NAMES_ARRAY[0]}")
for i in "${TEAM_NAMES_ARRAY[@]:1}"; do
  JQ_FILTER+=' or .name == "'$i'"'
done

echo $JQ_FILTER

# Check if TOKEN is set and add Authorization header, else just call the API
if [ -z "${TOKEN}" ]; then
    RESPONSE=$(curl -s "$GITHUB_API_URL")
else
    RESPONSE=$(curl -s -H "Authorization: token $TOKEN" "$GITHUB_API_URL")
fi


echo $RESPONSE | jq '.[] | select(any(.requested_teams[]; '"$JQ_FILTER"'))| "\(.user.login) - \(.title) - \(.html_url)"'