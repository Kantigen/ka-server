create database keno;
create user 'keno'@'%' identified by 'keno';
grant all privileges on keno.* to 'keno'@'%';
flush privileges;


