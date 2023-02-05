CREATE DATABASE UPS_PRODUCT
GO

use UPS_PRODUCT
GO

CREATE TABLE EMPLOYEE (
         TCKN varchar(11) PRIMARY KEY,
		 FirstName nvarchar(20),
		 LastName nvarchar(20),
		 Address nvarchar(60),
		 Birthdate Date,
		 Age AS (datediff(year,BirthDate,getDate())),
		 Gender char(1),
		 PhoneNumber varchar(14) UNIQUE,
		 StartingDate Date,
		 Salary float DEFAULT 0.0,
		 EmployeeType char(1),
		 DepartmentNo smallint,
		 INDEX name_asc(LastName ASC),
		 INDEX salary(Salary DESC)
);
GO

CREATE TABLE BLUECOLLAREMPLOYEE(
         TCKN varchar(11) PRIMARY KEY,
         Seniority smallint DEFAULT 0,
		 FOREIGN KEY (TCKN) REFERENCES EMPLOYEE(TCKN) ON DELETE CASCADE
);
GO

CREATE TABLE WHITECOLLAREMPLOYEE(
         TCKN varchar(11) PRIMARY KEY,
         GradutionMajor nvarchar(75),
		 FOREIGN KEY (TCKN) REFERENCES EMPLOYEE(TCKN) ON DELETE CASCADE
);
GO

CREATE TABLE DEPARTMENT(
        Dno smallint PRIMARY KEY,
		DField nvarchar(50),
		NoOfEmployees int DEFAULT 0,
		ManagerTCKN varchar(11),
		FactoryID varchar(11),
		INDEX dno_employees(Dno,NoOfEmployees),
		INDEX manager_list(ManagerTCKN,DField)
);
GO


CREATE TABLE FACTORY(
        TradeRegistrationNumber varchar(11) PRIMARY KEY,
		FactoryName nvarchar(100),
		Address nvarchar(100),
		PhoneNumber varchar(14) UNIQUE,
		Fax varchar(12) UNIQUE,
);
GO

ALTER TABLE DEPARTMENT
ADD FOREIGN KEY (FactoryID) REFERENCES FACTORY(TradeRegistrationNumber)
GO


CREATE TABLE SUPPLIER_COMPANY(
        CompanyID nvarchar(11) PRIMARY KEY,
		CompanyName nvarchar(35),
		Address nvarchar(60),
		PhoneNumber varchar(14) UNIQUE,
);
GO

CREATE TABLE ITEM(
        ItemID nvarchar(11) PRIMARY KEY,
		ItemType nvarchar(150),
		UnitPrice float CHECK (UnitPrice >= 0.5),
		CompanyId nvarchar(11),
		INDEX item_price(ItemType,UnitPrice DESC),
		FOREIGN KEY (CompanyId) REFERENCES SUPPLIER_COMPANY(CompanyID)
);
GO

CREATE TABLE SUPPLY_RECORD(
		SupplyNo int Identity(1,1),
        ItemID nvarchar(11) FOREIGN KEY REFERENCES ITEM(ItemID),
		FactoryTradeRegistrationNumber varchar(11) FOREIGN KEY REFERENCES FACTORY(TradeRegistrationNumber),
		Quantity int,
		SupplyDate Date,
		PRIMARY KEY(SupplyNo,ItemID,FactoryTradeRegistrationNumber)
);
GO

CREATE TABLE CUSTOMER(
        CustomerID varchar(11) PRIMARY KEY ,
		ContactPersonName nvarchar(20),
		PhoneNumber varchar(14) UNIQUE,
		Email nvarchar(35) CHECK (Email LIKE '%@%.com'),
		ShippingAddress nvarchar(60),
);
GO

CREATE TABLE UPS_PRODUCT(
       ProductID varchar(20) PRIMARY KEY,
	   ProductName nvarchar(100),
	   ProductPrice float,
	   Stock int,
	   EngerySavingMode nvarchar(15),
	   ConversionTechnology nvarchar(30),
	   Standart nvarchar(60),
	   ProductType varchar(3) NOT NULL,
	   INDEX product_stock(ProductID,Stock),
	   INDEX product_price(ProductName,ProductPrice DESC)
);

CREATE TABLE ONE_ONE_PHASE(
      ProductID varchar(20) PRIMARY KEY,
	  FrequencyConverterHZ float,
	  FOREIGN KEY (ProductID) REFERENCES UPS_PRODUCT(ProductID),
	  CONSTRAINT CheckFrequencyConverter  CHECK (FrequencyConverterHZ >= 50)
);
GO

CREATE TABLE THREE_ONE_PHASE(
      ProductID varchar(20) PRIMARY KEY,
	  InputPowerFactor float,
	  InputVoltageRange float,
	  FOREIGN KEY (ProductID) REFERENCES UPS_PRODUCT(ProductID),
	  CONSTRAINT CheckVoltages CHECK (InputPowerFactor >= 0.5 AND InputVoltageRange >= 35),
	  INDEX input_voltage_range(ProductId,InputVoltageRange DESC )
);
GO

CREATE TABLE THREE_THREE_PHASE(
      ProductID varchar(20) PRIMARY KEY,
	  HarmonicDistortionLevel float,
	  OptinalPart nvarchar(500),
	  FOREIGN KEY (ProductID) REFERENCES UPS_PRODUCT(ProductID)
);
GO
       
CREATE TABLE CUSTOMER_ORDER(
      OrderNo int Identity(1,1),
      CustomerID varchar(11),
	  ProductID varchar(20),
      OrderInfo nvarchar(100),
	  Quantity int,
	  DateSold Date,
	  IsPlaced bit,
	  INDEX order_view(OrderNo,ProductID,CustomerID),
	  FOREIGN KEY (ProductID) REFERENCES UPS_PRODUCT(ProductID),
	  FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID),
	  PRIMARY KEY (OrderNo,CustomerID,ProductID)
);
GO

CREATE TABLE FACTORY_PRODUCT(
      ID int Identity(1,1),
      TradeRegistrationNumber varchar(11) FOREIGN KEY REFERENCES FACTORY(TradeRegistrationNumber),
	  ProductID varchar(20) FOREIGN KEY REFERENCES UPS_PRODUCT(ProductID),
	  Quantity int,
	  ProductionDate date,
	  PRIMARY KEY(ID,TradeRegistrationNumber,ProductID),
);
GO


/*STORED PROCEDURE 1*/
CREATE PROCEDURE sp_AddNewProduct
	@ProductID varchar(20),
	@Name nvarchar(100),
	@Price float,
	@EnergySavingMode nvarchar(15),
	@ConversionTechnology nvarchar(30),
	@Standart nvarchar(60),
	@Type nvarchar(3),
	@TypeAttribute1 float,
	@TypeAttribute2 nvarchar(500) = NULL
AS
	IF EXISTS (Select *
				From UPS_PRODUCT p
				Where @ProductID = p.ProductID)
	BEGIN
		RAISERROR('Product already exists',16,1)
		RETURN
	END

	DECLARE @Stock int = 0
	if(@Type = '1-1')
	BEGIN
		Declare @FrequencyConverterHZ float = @TypeAttribute1
		INSERT INTO UPS_PRODUCT VALUES (@ProductID, @Name, @Price, @Stock, @EnergySavingMode,
										@ConversionTechnology, @Standart, @Type)
		INSERT INTO ONE_ONE_PHASE VALUES(@ProductID, @FrequencyConverterHZ);
	END
	else if(@Type = '3-1')
	BEGIN
		Declare @InputPowerFactor float = @TypeAttribute1
		Declare @InputVoltageRange float = Convert(float, @TypeAttribute2)
		INSERT INTO UPS_PRODUCT VALUES (@ProductID, @Name, @Price, @Stock, @EnergySavingMode, 
										@ConversionTechnology, @Standart, @Type)
		INSERT INTO THREE_ONE_PHASE VALUES(@ProductID, @InputPowerFactor, @InputVoltageRange);
	END
	else if(@Type = '3-3')
	BEGIN
		Declare @HarmonicDistortionLevel float = @TypeAttribute1
		Declare @OptionalPart nvarchar(500) = @TypeAttribute2
		INSERT INTO UPS_PRODUCT VALUES (@ProductID, @Name, @Price, @Stock, @EnergySavingMode, 
										@ConversionTechnology, @Standart, @Type)
		INSERT INTO THREE_THREE_PHASE VALUES(@ProductID, @HarmonicDistortionLevel, @OptionalPart);
	END;
GO

/*STORED PROCEDURE 2*/

CREATE PROCEDURE sp_AddingProductToStock
	@TradeRegistrationNumber varchar(11),
	@ProductID varchar(20),
	@Quantity int,
	@ProductionDate Date
AS
	IF NOT EXISTS (Select *
			   From UPS_PRODUCT p
			   Where @ProductID = p.ProductID)
	BEGIN
		RAISERROR('Product not exists',16,1)
		RETURN
	END

	IF @Quantity < 0
	BEGIN
		RAISERROR('Quantity cannot be < 0',16,1)
		RETURN
	END

	INSERT INTO FACTORY_PRODUCT VALUES(@TradeRegistrationNumber, @ProductID, 
									   @Quantity, @ProductionDate);
		
	Update p
	Set p.Stock = p.Stock + @Quantity
	From UPS_PRODUCT p
	Where p.ProductID = @ProductID;
GO

/*STORED PROCEDURE 3*/

CREATE PROCEDURE sp_AddEmployee
	@TCKN varchar(11),
	@FName nvarchar(20),
	@LName nvarchar(20),
	@Address nvarchar(60),
	@Birthdate date,
	@Gender char(1),
	@PhoneNumber varchar(14),
	@StartingDate date,
	@Salary float,
	@Type char(1),
	@Dno int,
	@Major nvarchar(75) = NULL
AS
	IF EXISTS (Select *
				From EMPLOYEE e
				Where @TCKN = e.TCKN)
	BEGIN
		RAISERROR('Employee already exists',16,1)
		RETURN
	END

	if(@Type = 'B')
	BEGIN
		INSERT INTO EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, 
							  PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) 
		VALUES (@TCKN, @FName, @LName, @Address, @Birthdate, @Gender, 
							  @PhoneNumber, @StartingDate, @Salary, 'B', @Dno)
	END
	else if(@Type = 'W')
	BEGIN
		INSERT INTO EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, 
							  PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) 
		VALUES (@TCKN, @FName, @LName, @Address, @Birthdate, @Gender, 
							  @PhoneNumber, @StartingDate, @Salary, 'W', @Dno);

		INSERT INTO WHITECOLLAREMPLOYEE VALUES(@TCKN, @Major);
	END;
GO

/*STORED PROCEDURE 4*/

CREATE PROCEDURE sp_OrderProduct
	@CustomerID varchar(11),
	@ProductID varchar(20),
	@OrderInfo nvarchar(100),
	@Quantity int,
	@DateSold Date
AS
	
	IF NOT EXISTS (Select * From UPS_PRODUCT p Where p.ProductID = @ProductID)
	BEGIN
		RAISERROR('Product not found',16,1)
		RETURN
	END
	IF NOT EXISTS (Select * From CUSTOMER c Where c.CustomerID = @CustomerID)
	BEGIN
		RAISERROR('Customer not found',16,1)
		RETURN
	END	

	DECLARE @Stock int, @IsPlaced bit

	Select @Stock = p.Stock
	From UPS_PRODUCT p
	Where p.ProductID = @ProductID

	IF @Stock >= @Quantity
	BEGIN
		Set @IsPlaced = 1
		Update p
		Set p.Stock = p.Stock - @Quantity
		From UPS_PRODUCT p
		Where p.ProductID = @ProductID
	END
	ELSE
	BEGIN
		set @IsPlaced = 0
		RAISERROR('Not enough stock',16,1)
	END

	INSERT INTO CUSTOMER_ORDER VALUES(@CustomerID, @ProductID, @OrderInfo, @Quantity, @DateSold, @IsPlaced);
GO

/*STORED PROCEDURE 5*/

CREATE PROCEDURE sp_UpdateSalary
   @empid varchar(12)
AS
BEGIN

   Update EMPLOYEE Set Salary = Salary + ( Salary * 0.25 )

   Declare @type varchar(1)

   IF ( @type = 'B')
   BEGIN
    
	Declare @seniority int
    Set @seniority = (Select b.Seniority 
                      From BLUECOLLAREMPLOYEE b)

	  IF( @seniority >= 0  and @seniority <=3)
	  BEGIN
	     Update EMPLOYEE Set Salary = Salary +( Salary * 0.10)
	  END

	  ELSE IF ( @seniority >= 4 and @seniority <= 7)
	  BEGIN
	     Update EMPLOYEE Set Salary =  Salary + (Salary * 0.15)
	  END

	  Else
	  BEGIN
	     Update EMPLOYEE Set Salary =  Salary + (Salary * 0.20)
	  END
   END
END;
GO

/*STORED PROCEDURE 6*/

CREATE PROCEDURE sp_DeleteEmployee
      @empid varchar(12)
AS
BEGIN
    IF NOT EXISTS ( Select TCKN
	                FROM EMPLOYEE
					Where @empid = TCKN)
	BEGIN 
	    RAISERROR('Employee does not exist',16,1)
		RETURN
	END

	IF EXISTS ( Select TCKN
	            FROM EMPLOYEE e inner join DEPARTMENT d on @empid = d.ManagerTCKN)
	BEGIN
		RAISERROR('You can not delete manager',16,1)
		RETURN
    END

	Declare @noOfEmp int
	Declare @dno int

	Set @dno = (Select DepartmentNo From EMPLOYEE Where TCKN = @empid)
	Set @noOfEmp = ( Select NoOfEmployees From DEPARTMENT Where Dno = @dno)

	Delete FROM EMPLOYEE 
	WHERE @empid = TCKN

	Update DEPARTMENT set NoOfEmployees = NoOfEmployees - 1 WHERE Dno = @dno
END;
GO

/*TRIGGER 1*/


CREATE TRIGGER trg_Fill_Blue_Collar_Update_Department ON EMPLOYEE

	AFTER INSERT AS

BEGIN

  Update d
  Set d.NoOfEmployees = d.NoOfEmployees + 1
  From DEPARTMENT d, inserted i
  Where d.Dno = i.DepartmentNo

  Declare @type char(1)
  set @type = (Select i.EmployeeType FROM inserted i)

  if (@type = 'B')
	BEGIN
		Declare @startingdate date
		set @startingdate = ( Select i.StartingDate FROM inserted i)
		Declare @tckn varchar(11)
		set @tckn = ( Select i.TCKN FROM inserted i)
		INSERT INTO BLUECOLLAREMPLOYEE VALUES(@tckn,DATEDIFF(year,@startingdate,GETDATE()))
	END

END;


GO

/*TRIGGER 2*/
/*
ALTER TABLE EMPLOYEE 
ADD FOREIGN KEY (DepartmentNo) REFERENCES DEPARTMENT(Dno) on delete no action
GO
ALTER TABLE DEPARTMENT 
ADD FOREIGN KEY(ManagerTCKN) REFERENCES EMPLOYEE(TCKN) on delete no action
GO
*/

--drop trigger trg_DeleteDepartment
/*
CREATE TRIGGER trg_DeleteDepartment ON DEPARTMENT

	INSTEAD OF DELETE AS

BEGIN

  Declare @Dno int
  set @Dno = (Select i.Dno FROM deleted i)

  Declare @ManagerTCKN varchar(11)
  set @ManagerTCKN = (Select i.ManagerTCKN  FROM deleted i)

  Update e
  Set e.DepartmentNo = NULL
  From EMPLOYEE e
  Where e.DepartmentNo = @Dno;
  Update d
  Set d.ManagerTCKN = NULL
  From DEPARTMENT d
  Where d.Dno = @Dno;

  Declare @TCKN varchar(12)

  select @TCKN = e.TCKN
  from EMPLOYEE e
  Where e.DepartmentNo = @Dno and e.TCKN <> @ManagerTCKN
  exec sp_DeleteEmployee @TCKN;

  delete from DEPARTMENT where Dno = @Dno;

END;

delete from DEPARTMENT where dno=1
select * from DEPARTMENT
select * from EMPLOYEE where DepartmentNo=1
select w.TCKN, w.GradutionMajor from WHITECOLLAREMPLOYEE w inner join  EMPLOYEE e on e.TCKN= w.TCKN where e.DepartmentNo = 1
select b.TCKN, b.Seniority from BLUECOLLAREMPLOYEE b inner join  EMPLOYEE e on e.TCKN= b.TCKN where e.DepartmentNo = 1
*/




/*ADDING NEW PRODUCT*/
--1-1
exec sp_AddNewProduct '1101', 'Sinus Evo 1kVA to 3kVA', 7000, 'C', 'On-Line Double', 'RS-232','1-1', 55
exec sp_AddNewProduct '1102', 'Sinus Evo RM 1kVA to 3kVA', 9000, 'B', 'On-Line Double', 'EPO', '1-1', 53
exec sp_AddNewProduct '1103', 'Sinus LCD 1kVA to 3kVA', 11000,'A','On-Line Double', 'SNMP','1-1', 56
exec sp_AddNewProduct '1104', 'DSP EVO 6kVA to 10kVA', 13000,'A++','On-Line Double', 'USB','1-1', 52
exec sp_AddNewProduct '1105', 'DSP Multipower Convertible 5kVA to 20kVA', 15000, 'A++','On-Line Double', 'SNMP','1-1', 59
exec sp_AddNewProduct '1106', 'DSP Flexipower 3kVA to 10kVA', 17000, 'A+++','On-Line Double', 'RS485','1-1', 60
GO
--3-1
exec sp_AddNewProduct '3101', 'DSP Multipower Convertible 10kVA to 20kVA',20000,'ECO MODE','On-Line Double Conversion','RS232','3-1',0.90,80
exec sp_AddNewProduct '3102','DSP Multipower Series (Tower) 15&20kVA',25000,'GREEN MODE','On-Line Double Conversion','RS232','3-1',0.95,100
exec sp_AddNewProduct '3103', 'Saver Plus DSP 15kVA to 20kVA', 30000,NULL,'On-Line Double Conversion','RS232','3-1',0.98,150
exec sp_AddNewProduct '3104','DSP Flexipower Series 10kVA',35000,'ECO MODE','On-Line Double Conversion','RS232','3-1',0.98,170
exec sp_AddNewProduct '3105','Pyramid DSP 10kVA to 40kVA',40000,NULL,'On-Line Double Conversion','RS232','3-1',0.99,190
GO
--3-3
exec sp_AddNewProduct '3301',
	  'ESTIA 10kVA to 20kVA',
	  80000,'ECO MODE','TGG WP16 Double Conversion',
	  'GENSET','3-3',0.03,'SNMP,Relay Card,Modbus'
exec sp_AddNewProduct '3302',
	  'ESTIA Hybrid Solar 10kVA to 20kVA',
	  100000,'GREEN MODE','TGG WP16 Double Conversion',
	  'STS Sync','3-3',0.05,'Modbus'
exec sp_AddNewProduct '3303',
	  'StarK 10kVA to 20kVA',
	  120000,'ECO MODE','TGG WP16 Double Conversion',
	  'RS485(ModBus)','3-3',0.03,'Relay Card, SNMP'
exec sp_AddNewProduct '3304',
	  'SOLUTIO 300kVA to 400kVA',
	  150000,'GREEN MODE','TGG WP16 Double Conversion',
	  'ESD','3-3',0.04,NULL
exec sp_AddNewProduct '3305',
	  'Forte 10kVA to 250kVA',
	  170000,'ECO MODE','TGG WP16 Double Conversion',
	  'ModBus','3-3',0.015,'SNMP,Network systems'
exec sp_AddNewProduct '3306',
	  'Pyramid DSP 10kVA to 120kVA',
	  190000,'ECO MODE','TGG WP16 Double Conversion',
	  'EPO','3-3',0.04,'SNMP,EPO'
exec sp_AddNewProduct '3307',
	  'Pyramid DSP T 10 – 300kVA',
	  200000,'GREEN MODE','TGG WP16 Double Conversion',
	  'SNMP','3-3',0.015,'Battery Block'
exec sp_AddNewProduct '3308',
	  'Pyramid DSP Premium 160kVA to 400kVA',
	  220000,'ECO MODE','TGG WP16 Double Conversion',
	  'SNMP','3-3',0.039,'SNMP'
exec sp_AddNewProduct '3309',
	  'Pyramid DSP Premium-T 160kVA to 300kVA',
	  300000,'GREEN MODE','TGG WP16 Double Conversion',
	  'SNMP','3-3',0.04,'SNMP,Battery Block'
GO


/*FACTORY*/
INSERT INTO FACTORY
VALUES ('2940035696',
       'Inform Elektronik San. ve Tic. A.Þ',
	   'Esenþehir Mah. Hale Sk. No:6/1 34776 Ümraniye / ISTANBUL',
	   '02123682800',
	   '02122513430')
GO

/*ADDING STOCK*/
exec sp_AddingProductToStock '2940035696', '1101', 20, '2022-12-24'
exec sp_AddingProductToStock '2940035696', '1102', 20, '2022-12-24'
exec sp_AddingProductToStock '2940035696', '1103', 20, '2022-12-24'
exec sp_AddingProductToStock '2940035696', '1104', 20, '2022-12-24'
exec sp_AddingProductToStock '2940035696', '1105', 20, '2022-12-24'
exec sp_AddingProductToStock '2940035696', '1106', 20, '2022-12-24'

exec sp_AddingProductToStock '2940035696', '3101', 20, '2022-12-25'
exec sp_AddingProductToStock '2940035696', '3102', 20, '2022-12-25'
exec sp_AddingProductToStock '2940035696', '3103', 20, '2022-12-25'
exec sp_AddingProductToStock '2940035696', '3104', 20, '2022-12-25'
exec sp_AddingProductToStock '2940035696', '3105', 20, '2022-12-25'

exec sp_AddingProductToStock '2940035696', '3301', 20, '2022-12-26'
exec sp_AddingProductToStock '2940035696', '3302', 20, '2022-12-26'
exec sp_AddingProductToStock '2940035696', '3303', 20, '2022-12-26'
exec sp_AddingProductToStock '2940035696', '3304', 20, '2022-12-26'
exec sp_AddingProductToStock '2940035696', '3305', 20, '2022-12-26'
exec sp_AddingProductToStock '2940035696', '3306', 20, '2022-12-26'
exec sp_AddingProductToStock '2940035696', '3307', 20, '2022-12-26'
exec sp_AddingProductToStock '2940035696', '3308', 20, '2022-12-26'
exec sp_AddingProductToStock '2940035696', '3309', 20, '2022-12-26'
GO

/*
Select * From FACTORY_PRODUCT
Select * From UPS_PRODUCT
GO*/

/*ADDING DEPARTMENT*/
INSERT INTO DEPARTMENT VALUES(1,'Marketing',0,'831-54-0845','2940035696')
INSERT INTO DEPARTMENT VALUES(2,'Finance',0,'393-76-8644','2940035696')
INSERT INTO DEPARTMENT VALUES(3,'Accounting',0,'289-16-6128','2940035696')
INSERT INTO DEPARTMENT VALUES(4,'HR',0,'629-09-1068','2940035696')
INSERT INTO DEPARTMENT VALUES(5,'IT',0,'518-10-7304','2940035696')
INSERT INTO DEPARTMENT VALUES(6,'Quality',0,'210-51-1946','2940035696')
INSERT INTO DEPARTMENT VALUES(7,'AR-GE',0,'363-22-6910','2940035696')
INSERT INTO DEPARTMENT VALUES(8,'R&D',0,'397-96-6194','2940035696')

INSERT INTO DEPARTMENT VALUES(9,'Production',0,'211-58-8290','2940035696')
INSERT INTO DEPARTMENT VALUES(10,'Charging and Discharging',0,'878-66-2354','2940035696')
INSERT INTO DEPARTMENT VALUES(11,'Assembling',0,'609-29-2683','2940035696')
INSERT INTO DEPARTMENT VALUES(12,'Chip Production',0,'273-65-4523','2940035696')
INSERT INTO DEPARTMENT VALUES(13,'Battery Design',0,'729-62-3632','2940035696')
INSERT INTO DEPARTMENT VALUES(14,'Item Storing',0,'409-55-1346','2940035696')
INSERT INTO DEPARTMENT VALUES(15,'Machine Maintenance',0,'406-72-5608','2940035696')
INSERT INTO DEPARTMENT VALUES(16,'Techinal Service',0,'215-86-1949','2940035696')
GO

/*ADDING EMPLOYEE*/
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('211-58-8290', 'Laurette', 'Dun', '257 Blue Bill Park Plaza', '1960-03-15', 'F', '489-632-3529', '8/7/2020', 14715, 'B', 9);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('273-65-4523', 'Pietra', 'Fowden', '578 Kipling Junction', '1981-05-29', 'F', '838-324-1070', '7/10/2012', 14251, 'B', 12);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('872-85-2633', 'Ely', 'New', '6143 Daystar Crossing', '1962-01-25', 'M', '916-594-8894', '4/4/2021', 10157, 'B', 13);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('609-29-2683', 'Emilee', 'Strodder', '112 5th Center', '1964-11-29', 'F', '635-478-9952', '1/7/2022', 13074, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('812-09-1754', 'Nara', 'Ezele', '60794 Randy Court', '1962-07-31', 'F', '343-597-6836', '5/28/2019', 12961, 'B', 9);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('467-70-1993', 'Eleanora', 'Lob', '483 Canary Circle', '1962-01-06', 'F', '762-341-4153', '1/4/2016', 13629, 'B', 12);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('399-52-8421', 'Hedwiga', 'Barette', '006 Holy Cross Street', '1993-07-01', 'F', '833-992-8240', '12/5/2017', 9433, 'B', 9);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('831-77-1475', 'Kayne', 'Gregorowicz', '28 Meadow Valley Park', '1983-05-08', 'M', '618-513-1047', '10/19/2021', 11891, 'B', 13);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('683-02-5787', 'Jacinda', 'Pinare', '7 Daystar Circle', '1974-07-04', 'F', '807-607-5178', '10/12/2010', 12186, 'B', 12);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('826-94-9340', 'Dwain', 'Adhams', '789 Toban Lane', '1969-04-28', 'M', '805-746-8187', '12/9/2015', 9293, 'B', 13);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('212-96-2292', 'Hobey', 'Worviell', '35 Nobel Park', '1964-06-11', 'M', '221-518-8109', '12/19/2012', 10361, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('215-86-1949', 'Phillip', 'Witcomb', '76274 Graedel Center', '1978-05-21', 'M', '428-422-6675', '7/6/2016', 13948, 'B', 16);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('217-05-8759', 'Jed', 'Samsonsen', '08856 Evergreen Road', '1993-04-22', 'M', '292-521-9237', '9/13/2019', 9037, 'B', 13);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('610-30-2798', 'Cristiano', 'Winterbottom', '8 Butternut Plaza', '1994-11-19', 'M', '577-495-0309', '6/10/2016', 12008, 'B', 10);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('517-51-9179', 'Kristos', 'Dillway', '2857 Marquette Place', '1967-10-17', 'M', '196-929-9848', '9/9/2013', 8753, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('729-62-3632', 'Sheffy', 'Jindacek', '64 Sutherland Center', '1993-09-17', 'M', '474-477-8941', '12/27/2017', 13763, 'B', 13);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('748-15-8632', 'Burnard', 'Sive', '704 Kennedy Alley', '1966-04-15', 'M', '625-672-7631', '1/1/2011', 12946, 'B', 15);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('561-18-8892', 'Dallon', 'Bareham', '35255 Mariners Cove Junction', '1996-09-25', 'M', '748-596-2542', '2/1/2018', 11297, 'B', 14);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('340-11-1307', 'Rebekkah', 'Boundey', '7944 Dunning Plaza', '1976-04-23', 'F', '212-839-7527', '5/28/2020', 8914, 'B', 10);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('815-95-5155', 'Scottie', 'Mival', '98 Golf View Drive', '1991-08-19', 'M', '903-514-8036', '9/23/2019', 12775, 'B', 12);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('243-57-0502', 'Bevvy', 'Maben', '3244 Nancy Alley', '1971-12-20', 'F', '782-529-3789', '2/27/2022', 10154, 'B', 13);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('773-30-5719', 'Michael', 'Vynoll', '39857 Ilene Place', '1981-01-11', 'M', '942-978-6328', '10/6/2014', 10729, 'B', 15);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('694-80-3674', 'Oralee', 'Pepperrall', '91 Emmet Circle', '1967-07-13', 'F', '417-780-4996', '7/30/2017', 10545, 'B', 10);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('829-81-3571', 'Damaris', 'Elsby', '15398 Iowa Court', '1995-03-03', 'F', '659-638-0946', '5/24/2011', 10719, 'B', 12);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('223-13-0549', 'Cynthy', 'Colgrave', '48 Buena Vista Hill', '1969-08-04', 'F', '651-264-4263', '10/14/2019', 13221, 'B', 16);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('396-88-6001', 'Tod', 'Martygin', '2 Hintze Hill', '1981-02-15', 'M', '527-703-2133', '11/19/2014', 11129, 'B', 9);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('774-78-8912', 'Micah', 'Maynell', '6 Clemons Place', '1965-02-14', 'M', '634-583-4976', '6/21/2013', 13235, 'B', 9);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('476-19-4900', 'Livia', 'Jobke', '52044 Hallows Place', '1981-06-01', 'F', '974-779-2178', '7/22/2018', 8877, 'B', 9);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('689-28-8622', 'Blane', 'McGarva', '002 Carey Pass', '1972-12-29', 'M', '427-481-5266', '10/16/2021', 14671, 'B', 12);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('382-99-8679', 'Dory', 'Kestin', '57 Waxwing Pass', '1988-01-22', 'F', '515-538-3355', '4/24/2016', 10380, 'B', 14);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('827-74-7778', 'Marsiella', 'Laydon', '3532 Laurel Lane', '1983-04-01', 'F', '978-686-4167', '12/3/2018', 12354, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('630-21-1236', 'Bessy', 'Ockwell', '67 Morningstar Circle', '1993-10-24', 'F', '451-442-4309', '4/30/2011', 10408, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('339-18-4973', 'Stormie', 'Zuenelli', '79 Farwell Point', '1994-04-21', 'F', '126-266-8806', '12/30/2011', 13595, 'B', 12);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('330-58-5390', 'Tomaso', 'Stanner', '0125 Bellgrove Street', '1990-08-22', 'M', '511-441-8630', '7/27/2021', 10295, 'B', 10);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('732-94-4581', 'Gustie', 'Aymerich', '5326 Blaine Alley', '1982-01-18', 'F', '597-683-1270', '1/27/2015', 13466, 'B', 15);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('491-47-4332', 'Renee', 'Ebourne', '65 Chinook Road', '1989-03-06', 'F', '165-508-6563', '4/5/2018', 9175, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('214-10-8104', 'Jesus', 'Eastmond', '29045 Dorton Plaza', '1978-08-06', 'M', '428-542-7874', '8/3/2011', 12440, 'B', 10);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('635-35-0631', 'Baxie', 'Patershall', '5942 Aberg Pass', '1963-11-12', 'M', '648-848-3522', '1/14/2012', 12607, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('788-48-5934', 'Lottie', 'Brennand', '51694 Susan Junction', '1986-12-05', 'F', '671-130-0080', '1/30/2021', 13277, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('592-84-2902', 'Dorri', 'Ketteringham', '1 Magdeline Avenue', '1995-06-28', 'F', '304-417-7454', '1/20/2010', 9712, 'B', 16);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('201-87-8164', 'Archibald', 'Stendall', '58005 Kensington Trail', '1998-06-03', 'M', '538-338-6182', '12/12/2022', 9944, 'B', 10);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('877-85-7367', 'Lane', 'Memory', '0001 Helena Terrace', '1991-05-13', 'F', '863-724-7519', '10/4/2013', 14193, 'B', 9);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('878-66-2354', 'Tandi', 'Jonczyk', '967 Westport Court', '1995-11-02', 'F', '626-331-6922', '10/20/2022', 13500, 'B', 10);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('248-12-7889', 'Candis', 'Mitkcov', '1 Fordem Pass', '1999-06-15', 'F', '751-442-4356', '9/19/2018', 9158, 'B', 16);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('697-41-6531', 'Lilla', 'Berthe', '12 Independence Point', '1973-03-06', 'F', '924-552-9733', '1/8/2020', 11924, 'B', 10);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('406-72-5608', 'Gipsy', 'Whitters', '23 Westerfield Junction', '1979-10-01', 'F', '747-905-3119', '9/6/2021', 14653, 'B', 15);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('409-55-1346', 'Geoff', 'Fielder', '8 Straubel Terrace', '1988-04-25', 'M', '471-695-5359', '10/10/2021', 14911, 'B', 14);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('342-64-6342', 'Willem', 'Wickman', '84 Moland Plaza', '1979-10-11', 'M', '517-508-3518', '11/17/2016', 11575, 'B', 13);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('228-42-7138', 'Dorena', 'Roelofs', '03 Village Green Pass', '1989-11-20', 'F', '358-820-6763', '11/22/2015', 12150, 'B', 11);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('741-98-6165', 'Gibby', 'MacCawley', '080 Erie Junction', '1966-01-18', 'M', '214-105-9189', '7/7/2013', 9839, 'B', 9);


insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('210-51-1946', 'Mariquilla', 'Hastelow', '6146 Anniversary Trail', '1977-04-21', 'F', '695-193-7170', '3/14/2017', 43625, 'W', 6);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('393-76-8644', 'Milissent', 'Crutch', '922 Monterey Parkway', '1973-03-31', 'F', '267-478-6982', '12/25/2018', 39494, 'W', 2);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('741-28-5572', 'Shaina', 'Wing', '36300 Fordem Terrace', '1964-05-28', 'F', '334-452-0676', '7/26/2015', 26050, 'W', 6);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('606-17-5664', 'Nathalie', 'Clarkson', '919 Ryan Point', '1982-03-05', 'F', '738-681-8394', '11/16/2020', 33110, 'W', 2);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('348-12-2135', 'Rosemonde', 'Aitcheson', '1424 Acker Plaza', '1989-03-14', 'F', '674-954-5940', '8/19/2010', 33985, 'W', 2);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('752-56-8219', 'Lynn', 'Rudeforth', '187 Express Parkway', '1972-11-27', 'M', '676-155-9458', '4/5/2016', 31857, 'W', 4);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('642-59-0616', 'Prudi', 'Shallcrass', '6 Novick Trail', '1977-12-03', 'F', '201-123-3498', '5/30/2017', 36293, 'W', 1);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('290-62-1316', 'Nevil', 'Claw', '2 5th Pass', '1977-03-19', 'M', '931-138-3011', '9/3/2020', 41811, 'W', 1);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('611-89-8373', 'Fonz', 'Bilton', '7473 Coleman Junction', '1982-11-20', 'M', '409-344-3780', '4/5/2020', 35550, 'W', 4);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('518-10-7304', 'Bab', 'Cookes', '9105 Warrior Street', '1972-02-17', 'F', '173-949-8784', '11/19/2018', 33511, 'W', 5);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('566-68-1933', 'Austina', 'Keyes', '20 Colorado Trail', '1973-05-26', 'F', '401-860-3668', '5/4/2022', 27004, 'W', 3);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('570-98-3325', 'Johnathan', 'Westberg', '007 Montana Center', '1969-02-10', 'M', '445-531-9619', '4/5/2012', 37551, 'W', 1);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('629-09-1068', 'Wilbert', 'Ludwikiewicz', '94 Artisan Junction', '1993-07-10', 'M', '964-597-0703', '7/7/2020', 42551, 'W', 4);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('566-68-3027', 'Rubina', 'Westman', '9512 Center Plaza', '1985-07-02', 'F', '304-236-7973', '7/20/2015', 17456, 'W', 8);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('872-61-0548', 'Agnese', 'Blowen', '7750 Caliangt Drive', '1981-08-25', 'F', '638-943-7272', '11/25/2014', 35145, 'W', 8);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('831-54-0845', 'Sawyer', 'Bartlosz', '2 Luster Circle', '1972-09-30', 'M', '799-130-8264', '11/27/2012', 44626, 'W', 1);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('289-16-6128', 'Eva', 'Sillick', '20 Bobwhite Avenue', '1965-06-04', 'F', '874-920-5204', '10/23/2016', 34651, 'W', 3);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('500-68-4885', 'Sonni', 'Dudgeon', '1 Utah Place', '1992-04-14', 'F', '686-291-7356', '11/22/2010', 27147, 'W', 2);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('685-04-0908', 'Aylmar', 'Antonomoli', '0592 Di Loreto Drive', '1965-07-10', 'M', '914-105-4928', '4/25/2020', 29967, 'W', 5);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('782-22-8052', 'Hugues', 'Geistmann', '455 Fulton Terrace', '1995-03-12', 'M', '741-618-5661', '10/27/2022', 38801, 'W', 8);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('363-22-6910', 'Bobbe', 'Littrik', '4804 Main Street', '1990-06-26', 'F', '526-544-4059', '7/19/2016', 35800, 'W', 7);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('395-97-9908', 'Avigdor', 'Philipard', '50333 Delaware Parkway', '1978-03-13', 'M', '792-494-7385', '7/30/2019', 29134, 'W', 6);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('351-65-5089', 'Mary', 'Foort', '05 Ronald Regan Trail', '1963-10-23', 'F', '506-503-6057', '2/25/2014', 32331, 'W', 6);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('594-98-4524', 'Nadia', 'Flecknell', '67857 Red Cloud Place', '1985-05-09', 'F', '828-815-7203', '11/29/2012', 30626, 'W', 4);
insert into EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) values ('397-96-6194', 'Rustin', 'Dorward', '7 Shopko Park', '1971-04-02', 'M', '931-829-0387', '6/6/2013', 39007, 'W', 8);
GO

ALTER TABLE EMPLOYEE 
ADD FOREIGN KEY (DepartmentNo) REFERENCES DEPARTMENT(Dno)
GO
ALTER TABLE DEPARTMENT 
ADD FOREIGN KEY(ManagerTCKN) REFERENCES EMPLOYEE(TCKN)
GO


INSERT INTO WHITECOLLAREMPLOYEE VALUES('210-51-1946','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('393-76-8644','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('741-28-5572','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('606-17-5664','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('348-12-2135','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('752-56-8219','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('642-59-0616','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('290-62-1316','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('611-89-8373','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('518-10-7304','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('566-68-1933','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('570-98-3325','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('629-09-1068','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('566-68-3027','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('872-61-0548','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('831-54-0845','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('289-16-6128','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('500-68-4885','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('685-04-0908','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('782-22-8052','Postgraduate')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('363-22-6910','Master')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('395-97-9908','Master')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('351-65-5089','Master')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('594-98-4524','Master')
INSERT INTO WHITECOLLAREMPLOYEE VALUES('397-96-6194','Master')
GO


/*ADDING SUPPLIER COMPANY*/
INSERT INTO SUPPLIER_COMPANY VALUES('41480','Legrand Elektrik San. A.Þ', 'GOSB Gebze Organize Sanayi Bölgesi Ihsan Dede Cad. No: 112','02626489000')
INSERT INTO SUPPLIER_COMPANY VALUES('18053','Sönmezler Metal San. A.Þ', 'Barýþ Mahallesi 1805/3 Sokak No:5/A Gebze/Kocaeli','02626440020')
GO

/*ADDING ITEM*/
INSERT INTO ITEM VALUES (1,'Switfs cable ladder',10,'41480')
INSERT INTO ITEM VALUES (2,'Salamandre distribution trunking',300,'41480')
INSERT INTO ITEM VALUES (3,'Swiftwire wire suspension',251,'41480')
INSERT INTO ITEM VALUES (4,'Transcab Panel Trunking',77,'41480')
INSERT INTO ITEM VALUES (5,'Cable marking',267,'41480')
INSERT INTO ITEM VALUES (6,'Viking 3 terminal blocks',666,'41480')
INSERT INTO ITEM VALUES (7,'Enclosures',500,'41480')
INSERT INTO ITEM VALUES (8,'P17 TEMPRA PLUGS AND SOCKETS',223,'41480')
INSERT INTO ITEM VALUES (9,'HYPRA PLUGS AND SOCKETS',661,'41480')
INSERT INTO ITEM VALUES (10,'HYPRA PRISINTER SOCKETS',56,'41480')
INSERT INTO ITEM VALUES (11,'P17 TEMPRA COMBINATION UNITS',710,'41480')
INSERT INTO ITEM VALUES (12,'POWERTRACK',71,'41480')
INSERT INTO ITEM VALUES (13,'FLOOR GROMMETS',93,'41480')
INSERT INTO ITEM VALUES (14,'INTERMOD',102,'41480')
INSERT INTO ITEM VALUES (15,'BUSCOM TRUNKING',777,'41480')
INSERT INTO ITEM VALUES (16,'LIGHTRAK',897,'41480')
INSERT INTO ITEM VALUES (17,'HYPRA PRISINTER SOCKETS',119,'41480')
INSERT INTO ITEM VALUES (18,'KONTOUR™',578,'41480')
INSERT INTO ITEM VALUES (19,'KONCIS™',231,'41480')
INSERT INTO ITEM VALUES (20,'RARITAN',65,'41480')
INSERT INTO ITEM VALUES (21,'STARLINE',277,'41480')
INSERT INTO ITEM VALUES (22,'MINKELS',198,'41480')
INSERT INTO ITEM VALUES (23,'LIGHTRAK',201,'41480')
INSERT INTO ITEM VALUES (24,'HYPRA PRISINTER SOCKETS',710,'41480')
INSERT INTO ITEM VALUES (25,'KONTOUR™',551,'41480')
INSERT INTO ITEM VALUES (26,'KONCIS™',320,'41480')
INSERT INTO ITEM VALUES (27,'RARITAN',67,'41480')
INSERT INTO ITEM VALUES (28,'STARLINE',53,'41480')
INSERT INTO ITEM VALUES (29,'Profile',2000,'18053')
INSERT INTO ITEM VALUES (30,'Roll Hair',517,'18053')
INSERT INTO ITEM VALUES (31,'Package Sheet',500,'18053')
INSERT INTO ITEM VALUES (32,'Sliced Sheet',243,'18053')
INSERT INTO ITEM VALUES (33,'Straight Bar',713,'18053')
INSERT INTO ITEM VALUES (34,'Round Bar',800,'18053')
INSERT INTO ITEM VALUES (35,'Square Bar',1111,'18053')
INSERT INTO ITEM VALUES (36,'Relbar',1443,'18053')
INSERT INTO ITEM VALUES (37,'Wire Rod',2000,'18053')
GO



/*ADDING CUSTOMER*/
INSERT INTO CUSTOMER VALUES ('150119566','Müslim Yýlmaz','05384833410','mslmyilmaz5@gmail.com',' Ümraniye/Istanbul')
INSERT INTO CUSTOMER VALUES ('150119037','Ömer Kibar','05469746230','omerkib592@gmail.com',' Kucukcekmece/Istanbul')
INSERT INTO CUSTOMER VALUES ('150119036','Serkan Korkut','05364925885','srknkrktgs@gmail.com',' Yenisahra/Istanbul')

INSERT INTO CUSTOMER VALUES ('100000001','Serap Korkmaz','05140000000','serap_korkmaz@gmail.com',' Kadiköy/Istanbul')
INSERT INTO CUSTOMER VALUES ('100000002','Mustafa Aðoðlu','05340000000','mustaga_agoglu@gmail.com',' Maltepe/Istanbul')
INSERT INTO CUSTOMER VALUES ('100000003','Ali Haydar','05330000000','ali_haydar@gmail.com',' Kartal/Istanbul')

INSERT INTO CUSTOMER VALUES ('100000004','Hasan Berkay Kürkçü','05059743077','hasan_berkay@gmail.com',' Pendik/Istanbul')
INSERT INTO CUSTOMER VALUES ('100000005','Metin Alperen','05541917550','metin_bykgvn@gmail.com',' Ümraniye/Istanbul')
INSERT INTO CUSTOMER VALUES ('100000006','Taha Uzun','05414046649','taha_uzun@gmail.com',' Sultanbeyli/Istanbul')

INSERT INTO CUSTOMER VALUES ('100000007','Buhari Yýlmaz','05396769708','buhari_yilmaz@gmail.com',' Ümraniye/Istanbul')
INSERT INTO CUSTOMER VALUES ('100000008','Yýldýray Yýlmaz','05342607220','yildiray_yilmaz@gmail.com',' Silvri/Istanbul')
INSERT INTO CUSTOMER VALUES ('100000009','Emre Ergin','05426105411','emre_ergin@gmail.com',' Osmangazi/Gebze')


INSERT INTO CUSTOMER VALUES ('100000010','Mehmet Ergin','05311111111','mehmet_ergin@gmail.com',' Osmaneli/Bilecik')
INSERT INTO CUSTOMER VALUES ('100000011','Fatih Yýlmaz','05311011111','fatih_yilmaz@gmail.com',' Bornova/Ýzmir')
INSERT INTO CUSTOMER VALUES ('100000012','Elif Bak','05333333333','elif_bak@gmail.com',' Didim/Antalya')
GO


/*ADDING SUPPLY RECORD*/
INSERT INTO SUPPLY_RECORD VALUES (1,'2940035696',5,'2022-12-12')
INSERT INTO SUPPLY_RECORD VALUES (2,'2940035696',30,'2022-11-13')
INSERT INTO SUPPLY_RECORD VALUES (3,'2940035696',1,'2022-10-14')
INSERT INTO SUPPLY_RECORD VALUES (4,'2940035696',13,'2022-09-15')
INSERT INTO SUPPLY_RECORD VALUES (5,'2940035696',66,'2022-08-16')
INSERT INTO SUPPLY_RECORD VALUES (6,'2940035696',91,'2022-07-17')
INSERT INTO SUPPLY_RECORD VALUES (7,'2940035696',20,'2022-06-18')
INSERT INTO SUPPLY_RECORD VALUES (8,'2940035696',93,'2022-12-19')
INSERT INTO SUPPLY_RECORD VALUES (9,'2940035696',133,'2022-12-20')
INSERT INTO SUPPLY_RECORD VALUES (10,'2940035696',158,'2022-11-03')
INSERT INTO SUPPLY_RECORD VALUES (11,'2940035696',221,'2022-06-05')
INSERT INTO SUPPLY_RECORD VALUES (12,'2940035696',341,'2022-07-06')
INSERT INTO SUPPLY_RECORD VALUES (13,'2940035696',213,'2022-11-03')
INSERT INTO SUPPLY_RECORD VALUES (14,'2940035696',65,'2022-11-03')
INSERT INTO SUPPLY_RECORD VALUES (15,'2940035696',33,'2022-12-06')
INSERT INTO SUPPLY_RECORD VALUES (16,'2940035696',156,'2022-12-07')
INSERT INTO SUPPLY_RECORD VALUES (17,'2940035696',34,'2022-12-15')
INSERT INTO SUPPLY_RECORD VALUES (18,'2940035696',32,'2022-12-17')
INSERT INTO SUPPLY_RECORD VALUES (19,'2940035696',10,'2022-11-16')
INSERT INTO SUPPLY_RECORD VALUES (20,'2940035696',23,'2022-11-17')
INSERT INTO SUPPLY_RECORD VALUES (21,'2940035696',45,'2022-06-02')
INSERT INTO SUPPLY_RECORD VALUES (22,'2940035696',387,'2022-04-01')
INSERT INTO SUPPLY_RECORD VALUES (23,'2940035696',212,'2022-10-02')
INSERT INTO SUPPLY_RECORD VALUES (24,'2940035696',321,'2022-12-03')
INSERT INTO SUPPLY_RECORD VALUES (25,'2940035696',543,'2022-12-04')
INSERT INTO SUPPLY_RECORD VALUES (26,'2940035696',53,'2022-12-05')
INSERT INTO SUPPLY_RECORD VALUES (27,'2940035696',22,'2022-12-06')
INSERT INTO SUPPLY_RECORD VALUES (28,'2940035696',111,'2022-12-07')
INSERT INTO SUPPLY_RECORD VALUES (29,'2940035696',222,'2022-12-08')
INSERT INTO SUPPLY_RECORD VALUES (30,'2940035696',333,'2022-12-09')
INSERT INTO SUPPLY_RECORD VALUES (31,'2940035696',444,'2022-12-10')
INSERT INTO SUPPLY_RECORD VALUES (32,'2940035696',231,'2022-12-11')
INSERT INTO SUPPLY_RECORD VALUES (33,'2940035696',261,'2022-12-12')
INSERT INTO SUPPLY_RECORD VALUES (34,'2940035696',654,'2022-12-13')
INSERT INTO SUPPLY_RECORD VALUES (35,'2940035696',311,'2022-12-14')
INSERT INTO SUPPLY_RECORD VALUES (36,'2940035696',223,'2022-12-28')
INSERT INTO SUPPLY_RECORD VALUES (37,'2940035696',651,'2022-12-29')
GO

Select * From SUPPLY_RECORD
GO

/*ORDER PRODUCT*/
exec sp_OrderProduct '150119036', 1101, 'Information about purchase', 5, '2022-12-25'
exec sp_OrderProduct '150119037', 1102, 'Information about purchase', 10, '2022-12-20'
exec sp_OrderProduct '150119566', 1103, 'Information about purchase', 9, '2022-12-15'

exec sp_OrderProduct '100000001', 1104, 'Information about purchase', 13, '2022-12-25'
exec sp_OrderProduct '100000002', 1105, 'Information about purchase', 22, '2022-12-20'
exec sp_OrderProduct '100000003', 1106, 'Information about purchase', 11, '2022-12-15'

exec sp_OrderProduct '100000004', 3101, 'Information about purchase', 1, '2022-12-25'
exec sp_OrderProduct '100000005', 3102, 'Information about purchase', 2, '2022-12-20'
exec sp_OrderProduct '100000006', 3303, 'Information about purchase', 4, '2022-12-15'

exec sp_OrderProduct '100000007', 3301, 'Information about purchase', 5, '2022-12-25'
exec sp_OrderProduct '100000008', 3302, 'Information about purchase', 15, '2022-12-20'
exec sp_OrderProduct '100000009', 3303, 'Information about purchase', 16, '2022-12-15'

exec sp_OrderProduct '100000010', 3304, 'Information about purchase', 9, '2022-12-25'
exec sp_OrderProduct '100000011', 3105, 'Information about purchase', 19, '2022-12-20'
exec sp_OrderProduct '100000012', 3306, 'Information about purchase', 7, '2022-12-15'

exec sp_OrderProduct '150119036', 1101, 'Information about purchase', 10, '2022-12-26'
exec sp_OrderProduct '150119037', 3101, 'Information about purchase', 20, '2022-12-20'
exec sp_OrderProduct '150119566', 3301, 'Information about purchase', 39, '2022-12-15'

exec sp_OrderProduct '150119036', 1101, 'Information about purchase', 10, '2022-12-27'
exec sp_OrderProduct '150119036', 1101, 'Information about purchase', 10, '2022-12-28'
GO

Select * From CUSTOMER_ORDER
GO

/* gives detailed information about the managers */
CREATE VIEW  [Manager_Details] AS
 Select e.FirstName + ' ' + e.LastName FullName, d.DField,e.Age,e.Salary,
 DATEDIFF(year,e.StartingDate,GETDATE()) WorkingYear
 From EMPLOYEE e inner join DEPARTMENT d on e.TCKN = d.ManagerTCKN

/*
Gives statistic about employee payment on a 
department basis.
*/
CREATE VIEW [Department_Payment_Statistic] AS
 Select d.DField,d.Dno, MAX(e.Salary) MaxPayment , MIN(e.Salary) 
 MinPayment, cast(AVG(e.Salary) as decimal(10,2)) AvaragePayment
 From DEPARTMENT d inner join EMPLOYEE e on d.Dno = e.DepartmentNo 
 GROUP BY d.DField,d.Dno
GO

/*
Gives statistic about all type of ups
product in factory (1-1,3-1,3-3)
*/
CREATE VIEW [Ups_ProducType_Price_Statistic] As
 Select u.ProductType,COUNT(u.ProductType) TypeQuantitiy,
 MAX( u.ProductPrice) MaxPrice , 
 MIN(u.ProductPrice) MinPrice, AVG(u.ProductPrice) AvgPrice
 From UPS_PRODUCT u
 Group By u.ProductType
GO

 /*
Gives detailed information about 
customer order.Addition to that 
it calculates total payment with using
quantatiy and item price.
 */
CREATE VIEW [Detailed_Customer_Order] As
 Select c.ContactPersonName as Customer,ups.ProductName,co.DateSold as SoldDate, ups.ProductPrice SingleProductPrice, 
 co.Quantity, (ups.ProductPrice * co.Quantity) AS TotalPayment
 From CUSTOMER_ORDER co left join CUSTOMER c on co.CustomerID = c.CustomerID
 left join UPS_PRODUCT ups on co.ProductID= ups.ProductID
 WHERE co.IsPlaced = 1
GO

 /*
Gives total payment info for each supplier company.
Addition to that it calculates total item count taken
from each supplier company and payment per item.
 */
CREATE VIEW [SupplierCompany_Payment] As
 Select sc.CompanyName,sum(sr.Quantity * i.UnitPrice) AS TotalPaymentForCompany, 
  sum(sr.Quantity) AS TotalItemCount, 
  cast((sum(sr.Quantity * i.UnitPrice) / sum(sr.Quantity)) as decimal(10,2)) As PaymentPerItem
  From ITEM i inner join SUPPLIER_COMPANY sc on i.CompanyId = sc.CompanyID
  inner join SUPPLY_RECORD sr on i.ItemID = sr.ItemID
  GROUP BY sc.CompanyName
GO

/*
Gives information about how many 
employee exist in;his/her departmant
includes more than 2 people and his/her 
seniority is greater than 10.
*/
CREATE VIEW [BlueCollar_Department_Seniority] As
 Select d.Dno,d.DField, count(*) k
 From EMPLOYEE e inner join DEPARTMENT d on e.DepartmentNo=d.Dno
 Where  e.DepartmentNo in ( Select e.DepartmentNo
                            From EMPLOYEE e
							Group By e.DepartmentNo
							Having count(*) > 2)
            and e.TCKN in ( Select bc.TCKN
                            From BLUECOLLAREMPLOYEE bc
						    Where bc.Seniority >=5)	   
  Group By d.Dno,d.DField
GO

Select * From Manager_Details
Select * From Department_Payment_Statistic
Select * From Ups_ProducType_Price_Statistic
Select * From Detailed_Customer_Order
Select * From SupplierCompany_Payment
Select * From BlueCollar_Department_Seniority
GO

exec sp_helpindex FACTORY