#!/bin/bash

# 스크립트는 세 개의 입력 파일(teams.csv, players.csv, matches.csv)을 사용합니다.
# 사용자에게 메뉴를 제공하고 다양한 메뉴을 선택할 수 있도록 합니다.
# 메뉴에는 플레이어 데이터 가져오기, 팀 데이터 가져오기, 최고 관중 경기 가져오기,
# 팀의 리그 순위와 최고 득점자 가져오기, date_GMT의 수정된 포맷 가져오기,
# 홈 경기에서 가장 큰 차이로 이긴 팀 가져오기, 프로그램 종료하기 등이 포함됩니다.

# 스크립트는 각 옵션을 처리하기 위해 여러 함수를 정의합니다.
# main_menu 함수는 사용자에게 메뉴 옵션을 표시합니다.
# get_player_data 함수는 특정 플레이어의 데이터를 검색하고 표시합니다.
# get_team_data 함수는 리그 순위를 기준으로 팀의 데이터를 검색하고 표시합니다.
# get_top_attendance 함수는 상위 3개 관중 경기를 검색하고 표시합니다.
# get_team_ranking_and_top_scorer 함수는 각 팀의 순위와 최고 득점자를 검색하고 표시합니다.
# format_date_gmt 함수는 matches.csv의 date_GMT 필드를 형식화하고 형식화된 날짜를 표시합니다.
# find_largest_home_win 함수는 홈 골 차이가 가장 큰 경기를 검색하고 표시합니다.
# get_largest_home_win 함수는 사용자에게 팀 번호를 입력하도록 요청하고 find_largest_home_win 함수를 호출합니다.

# 스크립트는 사용자가 종료를 7을 선택할 때까지 메뉴를 계속해서 표시하고 사용자 입력을 처리하기 위해 while 루프를 사용합니다.

# 사용 예시:
# ./prj1_12204948_Choiseunghyuk.sh teams.csv players.csv matches.csv



#!/bin/bash

export LC_ALL=C.UTF-8
if [ $# -ne 3 ]; then
    echo "usage: ./prj1_12204948_Choiseunghyuk.sh file1 file2 file3"
    exit 1
fi

teams_file=$1
players_file=$2
matches_file=$3

echo "************OSS1 - Project1************"
echo "*       StudentID : 12204948          *" 
echo "*       Name : Seunghyuk Choi         *"    
echo "***************************************"

# 메인 메뉴
function main_menu {
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in mateches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
}

function get_player_data() {
    #players.csv 파일에서 matching player data를 추출합니다
    local player_name="$1"
    local player_data=$(grep "$player_name" players.csv) 

    if [ -z "$player_data" ]; then
        echo "Player '$player_name' not found in the data."
        return 1
    fi
    # 팀명, 경기수, 득점, 도움 등을 출력합니다.
    local full_name=$(echo "$player_data" | cut -d',' -f1)
    local current_club=$(echo "$player_data" | cut -d',' -f4)
    local appearances=$(echo "$player_data" | cut -d',' -f6)
    local goals=$(echo "$player_data" | cut -d',' -f7)
    local assists=$(echo "$player_data" | cut -d',' -f8)

    echo "Team:$current_club,Appearance:$appearances,Goal:$goals,Assist:$assists\n"
}

function get_team_data() {
    local league_position="$1"
    # awk를 사용하여 리그 위치를 기반으로 teams.csv 파일에서 팀 데이터를 검색합니다.
    local team_data=$(awk -F',' -v pos="$league_position" '$6 == pos {print $0}' teams.csv)

    if [ -z "$team_data" ]; then
        echo "No team found for league position $league_position."
        return 1
    fi

    local team_name=$(echo "$team_data" | cut -d',' -f1)
    local wins=$(echo "$team_data" | cut -d',' -f2)
    local draws=$(echo "$team_data" | cut -d',' -f3)
    local losses=$(echo "$team_data" | cut -d',' -f4)

    # 총 게임 수를 계산합니다 (승리 + 무승부 + 패배).
    local total_games=$((wins + draws + losses))
    # 승률을 계산합니다.
    local winning_rate=$(awk "BEGIN {printf \"%.6f\", $wins / $total_games}")

    # 리그 위치, 팀 이름, 승률을 출력합니다.
    echo "$league_position $team_name $winning_rate\n"
}


function get_top_attendance() {
    # matches.csv 파일을 출석률(2번째 열)을 기준으로 내림차순으로 정렬합니다.
    local sorted_matches=$(sort -t',' -k2 -nr matches.csv)
    # 정렬된 경기 중 상위 3개를 선택합니다.
    local top_matches=$(echo "$sorted_matches" | head -n 3)
    echo "***Top-3 Attendance Match***\n"

    # 각 경기의 정보를 읽어와서 홈 팀, 원정 팀, 날짜, 출석률, 경기장을 출력합니다.
    echo "$top_matches" | while IFS=',' read -r date attendance home_team away_team stadium; do
        echo "$home_team vs $away_team ($date)"
        echo "$attendance $stadium"
        echo "" 
    done
}

# 이 함수는 각 팀의 순위와 최고 득점자를 가져옵니다.
function get_team_ranking_and_top_scorer() {
    read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " answer
    if [[ $answer != "y" ]]; then
        return
    fi

    IFS=$'\n' 

    for team_data in $(awk -F',' '{print $6 "," $1 }' teams.csv | sort -n); do
        IFS=, 
        # 팀 순위와 팀 이름을 추출합니다.
        team_rank=$(echo "$team_data" | cut -d ',' -f1)
        team_name=$(echo "$team_data" | cut -d ',' -f2)

        # players.csv 파일에서 해당 팀의 최고 득점자를 찾습니다.
        top_scorer=$(awk -F ',' -v team="$team_name" '$4 == team {print $1 " " $7}' players.csv | sort -nr -k 3 | head -n 1)
    
        # 팀 순위, 팀 이름, 최고 득점자를 출력합니다.
        printf "%d %s\n" "$team_rank" "$team_name"
        printf "%s\n\n" "$top_scorer" 
    done
    IFS=' ' 
}

# 시간의 포맷을 바꿉니다.
function format_date_gmt() {
    counter=0

    # matches.csv 파일에서 날짜를 추출하고, 상위 10개의 날짜에 대해 반복합니다.
    awk -F ',' '{if(NR!=1) print $1}' matches.csv | head -n 10 | while read -r date_string; do
        if ((counter <= 9)); then

            # 날짜를 공백으로 분리하여 배열에 저장합니다.
            IFS=' ' read -r -a date_array <<< "$date_string"

            # 월, 일, 년, 시간을 추출합니다.
            month="${date_array[0]}"
            day="${date_array[1]}"
            year="${date_array[2]}"
            time="${date_array[4]}"

            # 월의 약어를 숫자로 변환합니다.
            month=$(sed 's/Aug/08/g' <<< "$month")   

            # 포맷된 날짜를 출력합니다.
            printf "%s/%s/%s %s\n" "$year" "$month" "$day" "$time"

            ((counter++))
        fi
    done

    # 모든 포맷된 날짜를 출력합니다.
    for ((i=0; i<${#date_formatted[@]}; i++)); do
        echo "${date_formatted[$i]}"
    done
    echo ""
}

# 팀들을 모두 출력합니다.
display_team_choices() {
   awk -F ',' '{if (NR!=1) print NR-1 ") " $1}' teams.csv 
}

# 팀이름을 가져옵니다.
get_team_name() {
    local team_number="$1"
    local team_name=$(awk -F ',' "NR==$team_number+1 { print \$0 }" teams.csv | awk -F ',' '{ print $1 }')
    echo "$team_name"
}

# 홈 경기에서 가장 큰 차이로 이긴 팀을 찾습니다.
function find_largest_home_win() {
    local team_name=$(get_team_name "$1")
    echo "Team: $team_name"
    largest_diff=0
    best_matches=""

    # matches.csv 파일에서 각 경기를 읽어와서 홈 팀이 주어진 팀인 경우에 대해 처리합니다.
    while IFS=, read -r date_GMT attendance home_team_name away_team_name home_team_goal_count away_team_goal_count stadium_name; do
        if [[ "$home_team_name" == "$team_name" ]]; then
            # 홈 팀과 원정 팀의 골 수를 가져옵니다.
            home_goals=$(echo "$home_team_goal_count" | tr -d ' ')
            away_goals=$(echo "$away_team_goal_count" | tr -d ' ')
            # 골 차이를 계산합니다.
            goal_diff=$((home_goals - away_goals))
            
            # 날짜를 분리합니다.
            IFS=' ' read -r -a date_array <<< "$date_GMT"
            month="${date_array[0]}"
            day="${date_array[1]}"
            year="${date_array[2]}"
            time="${date_array[4]}"

            # 골 차이가 같은 경우, 여러 경기를 저장합니다.
            if [[ $goal_diff -gt $largest_diff ]]; then
                largest_diff=$goal_diff
                best_matches="$month $day $year - $time\n$home_team_name $home_team_goal_count vs $away_team_goal_count $away_team_name\n\n"
            elif [[ $goal_diff -eq $largest_diff ]]; then
                best_matches+="$month $day $year - $time\n$home_team_name $home_team_goal_count vs $away_team_goal_count $away_team_name\n\n"
            fi
        fi
    done < matches.csv
    echo ""
    echo "$best_matches"
}

# 메인 메뉴를 표시하고 사용자 입력을 처리합니다.
while true; do
    main_menu
    read -p "Enter your CHOICE (1~7) : " choice

    if [ $choice -eq 1 ]; then
        read -p "Do you want to get the Heung-Min Son's data? (y/n) : " confirm

        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
            get_player_data "Heung-Min Son"
        else
            echo "Exiting..."
        fi
    elif [ $choice -eq 2 ]; then
        read -p "What do you want to get the team data of league_position[1~20] : " league_position
        if [ "$league_position" -ge 1 ] && [ "$league_position" -le 20 ]; then
            get_team_data "$league_position"
        else
            echo "Invalid league position. Please enter a value between 1 and 20."
        fi
    elif [ $choice -eq 3 ]; then
        read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) : " choice

        if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
            get_top_attendance
        else
            echo "Exiting..."
        fi
    elif [ $choice -eq 4 ]; then
        get_team_ranking_and_top_scorer
    elif [ $choice -eq 5 ]; then
        format_date_gmt
    elif [ $choice -eq 6 ]; then
        display_team_choices
        read -p "Enter team number: " team_number
        find_largest_home_win "$team_number"
    elif [ $choice -eq 7 ]; then
        echo "Bye!"
        exit 0    
    else
        echo "Invalid option. Please try again."
    fi
done
