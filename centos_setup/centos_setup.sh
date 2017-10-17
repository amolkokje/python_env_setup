# INSTRUCTIONS TO RUN:
# 1 --> copy this script to centos machine
# 2 --> chmod 775 script_name.sh
# 3 --> ./script_name.sh


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

# Change this folder if you want to install in a different location
RUNDIR="/root/env_setup/"
echo RUNDIR=${RUNDIR}
if [ ! -d "$RUNDIR" ]; then
  mkdir ${RUNDIR}
fi

cd ${RUNDIR}
run pwd


run yum -y update
run yum -y install which 


# ---------------------------------
# INSTALL WGET
# ---------------------------------
run yum -y install wget

# Install development tools and some misc. necessary packages
run yum -y groupinstall "Development tools"
run yum -y install zlib-devel  # gen'l reqs
run yum -y install bzip2-devel openssl-devel ncurses-devel  # gen'l reqs
run yum -y install mysql-devel  # req'd to use MySQL with python ('mysql-python' package)
run yum -y install libxml2-devel libxslt-devel  # req'd by python package 'lxml'
run yum -y install unixODBC-devel  # req'd by python package 'pyodbc'
run yum -y install sqlite sqlite-devel  # you will be sad if you don't install this before compiling python, and later need it.
# Alias shasum to == sha1sum (will prevent some people's scripts from breaking)
echo 'alias shasum="sha1sum"' >> $HOME/.bashrc

echo "INSTALL WGET DONE ---"
read -p "Press Enter to Continue ..."

# ---------------------------------
# INSTALL PYTHON AND PIP
# ---------------------------------
# Install Python 2.7.14 (do NOT remove 2.6, by the way)
cd ${RUNDIR}
run pwd
run wget --no-check-certificate https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz
run tar xf Python-2.7.14.tgz
cd ${RUNDIR}Python-2.7.14/
run pwd
run ./configure --prefix=/usr/local
run make && make altinstall
run ln -s /usr/local/bin/python2.7 /usr/local/bin/python

run curl "https://bootstrap.pypa.io/get-pip.py" -o "${RUNDIR}get-pip.py"
run python ${RUNDIR}get-pip.py

echo "INSTALL PYTHON AND PIP DONE ---"
read -p "Press Enter to Continue ..."


# Install virtualenv and virtualenvwrapper
# Once you make your first virtualenv, you'll have 'pip' in there. No need to install pip outside the virtualenv.

# ---------------------------------
# INSTALL SETUPTOOLS
# ---------------------------------
cd ${RUNDIR}
run pwd
run wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz
run tar -xvf setuptools-1.4.2.tar.gz
cd ${RUNDIR}setuptools-1.4.2/
run pwd
run python2.7 setup.py install

echo "INSTALL SETUPTOOLS DONE ---"
read -p "Press Enter to Continue ..."


# ---------------------------------
# INSTALL VIRUTALENV
# ---------------------------------
cd ${RUNDIR}
run pwd
run wget --no-check-certificate https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.9.1.tar.gz#md5=07e09df0adfca0b2d487e39a4bf2270a
run tar -xvzf virtualenv-1.9.1.tar.gz
cd ${RUNDIR}virtualenv-1.9.1/
run pwd
run python2.7 setup.py install

echo "INSTALL VIRTUALENV DONE ---"
read -p "Press Enter to Continue ..."


# ---------------------------------
# INSTALL VIRTUALENV-WRAPPER
# ---------------------------------
cd ${RUNDIR}
run pwd
run wget --no-check-certificate https://pypi.python.org/packages/source/v/virtualenvwrapper/virtualenvwrapper-4.0.tar.gz#md5=78df3b40735e959479d9de34e4b8ba15
run tar -xvzf virtualenvwrapper-*
cd ${RUNDIR}virtualenvwrapper-4.0/
run pwd
run python2.7 setup.py install

echo "INSTALL VIRTUALENV-WRAPPER DONE ---"
read -p "Press Enter to Continue ..."


echo '. '${RUNDIR}'virtualenvwrapper-4.0/virtualenvwrapper.sh' >> $HOME/.bashrc
run source $HOME/.bashrc

echo "ENVIRONMENT SETUP DONE!"
