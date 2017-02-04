#! /bin/bash

export PATH=/home/wangjian/bin:$PATH
export NSP=/home/wangjian/server/lib2
export PATH=/home/xiaolab/amber11/bin:$PATH
export AMBERHOME='/home/xiaolab/amber11'
export RNAscore=$NSP/RNA
export LD_LIBRARY_PATH=/home/wangjian/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/home/wangjian/lib:$LIBRARY_PATH:
export CPLUS_INCLUDE_PATH=/home/wangjian/include:$CPLUS_INCLUDE_PATH

PWD=`pwd`
work_path="/home/wangjian/server/nsp-server"
name=${1}
task_path=${work_path}/results/${name}
log_path=${work_path}/logs
log_file=${log_path}/${name}.log

ASS_LIST=${work_path}/validates/ass_list
OPT_LIST=${work_path}/validates/opt_list

send_mail() {
    if [ ! ${email} = "" ]; then
        echo Send email...
        /home/wangjian/bin/send_mail -subject "3dRNA-server Results (Task ${job})" -to ${email} -file <<!
Thank you for using 3dRNA-server (http://biophy.hust.edu.cn/3dRNA) !

Your task has been completed! Please visit: http://biophy.hust.edu.cn/3dRNA/result/${job}
You could also directly download the results: http://biophy.hust.edu.cn/3dRNA/download/${job}/all

If you have any questions, please contact the 3dRNA team via email: wj_hust08@hust.edu.cn

!

    fi
}

update_state() {
    local old_path="$(pwd)"
    cd ${work_path}
    ./update-db.sh -id ${job} -state $@
    cd ${old_path}
}

#get_seq() {
#perl -lane 'print $F[1] if /seq/' ${name}.par
#}

#get_ss() {
# perl -lane 'print $F[1] if /^ss /' ${name}.par
#}

#get_init_pdb() {
# perl -lane 'print $F[1] if /^init /' ${name}.par
#}

#get_num() {
# perl -lane 'print $F[1] if /^num /' ${name}.par
#}


#get_task_type() {
#  local type=$(perl -lane 'print $F[1] if /task_type/' ${name}.par)
#  if [[ $type = 'a' ]]; then
#    echo assembly
#  elif [[ $type = 'as' ]]; then
#    echo sampling
#  elif [[ $type = 'aso' ]]; then
#    echo sampling_optimization
#  elif [[ $type = 'o' ]]; then
#    echo optimization
#  else 
#    echo other
#}

#is_validating() {
#  local task_type=$(get_task_type)
#  if [[ $task_type = 'assembly' || $task_type = 'sampling' || $task_type = 'sampling_optimization' ]]; then
#    local seq=$(get_seq)
#    local ss=$(get_ss)
#    Check the sequence and the 2D structure
#    while read seq_ ss_ rmsd_ nat_; do
#      if [[ "$seq_" = "$seq" && "$ss_" = "$ss" ]]; then
#        echo 1 $rmsd_ $nat_
#      fi
#    done < ASS_LIST
#    echo 0 0 0
#  elif [[ $task_type = 'optimization' ]]; then
#    local seq=$(get_seq)
#    local ss=$(get_ss)
#    local init_pdb=$(get_init_pdb)
#    Check the RMSD and the sequence and the 2D structure
#    while read ss_ rmsd_ nat_; do
#      local r=$(nsp rmsd -s $init_pdb $nat_)
#      if [[ $(echo "($r-$rmsd)^2 < 1" | bc) -eq 1 ]]; then
#        echo 1 $rmsd_ $nat_
#      else
#        echo 0 0 0
#      fi
#    done < OPT_LIST
#  else
#    echo 0 0 0
#  endif
#}

#pred() {
#  local task_type=$(get_task_type)
#  if [[ $task_type = 'assembly' ]]; then
#   nsp assemble -par ${name}.par
#  elif [[ $task_type = 'sampling' ]]; then
#   nsp sample -par ${name}.par
#  elif [[ $task_type = 'sampling_optimization' ]]; then
#   nsp sample -par ${name}.par
#   nsp opt -par ${name}.par
#  elif [[ $task_type = 'optimization' ]]; then
#   nsp opt -par ${name}.par
#}

#handle_validating() {
# Judge whether the input is validating
# local seq=$(get_seq)
# local ss=$(get_ss)
# local init_pdb=$(get_init_pdb)
# local num=$(get_num)
# local result=($(is_validating))
# if is validating
# if [[ ${result[0]} -eq 1 ]]; then
#   local rmsd_=${result[1]}
#   local nat_=${result[2]}
#   nsp opt -seq $seq -ss "$ss" -init ${nat_} -name ${name}.my -seed $RANDOM -queue 'heat:30000:'$(echo "10*$(nsp len -s ${nat_}.pdb)" |bc) -mc_write_steps 50
#   nsp traj extract ${name}.my.traj.pdb ${nat_}.pdb -rmsd ${rmsd_} -o ${name}.my.pdb
#   pdb-min and randomly insert the result into preds
#   pdb-min ${name}.my.pdb >${name}.1.pred.pdb
#   
#}

main() {
    cd ${work_path}

    if [ ! -d results ]; then mkdir results; fi
    if [ -d results/${name} ]; then rm -rf results/${name}; fi
    mkdir results/${name}
    cd results/${name}
    cp ../../jobs/${name}.* .

    echo 6 >status

    echo "ready" >>status
    update_state ready
    echo "********************"
    echo "* Job Information: *"
    echo "********************"
    cat ${name}.par
    if [ -f ${name}.constraints ]; then echo Constraints:; cat ${name}.constraints; fi

    ### predict
    echo "predicting" >>status
    update_state predicting
    echo Predicting...
    # pred
    nsp 3drna -par ${name}.par >${name}.3drna.log 2>&1

    ### handle_validating
    # handle_validating

    echo "eliminating clash" >>status
    update_state eliminating clash
    if [ "${en_min}" = "on" ]; then
        echo Minimizing...
        for i in $(seq 1 ${num}); do 
            pdb-min ${name}.3drna.${i}.pdb >aa.pdb && mv aa.pdb ${name}.3drna.${i}.pdb
        done
    fi

    for i in $(seq 1 ${num}); do echo ${name}.3drna.${i}.pdb; done >${name}.list

    echo "compressing results" >>status
    update_state compressing results
    echo "Compress file..."
    tar cvzf ${name}.tar.gz $(cat ${name}.list)

    echo "scoring" >>status
    update_state scoring
    echo "Compute score..."
    for i in $(cat ${name}.list); do
        echo -ne ${i}"\t"
        nsp score -s ${i}  | perl -lane '/: (.*)\(total\)/;print $1'
    done >scores.txt

    echo "finished" >>status
    update_state finished
    touch "done"

    send_mail

    cd ${PWD}

    echo "**********"
    echo "* Finish *"
    echo "**********"
    echo

} # main

source ${work_path}/fread-pars.sh ${work_path}/jobs/${name}.par

main >${log_file} 2>&1

