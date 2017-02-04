#! /bin/bash

source mysql.inf.sh
source get-pars.sh

if [ "${state}" ]; then
mysql -h${host} -u${user}  -p${password} ${database} <<!
update jobs set state="${state[@]}" where num=${id};
!
fi
