import random
import multiprocessing
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

'''worker function called in each process'''
def worker(n):
    count = 0
    for i in range(int(n)):

        '''Generate coordinates of point in square containing unit circle.
         x,y ~ U(-1,1)'''
        x = random.random() * 2.0 - 1
        y = random.random() * 2.0 - 1

        # Check if point is within circle
        if x * x + y * y <= 1:
            count += 1

    return count

"""Each worker process will import this file. Everything in the block below will
   only run in the initial process"""
if __name__ == '__main__':

    # Get the number of CPUs available
    n_procs = multiprocessing.cpu_count()
    print('{0:1d} CPUs available'.format(n_procs))

    # Nummber of points to use for the Pi estimation
    n = 1000000000

    '''Create list of containing the arguments to the worker function
       In this case we want to generate 'n' points across 'n_procs'
       processes, so each worker will calculate n/n_procs points.
       Note: We might not get exactly n points due to conversion of floats to ints,
       but we can calculate how many points are created by summing par_args'''
    par_args = [int(n / n_procs) for i in range(n_procs)]

    ''' Rather than creating processes manually we create a worker pool from the multiprocessing
    module. This sets up the processes that will generate points to calculate pi. You can create
    a pool with more processes than the number of CPUs available, but this will be slower.
    Seawulfs nodes each have 28 cores that can be used.
    http://docs.python.org/library/multiprocessing.html#module-multiprocessing.pool'''
    pool = multiprocessing.Pool(processes=n_procs)

    '''map the problem across the pool of 'worker' processes, then collect the results
    into the variable 'count'. '''
    count = pool.map(worker, par_args)

    '''The proportion of points within the circle should be approximately equal to the ratio
    between the area of the circe (pi*1^2) and the square (2^2).
    sum(count)/sum(par_args) = pi/4
    pi = 4 * sum(count)/sum(par_args)
    '''
    pi = (sum(count) * 4.0) / n

    # Timing
    td = datetime.datetime.now() - t

    '''Output is printed to STDOUT. If this was interactive this would be the console, but if
    its run with a job scheduler (eg. torque) this may be redirected to an output file.'''

    print("""Finished generating {n} points in {time_delta} seconds.
    PI is approximately {pi}""".format(n=n, time_delta=td.total_seconds(), pi=pi))
