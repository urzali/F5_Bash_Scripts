>/var/tmp/bigiqscheduled_backup.ucs
>/var/tmp/failedbackups

chmod 744 /app/tmp/bigiqscheduled_backup.ucs

firstday="$(date '+%d')"
fulldate="$(date +'%m-%d')"
dayoweek="$(date +'%A')"

HOSTS=“LBNODE1 LBNODE2 LBNODE3 LBNODE4 LBNODE5 LBNODE6”


for HOSTNAME in ${HOSTS} ; do
  if ssh root@${HOSTNAME} [ $? -eq 0 ];
    then
        ssh root@${HOSTNAME} "tmsh save sys ucs cs_backup.ucs; tar -czpf /var/tmp/${HOSTNAME}_tar_gz -P /var/log/*"
    else
        echo "Unable to ssh to ${HOSTNAME}. Config not backed up" | mail -s "Error" myemail@domain.com
        continue
  fi
  
rsync -rv root@${HOSTNAME}:/var/local/ucs/cs_backup.ucs /app/tmp/bigiqscheduled_backup.ucs
rsync -rv root@${HOSTNAME}:/var/tmp/${HOSTNAME}_tar_gz /app/f5_logfiles/${HOSTNAME}_${dayoweek}_logfile.tar.gz

        if [ $firstday == 01 ]
                then
                        cp /app/tmp/bigiqscheduled_backup.ucs /app/ucs/${HOSTNAME}_${fulldate}_MonthlyBackup.ucs
                                                        cp /app/ucs/${HOSTNAME}_${fulldate}_MonthlyBackup.ucs /app/f5config/${HOSTNAME}_${fulldate}_MonthlyBackup.ucs.tar.gz
                                                        cd /app/f5config
                                                        tar -xzf /app/f5config/${HOSTNAME}_${fulldate}_MonthlyBackup.ucs.tar.gz config
                                                                if [ -d "/app/f5config/${HOSTNAME}_${fulldate}_Config" ]; then
                                                                        rm -rf /app/f5config/${HOSTNAME}_${fulldate}_Config
                                                                fi
                                                        mv /app/f5config/config /app/f5config/${HOSTNAME}_${fulldate}_Config
                                                        rm -f /app/f5config/${HOSTNAME}_${fulldate}_MonthlyBackup.ucs.tar.gz
                        echo "" > /app/tmp/bigiqscheduled_backup.ucs

              if [ $(stat -c %s /app/ucs/${HOSTNAME}_${fulldate}_MonthlyBackup.ucs) = 1 ];
                then
                   echo "Backup for ${HOSTNAME} Failed" >> /var/tmp/failedbackups
                   rm -rf /app/ucs/${HOSTNAME}_${fulldate}_MonthlyBackup.ucs
              fi


        else
                        cp /app/tmp/bigiqscheduled_backup.ucs /app/ucs/${HOSTNAME}_${dayoweek}_backup.ucs
                                                        cp /app/ucs/${HOSTNAME}_${dayoweek}_backup.ucs /app/f5config/${HOSTNAME}_${dayoweek}_backup.ucs.tar.gz
                                                        cd /app/f5config
                                                        tar -xzf /app/f5config/${HOSTNAME}_${dayoweek}_backup.ucs.tar.gz config
                                                                if [ -d "/app/f5config/${HOSTNAME}_${dayoweek}_Config" ]; then
                                                                        rm -rf /app/f5config/${HOSTNAME}_${dayoweek}_Config
                                                                fi
                                                        mv /app/f5config/config /app/f5config/${HOSTNAME}_${dayoweek}_Config
                                                        rm -f /app/f5config/${HOSTNAME}_${dayoweek}_backup.ucs.tar.gz
                        echo "" > /app/tmp/bigiqscheduled_backup.ucs
              if [ $(stat -c %s /app/ucs/${HOSTNAME}_${dayoweek}_backup.ucs) = 1 ];
                then
                   echo "Backup for ${HOSTNAME} Failed" >> /var/tmp/failedbackups
                   rm -rf /app/ucs/${HOSTNAME}_${dayoweek}_backup.ucs
              fi

        fi
done

for HOSTNAME in ${HOSTS} ; do
  if ssh root@${HOSTNAME} [ $? -eq 0 ];
    then
        ssh root@${HOSTNAME} "rm -f /var/local/ucs/scheduled_backup.ucs; rm -f /var/tmp/${HOSTNAME}_tar_gz"
  fi
done

echo "Backed up $(find /app/ucs -maxdepth 1 -mmin -180 -type f | wc -l) Devices. Total Hosts are 6” | mail -s "Backup Completed" -r 'F5Backup <reports@f5backups.domain.com>' groupemail@domain.com

if [ -s /var/tmp/failedbackups ]
then
mail -s "Failed Backup Report" -r 'F5Backup <reports@f5backups.domain.com>' groupemail@domain.com < /var/tmp/failedbackups
fi
