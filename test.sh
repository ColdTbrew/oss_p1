#!/bin/bash
get_team_name() {
    local team_number="$1"
    local team_name=$(awk -F ',' "NR==$team_number+1 { print \$0 }" teams.csv | awk -F ',' '{ print $1 }')
    echo "$team_name"
}
read -p "Enter team number: " team_number
team_name=$(get_team_name "$team_number")
echo "$team_name"