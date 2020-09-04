FROM ubuntu:20.04

MAINTAINER "Volodymyr Savchenko"
ARG python_version=3.8.3
ARG heasoft_version=6.27.2

LABEL python_version=$python_version
LABEL osa_version=$OSA_VERSION
LABEL heasoft_version=$heasoft_version

RUN echo -e "\033[34m Latest HEASoft: \033[0m"; \
    curl https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/ | awk '/heasoft-6.28src.tar.gz/'

ENV DEBIAN_FRONTEND=noninteractive
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

RUN echo 'deb http://dk.archive.ubuntu.com/ubuntu/ focal main universe' >> /etc/apt/sources.list
RUN echo 'deb http://dk.archive.ubuntu.com/ubuntu/ focal-updates main universe' >> /etc/apt/sources.list

RUN apt-get update -y

RUN apt-get -y install \
                   git curl make  \
                   g++ gcc gfortran build-essential libgfortran5 llvm\
                   libxpm-dev libxext-dev file xorg-dev libxt-dev \
                   libreadline8 libreadline-dev libbz2-dev \
                   perl-modules \
                   zlib1g-dev libpng-dev  libsqlite3-dev \
                   libssl-dev zlib1g-dev libbz2-dev \
                   net-tools strace sshfs sudo iptables \
                   libsqlite3-dev wget libncurses5-dev libncursesw5-dev \
                   xz-utils tk-dev vim lsb-core libextutils-f77-perl \
                   libcurl4 libcurl4-gnutls-dev curl \
                   libgsl-dev libtinfo-dev libtinfo5


RUN dpkg-reconfigure --frontend noninteractive tzdata


# python


RUN git clone git://github.com/yyuu/pyenv.git /pyenv && \
        echo 'export PYENV_ROOT="/pyenv"' >> /etc/profile && \
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /etc/profile && \
        echo 'eval "$(pyenv init -)"' >> /etc/profile


RUN . /etc/profile && \
        which pyenv && \
        PYTHON_CONFIGURE_OPTS="--enable-shared"  CFLAGS="-fPIC" CXXFLAGS="-fPIC" pyenv install $python_version && \
        pyenv versions

RUN . /etc/profile && pyenv shell $python_version && pyenv global $python_version && pyenv versions && pyenv rehash


ADD init.sh /init.sh
RUN echo '. /etc/profile' >> /init.sh

# needed for heasoft
RUN . /init.sh && pip install numpy scipy 





# OSA 

ARG OSA_VERSION=11.1-3-g87cee807-20200410-144247 
ARG OSA_PLATFORM=Ubuntu_20.04_x86_64

RUN cd /opt/ && \
    wget -q https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-binary-tarball/${OSA_PLATFORM}/${OSA_VERSION}/build-latest/osa-${OSA_VERSION}-${OSA_PLATFORM}.tar.gz && \
    tar xzf osa-${OSA_VERSION}-*.tar.gz && \
    rm -fv osa-${OSA_VERSION}-*.tar.gz && \
    mv osa11 osa; \
    wget -q https://www.isdc.unige.ch/integral/download/osa/sw/10.2/osa10.2-bin-linux64.tar.gz && \
    tar xzf osa10.2-bin-linux64.tar.gz && \
    rm -fv osa10.2-bin-linux64.tar.gz

ARG isdc_ref_cat_version=43.0

RUN wget -q https://www.isdc.unige.ch/integral/download/osa/cat/osa_cat-${isdc_ref_cat_version}.tar.gz && \
    tar xvzf osa_cat-${isdc_ref_cat_version}.tar.gz && \
    mkdir -pv /data/ && \
    mv osa_cat-${isdc_ref_cat_version}/cat /data/ && \
    rm -rf osa_cat-${isdc_ref_cat_version}

RUN wget -q http://ds9.si.edu/download/ubuntu18/ds9.ubuntu18.8.2b2.tar.gz && \
    tar xvfz ds9.*.tar.gz && \
    chmod a+x ds9 && \
    mv ds9 /usr/local/bin && \
    rm -f ds9.*.tar.gz



# HEASoft


ADD build-heasoft.sh /build-heasoft.sh 

#RUN echo '. /opt/rh/devtoolset-7/enable' >> /init.sh

RUN cp -fv /usr/bin/gfortran /usr/bin/g95

#RUN exit 1
    
RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    rm -rf /opt/heasoft || true && \
    bash /build-heasoft.sh  || true

RUN exit 1
    
    
RUN p=$(ls -d /opt/heasoft/x86*/); echo "found HEADAS: $p"; echo 'export HEADAS="'$p'"; . $HEADAS/headas-init.sh' >> /init.sh

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    git clone https://github.com/volodymyrss/heasoft-heasp.git /heasoft-heasp && \
    cd /heasoft-heasp/python && \
    swig -python -c++ -classic heasp.i && \
    hmake install && \
    cd /heasoft-heasp && \
    hmake install


# Python modules

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    python -c 'import xspec; print(xspec.__file__)' && \
    pip install numpy scipy ipython jupyter matplotlib pandas astropy==2.0.11


RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    pip install -r https://raw.githubusercontent.com/volodymyrss/data-analysis/py3/requirements.txt && \
    pip install git+https://github.com/volodymyrss/data-analysis@py3 && \
    pip install git+https://github.com/volodymyrss/pilton && \
    pip install git+https://github.com/volodymyrss/dda-ddosa

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    pip install git+https://github.com/volodymyrss/dqueue.git


ADD activate.sh /activate.sh


# 3ml

RUN git clone https://github.com/threeML/astromodels.git && \
    export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    ls -lotr && \
    cd /astromodels/ && python setup.py install && pip install .

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    python -c 'import astromodels; print(astromodels.__file__)' 


RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    pip install jupyter

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    . /init.sh && \
    pip install pymysql peewee

ADD tests /tests

RUN . /init.sh; pip install jupyterlab

ENTRYPOINT bash -c 'export HOME_OVERRRIDE=/home/jovyan; cd /home/jovyan; . /init.sh; jupyter lab --ip 0.0.0.0 --no-browser'
