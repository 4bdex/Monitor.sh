#!/bin/bash
# Usage: sudo monitor.sh -k keyword1 keyword2 ... -w website1 website2 ... -a true|false

# Constants
CONFIG_FILE="config.txt"

# Get History log file path from config file
HISTORY_LOG=$(grep -i "history_log" "$CONFIG_FILE" | cut -d'=' -f2)

# Initialize arrays
keywords=()
websites=()
should_exist=""
itskeyword=0
itswebsite=0



# Parse command-line arguments
for arg in $* ; do

        if [ "$arg" == '-k' ]; then
                itskeyword=1
                itswebsite=0

        elif [ "$arg" == '-w' ]; then
                itskeyword=0
                itswebsite=1

        elif [ "$arg" == "-a" ]; then
                itskeyword=0
                itswebsite=0

        elif [ $itskeyword -eq 1 ]; then
                keywords+=("$arg")

        elif [ $itswebsite -eq 1 ]; then
                websites+=("$arg")
        else
                a=$arg
        fi
done

echo "Keywords: ${keywords[@]}"
echo "Websites: ${websites[@]}"
echo "Should exist: $a"

# Log the keywords and the websites in the history log
# Check if the history log file exists
if [ ! -f "$HISTORY_LOG" ]; then
    # Create the history log file if it doesn't exist (/var/log/monitor/history.log)
    mkdir -p "$(dirname "$HISTORY_LOG")"
    touch "$HISTORY_LOG"
fi

# Iterate over each website and check if the keywords exists based on the should_exist value
for website in "${websites[@]}"; do
    echo "Checking $website"
    for keyword in "${keywords[@]}"; do
        echo "Checking for keyword: $keyword"
        # Check if the keyword exists in the website
        if curl -s "$website" | grep -q "$keyword"; then
            # Log the keyword and website in the history log
            echo "$(date) - $keyword found in $website" >> "$HISTORY_LOG"
            if [ "$should_exist" = false ]; then
                echo "Keyword $keyword found in $website"
            fi
        else
            # Log the keyword and website in the history log
            echo "$(date) - $keyword not found in $website" >> "$HISTORY_LOG"
            if [ "$should_exist" = true ]; then
                echo "Keyword $keyword not found in $website"
            fi
        fi
    done
done


# Print the keywords and the websites
echo "history log: $HISTORY_LOG"
echo "Should exist: $should_exist"
echo "Keywords: ${keywords[@]}"
echo "Websites: ${websites[@]}"
