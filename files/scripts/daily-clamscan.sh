#!/bin/bash
LOGFILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d-%H-%M').log";
EMAIL_MSG="Please see the log file attached";
EMAIL_FROM="email@domain.com.br";
EMAIL_TO="email@domain.com.br";
DIRTOSCAN="/etc /home /opt /root /tmp /var";
EXCLUDEDIR="/var/lib/docker/";
 
echo "..."
echo "....."
echo "........"
echo "Starting ClamAV Database update process..."
echo
freshclam
echo
echo "Database update process finished!"
echo "........"
echo "....."
echo "..."
  
for S in ${DIRTOSCAN}; do
 DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);
  
 echo "Starting scan of "$S" directory.
 Directory size: "$DIRSIZE".";
  
 echo "----------- SCANNING "$S" -----------" >> "$LOGFILE";
 clamscan -ri "$S" --exclude-dir="$EXCLUDEDIR" --exclude-dir="/var/lib/clamav/" --exclude-dir="/var/log/clamav/" >> "$LOGFILE";
 echo " " >> "$LOGFILE";
 echo " " >> "$LOGFILE";
  
 MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);
  
 if [ "$MALWARE" -ne "0" ];then
 echo "$EMAIL_MSG"|mail -a "$LOGFILE" -s "MALWARE FOUND - $HOSTNAME" -r "$EMAIL_FROM" "$EMAIL_TO";
 fi
done
 
echo "Daily Scan Finished!"
 
find /var/log/clamav/ -type f -mtime +30 -exec rm {} \;
  
exit 0