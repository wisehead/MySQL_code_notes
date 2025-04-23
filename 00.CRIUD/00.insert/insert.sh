#############################################################
#   File Name: insert.sh
#     Autohor: Hui Chen (c) 2025
#        Mail: alex.chenhui@gmail.com
# Create Time: 2025/04/23-17:13:08
#############################################################
#!/bin/sh 
create database test;
use test;
create table t1(id int NOT NULL, name varchar(50) NOT NULL);
insert t1 values(1,'aaa');
