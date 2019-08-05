#! /bin/zsh
echo 'Usage: ./run.s ini_time (final_time-interval) interval'

# region = bar, pattern speed = bar
for i in {$1..$2..$3};
do python run5018_anlys.py $i $3 bar bar;
done

# region = bar, pattern speed = bar
for i in {$1..$2..$3};
do python run5018_anlys.py $i $3 spiral spiral;
done

# region = interm, pattern speed = spiral
for i in {$1..$2..$3};
do python run5018_anlys.py $i $3 interm spiral;
done
