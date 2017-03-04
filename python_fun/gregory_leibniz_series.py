# This script approximates pi using the Gregory Leibniz series.
from time import sleep
from decimal import *
from math import pi
from math import log10
from math import floor
getcontext().prec = 40
print("Hello, I will approximate pi using the Gregory Leibniz series by iterations.")
m = input("How many iterations do you want me to perform ?")
n = 1
p = 0
pos = True
while n < 2*int(m):
	if pos:
	    p += Decimal(1/n)
	else:
		p -= Decimal(1/n)
	pos = not pos
	#print(Decimal(p*4))
	n += 2
	#sleep(0.001)
print("="*50)
print("Estimated pi: ",Decimal(p*4))
print("Difference with real pi: ", float(p*4)-pi)
print("="*50)
