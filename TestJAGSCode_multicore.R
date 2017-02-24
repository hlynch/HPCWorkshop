#############################
#
# Step #1: Load all the libraries and data
#
#############################
dir.create("R_libs", showWarnings = FALSE, recursive = TRUE)

install.packages(c("boot","abind","snowfall","R2WinBUGS"),lib="R_libs", repos = "http://cran.case.edu")

library(rjags)
library(R2jags)
library(abind)
library(boot)
library(snowfall)
library(R2WinBUGS)

Concord<-read.csv("PLOSdataConcord.csv",header=T)


#############################
#
# Step #2: Make a list where you include all the data the model will need to run
#
#############################

Dat <- list(
  y=Concord$Aquilegia.canadensis,
  Temperature=Concord$Year
)
#############################
#
# Step #3: Make a function (with no inputs) where you put a list of parameters and their initial values
#
#############################

InitStage <- function() {list(alpha=1,beta=1,tau=100)}

#############################
#
# Step #4: Make a column vector with the names of the parameters you want to track
#
#############################

ParsStage <- c("alpha","beta","sigma")

#############################
#
# Step #5: Set the variables for the MCMC
#
#############################

ni <- 11000  # number of draws from the posterior
nt <- 5    #thinning rate
nb <- 1000  # number to discard for burn-in
nc <- 2  # number of chains

#############################
#
# Step #6: Run the jags function to run the code
#
#############################

JAGSParallelized = function(Index, jags.seed.vec, inits, model.file, data, working.directory=NULL, params, n.thin, n.iter, n.burnin, DIC){
  RNGset = c("Mersenne-Twister","Marsaglia-Multicarry","Super-Duper","Knuth-TAOCP-2002","Knuth-TAOCP","Wichmann-Hill","L'Ecuyer-CMRG")
  set.seed(1,kind=RNGset[Index])
  random.seed = runif(1,1,1e6)
  Jags = jags(inits=inits, n.chains=1, model.file=model.file, working.directory=working.directory, data=data, parameters.to.save=params, n.thin=n.thin, n.iter=n.iter, n.burnin=n.burnin, DIC=DIC)
  return(Jags)
}


JAGSParallel = function(n.cores,data,inits,params,model.file,debug,n.chains,n.iter,n.burnin,n.thin,DIC=FALSE){
  # Start snowfall
  sfInit(parallel=TRUE, cpus=n.cores)
  sfLibrary(R2jags)
  sfLibrary(snowfall)
  sfExportAll()
  sfClusterCall( runif, 4 )
  jags.seed.vec = ceiling(runif(n.chains,1,1e6))
  # Run JAGS
  JAGSList <- sfLapply(1:n.chains, JAGSParallelized, jags.seed.vec =jags.seed.vec, data=data, inits=inits, params=params,
                       model.file= model.file, n.iter=n.iter, n.burnin=n.burnin, n.thin=n.thin, DIC=DIC)
  # End snowfall
  sfStop()
  result <- NULL
  model <- NULL
  for (ch in 1:n.chains) {
    result <- abind(result, JAGSList[[ch]]$BUGSoutput$sims.array, along = 2)
    model[[ch]] <- JAGSList[[ch]]$model
  }
  result <- as.bugs.array(result, model.file = model.file,program = "jags", DIC = DIC, n.iter = n.iter, n.burnin = n.burnin,n.thin = n.thin)
  out <- list(model = model, JAGSoutput = result, parameters.to.save = params, model.file = model.file, n.iter = n.iter, DIC = DIC)
  class(out) <- c("rjags.parallel", "rjags")
  return(out)
}

system.time(m<-JAGSParallel(3,data=Dat, inits=InitStage, params=ParsStage, model.file= "TestJAGSCode.jags", n.chains=nc, n.iter=ni, n.burnin=nb, n.thin=nt))


#############################
#
# Step #7: Print the sumamry and explore the object that was returned
#
#############################

save(m,file="TestJAGSCode_output.Rdata")

options(scipen=5)
sink("TestJAGSCode_output.txt")
m$JAGSoutput$summary
sink()