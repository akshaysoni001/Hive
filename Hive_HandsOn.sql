alias hd="hdfs dfs" -To create alias of hdfs dfs
hdfs dfs -df / -Shows available space
hdfs dfs -df -h / -Show available space in GBs
hdfs dfs -count /
hdfs dfs -count /<Path> -Count of files and dirs
hdfs fsck /<Path> -Health chkup
hdfs dfs -cat /Einstein/gaur.txt -To check the contents inside a file
hdfs dfs -copyToLocal /Einstein/gaur.txt -Copy to local machine from cluster
-copyFromLocal   <Path> -Copy from local to cluster
-moveToLocal -Move file to local machine
-moveFromLocal -Move from local machine to cluster
hdfs dfs -cp <SPath> <DPath> -To copy the file within the cluster dirs
hdfs dfs -mv <SPath> <DPath> -To move the file within the cluster dirs

sqoop import --connect jdbc:mysql://localhost:3306/temp --username root --password cloudera --table emp --m 1
sqoop import --connect jdbc:mysql://localhost:3306/temp --username root --password cloudera --table emp --target-dir /vikas --m 1
sqoop import-all-tables --connect jdbc:mysql://localhost:3306/temp --username root --password cloudera --warehouse-dir /empWarehouse --m 2
sqoop import-all-tables --connect jdbc:mysql://localhost:3306/temp --username root --password cloudera --exclude-tables emp,emp_add --warehouse-dir /emp3Warehouse --m 1


SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE '/home/cloudera/Desktop/scoop/emp.csv' INTO TABLE emp FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/home/cloudera/Desktop/scoop/emp_add.csv' INTO TABLE emp_add FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;
LOAD DATA LOCAL INFILE '/home/cloudera/Desktop/scoop/emp_contact.csv' INTO TABLE emp_contact FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;


sqoop export --connect jdbc:mysql://localhost:3306/temp_emp --username root --password cloudera --table emp --export-dir emp --m 1

CREATE DATABASE temp_emp;
use temp_emp;
CREATE TABLE emp(id int PRIMARY KEY, name varchar(150),deg varchar(20),salary int(11),dept varchar(10));


sqoop import-all-tables --connect jdbc:mysql://localhost:3306/bank --username root --password cloudera --warehouse-dir /bankWarehouse --m 1


beeline -u jdbc:hive2:// - beeline login



1,iphone,379.99,mobiles
CREATE TABLE product(id STRING, name STRING, price FLOAT, category string) row format delimited fields terminated by ',';
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/products.csv' INTO TABLE product;

CREATE TABLE freshproducts(id STRING, title STRING, price FLOAT) row format delimited fields terminated by ',';
LOAD DATA INPATH '/ScoobyDoo/freshproducts.csv' INTO TABLE freshproducts;


samsungj7, Samsung J7, 250, red#blue#black, 5.5,camera:true#dualsim:false,24 hours#2MP
CREATE TABLE mobiles(id STRING, name STRING, price float, color strin>, screensize float, features string, info STRING) row format delimited fields terminated by ',';
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/mobilephones.csv' INTO TABLE mobiles;

#-----------------
COMPLEX DATA TYPES
#-----------------
#-----------------
ARRAY
#-----------------
CREATE TABLE mobiles1(id STRING, name STRING, price float, color array<string>, screensize float, features array<string>, info STRING) row format delimited fields terminated by ',' collection items terminated by '#';
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/mobilephones.csv' INTO TABLE mobiles1;


#----------
MAP
#----------
CREATE TABLE mobiles2(id STRING, name STRING, price float, color array<string>, screensize float, features map<string, boolean>, info STRING) row format delimited fields terminated by ',' collection items terminated by '#' map keys terminated by ':';
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/mobilephones.csv' INTO TABLE mobiles2;


#----------
STRUCT
#----------
CREATE TABLE mobiles3(id STRING, name STRING, price float, color array<string>, screensize float, features map<string, boolean>, info struct<battery:string, camera:string>) row format delimited fields terminated by ',' collection items terminated by '#' map keys terminated by ':';
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/mobilephones.csv' INTO TABLE mobiles3;


select id, color[0] from mobiles3;


#------------------------------------------------------------------
How to reterive values from complex data types
#------------------------------------------------------------------
select id, color[0], features['camera'], info.battery from mobiles3;

select id, color[0], features['camera'] as cameraPresent, info.battery from mobiles3;

select id, color[0], features['camera'] as cameraPresent, info.battery, info.camera from mobiles3;

select explode(color) from mobiles3;

select posexplode(color) from mobiles3;

#-----------------
LATERAL VIEW
#-----------------

select id,variants from mobiles3 lateral view posexplode(color) lv as variants;

select id,pos,variants from mobiles3 lateral view posexplode(color) lv as pos,variants;

+---------------+------+-----------+--+
|      id       | pos  | variants  |
+---------------+------+-----------+--+
| samsungj7     | 0    |  red      |
| samsungj7     | 1    | blue      |
| samsungj7     | 2    | black     |
| oneplusthree  | 0    |  gold     |
| oneplusthree  | 1    | silver    |
+---------------+------+-----------+--+

#-----------------
21-SEPT-2021
#-----------------
01, c1, p1, 1, 379.99, 90210,
CREATE TABLE order(ID BIGINT, category STRING, product STRING, qty BIGINT, price FLOAT, pin STRING) row format delimited fields terminated by ',' ;
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/orders_CA.csv' INTO TABLE order;


#---------------------
#Static Partition
#---------------------

CREATE TABLE orders(ID BIGINT, category STRING, product STRING, qty BIGINT, price FLOAT, pin STRING) partitioned by(state char(2)) row format delimited fields terminated by ',' ;

insert into orders
partition(state= "CA")
values
("01","c1","p1",1,379.99,"90210"),
("02","c2","p2",1,8.99,"90002"),
("03","c33","p100",1,100,"94305"),
("04","c444","p992",1,669,"94304");


insert into orders
partition(state= "WA")
values
("011","c100","p101",1,379.99,"98001"),
("022","c200","p201",1,8.99,"98015"),
("033","c3300","p100",1,100,"98052"),
("044","c4440","p992",1,669,"98052");

LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/orders_CT.csv' INTO TABLE orders partition(state='CT');


CREATE EXTERNAL TABLE orders_ext(ID BIGINT, category STRING, product STRING, qty BIGINT, price FLOAT, pin STRING) partitioned by(state char(2)) row format delimited fields terminated by ',' location '/hivedb/orders' ;
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/orders_CT.csv' INTO TABLE orders_ext partition(state='CT');

ALTER TABLE orders_ext add partition(state='CA');
ALTER TABLE orders_ext add partition(state='CA') location '/hivedb/orders';
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/orders_CA.csv' INTO TABLE orders_ext partition(state='CA');



#-------------------
#Dynamic Partition
#-------------------
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;


CREATE TABLE all_orders_wop(ID BIGINT, category STRING, product STRING, qty BIGINT, price FLOAT, pin STRING, state char(2)) row format delimited fields terminated by ',' ;
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/alldata.csv' INTO TABLE all_orders_wop;

CREATE TABLE all_orders_wp(ID BIGINT, category STRING, product STRING, qty BIGINT, price FLOAT, pin STRING) partitioned by (state char(2)) row format delimited fields terminated by ',' ;
INSERT INTO all_orders_wp partition(state) select * from all_orders_wop partition(state);


CREATE TABLE orders_wp(ID BIGINT, category STRING, product STRING, qty BIGINT, price FLOAT, pin STRING) partitioned by (state char(2)) row format delimited fields terminated by ',' ;
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/alldata.csv' INTO TABLE orders_wp partition(state='CA');

#----------------------
Multi column partition
#----------------------
CREATE TABLE test_orders(ID BIGINT, category STRING, product STRING, qty BIGINT, price FLOAT) partitioned by (state char(2),pin STRING) row format delimited fields terminated by ',' ;
INSERT INTO test_orders partition(state,pin) select * from all_orders_wop partition(state);

CREATE TABLE test_orders_stat(ID BIGINT, category STRING, product STRING, qty BIGINT, price FLOAT,pin STRING) partitioned by (country STRING,state char(2)) row format delimited fields terminated by ',' ;
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/orders_CA.csv' INTO TABLE test_orders_stat partition(country='US',state='CA');
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/orders_karnataka.csv' INTO TABLE test_orders_stat partition(country='IN',state='KT');
#--------------------
#Bucketing
#--------------------

set hive.enforce.bucketing=True;


CREATE TABLE prod_wb(id INT, name STRING, cost double, category STRING) clustered by(id) into 4 buckets row format delimited fields terminated by ',' ;
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/products1.csv' INTO TABLE prod_wb;

select * from prod_wob tablesample(bucket 1 out of 4 on id);


CREATE TABLE prod_without_bkt(id INT, name STRING, cost double, category STRING) row format delimited fields terminated by ',' ;
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/products1.csv' INTO TABLE prod_without_bkt;


CREATE TABLE prod_with_bkt(id INT, name STRING, cost double, category STRING) clustered by(id) into 4 buckets row format delimited fields terminated by ',' ;
insert into prod_with_bkt select * from prod_without_bkt;
select * from prod_with_bkt tablesample(bucket 1 out of 4 on id);


CREATE TABLE prod_wb_test(id INT, name STRING, cost double, category STRING) clustered by(id) into 4 buckets row format delimited fields terminated by ',' ;
LOAD DATA LOCAL INPATH '/vikas/products1.csv' INTO TABLE prod_wb_test;





CREATE EXTERNAL TABLE prod_without_bkt1(id INT, name STRING, cost double, category STRING) row format delimited fields terminated by ',' ;
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/products1.csv' INTO TABLE prod_without_bkt1;


CREATE EXTERNAL TABLE prod_with_bkt1(id INT, name STRING, cost double, category STRING) clustered by(id) into 4 buckets row format delimited fields terminated by ',' ;
insert into prod_with_bkt1 select * from prod_without_bkt1;
select * from prod_with_bkt1 tablesample(bucket 1 out of 4 on id);


CREATE EXTERNAL TABLE prod_with_bkt2(id INT, name STRING, cost double, category STRING) clustered by(id) into 4 buckets row format delimited fields terminated by ',' location '/vikas/prod';
LOAD DATA LOCAL INPATH '/user/hive/warehouse/hivedb.db/prod_without_bkt1/products1.csv' INTO TABLE prod_with_bkt2;


CREATE EXTERNAL TABLE prod_with_bkt3(id INT, name STRING, cost double, category STRING) clustered by(id) into 4 buckets row format delimited fields terminated by ',' location '/vikas/prod';

CREATE EXTERNAL TABLE prod_with_bkt4(id INT, name STRING, cost double, category STRING) clustered by(id) into 5 buckets row format delimited fields terminated by ',' location '/vikas/prod';



CREATE EXTERNAL TABLE prod_with_bkt5(id INT, name STRING, cost double) clustered by(id) into 5 buckets row format delimited fields terminated by ',' location '/vikas/prod';

CREATE EXTERNAL TABLE prod_with_bkt6(id INT, name STRING, cost double, category STRING, hupp STRING) clustered by(id) into 4 buckets row format delimited fields terminated by ',' location '/vikas/prod';



#-----------------------------
#Bucketing and partitioning
#-----------------------------


CREATE TABLE prod_wpb(id INT, name STRING, cost double, category STRING) partitioned by (category STRING) clustered by(id) into 4 buckets row format delimited fields terminated by ',' ;

INSERT INTO prod_wpb select * from prod_without_bkt;


select * from prod_wpb tablesample(bucket 1 out of 4 on id) where category = 'fashion';




#-----------------------------
#Impala
#-----------------------------

impala-shell

CREATE TABLE prod_impala(id INT, name STRING, cost double, category STRING) row format delimited fields terminated by ',' location '/home/cloudera/Desktop/hive/';


hive -login Hive
beeline -u jdbc:hive2:// -login beeline
create table cust(id bigint, name string, address string);
insert into cust values(1234,"Arun","KA");
insert into cust values(1235,"Nihal","KA");
insert into cust values(1235,"Akshay","MP");
insert into cust values(1235,"Yaasir","BI");


insert into cust_ext_2 values(1003,"Trivenu","KA"),
(1004,"Vaibhav","DL"),
(1005,"Saurabh","CG"),
(1006,"Digvijay","MP");


