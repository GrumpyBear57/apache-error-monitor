RED='\033[0;31m'
NC='\033[0m'

while inotifywait -q -e modify /var/log/apache2/error.log >/dev/null; do
	linesBefore=$lines
	lines=$(awk 'END {print NR}' /var/log/apache2/error.log)
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
		lineText=$(sed "${lineToRead}q;d" /var/log/apache2/error.log)
		printf "${RED}$lineText${NC}\n"
		let "checkedLines += 1"
	done
	lines=$(awk 'END {print NR}' /var/log/apache2/error.log)
	unset linesToCheckARRAY
done
