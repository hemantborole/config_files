#!/bin/bash

LOG="deploy.log"

## usage
function usage {
  echo
  echo "    Usage:        deploy_watson <ssh-key> <server> [watson_dir] [channels]"
  echo
  echo "  - ssh-key       (required) identity file"
  echo "  - server        (required) remote server on which you intend to install watson."
  echo "                  Can take the form user@server:dest_dir."
  echo "                  user defaults to root, dest_dir is the directory where watson will "
  echo "                  be installed on <server> defaults to /opt/watson"
  echo "  - watson_dir    defaults to /opt/watson, directory on your local(this) machine"
  echo "                  where watson is successfully built"
  echo "  - channels      Number of channels to start watson with"
  echo
}

function logit {
  if [ -f $LOG ]
  then
    echo $1 |tee -a $LOG
  else
    touch $LOG
    if [ $? -ne 0 ]
    then
      echo "Could not create log. Make sure your current directory is writable"
      exit -1
    fi
  fi
}

## Check existence and permissions of ssh key
function verify_key {
  if [[ ! -s $1 ]]
  then
    logit "File $1 does not exist, please use a key file with 600 permissions"
    exit -1
  elif [[ `ls -l $1|awk '{print $1}'` != "-rw-------" ]]
  then
    logit "File $1 should have 600 permissions, exiting.."
    exit -1
  fi
  key=$1
}
## deploy remote environment
function remote_cfg {
  logit "Setting configuration for remote server"
  server=$2
  user=root
  dest_dir=/opt

  if [[ "x$2" == "x" ]]
  then
    logit "Server name missing. Aborting.."
    exit -1
  fi

  if [[ "$2" == "*@*" ]]
  then
    user=`echo $2|awk -F'@' '{print $1}'`
    server=`echo $2|awk -F'@' '{print $2}'`
    if [[ "$server" == "*:*" ]]
    then
      server=`echo $server|awk -F':' '{print $1}'`
      dest_dir=`echo $server|awk -F':' '{print $2}'` 
    fi
  fi

}

## local Watson environment
function local_watson_cfg {
  WATSON_HOME=${3:-/opt/watson}
  arch=`uname -m`
  os=`uname|awk '{print tolower($0)}'`
  gccv=`gcc --version|grep '^gcc'|awk '{print $1substr($3,0,3)}'`
  pyv=`python --version 2>&1 |awk '{print tolower(substr($1,0,2))substr($2,0,3)}'`

  build_dir_str=`echo ${arch}-${os}-${gccv}-${pyv}`
  BUILD_DIR=$WATSON_HOME/${build_dir_str}
  bundle=${BUILD_DIR}.tgz
  channels=${4:-4}
  hstart
  watsond_cmds
}


function tar_bundle {
  if [[ ! -s $bundle ]]
  then
    tar zcvf ${bundle} ${BUILD_DIR} 1>> $LOG 2>&1
    if [ $? -ne 0 ]
    then
      logit "Tarring failed. See $LOG for details. Aborting.."
      exit -1
    fi
  fi
}

function remote_execs {
  remote_cfg $@
  rsync -avz -e "ssh -i ${key}" $bundle ${user}@${server}:/tmp/.
  ssh -i ${key} ${user}@${server} "tar -C ${dest_dir} zxvf /tmp/${bundle}"
  ssh -i ${key} ${user}@${server} "rm -f ${dest_dir}/watson 2>/dev/null && ln -f -s ${BUILD_DIR} ${dest_dir}/watson"
  rsync -avz -e "ssh -i ${key}" /tmp/watsond.ypc.cmds ${user}@${server}:${dest_dir}/watson/.
  rsync -avz -e "ssh -i ${key}" /tmp/hstart ${user}@${server}:/etc/init.d/. 2>$LOG
  if [ $? -ne 0 ]
  then
    logit "Warning !! Could not copy init scripts."
    logit "You will have to manually transfer /tmp/hstart from local host to ${server}:/etc/init.d"
    logit "See $LOG for details."
  fi
}

function main {
  verify_key $1
  local_watson_cfg $@
  tar_bundle 
  remote_execs $@
}


if [[ $# -ne 2 && $# -ne 3 && $# -ne 4 ]]
then
  usage
  exit -1
fi


### This is static text, no code below this.
## hstart.sh <number of channels>
function hstart {
hstart='
#!/bin/sh
# /etc/inid.d/hstart

if [ $# -eq 0 ]
then
  arg="start"
else
  arg="$1"
fi

case "${arg}" in
  start)
    WATSON_BASE=/opt/watson/x86_64-linux-gcc4.3-py2.6
    export PATH=${WATSON_BASE}/bin:/usr/local/bin:/bin:/usr/bin
    watsond'
hstart="${hstart} ${channels} "'${WATSON_BASE}/../watsond.ypc.cmds --protocol=wirehttp --port=8080 --daemonize=${WATSON_BASE} --log-dir=${WATSON_BASE}/logs --trace-level=info&
    ;;
  stop)
    pkill watson
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
'
echo "$hstart" > /tmp/hstart
}

function watsond_cmds {
  watsond_cmds='def DATAPATH="/grammars:${DATAPATH}"

def HANDLER_DIR = "${WATSON_ROOT}/var/watsond/http"
def TTS_HOST = "localhost:7000"
httpConfig { "/asr  : $HANDLER_DIR/asr.py",
            "/nlu  : $HANDLER_DIR/nlu.py"
            "/xlog : $HANDLER_DIR/xlog.py",
            "/smm/watson : $HANDLER_DIR/asr.py",
            "/smm/nlp    : $HANDLER_DIR/nlu.py",
            "/smm/logCorrection : $HANDLER_DIR/xlog.py",
            "/smm/tts : $HANDLER_DIR/tts.py" }'
echo "$watsond_cmds" > /tmp/watsond.ypc.cmds
}

main $@

