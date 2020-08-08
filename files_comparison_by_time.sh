#/bin/bash

###################
#simple script to compare if the timestamp of a previously held file 
#has been changed. You can insert your operation in this script and get
#a list of only those files that were previously present and modified
# due to the operation.
###################

files=$(ls -l | awk '{print $6"/"$7"/"$8"$"$9}')
for f in $(echo $files)
do
    if [[ "$f" != "//$" ]]
    then
        echo $f | tr  "$" "\t" >> before_move.txt
    fi
done

#for testing purposes
touch testfile.txt
mv testfile.txt testfile1.txt

######################
#!PERFORM OPERATION HERE!
######################

files=$(ls -l | awk '{print $6"/"$7"/"$8"$"$9}')
for f in $(echo $files)
do
#    echo $f
    if [[ "$f" != "//$" && "$f" != *"before_move.txt"* ]]
    then
        echo $f | tr  "$" "\t" >> after_move.txt
    fi
done

#echo "before move"
#cat before_move.txt
#echo "after move"
#cat after_move.txt

while read -r line;
do
    filestimes=$(echo $line | awk '{print $1" "$3}')
    t1=$(echo $filestimes | cut -d' ' -f1)
    t2=$(echo $filestimes | cut -d' ' -f2)
    if [[ "$t1" != "$t2" ]]
    then
        echo $line
    fi
done < <(paste before_move.txt after_move.txt)


rm before_move.txt
rm after_move.txt
