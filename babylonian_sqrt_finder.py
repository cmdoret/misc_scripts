# This script calculates the square root of a given number (R).
# It starts from a wild guess (a) and refine the result at every iteration:
# R/a(n)=b(n) --> (a(n)+b(n))/2 = a(n+1)

from time import sleep
print("Hi, I'ma simple program that tries to guess the square root of a given number.")
radicand = float(input("What number do you want to know the square root of ? \n>"))
guess = float(input("Give me a number to start with ! \n>"))

divider = round(radicand/guess,4)
count = 1
exact = True
while (abs(divider-guess)>0.001):
	print("Iteration number %i" % count)
	print("%f is not the right answer." % guess)
	divider = round(radicand/guess,4)
	guess = round((guess+divider)/2,4)
	sleep(0.1)
	count += 1
print("After {0} iterations, I found that the answer is approximately {1:.3f}".format(count,guess))

	
