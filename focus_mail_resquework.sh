cd /home/work/focus_mail
nohup rake resque:work RAILS_ENV=development VERBOSE=1 QUEUES=* &
nohup rake resque:scheduler &
