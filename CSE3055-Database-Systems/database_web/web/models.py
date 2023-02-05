# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Bluecollaremployee(models.Model):
    tckn = models.OneToOneField('Employee', models.DO_NOTHING, db_column='TCKN', primary_key=True)  # Field name made lowercase.
    seniority = models.SmallIntegerField(db_column='Seniority', blank=True, null=True)  # Field name made lowercase.
    
    class Meta:
        managed = False
        db_table = 'BLUECOLLAREMPLOYEE'

    def __str__(self):
        return f'{self.tckn}'


class Customer(models.Model):
    customerid = models.CharField(db_column='CustomerID', primary_key=True, max_length=11, db_collation='Turkish_CI_AS')  # Field name made lowercase.
    contactpersonname = models.CharField(db_column='ContactPersonName', max_length=20, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    phonenumber = models.CharField(db_column='PhoneNumber', unique=True, max_length=14, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    email = models.CharField(db_column='Email', max_length=35, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    shippingaddress = models.CharField(db_column='ShippingAddress', max_length=60, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    

    def __str__(self):
        return f'{self.contactpersonname}'

    class Meta:
        managed = False
        db_table = 'CUSTOMER'


class CustomerOrder(models.Model):
    orderno = models.AutoField(db_column='OrderNo', primary_key=True)  # Field name made lowercase.
    customerid = models.ForeignKey(Customer, models.DO_NOTHING, db_column='CustomerID')  # Field name made lowercase.
    productid = models.ForeignKey('UpsProduct', models.DO_NOTHING, db_column='ProductID')  # Field name made lowercase.
    orderinfo = models.CharField(db_column='OrderInfo', max_length=100, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    quantity = models.IntegerField(db_column='Quantity', blank=True, null=True)  # Field name made lowercase.
    datesold = models.DateField(db_column='DateSold', blank=True, null=True)  # Field name made lowercase.
    isplaced = models.BooleanField(db_column='IsPlaced', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'CUSTOMER_ORDER'
        unique_together = (('orderno', 'customerid', 'productid'),)
    
    def __str__(self):
        return f'Order No: {self.orderno}'

class Department(models.Model):
    dno = models.SmallIntegerField(db_column='Dno', primary_key=True)  # Field name made lowercase.
    dfield = models.CharField(db_column='DField', max_length=50, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    noofemployees = models.IntegerField(db_column='NoOfEmployees', blank=True, null=True)  # Field name made lowercase.
    managertckn = models.ForeignKey('Employee', models.DO_NOTHING, db_column='ManagerTCKN', blank=True, null=True)  # Field name made lowercase.
    factoryid = models.ForeignKey('Factory', models.DO_NOTHING, db_column='FactoryID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'DEPARTMENT'
    
    def __str__(self):
        return f'{self.dfield}'
    


class Employee(models.Model):
    tckn = models.CharField(db_column='TCKN', primary_key=True, max_length=11, db_collation='Turkish_CI_AS')  # Field name made lowercase.
    firstname = models.CharField(db_column='FirstName', max_length=20, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    lastname = models.CharField(db_column='LastName', max_length=20, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    address = models.CharField(db_column='Address', max_length=60, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    birthdate = models.DateField(db_column='Birthdate', blank=True, null=True)  # Field name made lowercase.
    gender = models.CharField(db_column='Gender', max_length=1, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    phonenumber = models.CharField(db_column='PhoneNumber', unique=True, max_length=14, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    startingdate = models.DateField(db_column='StartingDate', blank=True, null=True)  # Field name made lowercase.
    salary = models.FloatField(db_column='Salary', blank=True, null=True)  # Field name made lowercase.
    employeetype = models.CharField(db_column='EmployeeType', max_length=1, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    departmentno = models.ForeignKey(Department, models.DO_NOTHING, db_column='DepartmentNo', blank=True, null=True)  # Field name made lowercase.
    
    def __str__(self):
        return f'{self.firstname} {self.lastname}'
    class Meta:
        managed = False
        db_table = 'EMPLOYEE'


class Factory(models.Model):
    traderegistrationnumber = models.CharField(db_column='TradeRegistrationNumber', primary_key=True, max_length=11, db_collation='Turkish_CI_AS')  # Field name made lowercase.
    factoryname = models.CharField(db_column='FactoryName', max_length=100, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    address = models.CharField(db_column='Address', max_length=100, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    phonenumber = models.CharField(db_column='PhoneNumber', unique=True, max_length=14, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    fax = models.CharField(db_column='Fax', unique=True, max_length=12, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'FACTORY'

    def __str__(self):
        return f'{self.factoryname}'


class FactoryProduct(models.Model):
    id = models.AutoField(db_column='ID', primary_key=True)  # Field name made lowercase.
    traderegistrationnumber = models.ForeignKey(Factory, models.DO_NOTHING, db_column='TradeRegistrationNumber')  # Field name made lowercase.
    productid = models.ForeignKey('UpsProduct', models.DO_NOTHING, db_column='ProductID')  # Field name made lowercase.
    quantity = models.IntegerField(db_column='Quantity', blank=True, null=True)  # Field name made lowercase.
    productiondate = models.DateField(db_column='ProductionDate', blank=True, null=True)  # Field name made lowercase.
    
    
    def __str__(self):
        return f'{self.productid.productname}'

    class Meta:
        managed = False
        db_table = 'FACTORY_PRODUCT'
        unique_together = (('id', 'traderegistrationnumber', 'productid'),)
   
  
class Item(models.Model):
    itemid = models.CharField(db_column='ItemID', primary_key=True, max_length=11, db_collation='Turkish_CI_AS')  # Field name made lowercase.
    itemtype = models.CharField(db_column='ItemType', max_length=150, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    unitprice = models.FloatField(db_column='UnitPrice', blank=True, null=True)  # Field name made lowercase.
    companyid = models.ForeignKey('SupplierCompany', models.DO_NOTHING, db_column='CompanyId', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ITEM'
    
    def __str__(self):
        return f'{self.itemtype}'


class OneOnePhase(models.Model):
    productid = models.OneToOneField('UpsProduct', models.DO_NOTHING, db_column='ProductID', primary_key=True)  # Field name made lowercase.
    frequencyconverterhz = models.FloatField(db_column='FrequencyConverterHZ', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ONE_ONE_PHASE'
    
    def __str__(self):
        return f'{self.productid.productname}'


class SupplierCompany(models.Model):
    companyid = models.CharField(db_column='CompanyID', primary_key=True, max_length=11, db_collation='Turkish_CI_AS')  # Field name made lowercase.
    companyname = models.CharField(db_column='CompanyName', max_length=35, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    address = models.CharField(db_column='Address', max_length=60, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    phonenumber = models.CharField(db_column='PhoneNumber', unique=True, max_length=14, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'SUPPLIER_COMPANY'
    
    def __str__(self):
        return f'{self.companyname}'


class SupplyRecord(models.Model):
    supplyno = models.AutoField(db_column='SupplyNo', primary_key=True)  # Field name made lowercase.
    itemid = models.ForeignKey(Item, models.DO_NOTHING, db_column='ItemID')  # Field name made lowercase.
    factorytraderegistrationnumber = models.ForeignKey(Factory, models.DO_NOTHING, db_column='FactoryTradeRegistrationNumber')  # Field name made lowercase.
    quantity = models.IntegerField(db_column='Quantity', blank=True, null=True)  # Field name made lowercase.
    supplydate = models.DateField(db_column='SupplyDate', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'SUPPLY_RECORD'
        unique_together = (('supplyno', 'itemid', 'factorytraderegistrationnumber'),)
    
    def __str__(self):
        return f'Supply ID:{self.supplyno}'


class ThreeOnePhase(models.Model):
    productid = models.OneToOneField('UpsProduct', models.DO_NOTHING, db_column='ProductID', primary_key=True)  # Field name made lowercase.
    inputpowerfactor = models.FloatField(db_column='InputPowerFactor', blank=True, null=True)  # Field name made lowercase.
    inputvoltagerange = models.FloatField(db_column='InputVoltageRange', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'THREE_ONE_PHASE'
    
    def __str__(self):
        return f'{self.productid.productname}'


class ThreeThreePhase(models.Model):
    productid = models.OneToOneField('UpsProduct', models.DO_NOTHING, db_column='ProductID', primary_key=True)  # Field name made lowercase.
    harmonicdistortionlevel = models.FloatField(db_column='HarmonicDistortionLevel', blank=True, null=True)  # Field name made lowercase.
    optinalpart = models.CharField(db_column='OptinalPart', max_length=500, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'THREE_THREE_PHASE'
    
    def __str__(self):
        return f'{self.productid.productname}'


class UpsProduct(models.Model):
    productid = models.CharField(db_column='ProductID', primary_key=True, max_length=20, db_collation='Turkish_CI_AS')  # Field name made lowercase.
    productname = models.CharField(db_column='ProductName', max_length=100, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    productprice = models.FloatField(db_column='ProductPrice', blank=True, null=True)  # Field name made lowercase.
    stock = models.IntegerField(db_column='Stock', blank=True, null=True)  # Field name made lowercase.
    engerysavingmode = models.CharField(db_column='EngerySavingMode', max_length=15, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    conversiontechnology = models.CharField(db_column='ConversionTechnology', max_length=30, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    standart = models.CharField(db_column='Standart', max_length=60, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    producttype = models.CharField(db_column='ProductType', max_length=3, db_collation='Turkish_CI_AS')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'UPS_PRODUCT'
    
    def __str__(self):
        return f'{self.productname}'


class Whitecollaremployee(models.Model):
    tckn = models.OneToOneField(Employee, models.DO_NOTHING, db_column='TCKN', primary_key=True)  # Field name made lowercase.
    gradutionmajor = models.CharField(db_column='GradutionMajor', max_length=75, db_collation='Turkish_CI_AS', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'WHITECOLLAREMPLOYEE'
    
    def __str__(self):
        return f'{self.tckn}'
