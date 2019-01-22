#!/bin/bash
for number in {0..200..1}
do
	./ang $number
done

mv ./ang_t*.dat ./data/
exit 0
