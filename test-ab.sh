#!/bin/bash

# Copyright 2022 Kirti Singh < kirti.singh@packwebhosting.com >

#This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

requirements=1

which ab > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "ab a.k.a.apache benchmark is not installed"
	requirements=0
fi

which bc > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "bc is not installed"
        requirements=0
fi

if [ $requirements -eq 0 ]; then
	exit
fi


if [ ! -z $1 ] && [ $1 = "help" -o $1 = "-h" -o $1 = "--help" ]; then
	echo "usage : test-ab.sh URL LOG_FOLDER CONCURRENCY[optional, default 3] INTERVAL[optional, default 1] ITERATIONS[optional, default 60]"
	exit
fi

if [ -z $1 ]; then
	echo "Please enter URL"
	exit
fi

if [ -z $2 ]; then
	echo "Please enter a log folder"
	exit;
fi

if [ -d $2 ]; then
	echo "Folder already exists"
	exit
fi

concurrency=3

re='^[0-9]+$'

if [ ! -z $3 ]; then
	if ! [[ $3 =~ $re ]]; then
		echo "Please enter a proper number for concurrency"
		exit
	fi
	
	if [ $3 -lt 1 ] || [ $3 -gt 50 ]; then
		echo "Concurrency value should be between 1 and 50"
		exit
	fi
	
	concurrency=$3
fi	

interval=1

re_decimal='^[0-9]+\.[0-9]+$'

if [ ! -z $4 ]; then
        if ! [[ $4 =~ $re ]] &&  ! [[ $4 =~ $re_decimal ]]; then
                echo "Please enter a valid value for interval"
                exit
        fi

	if (( $(echo "$4 < 0.1" | bc -l) )) ||  (( $(echo "$4 > 20" | bc -l) ))  ; then
                echo "Concurrency value should be between 0.1 and 20"
                exit
        fi

        interval=$4
fi

iterations=60

if [ ! -z $5 ]; then
        if ! [[ $5 =~ $re ]]; then
                echo "Please enter a proper number for iterations"
                exit
        fi

        if [ $5 -lt 1 ] || [ $5 -gt 1000 ]; then
                echo "Iterations value should be between 1 and 1000"
                exit
        fi

        iterations=$5
fi




url=$1
log_folder=$2
mkdir -p $log_folder


for (( i = 1; i <= $iterations; i++ )) ; do
	dt=`date +'%Y-%m-%d--%H:%M:%S:%N'`
	file="$log_folder/$i-$dt.tsv"
	ab -s 600 -g $file -n $concurrency -c $concurrency $url > /dev/null 2>1 &
	pids[${i}]=$!
	sleep $interval
done


# wait for all pids
# refer to https://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0
for pid in ${pids[*]}; do
    wait $pid
done

cd $log_folder
head -1 1-* > $log_folder/report.txt  ;for (( i = 1; i <= $iterations; i++ )) ; do if [ -f $i-* ]; then tail -n+2 $i-* >> $log_folder/report.txt; fi done

echo "Please check report at : $log_folder/report.txt"

tot=0;for i in `tail -n+2 $log_folder/report.txt |sed -r 's/\t/ /g'|cut -d ' ' -f9`; do tot=$((tot+i)); done; echo $tot

echo -n "Total requests : $(echo ${concurrency}*${iterations}|bc), Total time : ${tot}, Time per request : "  ; val=`echo  "scale=3; ${tot}/(${concurrency}*${iterations})"|bc`; echo $val


