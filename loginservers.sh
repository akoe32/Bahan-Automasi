#!/bin/bash
## @ygemici unix.com last logins check script

# # # # # # # # # # # # # # # # #
# ./loginusers.sh notlogins 90  #
# ./loginusers.sh logins 90     #
# ./loginusers.sh username 90   #
# ./loginusers.sh 90            #
# # # # # # # # # # # # # # # # #

calldates() {
daysago=$(date -d "-$day days" +'%Y%m%d%H%M%S')
#lastyearstart=$(last|awk 'END{print $NF}')
validyear=$(date -d "-$day days" +'%Y')
}

writeerror() {
echo "Last Login information for '$1' could [not found] for $day days"
}

writelogin() {
nowepochtime=$(date +%s)
diff=$((nowepochtime-lastlgepochtime))
awk -vuser=$user 'BEGIN{printf "\n%20s\n",user}' ; awk 'BEGIN{$55=OFS="=";printf "%s\n",$0}'
awk -vdatex="$(date -d @${lastlgepochtime})" 'BEGIN{printf "%s%30s\n","Last Login Date -> ", datex}'
awk -vdiff=$diff 'BEGIN{printf "%20s%s\n%20s%s\n%20s%s\n%20s%s\n","Elapsed Times (Days): ",diff/60/60/24,"Elapsed Times (Hours): ",diff/60/60,"Elapsed Times
(Minutes): ",diff/60,"Elapsed Times (Seconds): ",diff}'
awk 'BEGIN{$55=OFS="=";print $0"\n"}'
}

calloldwtmp() {
lastlogf=$(ls -lt /var/log/wtmp*|awk 'END{print $NF}')
lasttyear=$(last -f $lastlogf|awk 'END{print $NF}')
}

calllastlogin() {
#lmonth=$(awk -vmonth=$lastmonthstart 'BEGIN{split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec",month," ");for(i=1;i<=12;i++)if(month[i]~month)print i}'

calloldwtmp

for((i=$lasttyear;i<$validyear;i++)) ; do
lastlogl=$(last -t ${i}1231235959 -1 $user -f /var/log/wtmp*|awk 'NR==1')
j=$((i+1)) ; lastlogf=$(last -t ${j}1231235959 -1 $user -f /var/log/wtmp*|awk 'NR==1')

if [ "$lastlogl" == "$lastlogf" ] ; then
validyearnew=$i
else
validyearnew=$validyear
fi
done
lastlogin=$(last -1 $user -f /var/log/wtmp*|awk -vy=$validyearnew 'NR==1&&NF{print $5,$6,",",y,$7":01"}')
if [ -z "$lastlogin" ] ; then
 if [ "$1" = "notlogins" ] || [ "$1" = "$user" ] || [ -z "$1" ] ; then
 writeerror $user
 fi
else
 lastlgepochtime=$(date +%s -d"$lastlogin")
 wantedepochtime=$(date +%s -d"-$day days")
 if [ $((lastlgepochtime)) -lt $((wantedepochtime)) ] ; then
 echo "Last Login time is long from period ['$day'] of days ago for [$user] user"
 else
 if [ "$1" = "logins" ] || [ "$1" = "$user" ] || [ -z "$1" ] ; then
 writelogin $user
 fi
 fi
fi
}

calllastloginall() {
awk -F':' '$NF!~/nologin/{print $1}' $passwd | while read -r user ; do
if [ -z "$1" ] ; then
calllastlogin
else
calllastlogin $1
fi
done
}

checkuser() {
if [ "$1" != "notlogins" ] && [ "$1" != "logins" ] ; then
grep $1 $passwd 2>&1 >/dev/null
if [ $? -ne 0 ] ; then
echo "Username is seem invalid!!" ; exit 1
fi
else
awk -vn=$1 'BEGIN{printf "%30s\n",n}'
echo|awk 'BEGIN{printf "%15c","-";for(i=1;i<=25;i++)printf "%c","-"}END{printf "%s","\n"}'
fi
}

callfunc() {
case $1 in
 notlogins) calllastloginall notlogins ;;
 logins)  calllastloginall logins ;;
 *) user=$1 ; calllastlogin $user ;;
esac
}

numcheckandset() {
numcheck=$(echo|awk -va=$1 '{print a+=0}')
if [ $numcheck -eq 0 ] ; then echo "where is the period of day ? " ; exit 1 ; fi
passwd='/etc/passwd'
calldates
}

case $# in
 2) day=$2 ; numcheckandset $day ; checkuser $1 ; callfunc $1 ;;
 1) day=$1 ; numcheckandset $day ; calllastloginall ;;
 *) exit 1 ;;
esac
