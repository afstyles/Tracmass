#!/bin/bash

# Shell script for identifying runs which fail, 
# most likely because of simultaneous attempts to access model data

# Specify OUTPUT directory for TRACMASS run
export DIR=${SCRATCH}/ORCA025/OUTPUT/

export fail_list=($(grep -lir "ERROR:" ${DIR}/*/TRACMASS.*.out ))

echo  "Failed experiment numbers" > n_fail.out


for fail in "${fail_list[@]}"
do
   export keystr=$(echo ${fail} | cut -d '.' -f 2 )
   export n=$(echo ${keystr} | cut -d '_' -f 2)
   
   echo ${keystr}
   echo ${n} >> n_fail.out

   # Resubmit failed experiments (comment out if you just wish for a list of failed experiments)
   sleep 3
   sbatch subm_script_template.${keystr}.sh
done
