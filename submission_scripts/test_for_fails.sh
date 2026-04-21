#!/bin/bash

export DIR=${SCRATCH}/ORCA025/OUTPUT/
##export DIR=/gws/nopw/j04/bas_pog/astyles/ORCA025_fwd/

export fail_list=($(grep -lir "ERROR:" ${DIR}/*/TRACMASS.*.out ))

echo  "Failed experiment numbers" > n_fail.out


for fail in "${fail_list[@]}"
do
   export keystr=$(echo ${fail} | cut -d '.' -f 2 )
   export n=$(echo ${keystr} | cut -d '_' -f 2)
   
   echo ${keystr}
   echo ${n} >> n_fail.out

   sleep 3
   sbatch subm_script_template.${keystr}.sh
done
