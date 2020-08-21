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

daily_retention_count="7"
weekly_retention_count="4"
monthly_retention_count="12"
yearly_retention_count="1"

dump_path="/var/backups/postgres_dumps/"
daily_path="${dump_path}daily/"
weekly_path="${dump_path}weekly/"
monthly_path="${dump_path}monthly/"
yearly_path="${dump_path}yearly/"

daily_files=$(ls ${daily_path} -c)
count_of_daily=$(ls -1q  ${daily_path} | wc -l)
echo $files
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
            else
                mv "${monthly_path}${monthly_files}"[${count_of_monthly}-1] ${yearly_path}
                mv "${weekly_path}${weekly_files}"[${count_of_weekly}-1] ${monthly_path}
                mv "${daily_path}${daily_files}"[${count_of_daily}-1] ${weekly_path}
            fi
        else
            mv "${weekly_path}${weekly_files}"[${count_of_weekly}-1] ${monthly_path}
            mv "${daily_path}${daily_files}"[${count_of_daily}-1] ${weekly_path}
        fi
    else
        mv "${daily_path}${daily_files}"[${count_of_daily}-1] ${weekly_path}
    fi
fi

#take a dump and place it in the daily backup folder