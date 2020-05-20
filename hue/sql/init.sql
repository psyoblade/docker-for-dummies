create database hue default character set utf8 default collate utf8_general_ci;
create user 'hue'@'%' identified by '<password>';
gran all privileges on hue.* to 'hue'@'%';
flush privileges;
