# tools
Stress testing and other useful tools
### test-ab.sh
Stress testing using ab a.k.a. Apache Benchmark . 

This script solves a particular problem which default functionality of ab does not solve i.e. if we are to run say 5 concurrent connections over 60 iterations , the 1st iteration will only end when all the 1st 5 requests have been handled or taken care off. Only after that the 2nd iteration will begin.

Now in real world sceario, a URL will be getting hit by a bot/traffic with some regularilty irrespective whether the previous requests have been completed or not. 

The script test-ab.sh solves this problem by iterating over a certain fixed time frame whithout considering the status of the previous requests. In the end this script will mention a file which contains the timelines of all the requests have the same format as -g switch used with ab i.e. TSV (tab separated).

This scripts ab and bc scripts/packages.

Typical usage

bash test-ab.sh URL LOG_FOLDER

The LOG_FOLDER will be created by the script.

e.g

bash test-ab.sh https://example.com /var/log/test-ab/t1

By default the concurrency is 3  , iteration interval is 1s and no. of iterations are 60

Once its done, it provides the path to the report as /var/log/test-ab/t1/report.txt

Full options can be checkout using 

bash test-ab.sh -h 

usage : test-ab.sh URL LOG_FOLDER CONCURRENCY[optional, default 3] INTERVAL[optional, default 1] ITERATIONS[optional, default 60]

