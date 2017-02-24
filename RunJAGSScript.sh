#!/bin/bash

#PBS -l nodes=1:ppn=3,walltime=00:05:00
#PBS -N Occupancy
#PBS -q debug

module load shared
module load openblas/dynamic/0.2.18
module load R/3.3.2
module load mvapich2/gcc/64/2.2rc1
module load JAGS/4.2.0

cd $HOME
export R_LIBS=~/R_libs

Rscript TestJAGSCode_multicore.R
