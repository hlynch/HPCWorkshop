#############################
#
# Step #1: Load the data
#
#############################

Concord<-read.csv("PLOSdataConcord.csv",header=T)

#############################
#
# Step #2: Do your calculation
#
#############################

y<-Concord$Aquilegia.canadensis
Temperature<-Concord$MAMTemp


trend<-cor(y,Temperature,use="complete.obs")


#############################
#
# Step #3: Save and output results
#
#############################

save(trend,file="TestRCode_output.Rdata")

options(scipen=5)
sink("TestRCode_output.txt")
trend
sink()