from django.shortcuts import render
from .models import *

def index(request):
 return render(request,'web/index.html',{
    'employee': Employee.objects.all(),
    'b_employee': Bluecollaremployee.objects.all(),
    'w_employee': Whitecollaremployee.objects.all(),
    'customers':Customer.objects.all(),
    'customer_order':CustomerOrder.objects.all(),
    'departments':Department.objects.all(),
    'factories':Factory.objects.all(),
    'factory_products':FactoryProduct.objects.all(),
    'items':Item.objects.all(),
    'sup_companies':SupplierCompany.objects.all(),
    'sup_records':SupplyRecord.objects.all(),
    'ups_products':UpsProduct.objects.all(),
    'o_o_phase': OneOnePhase.objects.all(),
    't_o_phase':ThreeOnePhase.objects.all(),
    't_t_phase':ThreeThreePhase.objects.all()
 })

