#!/bin/bash

function usage {
  echo '
  Usage: pull_watson [-hqfsb] [-w watson_dir] [-p port] [-c channels] [-g grammar_di] [-a AM] [-l LM] [-n NLP] [-t TTS] [i]

  -h  Print this help message
  -q  Quiet mode. Most messages will be suppressed. But everything is logged.
  -f  Force overwriting files if they already exist.
  -s  Install initialization softwares and dependencies (apt-get or yum)
  -b  Request watson build. The build file will be detected based on your OS.
  -w  <directory>  Directory where watson is (or will be) installed. The option
                   -b will install watson in this directory.
                   Default '/opt/watson'
  -p <port>        Port on which watson will run after installation.
                   Default 8080
  -c <channels>    Number of channels to run watson with.
                   Default 4
  -g <grammar>     Directory where grammars will be deployed.
                   Default /mnt
  -a <AM>          Request the particular AM. If this is left blank, put it as
                   a space in quotes. In this situation all available AM will
                   be pulled. Working on specifying multiple AM.
  -l <LM>          Same as above but for LM data.
  -n <NLM>         Same as above but for NLM data.
  -t <TTS>         Same as above but for TTS data.
  -i  Install watson i.e. deploy hstart and watsond.cmds file.
  '
  exit 0
}

function logit {
  if [ ! -f $LOG ]
  then
    touch $LOG
    if [ $? -ne 0 ]
    then
      echo "Could not create log. Make sure your current directory is writable"
      exit -1
    fi
  fi
  if [[ ! -z $quiet ]]
  then
    echo $1 >> $LOG
  else
    echo $1|tee -a $LOG
  fi
}

function abs_path {
  if [[ "`echo $1|cut -c1`" == "/" ]]
  then
    echo "$1"
  else
    echo "$PWD/$1"
  fi
}


function install_softwares {
  ## update repo.
  sudo apt-get update 1>> $LOG

  ## install build tools for watson
  sudo apt-get -y install wget build-essential cmake 1>>$LOG
  sudo ln -f -s /usr/bin/make /usr/bin/gmake

  ## watson library dependencies. in order.
  sudo apt-get -y install python-dev uuid-dev liblapack-dev libgfortran3 gfortran libclucene-dev 1>> $LOG

  ## ruby for s3 stuff
  #sudo apt-get -y install openssl ruby rubygems1.9.1 libopenssl-ruby libssl-dev
  sudo apt-get -y install s3cmd 1>> $LOG
}


## start watson deployment by pull mechanism
LOG=pull_watson.log
S3_BASE=/ypcsrd-watson/
WATSON_BUILDS="${S3_BASE}builds"
S3_GRAMMARS="${S3_BASE}grammars"

user=`id -un`
group=`id -gn`

function init {
  watsond_cmds
  hstart
  sudo /etc/init.d/hstart
}

function build_str {
  arch=`uname -m`
  os=`uname | awk '{print tolower($0)}'`
  gccv=`gcc --version| grep '^gcc' | awk '{print $1substr($NF,1,3)}'`
  pyv=`python --version 2>&1 |awk '{print tolower(substr($1,1,2))substr($2,1,3)}'`
  build_name="${arch}-${os}-${gccv}-${pyv}.tgz"
  build_dir_name="${arch}-${os}-${gccv}-${pyv}"
}

function get_build {
  build_str
  buildls=`s3cmd ls s3:/$WATSON_BUILDS/$build_name 2>>$LOG|awk '{print $4}'`
  if [[ "x$buildls" == "x" ]]
  then
    logit "Could not find build $buildls for $arch, $os, $gccv, $pyv. Skipping."
  else
    logit "Fetching ${buildls} Please be patient..."
    s3cmd sync ${buildls} .
    logit "$build_name Downloaded successfully. Extracting the build."
    watson_dir="${WATSON_BASE}`date +%d%b%y`"
    sudo mkdir -p $watson_dir
    sudo tar -C $watson_dir -zxvf $build_name
    sudo rm -f $WATSON_BASE 2>/dev/null
    sudo ln -f -s $watson_dir $WATSON_BASE
  fi
}

function get_grammar {
  gt=$1
  for gf in "${grammar[@]}"
  do
    g=(`s3cmd ls s3:/$S3_GRAMMARS/$gt/$gf 2>>$LOG|awk '{print $4}'`)
    if [[ "x$g" == "x" ]]
    then
      logit "Could not find $gt Skipping..."
    else
      sudo mkdir -p $MNT/$gt
      sudo chown "$user":"$group" $MNT/$gt
      for gram_file in "${g[@]}"
      do
        logit "Fetching $gram_file"
        name=`basename $gram_file`
        if [[ ! -z $force ]]
        then
          s3cmd get --force $gram_file ${MNT}/$gt/$name
        else
          s3cmd get --skip-existing $gram_file ${MNT}/$gt/$name
        fi
        ## if the requested file is compressed uncompres it
        if [[ `file "${MNT}/$gt/$name"|awk '{print $2}'` == "gzip" ]] 
        then
          filename=`echo $name | awk -F'.'  '{sub("."$NF,"",$0);print $0}'`
          if [[ ! -d ${MNT}/$gt/$filename ]]
          then
            sudo tar -C ${MNT}/$gt -zxvf ${MNT}/$gt/$name
          fi
        fi
      done
    fi
  done
}

function watsond_cmds {
  watsond_cmds='def DATAPATH="'
  watsond_cmds="${watsond_cmds}${MNT}"':${DATAPATH}"

def HANDLER_DIR = "${WATSON_ROOT}/var/watsond/http"
def TTS_HOST = "localhost:7000"
httpConfig { "/asr  : $HANDLER_DIR/asr.py",
            "/nlu  : $HANDLER_DIR/nlu.py"
            "/xlog : $HANDLER_DIR/xlog.py",
            "/smm/watson : $HANDLER_DIR/asr.py",
            "/smm/nlp    : $HANDLER_DIR/nlu.py",
            "/smm/logCorrection : $HANDLER_DIR/xlog.py",
            "/smm/tts : $HANDLER_DIR/tts.py" }'
echo "$watsond_cmds" > /tmp/$cmds_file_name
sudo mv /tmp/$cmds_file_name $WATSON_BASE/$cmds_file_name
}


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
    WATSON_BASE='
hstart="$hstart$WATSON_BASE/${build_dir_name}"'
export PATH=${WATSON_BASE}/bin:/usr/local/bin:/bin:/usr/bin
    watsond'
hstart="${hstart} ${channels} "'${WATSON_BASE}/../'
hstart="${hstart}$cmds_file_name"' --protocol=wirehttp --port='
hstart="${hstart}${wport}"' --daemonize=${WATSON_BASE} --log-dir=${WATSON_BASE}/logs --trace-level=info&
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
sudo mv /tmp/hstart /etc/init.d/hstart
sudo chmod u+x /etc/init.d/hstart
}

logit "Initializing `date`"

while getopts hqfsbw:p:c:g:a:l:n:t:i args
do
  case $args in
  h)
    usage
    ;;
  q)
    quiet='true'
    ;;
  f)
    force='true'
    ;;
  s)
    logit "Marking software installation"
    softwares=true
    ;;
  b)
    build=true
    ;;
  w)
    logit "Configuring watson base dir to $OPTARG"
    wdir=`abs_path $OPTARG`
    ;;
  p)
    logit "Configuring watson to run on port $OPTARG"
    wport=$OPTARG
    ;;
  c)
    logit "Configuring watson with $OPTARG channels"
    channels=$OPTARG
    ;;
  g)
    logit "Configuring watson grammar data path to $OPTARG"
    gdir=`abs_path $OPTARG`
    ;;
  a)
    IFS=','
    am=($OPTARG)
    ;;
  l)
    IFS=','
    lm=($OPTARG)
    ;;
  n)
    IGS=','
    nlm=($OPTARG)
    ;;
  t)
    IFS=','
    tts=($OPTARG)
    ;;
  i)
    logit "Marking watson installation"
    init=true
    ;;
  :)
    logit "The argument -$OPTARG requires a parameter"
    exit -1
    ;;
  *)
    usage
    ;;
  esac
done

if [[ $# -eq 0 ]]
then
  usage
fi

WATSON_BASE="${wdir:-/opt/watson}" ## This should just be a soft link, if not ...
MNT="${gdir:-/mnt/grammars}"
channels="${channels:-4}"
wport="${wport:-8080}"
cmds_file_name='watsond.ypc.cmds'

if [[ ! -z $softwares ]]
then
  install_softwares
fi

if [[ ! -z $build ]]
then
  grammar=("${lm[@]}")
  get_build
fi

if [[ ! -z $am ]]
then
  echo "PULLING ACOUSTIC MODEL $am"
  grammar=("${am[@]}")
  get_grammar am
fi

if [[ ! -z $lm ]]
then
  grammar=("${lm[@]}")
  get_grammar lm
fi

if [[ ! -z $nlm ]]
then
  grammar=("${nlm[@]}")
  get_grammar nlm
fi

if [[ ! -z $tts ]]
then
  grammar=("${tts[@]}")
  get_grammar tts
fi

if [[ ! -z $init ]]
then
  init
fi
