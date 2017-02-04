#! /bin/bash

export NSP=/home/wangjian/server/lib2
export PATH=/home/wangjian/bin:$PATH
export LD_LIBRARY_PATH=/home/wangjian/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/home/wangjian/lib:$LIBRARY_PATH:
export CPLUS_INCLUDE_PATH=/home/wangjian/include:$CPLUS_INCLUDE_PATH

nsp tri2d -seq ${1}
