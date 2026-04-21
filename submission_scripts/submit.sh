#!/bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> "
echo "SUBMITTING TRACMASS JOB TO LOTUS"
echo "submit.sh "
date

export PROJECT="NEMO"  #TRACMASS PROJECT (as defined in Tracmass/Makefile)
export CASE="ORCA025"   #TRACMASS CASE   (as defined in Tracmass/Makefile)
export COMPILE=true    #Compile executables if true
export BENCHMARK=false   #Only compile and submit one executable

echo "Project is:", ${PROJECT}
echo "Case is:" ${CASE} 

export TM_DIR="/home/users/afstyles/Tracmass"
echo "Tracmass directory is: " ${TM_DIR}


export NAM_PATH="${TM_DIR}/projects/${PROJECT}/namelist_${CASE}.in"
echo "Namelist path: ${NAM_PATH}"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

echo "Read namelist for seedfile location"
export NAMLINE=$(grep -ui '+++SEEDDIR+++' ${NAM_PATH})

SEEDDIR=$(echo $(grep -ui '+++SEEDDIR+++' ${NAM_PATH} | awk -F [\',\'] '{print $2}'))
echo "Seedfile directory: ${SEEDDIR}"
SEEDFILES=$(ls ${SEEDDIR}/seed_chunk* | xargs -n 1 basename )


echo "Creating namelists for seeding chunks"
n=1

for FILE in ${SEEDFILES}; do
    export LABEL=$(echo ${FILE} | awk -F ".csv" '{print $1}')
    export NAM_CHUNK_PATH=${TM_DIR}/projects/${PROJECT}/namelist_${CASE}_${n}.in
    export OUTDIR="out_${LABEL}"
    echo ${n}

    cp ${NAM_PATH} ${NAM_CHUNK_PATH}

    #Set output subdirectory
    OUTDIR=$(echo $(grep -ui '+++OUTDIR+++' ${NAM_CHUNK_PATH} | awk -F [\',\'] '{print $2}'))
    OUTDIR=$(echo ${OUTDIR} | sed -e "s/+++OUTDIR+++/out_${LABEL}/g")
    sed -i "s/+++OUTDIR+++/out_${LABEL}/" ${NAM_CHUNK_PATH}

    if [ ! -d ${OUTDIR} ] ; then
        mkdir ${OUTDIR}
    fi

    #Set SEEDFILE
    sed -i "s/+++SEEDFILE+++/${FILE}/g" ${NAM_CHUNK_PATH}

    #Set SUBSAMPLEFILE
    sed -i "s/+++SUBSAMPLEFILE+++/random.${FILE}/g" ${NAM_CHUNK_PATH}

    #Set LABEL
    sed -i "s/+++LABEL+++/${LABEL}/g" ${NAM_CHUNK_PATH}

    #Compile executable
    if [ ${COMPILE} = true ] ; then

        echo ${OUTDIR}
        echo ${LABEL}
        
        cd ${TM_DIR}
        cp Makefile Makefile.original
        sed -i "s/${CASE}/${CASE}_${n}/g" Makefile
        sed -i "s/runtracmass/runtracmass_${CASE}_${n}/g" Makefile
        
        make clean > ${OUTDIR}/compile.${n}.out
        make > ${OUTDIR}/compile.${n}.out
        cp Makefile ${OUTDIR}/Makefile.${n}.out
        mv Makefile.original Makefile
        cd submission_scripts
    fi

    #Prepare submission script
    cp subm_script_template.sh subm_script_template.${CASE}_${n}.sh

    sed -i "s/+++n+++/${CASE}_${n}/g" subm_script_template.${CASE}_${n}.sh
    echo "cd ${TM_DIR}" >> subm_script_template.${CASE}_${n}.sh
    echo "cp -v ${NAM_CHUNK_PATH} ${OUTDIR}/namelist_${CASE}_${n}.in " >> subm_script_template.${CASE}_${n}.sh
    echo "./runtracmass_${CASE}_${n} > ${OUTDIR}/TRACMASS.${CASE}_${n}.out" >> subm_script_template.${CASE}_${n}.sh
    echo "seff \$SLURM_JOBID >> ${OUTDIR}/TRACMASS.${CASE}_${n}.out" >> subm_script_template.${CASE}_${n}.sh

    if [ ${COMPILE} = false ] ; then
       sleep 3
    fi

    sbatch subm_script_template.${CASE}_${n}.sh

    n=$(($n+1))

    if [ ${BENCHMARK} = true ] ; then
        break
    fi

done
echo "Complete"
echo ""




# export SEEDDIR= $(echo ${NAMLINE} | awk -F \x27 '{print $1}')
# echo ${NAMLINE}
# echo ${SEEDDIR}

