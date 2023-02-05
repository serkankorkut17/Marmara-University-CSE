ALTER TRIGGER update_noOfEmployee_seniortiy
    on Employee
	after insert
As
Begin
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

		/*UPDATE b 
		SET b.Seniority = DATEDIFF(year,@startingdate,GETDATE())
		FROM BLUECOLLAREMPLOYEE b
		WHERE b.TCKN = @tckn*/
		INSERT INTO BLUECOLLAREMPLOYEE VALUES(@tckn,DATEDIFF(year,@startingdate,GETDATE()))
	END
End;