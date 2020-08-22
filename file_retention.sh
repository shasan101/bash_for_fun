#/bin/bash
daily_retention_count="7"
weekly_retention_count="4"
monthly_retention_count="12"
yearly_retention_count="1"


#dump_path="/var/backups/postgres_dumps/"
dump_path="/home/test/backups/"
daily_path="${dump_path}daily/"
weekly_path="${dump_path}weekly/"
monthly_path="${dump_path}monthly/"
yearly_path="${dump_path}yearly/"

mkdir -p $daily_path 
mkdir -p $weekly_path 
mkdir -p $monthly_path 
mkdir -p $yearly_path  

#take a dump and place it in the daily backup folder

HOSTNAME=127.0.0.1
DATABASE=test
PORT=5432

# Note that we are setting the password to a global environment variable temporarily.
echo "Pulling Database: This may take a few minutes"
filename="$(date +%Y-%m-%d-%s).bakup"
pg_dump -Fc -Z9 > ${daily_path}${filename}
gzip ${daily_path}${filename}
echo "Pull Complete"

count_of_daily=$(ls -1q  ${daily_path} | wc -l)

if (( ${count_of_daily} > ${daily_retention_count} ))
then
    to_move=$(ls -t ${daily_path}| tail -n 1)
    echo "moving to weekly: "${to_move} 
    mv ${daily_path}${to_move} ${weekly_path}
    count_of_weekly=$(ls -1q  ${weekly_path} | wc -l)
    if (( ${count_of_weekly} > ${weekly_retention_count} ))
    then
        to_move=$(ls -t ${weekly_path}| tail -n 1)
        echo "moving to monthly: "${to_move} 
        mv ${weekly_path}${to_move} ${monthly_path}
        count_of_monthly=$(ls -1q  ${monthly_path} | wc -l)
        if (( ${count_of_monthly} > ${monthly_retention_count} ))
        then
            to_move=$(ls -t ${monthly_path}| tail -n 1)
            echo "moving to yearly: "${to_move}
            mv ${monthly_path}${to_move} ${yearly_path}
            count_of_yearly=$(ls -1q  ${yearly_path} | wc -l)
            if (( ${count_of_yearly} > ${yearly_retention_count} ))
            then
                to_move=$(ls -t ${yearly_path}| tail -n 1)
                rm -f ${yearly_path}${to_move}
            fi
        fi
    fi
fi


# for d in `ls /home/test/backups`; do echo $d;ls -lah "/home/test/backups/"$d; done

# #ping machines
# for connection_string in ${machines}:
#     ping -c 1 ${connection_string}
#     if [[ "$?" -eq "0" ]] 
#     then
#         scp ${filename} ${copy_user}@${connection_string}:${user_path}/${filename}
#     fi
# done


#  rm -r backups/daily/*
#  rm -r backups/monthly/*
#  rm -r backups/weekly/*
#  rm -r backups/yearly/*



