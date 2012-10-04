/usr/local/redis/redis-server /etc/redis/redis.conf
cd /home/work/focus_mail/
passenger start -d -e production -p 80 --user webmail
su - webmail -c /home/work/focus_mail_resquework.sh
