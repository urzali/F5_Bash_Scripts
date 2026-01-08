>/var/tmp/BIGIQcertreport
>/var/tmp/certreportexp
>/var/tmp/Upcoming_Expiring_certreport
>/var/tmp/Prod_Expiring_certreport
# >/var/tmp/NonProd_Expiring_certreport

echo -e "\nHOSTNAME     |               CERTIFICATE NAME\n" > /var/tmp/BIGIQcertreport2
chmod 744 /var/tmp/certreportexp
HOSTS="REMOTE_HOST2 REMOTE_HOST4 REMOTE_HOST6 REMOTE_HOST8 REMOTE_HOST10 "
for HOSTNAME in ${HOSTS} ; do
  if ssh root@${HOSTNAME} [ $? -eq 0 ];
    then
        ssh root@${HOSTNAME} "tmsh run sys crypto check-cert" > /var/tmp/certreportexp
sed -e "s/CN=/$HOSTNAME, /g" /var/tmp/certreportexp | grep -v ca-bundle > /var/tmp/certreportexp2
                if diff /var/tmp/certreportexp /var/tmp/certreportexp2 >/dev/null ;
                        then
                        echo "No Output in ${HOSTNAME} Cert-Check Command" | mail -s "No Output in ${HOSTNAME} Cert-Check" youremailaddress@domain.com
                fi
        cat /var/tmp/certreportexp2 >> /var/tmp/BIGIQcertreport
    else
        echo "Unable to ssh to ${HOSTNAME}" | mail -s "Error" youremailaddress@domain.com
  fi
done

// Script is Run on Standby Units only
// Below command replaces device names so we can show both Active and Standby Units in our email notifications
sed -e "s/HOST2/HOST1\/02/g" -e "s/HOST4/HOST3\/4/g" -e "s/HOST6/HOST5\/6/g" -e "s/HOST8/HOST7\/8/g" -e "s/HOST10/HOST9\/10/g"

grep 'will expire' /var/tmp/BIGIQcertreport2 > /var/tmp/Upcoming_Expiring_certreport

// In below command, Find lines that have Prod Load Blancers
// Note: Searching REMOTE_HOST1 instead of REMOTE_HOST2 because we replaced REMOTE_HOST2 with REMOTE_HOST1/2 in sed command above
grep -E 'REMOTE_HOST1|REMOTE_HOST3|REMOTE_HOST5' /var/tmp/Upcoming_Expiring_certreport > /var/tmp/Prod_Expiring_certreport

// In below command, Find lines that have Prod Load Blancers
grep -E 'REMOTE_HOST7|REMOTE_HOST9' /var/tmp/Upcoming_Expiring_certreport > /var/tmp/NonProd_Expiring_certreport

sed '/GMT/ a -' /var/tmp/Prod_Expiring_certreport >  /var/tmp/Prod_Expiring_certreport2

sed '/GMT/ a -' /var/tmp/NonProd_Expiring_certreport >  /var/tmp/NonProd_Expiring_certreport2

if [ $(wc -l < "$/var/tmp/Prod_Expiring_certreport2") -eq 0 ]; then
    echo "No Prod Cert expiring in next 30 days" > /var/tmp/Prod_Expiring_certreport2
fi

if [ $(wc -l < "$/var/tmp/NonProd_Expiring_certreport2") -eq 0 ]; then
    echo "No Non Prod Cert expiring in next 30 days" > /var/tmp/NonProd_Expiring_certreport2
fi

mail -s "Non Prod Expiring Certificates" -r 'F5 Certs <reports@f5backups.domain.com>' teamemailadd@domain.com < /var/tmp/NonProd_Expiring_certreport2
mail -s "Prod Expiring Certificates" -r 'F5 Certs <reports@f5backups.domain.com>' teamemailadd@domain.com < /var/tmp/Prod_Expiring_certreport2

rm -f /var/tmp/*certreport*
