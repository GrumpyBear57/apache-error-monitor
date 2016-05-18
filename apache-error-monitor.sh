RED='\033[0;31m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
NC='\033[0m'
errorFile='[DIRECTORY TO YOUR ERROR FILE (eg /var/log/apache2/error.log)]

clear
while inotifywait -q -e modify $errorFile >/dev/null; do
        linesBefore=$lines
        lines=$(awk 'END {print NR}' $errorFile)
        lineToStart=$((linesBefore+1))
        linesToCheckARRAY+=($lineToStart)
        lastArrayValue=${linesToCheckARRAY[-1]}
        addToLinesToCheck=$lineToStart
        until [ "$lastArrayValue" = "$lines" ]; do
                let "addToLinesToCheck += 1"
                linesToCheckARRAY+=($addToLinesToCheck)
                lastArrayValue=${linesToCheckARRAY[-1]}
        done
        checkedLines=0
        entriesInArray=${#linesToCheckARRAY[@]}
        lineToRead=$linesBefore
        until [ "$checkedLines" = "$entriesInArray" ]; do
                let "lineToRead += 1"
                lineText=$(sed "${lineToRead}q;d" $errorFile)
                if [[ $lineText == *"PHP Fatal error"* ]]; then
                        printf "${RED}$lineText${NC}\n"
                elif [[ $lineText == *"auth_basic:error"* ]]; then
                        printf "${ORANGE}$lineText${NC}\n"
                elif [[ $lineText == *"PHP Warning"* ]]; then
                        printf "${YELLOW}$lineText${NC}\n"
                else
                        printf "$lineText\n"
                fi
                #printf "${RED}$lineText${NC}\n"
                let "checkedLines += 1"
        done
        lines=$(awk 'END {print NR}' $errorFile)
        unset linesToCheckARRAY
done
