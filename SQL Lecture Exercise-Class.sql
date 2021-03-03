################### Kindly run these queries first ################################
ALTER TABLE ecohort_sql.transactional_sales_filtered add COLUMN new_date DATE;

set sql_safe_updates=0;

UPDATE ecohort_sql.transactional_sales_filtered SET new_date = STR_TO_DATE(date,'%d-%m-%Y') WHERE substring(date,3,1) = '-';
UPDATE ecohort_sql.transactional_sales_filtered SET new_date = STR_TO_DATE(date,'%d/%m/%Y') WHERE substring(date,2,1) = '/';
UPDATE ecohort_sql.transactional_sales_filtered SET new_date = STR_TO_DATE(date,'%d/%m/%Y') WHERE substring(date,3,1) = '/';
UPDATE ecohort_sql.transactional_sales_filtered SET new_date = STR_TO_DATE(date,'%Y/%m/%d') WHERE substring(date,4,1) = '-';


################################ 1- select ##################################
SELECT * FROM ecohort_sql.masterdata_branch;
SELECT * FROM ecohort_sql.masterdata_customer;
SELECT * FROM ecohort_sql.masterdata_product;
SELECT * FROM ecohort_sql.masterdata_salesman;
SELECT * FROM ecohort_sql.transactional_sales_filtered;

################################ 2- Where, Between, And ##################################
SELECT * FROM ecohort_sql.transactional_sales_filtered where new_date between '2016-05-11' and '2016-05-31';

SELECT * FROM ecohort_sql.transactional_sales_filtered where new_date >'2016-05-10' and month(new_date)=5;

SELECT * FROM ecohort_sql.transactional_sales_filtered where day(new_date) >10 and month(new_date)=5;

################################ 3- Order by, Limit ##################################
Select * FROM ecohort_sql.masterdata_salesman order by rvs asc;

SELECT * FROM ecohort_sql.transactional_sales_filtered order by new_date desc limit 15;

################################ 4- Max, Min, Avg, Alias, Is, Null, Not ##################################
Select max(Sales),min(Sales), avg(Sales) FROM ecohort_sql.transactional_sales_filtered where Sales is not null;

Select max(Sales) as Max_Sale, min(Sales) as Min_Sale, avg(Sales) as Avg_Sale FROM ecohort_sql.transactional_sales_filtered where Sales is not null;

######### 4-a- Retrieve the 2nd highest sales value  #########
SELECT MAX(Sales) AS max_sales
FROM ecohort_sql.transactional_sales_filtered
WHERE Sales <(SELECT MAX(Sales) AS max_sales
FROM ecohort_sql.transactional_sales_filtered);

SELECT MAX(Sales) AS max_sales
FROM ecohort_sql.transactional_sales_filtered
WHERE Sales not in (SELECT MAX(Sales) 
FROM ecohort_sql.transactional_sales_filtered);

################################ 5- Sub Query, In, Distinct ##################################
Select * from ecohort_sql.transactional_sales_filtered where 
Sales_Office in (2100,2200,2502);

select  Sales_Office from ecohort_sql.masterdata_branch where Branch_Name in ('Makkah','Jeddah','Medinah');

Select * from ecohort_sql.transactional_sales_filtered where 
Sales_Office in (select distinct Sales_Office from ecohort_sql.masterdata_branch where Branch_Name in ('Makkah','Jeddah','Medinah'));

################################ 6- Like, % ##################################
SELECT * FROM ecohort_sql.masterdata_product where Product not like '%FD%';
SELECT * FROM ecohort_sql.masterdata_product where Product  like '%FD%';

################################ 7- OR, Substring ##################################

SELECT * FROM ecohort_sql.masterdata_product where Product like '%FD%' OR substr(BU,4,1) < 2;

################################ 8- Group by ##################################
select date(new_date),Product_ID,Sales_Office, count(*) as Transactions from ecohort_sql.transactional_sales_filtered group by 1,2,3;

Select date(new_date),count(*) as Transactions from 
ecohort_sql.transactional_sales_filtered group by 1 having Transactions >100;

Select date(date),Product_ID,count(*) as Transactions from ecohort_sql.transactional_sales_filtered group by 1,2;

################################ 9- Having ##################################
Select date(new_date),count(*) as Transactions from ecohort_sql.transactional_sales_filtered group by date(new_date) having Transactions >100;

################################ 10- Roll Up ##################################
Select date(new_date),round(avg(Sales),2) as RPT from ecohort_sql.transactional_sales_filtered
where month(new_date)=5 group by 1 with rollup;

################################ 11- Joins ###################################

################# 11-a- Left Join #####################
Select a.*,b.Branch_Name  from ecohort_sql.transactional_sales_filtered as a left join
ecohort_sql.masterdata_branch as b on a.Sales_office=b.Sales_office;

################# 11-b- Right Join #####################
Select a.*,b.Customer_Name  from ecohort_sql.masterdata_customer as b right join
ecohort_sql.transactional_sales_filtered as a
on a.Customer=b.Customer;

################# 11-c- Inner Join ##################### 
Select a.*,b.Product  from ecohort_sql.transactional_sales_filtered as a inner join
ecohort_sql.masterdata_product as b on a.Product_ID=b.Product_Code;

/**
################# 11-d- Cross Join ##################### 
Select a.*,b.RVS_Name from ecohort_sql.transactional_sales_filtered a cross join
ecohort_sql.masterdata_salesman b;
**/

/**
################# 11-d- Self Join ##################### 
Explian it to the class
**/

################################ 12- Creating Colummn ##################################

ALTER TABLE ecohort_sql.transactional_sales_filtered add COLUMN on_off_flag int;

#ALTER TABLE ecohort_sql.transactional_sales_filtered add COLUMN new_date Date;
################################ 13- Updating Colummn ##################################
set sql_safe_updates=0;

UPDATE ecohort_sql.transactional_sales_filtered SET on_off_flag = 0 WHERE day(new_date) % 2 = 0;

UPDATE ecohort_sql.transactional_sales_filtered SET on_off_flag = 1 WHERE day(new_date) % 2 <> 0;

/**
UPDATE ecohort_sql.transactional_sales_filtered SET new_date = STR_TO_DATE(date,'%d-%m-%Y') 
WHERE substring(date,3,1) = '-';
UPDATE ecohort_sql.transactional_sales_filtered SET new_date = STR_TO_DATE(date,'%d/%m/%Y') 
WHERE substring(date,2,1) = '/';
UPDATE ecohort_sql.transactional_sales_filtered SET new_date = STR_TO_DATE(date,'%Y/%m/%d') 
WHERE substring(date,4,1) = '-';
**/
################################ 14- Droping Colummn ##################################

ALTER TABLE ecohort_sql.transactional_sales_filtered DROP COLUMN Date_sales;
ALTER TABLE ecohort_sql.transactional_sales_filtered DROP COLUMN Date;

################################ 15- Temporary Table for April and May separately ##################################
Create database tempdb;

######## April ########
drop temporary table if exists tempdb.april;
create temporary table tempdb.april
Select * from ecohort_sql.transactional_sales_filtered where 
month(new_date)=4;

######### May #########
drop temporary table if exists tempdb.may;
create temporary table tempdb.may
Select * from ecohort_sql.transactional_sales_filtered where 
month(new_date)=5 ;

################################ 16- Transaction count per day for april and may separately  ##################################

######## April_daywise_count ########

Select date(new_date),count(distinct Invoice_ID) as Transactions from tempdb.april group by 1;


######### May_daywise_count #########

Select date(new_date),count(distinct Invoice_ID) as Transactions from tempdb.may  group by 1;


################################ 17- Joined all tables with transaction table ################################

drop temporary table if exists tempdb.joined;
create temporary table tempdb.joined
Select a.*,b.Branch_Name,c.Customer_Name, d.Product ,e.RVS_NAME from ecohort_sql.transactional_sales_filtered a 
left join ecohort_sql.masterdata_branch b on a.Sales_office=b.Sales_office
left join masterdata_customer c on a.Customer=c.Customer
left join ecohort_sql.masterdata_product d on a.Product_ID=d.Product_Code
left join ecohort_sql.masterdata_salesman e on a.RVS=e.RVS;

Select * from tempdb.joined;

################################ 18- April and May Transactions per Product  ################################

Select Product,count(distinct Invoice_ID) as Transactions from tempdb.joined where 
month(new_date)=4 group by 1;

Select Product,count(distinct Invoice_ID) as Transactions from tempdb.joined where 
month(new_date)=5 group by 1;

################################ 19- Salesman making Sales in April or May not in both  ################################

drop temporary table if exists tempdb.aprilonly;
Create temporary table tempdb.aprilonly
select * from tempdb.april where rvs not in (select distinct rvs from tempdb.may);

drop temporary table if exists tempdb.mayonly;
Create temporary table tempdb.mayonly
select * from tempdb.may where rvs not in (select distinct rvs from tempdb.april);

drop temporary table if exists tempdb.aprilormay;
Create temporary table tempdb.aprilormay
select * from tempdb.aprilonly union select * from tempdb.mayonly;

Select Distinct RVS, count(Distinct Invoice_ID) as Total_Transactions from tempdb.aprilormay 
group by RVS  Having Total_Transactions>15 order by Total_Transactions asc;


################################ 20- Case Statements  ################################
Select Branch_name ,
sum(case when sales>4000 then 1 else 0 end)*100/count(distinct Invoice_ID) as High_Potential_Cust,
sum(case when Sales >1000 and Sales<=4000 then 1 else 0 end)*100/count(distinct Invoice_ID) as Medium_Potential_Cust,
sum(case when Sales <=1000  then 1 else 0 end)*100/count(distinct Invoice_ID) as Low_Potential_Cust
from tempdb.joined group by branch_name;


