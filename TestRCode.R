#############################
#
# Step #2: Load all the libraries and data
#
#############################
#dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)
### Install multiple packages.
#install.packages(c("R2jags","boot","abind"), Sys.getenv("R_LIBS_USER"), repos = #"http://cran.case.edu", dependencies = "Imports")
install.packages(c("boot","abind"), repos = "http://cran.case.edu")

library(abind)
library(boot)

Concord<-read.csv("PLOSdataConcord.csv",header=T)


#############################
#
# Step #3: Do your calculation
#
#############################

y<-Concord$Aquilegia.canadensis
Temperature<-Concord$MAMTemp


trend<-cor(y,Temperature)


#############################
#
# Step #4: Save and output results
#
#############################

save(trned,file="TestRCode_output.Rdata")

options(scipen=5)
sink("TestRCode_output.txt")
trend
sink()