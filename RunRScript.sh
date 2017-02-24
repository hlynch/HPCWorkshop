#!/bin/bash

#PBS -l nodes=1:ppn=1,walltime=00:05:00
#PBS -N Occupancy
#PBS -q debug

module load shared
module load torque/6.0.2
module load openblas/dynamic/0.2.18
module load R/3.3.2

cd $HOME
export R_LIBS=~/R_libs

Rscript TestRCode.R
