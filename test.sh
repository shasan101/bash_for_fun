#/bin/bash
copy_user="postgres_user"
user_path="/home/"${copy_user}
machines=("172.16.1.10" "172.16.1.11" "172.16.1.12")
for connection_string in ${machines}:
do
     ping -c 1 ${connection_string}
     echo ${connection_string}
     if [[ "$?" -eq "0" ]]
     then
         scp ${daily_path}${filename} ${copy_user}@${connection_string}:${user_path}
     fi
done
