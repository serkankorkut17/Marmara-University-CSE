
--############### INDEXES ###############---

EXEC sp_helpindex 'EMPLOYEE'

SELECT *
FROM EMPLOYEE WITH(INDEX(name_asc))

EXEC sp_helpindex 'DEPARTMENT'

SELECT *
FROM DEPARTMENT WITH(INDEX(manager_list))

EXEC sp_helpindex 'ITEM'
EXEC sp_helpindex 'UPS_PRODUCT'
EXEC sp_helpindex 'THREE_ONE_PHASE'
EXEC sp_helpindex 'CUSTOMER_ORDER'
GO

--############### COMPUTED COLUMN ###############---
select schema_name(o.schema_id) as schema_name,
       object_name(c.object_id) as table_name,
       column_id,
       c.name as column_name,
       type_name(user_type_id) as data_type,
       definition
from sys.computed_columns c
join sys.objects o on o.object_id = c.object_id
order by schema_name,
         table_name,
         column_id;

--############### CONSTRAINT TABLE ###############---

SELECT OBJECT_NAME(object_id) AS ConstraintName,
SCHEMA_NAME(schema_id) AS SchemaName,
OBJECT_NAME(parent_object_id) AS TableName,
type_desc AS ConstraintType
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT' and OBJECT_NAME(parent_object_id) NOT LIKE '%auth%' 
and  OBJECT_NAME(parent_object_id) NOT LIKE '%django%'
 
 
 --################## VIEWS ######################--
/*
Gives information about how many 
employee exist in;his/her departmant
includes more than 2 people and his/her 
seniority is greater than 10.
*/
select * from BlueCollar_Department_Seniority

/*
Gives statistic about employee payment on a 
department basis.
*/
select * from Department_Payment_Statistic

 /*
Gives detailed information about 
customer order.Addition to that 
it calculates total payment with using
quantatiy and item price.
 */
select * from Detailed_Customer_Order

/* gives detailed information about the managers */
select * from Manager_Details

 /*
Gives total payment info for each supplier company.
Addition to that it calculates total item count taken
from each supplier company and payment per item.
 */
select * from SupplierCompany_Payment

/*
Gives statistic about all type of ups
product in factory (1-1,3-1,3-3)
*/
select * from Ups_ProducType_Price_Statistic

--################## PROCEDURES ######################--

/*STORED PROCEDURE 1 - sp_AddNewProduct*/

exec sp_AddNewProduct '999', 'newufgýgý', 9999, 'C', 'On-Liner', 'RS-999','1-1', 55

/*STORED PROCEDURE 2 - sp_AddingProductToStock*/

exec sp_AddingProductToStock '2940035696', '1101', 50, '2022-12-24'

/*STORED PROCEDURE 3 - sp_AddEmployee*/

exec sp_AddEmployee '999-99-999', 'John', 'Doe', 'somewhere', '1985-05-15', 'M', '999-999-9999', '1/1/2021', 20000, 'B', 1;


/*STORED PROCEDURE 4 - sp_OrderProduct*/

exec sp_OrderProduct '150119036', 1101, 'Information about purchase', 55, '2022-12-25'

/*STORED PROCEDURE 5 - sp_UpdateSalary*/

exec sp_UpdateSalary

/*STORED PROCEDURE 6 - sp_DeleteEmployee*/

exec sp_DeleteEmployee '999-99-999'






