import random
import datetime

'''
Estimating the value of pi through random sampling.

The area of a circle of radius 1 is pi.
This circle fits inside a 2x2 square, which has an area of 4.
To estimate the value of pi we generate random points across
the square and count how many are inside the circle. The ratio of
points within and outside the circle should be approximately
equal to the ration of the area of the circle and the area of
the square, or pi/4.
'''

# Timing
t = datetime.datetime.now()

# Nummber of points to use for the Pi estimation
n = 1000000000

count = 0
for i in xrange(int(n)):

    '''Generate coordinates of point in square containing unit circle.
     x,y ~ U(-1,1)'''
    x = random.random() * 2.0 - 1
    y = random.random() * 2.0 - 1

    # Check if point is within circle
    if x * x + y * y <= 1:
        count += 1


'''The proportion of points within the circle should be approximately equal to the ratio
between the area of the circe (pi*1^2) and the square (2^2).
sum(count)/sum(par_args) = pi/4
pi = 4 * count/n
'''
pi = (count * 4.0) / n

# Timing
td = datetime.datetime.now() - t


print("""Finished generating {n} points in {time_delta} seconds.
PI is approximately {pi}""".format(n=n, time_delta=td.total_seconds(), pi=pi))
