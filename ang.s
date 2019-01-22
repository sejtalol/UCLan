#!/bin/sh
for number in {0..200..1}
do
nice +19 ./ang $number
done

mv ./ang_t*.dat ./data/
exit 0
