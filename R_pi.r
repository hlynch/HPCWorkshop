install.packages(c("snowfall"), repos = "http://cran.case.edu")
library(snowfall)

#Timing
t = proc.time()

# Initialisation of snowfall.
n_cpus = 28
n = 100000000
sfInit(parallel=TRUE, cpus=n_cpus)

# Worker function which will be run `n_cpus` times in parallel.
worker <- function(n) {
    count <- 0
    for(i in 1:n){
        x = runif(1,-1,1)
        y = runif(1,-1,1)
        if((x^2 + y^2) <= 1){
            count = count + 1
        }
    }
    return(count)
}

# If you have data or packages that are used in your worker function they
# need to be sent using sfExport and sfLibrary respectively.
#   sfExport()
#   sfLibrary()

# Start network random number generator so that each processes generates different numbers
sfClusterSetupRNG()

# Distribute calculation
iters_per_cpu <- n/n_cpus
tasks <- rep(iters_per_cpu,n_cpus)

# sfLapply calls the worker function on each element of the tasks list and returns a list
# containing the result from each process.
result <- sfLapply(tasks, worker)

# Stop snowfall
sfStop()

# Result is always in list form.
pi = (sum(unlist(result))*4)/n

# Timing
td = proc.time() - t

sprintf("Finished generating %s points in %s seconds. PI is approximately %s",n,td[3],pi)