
tee /home/mysql/scripts/mysql_nomysqldb_backup.sh <<-'EOF'


#!/bin/bash

##   mkdir /home/mysql/scripts/
##   mkdir /home/mysql/backup_result/


PRE="11.11.11.11_"
nowday=$(date +%Y"-"%m"-"%d)
threeday_ago=$(date +%Y"-"%m"-"%d --date '2 days ago')
fourday_ago=$(date +%Y"-"%m"-"%d --date '3 days ago')

USER="backuser1"
PASSWORD="111111"
MYSQLDUMP="/usr/local/mysql/bin/mysqldump"
MYSQL="/usr/local/mysql/bin/mysql"
HOST="127.0.0.1"
PORT="3306"
SOCKET="/var/lib/mysqldb/run/mysql.sock"
BACKUPDIR="/home/mysql/backup_result/"
FILE1="$BACKUPDIR/inner_tmp_NoMyslDB.txt"
strB="the_schema_name"

LOG_FILE="$BACKUPDIR/backup_log.lst"

    
    echo "Start DUMP $(date +%Y%m%d_%H:%M:%S) No mysql DB" >> $LOG_FILE

    rm -f  $FILE1
    result=$( $MYSQL  -u$USER -p$PASSWORD  -h$HOST   -P$PORT  -S$SOCKET      -e "select t.SCHEMA_NAME the_schema_name  from information_schema.SCHEMATA t   where t.SCHEMA_NAME not in('information_schema','sys','performance_schema','mysql' )")
          tmp=$(echo $result  )
         for tmp_line in $tmp
    do
        if  [[ $tmp_line = $strB ]];   then
            echo 1
        else
            result2=$tmp_line
            echo $result2  >>   $FILE1
        fi
    done
     
    cat  $FILE1 | while read line
    do
       a=$line
       $MYSQLDUMP  -u$USER -p$PASSWORD  -h$HOST   -P$PORT  -S$SOCKET   --single-transaction  --master-data=2    --routines  --triggers  --events  --flush-logs  --set-gtid-purged=OFF  -B   $a      >  $BACKUPDIR/${PRE}_${nowday}_$a.sql 
     done
    
    cd  $BACKUPDIR
    zip  ${PRE}_${nowday}_nomysqldb.zip   ${PRE}_${nowday}_*.sql
    rm -f ${PRE}_${nowday}_*.sql
    
echo "------------ End Backup   $(date +%Y%m%d_%H:%M:%S)  No mysql DB " >>  $LOG_FILE 
     
     
cd  $BACKUPDIR
rm  *$threeday_ago*
rm  *$fourday_ago*

echo " Delete  over  $(date +%Y%m%d_%H:%M:%S) " >> $LOG_FILE 
echo "Done "   >> $LOG_FILE


EOF

