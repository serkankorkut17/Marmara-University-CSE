
/*
Gives statistic about employee payment on a 
department basis.
*/
CREATE VIEW [blue_collar_salaray_statistic] AS
 Select d.DField,d.Dno, MAX(e.Salary) MaxPayment , MIN(e.Salary) MinPayment, cast(AVG(e.Salary) as decimal(10,2)) AvaragePayment
 From DEPARTMENT d inner join EMPLOYEE e on d.Dno = e.DepartmentNo 
 inner join BLUECOLLAREMPLOYEE b on e.TCKN = b.TCKN
 GROUP BY d.DField,d.Dno

/*
Gives statistic about all type of ups
product in factory (1-1,3-1,3-3)
*/
CREATE VIEW [ups_product_type_statistic] As
 Select u.ProductType, MAX( u.ProductPrice) MaxPrice , MIN(u.ProductPrice) MinPrice, AVG(u.ProductPrice) AvgPrice
 From UPS_PRODUCT u
 Group By u.ProductType

 /*
Gives detailed information about 
customer order.Addition to that 
it calculates total payment with using
quantatiy and item price.
 */
CREATE VIEW [detailed_customer_order] As
 Select c.ContactPersonName as Customer,ups.ProductName,co.DateSold as SoldDate, ups.ProductPrice SingleProductPrice, 
 co.Quantity, (ups.ProductPrice * co.Quantity) AS TotalPayment
 From CUSTOMER_ORDER co left join CUSTOMER c on co.CustomerID = c.CustomerID
 left join UPS_PRODUCT ups on co.ProductID= ups.ProductID

 /*
Gives total payment info for each supplier company.
Addition to that it calculates total item count taken
from each supplier company and payment per item.
 */

CREATE VIEW [supplier_company_payment_detail] As
 Select sc.CompanyName,sum(sr.Quantity * i.UnitPrice) AS TotalPaymentForCompany, 
  sum(sr.Quantity) AS TotalItemCount, 
  cast((sum(sr.Quantity * i.UnitPrice) / sum(sr.Quantity)) as decimal(10,2)) As PaymentPerItem
  From Item i inner join SUPPLIER_COMPANY sc on i.CompanyId = sc.CompanyID
  inner join SUPPLY_RECORD sr on i.ItemID = sr.ItemID
  GROUP BY sc.CompanyName

/*
Gives information about how many 
employee exist in;his/her departmant
includes more than 5 people and his/her 
seniority is greater than 10.
*/

CREATE VIEW [BlueCollor_Dept_Seniority] As
 Select d.Dno,d.DField, count(*) k
 From Employee e inner join DEPARTMENT d on e.DepartmentNo=d.Dno
 Where  e.DepartmentNo in ( Select e.DepartmentNo
                            From Employee e
							Group By e.DepartmentNo
							Having count(*) > 5)
            and e.TCKN in ( Select bc.TCKN
                            From BLUECOLLAREMPLOYEE bc
						    Where bc.Seniority > 10)	   
  Group By d.Dno,d.DField



Select * From blue_collar_salaray_statistic
Select * From ups_product_type_statistic
Select * From detailed_customer_order
Select * From supplier_company_payment_detail
Select * From BlueCollor_Dept_Seniority