#!/bin/sh

for file in `ls -1 *.info`
do
	mv $file OGP_$file
done

