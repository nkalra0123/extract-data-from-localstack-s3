#! /bin/bash

function cleanup ()
{
    echo "in cleanup"
    rm step1
    rm raw_data
    rm filenames

}

function user_finish ()
{
    trap EXIT
    cleanup
    exit 1;
}

trap user_finish 1 2 3 15 # SIGHUP SIGINT SIGQUIT SIGTERM

cat recorded_api_calls.json | grep -i "\"a\": \"s3\", \"m\": \"PUT\", \"p\""  | grep -i "\"Content-Type\": \"image"> step1

jq -r .d step1 > raw_data

jq -r .p step1 > filenames

paste filenames raw_data | while read if of; 
do 
    echo $if
    DIR=`echo $if | cut -f2 -d"/"`
    mkdir -p $DIR
    FILENAME=`echo $if | cut -f3 -d"/" | cut -f1 -d"?"`
    touch $DIR/$FILENAME

    echo $of | base64 --decode > $DIR/$FILENAME

done

cleanup
