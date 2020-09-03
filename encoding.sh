#!/bin/bash
#coding:utf-8

function generatePadding(){

    paddingArray=(0 1 2 3 4 5 6 7 8 9 a b c d e f)

    for i in $(seq 1 $1); do
        echo ""
		randomCharnameSize=$((RANDOM%10+7))
        randomCharname=`cat /dev/urandom | tr -dc 'a-zA-Z' | head -c ${randomCharnameSize}`
		echo "unsigned char ${randomCharname}[]="
    	randomLines=$((RANDOM%20+13))
		for (( c=1; c<=$randomLines; c++ )); do
			randomString="\""
			randomLength=$((RANDOM%11+7))
			for (( d=1; d<=$randomLength; d++ )); do
				randomChar1=${paddingArray[$((RANDOM%15))]}
				randomChar2=${paddingArray[$((RANDOM%15))]}
				randomPadding=$randomChar1$randomChar2
		    	randomString="$randomString\\x$randomPadding"
			done
			randomString="$randomString\""
			if [ $c -eq ${randomLines} ]; then
				echo "$randomString;"
			else
				echo $randomString
			fi
		done
    done
}

generatePadding $1
