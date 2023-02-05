
CREATE PROCEDURE AddNewProduct
	@ProductID varchar(20),
	@Name nvarchar(100),
	@Price float,
	--@Stock int,
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
		INSERT INTO UPS_PRODUCT VALUES (@ProductID, @Name, @Price, @Stock, @EnergySavingMode, @ConversionTechnology, @Standart, @Type)
		INSERT INTO ONE_ONE_PHASE VALUES(@ProductID, @FrequencyConverterHZ);
	END
	else if(@Type = '3-1')
	BEGIN
		Declare @InputPowerFactor float = @TypeAttribute1
		Declare @InputVoltageRange float = Convert(float, @TypeAttribute2)
		INSERT INTO UPS_PRODUCT VALUES (@ProductID, @Name, @Price, @Stock, @EnergySavingMode, @ConversionTechnology, @Standart, @Type)
		INSERT INTO THREE_ONE_PHASE VALUES(@ProductID, @InputPowerFactor, @InputVoltageRange);
	END
	else if(@Type = '3-3')
	BEGIN
		Declare @HarmonicDistortionLevel float = @TypeAttribute1
		Declare @OptionalPart nvarchar(500) = @TypeAttribute2
		INSERT INTO UPS_PRODUCT VALUES (@ProductID, @Name, @Price, @Stock, @EnergySavingMode, @ConversionTechnology, @Standart, @Type)
		INSERT INTO THREE_THREE_PHASE VALUES(@ProductID, @HarmonicDistortionLevel, @OptionalPart);
	END;


Select * from UPS_PRODUCT
exec AddNewProduct '1101', 'Sinus Evo 1kVA to 3kVA', 7000, 'C', 'On-Line Double', 'RS-232','1-1', 55
exec AddNewProduct '3101', 'DSP Multipower Convertible 10kVA to 20kVA', 20000, 'ECO MODE','On-Line Double Conversion', 'RS232','3-1', 0.90, 80
exec AddNewProduct '3301', 'ESTIA 10kVA to 20kVA', 80000, 'ECO MODE', 'TGG WP16 Double Conversion', 'GENSET', '3-3', 0.03, 'SNMP,Relay Card,Modbus'
Select * from UPS_PRODUCT p
Select * from FACTORY_PRODUCT p
/*****************************************************************/


CREATE PROCEDURE AddingProductToStock
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

	INSERT INTO FACTORY_PRODUCT VALUES(@TradeRegistrationNumber, @ProductID, @Quantity, @ProductionDate);
		
	Update p
	Set p.Stock = p.Stock + @Quantity
	From UPS_PRODUCT p
	Where p.ProductID = @ProductID;

exec AddingProductToStock '2940035696', '1101', 20, '2022-12-26'
exec AddingProductToStock '2940035696', '1101', 20, '2022-12-26'
exec AddingProductToStock '2940035696', '1101', 20, '2022-12-26'
exec AddingProductToStock '2940035696', '1101', 20, '2022-12-26'
exec AddingProductToStock '2940035696', '1101', 20, '2022-12-26'
exec AddingProductToStock '2940035696', '1101', 20, '2022-12-26'
/**********************************************************************************/


CREATE PROCEDURE AddEmployee
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
		--Declare @Seniority int = Convert(int, @SeniorityOrMajor)
		INSERT INTO EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) 
		VALUES (@TCKN, @FName, @LName, @Address, @Birthdate, @Gender, @PhoneNumber, @StartingDate, @Salary, 'B', @Dno)
		--INSERT INTO BLUECOLLAREMPLOYEE VALUES(@TCKN, 0);
	END
	else if(@Type = 'W')
	BEGIN
		INSERT INTO EMPLOYEE (TCKN, FirstName, LastName, Address, Birthdate, Gender, PhoneNumber, StartingDate, Salary, EmployeeType, DepartmentNo) 
		VALUES (@TCKN, @FName, @LName, @Address, @Birthdate, @Gender, @PhoneNumber, @StartingDate, @Salary, 'W', @Dno);
		INSERT INTO WHITECOLLAREMPLOYEE VALUES(@TCKN, @Major);
	END;


select * from EMPLOYEE
select * from BLUECOLLAREMPLOYEE
select * from DEPARTMENT

update DEPARTMENT set NoOfEmployees = 0
Delete from EMPLOYEE
Delete from BLUECOLLAREMPLOYEE
AddEmployee '999-99-999', 'John', 'Doe', 'somewhere', '1985-05-15', 'M', '999-999-9999', '1/1/2021', 20000, 'B', 1;

/************************************************************************************/




CREATE PROCEDURE OrderProduct
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
		set @IsPlaced = 0

	INSERT INTO CUSTOMER_ORDER VALUES(@CustomerID, @ProductID, @OrderInfo, @Quantity, @DateSold, @IsPlaced);


Select * from UPS_PRODUCT p
exec OrderProduct '150119036', 1101, 'çaldım', 10, '2022-12-25'
Select * from CUSTOMER_ORDER c

/************************************************************************************/

CREATE procedure sp_UpdateSalary
   @empid varchar(12)
As
BEGIN
  
   IF NOT EXISTS(Select TCKN
				From EMPLOYEE 
				Where @empid = TCKN)
   BEGIN
		RAISERROR('Employee does not exist.',16,1)
		RETURN
   END

   Declare @salary int
   Declare @type varchar(1)

   Set @salary = (Select Salary From EMPLOYEE Where TCKN = @empid)
   Set @type = (Select EmployeeType From EMPLOYEE Where TCKN = @empid)

   Update EMPLOYEE Set Salary = Salary +( Salary * 0.25 ) Where TCKN = @empid

   IF ( @type = 'B')
   BEGIN
    
	Declare @seniority int
    Set @seniority = (Select b.Seniority 
                      From BLUECOLLAREMPLOYEE b 
					  WHERE @empid = TCKN)

	  IF( @seniority >= 0  and @seniority <=3)

	  BEGIN
	     Update EMPLOYEE Set Salary = Salary +( Salary * 0.10) Where TCKN = @empid
	  END

	  ELSE IF ( @seniority >= 4 and @seniority <= 7)

	  BEGIN
	     Update EMPLOYEE Set Salary =  Salary + (Salary * 0.15) Where TCKN = @empid
	  END

	  Else
	  BEGIN
	     Update EMPLOYEE Set Salary =  Salary + (Salary * 0.20) Where TCKN = @empid
	  END
   END
END

/************************************************************************************/


CREATE Procedure sp_deleteEmployee
      @empid varchar(12)
As
Begin
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

End

CREATE procedure sp_UpdateProductPrice
   @ProductID varchar(20),
   @RateOfIncrease int
As
BEGIN
  
   IF NOT EXISTS(Select *
				From UPS_PRODUCT 
				Where @ProductID = ProductID)
   BEGIN
		RAISERROR('Product does not exist.',16,1)
		RETURN
   END

   Declare @Price int
   Declare @type varchar(1)

   Set @Price = (Select ProductPrice From UPS_PRODUCT Where ProductID = @ProductID)

   Update UPS_PRODUCT Set ProductPrice = ProductPrice + ( ProductPrice * @RateOfIncrease ) Where TCKN = @empid

   IF ( @type = 'B')
   BEGIN
    
	Declare @seniority int
    Set @seniority = (Select b.Seniority 
                      From BLUECOLLAREMPLOYEE b 
					  WHERE @empid = TCKN)

	  IF( @seniority >= 0  and @seniority <=3)

	  BEGIN
	     Update EMPLOYEE Set Salary = Salary +( Salary * 0.10) Where TCKN = @empid
	  END

	  ELSE IF ( @seniority >= 4 and @seniority <= 7)

	  BEGIN
	     Update EMPLOYEE Set Salary =  Salary + (Salary * 0.15) Where TCKN = @empid
	  END

	  Else
	  BEGIN
	     Update EMPLOYEE Set Salary =  Salary + (Salary * 0.20) Where TCKN = @empid
	  END
   END
END