#/bin/bash
# Since we cant rotate same file for daily, monthly and yearly with logrotate, so we automate
# run the daily cron:

# if count(ls daily >= 7){
#     if count(ls weekly >= 4){
#         if count(ls monthly >= 12){
#             move oldest monthly to yearly.
#             remove the old yearly, IF exist
#             move oldest weekly to monthly
#             move oldest daily to weekly
#         } else {
#             move oldest weekly to monthly
#             move oldest daily to weekly
#         }
#     } else {
#        move oldest daily to weekly
#     }
# }

#to find the oldest file in a dir
#find . -type f -print0  | xargs -0 ls "${daily_path}" | head -n 1

daily_retention_count="7"
weekly_retention_count="4"
monthly_retention_count="12"
yearly_retention_count="1"

#dump_path="/var/backups/postgres_dumps/"
dump_path="/home/postgres_user/backups/"
daily_path="${dump_path}daily/"
weekly_path="${dump_path}weekly/"
monthly_path="${dump_path}monthly/"
yearly_path="${dump_path}yearly/"

mkdir -p $daily_path 
mkdir -p $weekly_path 
mkdir -p $monthly_path 
mkdir -p $yearly_path  

daily_files=$(ls ${daily_path} -c)
count_of_daily=$(ls -1q  ${daily_path} | wc -l)
# echo $files


if [[ "${count_of_daily}" -ge ${daily_retention_count} ]]
then
    weekly_files=$(ls ${weekly_path} -c)
    count_of_weekly=$(ls -1q  ${weekly_path} | wc -l)
    if [[ "${count_of_weekly}" -ge ${weekly_retention_count} ]]
    then
        monthly_files=$(ls ${monthly_path} -c)
        count_of_monthly=$(ls -1q  ${monthly_path} | wc -l)
        if [[ "${count_of_monthly}" -ge ${monthly_retention_count} ]]
        then
            yearly_files=$(ls ${yearly_path} -c)
            count_of_yearly=$(ls -1q  ${yearly_path} | wc -l)
            if [[ "${count_of_yearly}" -ge ${yearly_retention_count} ]]
            then
                rm -f "${yearly_path}${yearly_files}"
            fi
                
            mv `find . -type f -print0  | xargs -0 ls "${monthly_path}" | head -n 1` ${yearly_path}
            mv `find . -type f -print0  | xargs -0 ls "${weekly_path}" | head -n 1` ${monthly_path}
            mv `find . -type f -print0  | xargs -0 ls "${daily_path}" | head -n 1` ${weekly_path}
            
        else
            mv `find . -type f -print0  | xargs -0 ls "${weekly_path}" | head -n 1` ${monthly_path}
            mv `find . -type f -print0  | xargs -0 ls "${daily_path}" | head -n 1` ${weekly_path}
        fi
    else
        mv `find . -type f -print0  | xargs -0 ls "${daily_path}" | head -n 1` ${weekly_path}
    fi
fi

#take a dump and place it in the daily backup folder

HOSTNAME=127.0.0.1
DATABASE=test1
PORT=5432

# Note that we are setting the password to a global environment variable temporarily.
echo "Pulling Database: This may take a few minutes"
#export PGPASSWORD="$PASSWORD"
filename="$(date +%Y-%m-%d-%s).bakup"
pg_dump -Fc -Z9 -w -h $HOSTNAME -d $DATABASE -p ${PORT} > ${daily_path}${filename}
#unset PGPASSWORD
gzip ${daily_path}${filename}
echo "Pull Complete"

cd /home/postgres_user/backups;for d in `ls /home/postgres_user/backups`; do echo $d;ls -lah $d; done

# #ping machines
# for connection_string in ${machines}:
#     ping -c 1 ${connection_string}
#     if [[ "$?" -eq "0" ]] 
#     then
#         scp ${filename} ${copy_user}@${connection_string}:${user_path}/${filename}
#     fi
# done






HOSTNAME=127.0.0.1
DATABASE=test1
PORT=5432

# Note that we are setting the password to a global environment variable temporarily.
echo "Pulling Database: This may take a few minutes"
#export PGPASSWORD="$PASSWORD"
filename="$(date +%Y-%m-%d).bakup"
pg_dump -Fc -Z9 -w -h $HOSTNAME -d $DATABASE -p ${PORT} > ${filename}
gzip ${filename}