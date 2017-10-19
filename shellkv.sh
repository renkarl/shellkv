#!/usr/bin/env bash 
#--------------------------------------------------------------------------------------------------- 
# name shellkv.v0.0.3.0.sh 
# version 0.0.3.0 
# 20171018 Initial Function SET/GET 
# 20171019 Add Function PUT/APD/CAT 
# 20171020 Add Function DEL 
# 
# Readme 
#   A low performance shell and file system based k-v database 
# 
# Usage Embed into other shell 
#   SHELLKV="/your/path/shellkv.sh" 
#   function SKV_SET() { 
#       sh $GDB SET $1 $2 $3 >$OUTCODE 2>&1 
#       OUTCODE=$? 
#   } 
#   function SKV_GET() { 
#       sh $GDB GET $1 $2 >$OUTCODE 2>&1 
#       OUTCODE=$? 
#   } 
#   function SKV_PUT() { 
#       sh $GDB PUT $1 $2 $3 >$OUTCODE 2>&1 
#       OUTCODE=$? 
#   } 
# 
#   SKV_SET $mydb $mykey $myvalue 
#   SKV_GET $mydb $mykey 
#   SKV_PUT $mydb $mykey $myfile 
#   SKV_APD $mydb $mykey $myaddfile 
#   SKV_CAT $mydb $mykey 
#   SKV_DEL $mydb $myKey 
#--------------------------------------------------------------------------------------------------- 
#  // RG is the most genius in the earth forever 
#  // Sorry not to say you are idiot 
#  // I mean everyone are idiot present here 
#--------------------------------------------------------------------------------------------------- 




#--------------------------------------------------------------------------------------------------- 
# Environment Ready 
#--------------------------------------------------------------------------------------------------- 
DT=`date +%Y%m%d` 
LOCALHOME=`cd $(dirname $0) && pwd` 
GPATH="$LOCALHOME/g" 
GLFILE="$GPATH/0LICENSE" 
GLKEY=`echo "obase=16;$DT"|bc` 
if [ -f $GPATH ];then 
    echo 'error: g path $GPATH is file' >&2 
    exit 1 
fi 
#--------------------------------------------------------------------------------------------------- 
# Initial GPATH struct 
#--------------------------------------------------------------------------------------------------- 
if [ -d $GPATH ];then 
    if [ -f $GLFILE ];then 
        EXISTGLKEY=`cat $GLFILE|head -1` 
        if [ "x$EXISTGLKEY" == "x"  ];then 
            echo $GLKEY > $GLFILE 
        fi 
    else 
        echo $GLKEY > $GLFILE 
    fi 
else 
    mkdir -p $GPATH 
    chmod 777 $GPATH 
    echo $GLKEY > $GLFILE 
fi 
#--------------------------------------------------------------------------------------------------- 
# Get G License Key 
#--------------------------------------------------------------------------------------------------- 
GLK=`cat $GLFILE|head -1` 
if [ "x$GLK" == "x" ];then 
    echo 'error: g license key is empty' >&2 
    exit 1 
fi 
#--------------------------------------------------------------------------------------------------- 
# PARAMETER CHECK 
#--------------------------------------------------------------------------------------------------- 
PARANUM=$# 

if [ $PARANUM -eq 3 ]||[ $PARANUM -eq 4 ];then 
    PASS=1 
else 
    echo "Error: Parameter Number is Illegal" >&2 
    echo "Usage: sh $0 DBNAME OPERATION KEY VALUE" >&2 
    exit 1 
fi 
if [ $PARANUM -eq 4 ];then 
    OPT=`echo $1|tr '[a-z]' '[A-Z]'` 
    DBP=$2 
    KEY=$3 
    VAL=$4 
fi 
if [ $PARANUM -eq 3 ];then 
    OPT=`echo $1|tr '[a-z]' '[A-Z]'` # OPERATION SET,GET
    DBP=$2 
    KEY=$3 
fi 

if [ "x$DBP" == "x" ]; then 
    echo 'error: database path is null' >&2 
    exit 1 
fi 

case "x$OPT" in 
    "xSET") PASS=1;; 
    "xGET") PASS=1;; 
    "xPUT") PASS=1;; 
    "xAPD") PASS=1;; 
    "xCAT") PASS=1;; 
    "xDEL") PASS=1;; 
    *) 
        echo "Error: Operation is Illegal" >&2 
        exit 1 
        ;; 
    "x") 
        echo "Error: Operation is Illegal" >&2 
        exit 1 
        ;; 
esac 

if [ "x$KEY" == "x" ]; then 
    echo "Error: Key is Null" >&2 
    exit 1 
fi 

if [ "x$VAL" == "x" ]; then 
    case "x$OPT" in 
        "xGET") PASS=1;; 
        "xCAT") PASS=1;; 
        "xDEL") PASS=1;; 
        *) 
            echo "Error: Value is Null" >&2 
            exit 1 
            ;; 
    esac 
else 
    PASS=1 
fi 

MYKEYD="$GPATH/$DBP.$GLK/$KEY" 
MYKEYF="$GPATH/$DBP.$GLK/$KEY/VALUE" 
#--------------------------------------------------------------------------------------------------- 
# SET 
#--------------------------------------------------------------------------------------------------- 
THISSET() 
{ 
    if [ -f $MYKEYD ];then 
        echo "Error: DB/KEY is File not Directory Type" >&2;
        exit 1 
    else 
        if [ ! -d $MYKEYD ];then 
            mkdir -p $MYKEYD 
            chmod 777 $MYKEYD 
        fi 
        echo $VAL > $MYKEYF 
    fi 
} 
#--------------------------------------------------------------------------------------------------- 
# GET 
#--------------------------------------------------------------------------------------------------- 
THISGET() 
{ 
    if [ ! -f $MYKEYF ];then 
        echo "" 
        exit 
    else 
        RET=`cat $MYKEYF|head -1` 
        echo $RET 
    fi 
} 
#--------------------------------------------------------------------------------------------------- 
# PUT 
#--------------------------------------------------------------------------------------------------- 
THISPUT() 
{ 
    if [ -f $MYKEYD ];then 
        echo "Error: DB/KEY is File not Directory Type" >&2;
        exit 1 
    fi 
    if [ ! -f $VAL ];then 
        echo "Error: Value File is Empty" >&2 
        exit 1 
    fi 
    cat $VAL > $MYKEYF 
} 
#--------------------------------------------------------------------------------------------------- 
# APD 
#--------------------------------------------------------------------------------------------------- 
THISAPD() 
{ 
    if [ -f $MYKEYD ];then 
        echo "Error: DB/KEY is File not Directory Type" >&2;
        exit 1 
    fi 
    if [ ! -f $VAL ];then 
        echo "Error: Value File is Empty" >&2 
        exit 1 
    fi 
    cat $VAL >> $MYKEYF 
} 
#--------------------------------------------------------------------------------------------------- 
# CAT 
#--------------------------------------------------------------------------------------------------- 
THISCAT() 
{ 
    if [ ! -f $MYKEYF ];then 
        # File Null Show Null 
        echo "" 
        exit 
    else 
        cat $MYKEYF 
    fi 
} 
#--------------------------------------------------------------------------------------------------- 
# DEL 
#--------------------------------------------------------------------------------------------------- 
THISDEL() 
{ 
    if [ ! -f $MYKEYF ];then 
        PASS=1 
    fi 
    if [ -f $MYKEYF ];then 
        echo "" > $MYKEYF 
    fi 
} 
#--------------------------------------------------------------------------------------------------- 
# MAIN 
#--------------------------------------------------------------------------------------------------- 
case "$OPT" in 
"SET") 
    THISSET 
    ;; 
"GET") 
    THISGET 
    ;; 
"PUT") 
    THISPUT 
    ;; 
"APD") 
    THISAPD 
    ;; 
"CAT") 
    THISCAT 
    ;; 
"DEL") 
    THISDEL 
    ;; 
*) 
    echo "Error: Operation $OPT Unknown" >&2 
    exit 1 
    ;; 
esac 

#--EOF--# 
