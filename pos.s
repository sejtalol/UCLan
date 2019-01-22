#!/bin/sh
for number in {0..200..1}
do
nice +19 ./pos $number
done

mv ./pos_t*.dat ./data/
exit 0
