#!/bin/bash
# This file is part of the rsyslog project, released under ASL 2.0
echo ===============================================================================
echo \[mysql-act-mt.sh\]: test for mysql with multithread actionq
source $srcdir/diag.sh init
mysql --user=rsyslog --password=testbench < testsuites/mysql-truncate.sql
source $srcdir/diag.sh startup mysql-actq-mt-withpause-extended.conf


let "strtnum = 0"
for i in {1..50}
do
   echo "running iteration $i, startnum: $strtnum"
   source $srcdir/diag.sh injectmsg  $strtnum 5000
   source $srcdir/diag.sh wait-queueempty 
   echo waiting for worker threads to timeout
   ./msleep 1000
   let "strtnum = strtnum+5000"
done


source $srcdir/diag.sh shutdown-when-empty
source $srcdir/diag.sh wait-shutdown 
# note "-s" is requried to suppress the select "field header"
mysql -s --user=rsyslog --password=testbench < testsuites/mysql-select-msg.sql > rsyslog.out.log
source $srcdir/diag.sh seq-check  0 249999
source $srcdir/diag.sh exit
