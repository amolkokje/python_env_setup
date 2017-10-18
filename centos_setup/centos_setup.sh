# INSTRUCTIONS TO RUN:
# 1 --> copy this script to centos machine
# 2 --> chmod 775 script_name.sh
# 3 --> ./script_name.sh


# -----------------------------------------
# UTILS
# -----------------------------------------

function log() {
    echo "$( date '+[%F_%T]' )" "${HOSTNAME}:" "${LOG_PREFIX}:" "$@"
}

function to_log() {
    while read LINE; do
        log "${LINE}"
    done
}

function run() {
    log RUN: "$@"
    "$@" 2>&1 | to_log
    RETURN_CODE=${PIPESTATUS[0]}
    if [[ ${RETURN_CODE} -ne 0 ]]; then
        log FAILED with RETURN_CODE=${RETURN_CODE}
        exit ${RETURN_CODE}
    fi
    return ${RETURN_CODE}
}
# NOTE: 'cd' command does not work with run()


# -----------------------------------------
# INSTALL METHODS
# -----------------------------------------

function install_yum_which_wget() {
  echo "Install/Update required tools"
  run yum -y update
  run yum -y install which
  run yum -y install wget
}

function install_devtools() {
  echo "Install development tools and some misc. necessary packages"
  run yum -y groupinstall "Development tools"
  run yum -y install zlib-devel  # gen'l reqs
  run yum -y install bzip2-devel openssl-devel ncurses-devel  # gen'l reqs
  run yum -y install mysql-devel  # req'd to use MySQL with python ('mysql-python' package)
  run yum -y install libxml2-devel libxslt-devel  # req'd by python package 'lxml'
  run yum -y install unixODBC-devel  # req'd by python package 'pyodbc'
  run yum -y install sqlite sqlite-devel  # you will be sad if you don't install this before compiling python, and later need it.
  # Alias shasum to == sha1sum (will prevent some people's scripts from breaking)
  echo 'alias shasum="sha1sum"' >> $HOME/.bashrc
}

function install_python() {
  echo "Install Python 2.7.14 (do NOT remove 2.6, by the way)"
  RUNDIR="$@"
  cd ${RUNDIR}
  run pwd
  run wget --no-check-certificate https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz
  run tar xf Python-2.7.14.tgz
  cd ${RUNDIR}Python-2.7.14/
  run pwd
  run ./configure --prefix=/usr/local
  run make && make altinstall
  run ln -s /usr/local/bin/python2.7 /usr/local/bin/python
}

function install_pip () {
  echo "Install pip"
  RUNDIR="$@"
  run curl "https://bootstrap.pypa.io/get-pip.py" -o "${RUNDIR}get-pip.py"
  run python ${RUNDIR}get-pip.py
}

# -----------------------------------------
# MAIN FLOW
# -----------------------------------------

# Change this folder if you want to install in a different location
RUNDIR="/root/env_setup/"
echo RUNDIR=${RUNDIR}
if [ ! -d "$RUNDIR" ]; then
  mkdir ${RUNDIR}
fi

cd ${RUNDIR}
run pwd

run install_yum_which_wget
run install_devtools
run install_python ${RUNDIR}
run install_pip ${RUNDIR}

echo "ENVIRONMENT SETUP DONE!"
