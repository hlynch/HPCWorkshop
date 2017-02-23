#!/bin/bash
#PBS -l nodes=1:ppn=28,walltime=00:05:00
#PBS -N multiproc_pi
#PBS -q short

module load shared
module load mvapich2/gcc/64/2.2rc1
module load anaconda/2

cd $HOME/python_hpc
python pi_multiprocessing.py
