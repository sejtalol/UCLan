#!/bin/sh
for number in {0..200..1}
do
nice +19 ./energy $number
done

mv ./energy_t*.dat ./data/
exit 0
