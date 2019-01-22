#!/bin/sh
for number in {0..200..1}
do
nohup nice +19 ./mytest_vel $number
#nice -n +19 ./mytest_vel $number
#./mytest_vel $number
done

mv ./ptinfo_t*.dat ./data/
exit 0
