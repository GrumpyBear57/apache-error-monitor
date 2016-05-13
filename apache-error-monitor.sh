RED='\033[0;31m'
NC='\033[0m'
errorFile='[DIRECTORY TO YOUR ERROR FILE (eg /var/log/apache2/error.log)]'

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
		printf "${RED}$lineText${NC}\n"
		let "checkedLines += 1"
	done
	lines=$(awk 'END {print NR}' $errorFile)
	unset linesToCheckARRAY
done
