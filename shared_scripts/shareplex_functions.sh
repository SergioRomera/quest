function plex
{
        SP_COP_UPORT=2100; export SP_COP_UPORT
        SP_COP_TPORT=2100; export SP_COP_TPORT
        SP_SYS_HOST_NAME=`uname -n`; export SP_SYS_HOST_NAME
        SP_SYS_VARDIR=/u01/app/quest/vardir/2100; export SP_SYS_VARDIR
        SP_HOME=/u01/app/quest/shareplex9.2; export SP_HOME
        SP_LIB_PATH=/u01/app/quest/shareplex9.2/lib; export SP_LIB_PATH
        alias goplex='cd $SP_HOME/bin'
        alias golog='cd $SP_SYS_VARDIR/log'
        alias gocop='$SP_HOME/bin/sp_cop -u2100 &'
        alias spc='$SP_HOME/bin/sp_ctrl'

        PATH=$SP_HOME/bin:$PATH; export PATH
}
function plex2200
{
        #ORACLE_SID=SIONPS1; export ORACLE_SID
        SP_COP_UPORT=2200; export SP_COP_UPORT
        SP_COP_TPORT=2200; export SP_COP_TPORT
        SP_SYS_HOST_NAME=`uname -n`; export SP_SYS_HOST_NAME
        SP_SYS_HOST_NAME=osboxes; export SP_SYS_HOST_NAME
        SP_SYS_VARDIR=/Quest/Shareplex/vardir/2200; export SP_SYS_VARDIR
        SP_HOME=/Quest/Shareplex/9.1.4; export SP_HOME
        SP_LIB_PATH=/Quest/Shareplex/9.1.4/lib; export SP_LIB_PATH
        alias goplex='cd $SP_HOME/bin'
        alias golog='cd $SP_SYS_VARDIR/log'
        alias gocop='$SP_HOME/bin/sp_cop -u2200 &'
        PATH=$SP_HOME/bin:$PATH; export PATH
}
plex
