from mpipool import MPIPool
import sys
import random
import datetime

'''
Estimating the value of pi through random sampling parallelised using MPI

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
def mpi_worker(n):
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




''' Create the worker pool from the MPIPool module (https://github.com/adrn/mpipool). This sets up the processes
    that will generate points to calculate pi. '''
pool = MPIPool()

"""Make sure only we run map() on the master process. Everything above this section of code will be run in all
processes. Everything that follows it will only run in the master process."""
if not pool.is_master():
    pool.wait()
    sys.exit(0)

'''Calculate the number of processes to run. MPIPool will workout the number
of processes, but in this case its useful information to help split up the work'''
N_NODES = 2
N_CORES_PER_NODE = 28
n_procs = N_NODES * N_CORES_PER_NODE

# Nummber of points to use for the Pi estimation
n = 100000000

'''Create list of containing the arguments to the worker function
   In this case we want to generate 'n' points across 'n_procs'
   processes, so each worker will calculate n/n_procs points.
   You can have more tasks than processes in the pool. The worker processes
   will keep going until all the tasks are complete.
   Note: We might not get exactly n points due to conversion of floats to ints,
   but we can calculate how many points are created by summing par_args.'''
task_args = [int(n / n_procs) for i in range(n_procs)]

'''map the problem across the pool of 'worker' processes, then collect the results
   into the variable 'count'. '''
count = pool.map(mpi_worker, task_args)
pool.close()

'''The proportion of points within the circle should be approximately equal to the ratio
   between the area of the circe (pi*1^2) and the square (2^2).
   sum(count)/sum(par_args) = pi/4
   pi = 4 * sum(count)/sum(par_args)'''
pi = (sum(count) * 4.0) / n

# Timing
td = datetime.datetime.now() - t

'''Print statements go to STDOUT. If this was an interactive session this would be the console, but if
   its run with a job scheduler (eg. torque) this may be redirected to an output file.'''

print("""Finished generating {n} points in {time_delta} seconds.
PI is approximately {pi}""".format(n=n,time_delta=td.total_seconds(), pi=pi))
