#! /bin/zsh
echo 'Usage: ./run.s ini_time (final_time-interval) interval'

for i in {$1..$2..$3};
do python run5018_xy.py $i $3;
done

