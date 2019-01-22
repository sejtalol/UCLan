#!/bin/bash
for number in {0..200..1}
do
	./energy $number
done

mv ./energy_t*.dat ./data/
exit 0
