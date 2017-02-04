#! /bin/bash

task_id=${1}
email=${2}
/home/wangjian/bin/send_mail -subject "3dRNA-server Results (Task ${task_id})" -to ${email} -file <<!
Thank you for using 3dRNA-server (http://biophy.hust.edu.cn/3dRNA) !

Your task has been completed! Please visit: http://biophy.hust.edu.cn/3dRNA/result/${task_id}
You could also directly download the results: http://biophy.hust.edu.cn/3dRNA/download/${task_id}/all

If you have any questions, please contact the 3dRNA team via email: wj_hust08@hust.edu.cn

!
