#!/bin/bash 
#SBATCH --account=bas_pog
#SBATCH --partition=standard
#SBATCH --qos=long
#SBATCH -o subm_out/%j.+++n+++.out 
#SBATCH -e subm_out/%j.+++n+++.err
#SBATCH --time=3-00:00:00
#SBATCH --job-name=T25_+++n+++
#SBATCH --mem=80000
# executable 
