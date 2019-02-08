FROM centos:7

RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install gcc gcc-c++ gcc-gfortran \
                   git curl make zlib-devel bzip2 bzip2-devel \
                   readline-devel sqlite sqlite-devel openssl \
                   openssl-devel patch libjpeg libpng12 libX11 \
                   which libXpm libXext curlftpfs wget libgfortran file \
                   ruby-devel fpm rpm-build \
                   ncurses-devel \
                   libXt-devel libX11-devel libXpm-devel libXft-devel libXext-devel \
                   cmake openssl-devel pcre-devel mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel \
                   mysql-devel fftw-devel cfitsio-devel graphviz-devel avahi-compat-libdns_sd-devel libldap-dev python-devel libxml2-devel gsl-static \
                   compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-c++.gfortran \
                   perl-ExtUtils-MakeMaker \
                   net-tools strace sshfs sudo iptables

RUN ln -s /usr/lib64/libpcre.so.1 /usr/lib64/libpcre.so.0
#RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && yum -y install git-lfs
#RUN cp -fv /usr/bin/gfortran /usr/bin/g95


# root

#RUN cd /opt && \
#    wget https://root.cern.ch/download/root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz && \
#    tar xvzf root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz && \
#    rm -f root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz 

# heasoft

#RUN cd /opt && \
#    wget https://www.isdc.unige.ch/~savchenk/gitlab-ci/savchenk/osa-build-heasoft-binary-tarball/CentOS_7.5.1804_x86_64/heasoft-CentOS_7.5.1804_x86_64.tar.gz && \
#    tar xvzf heasoft-CentOS_7.5.1804_x86_64.tar.gz && \
#    pwd && \
#    rm -fv  heasoft-CentOS_7.5.1804_x86_64.tar.gz

# OSA 

ARG OSA_VERSION

#RUN cd /opt/ && \
#    if [ ${OSA_VERSION} == "10.2" ]; then \
#        wget https://www.isdc.unige.ch/integral/download/osa/sw/10.2/osa10.2-bin-linux64.tar.gz && \
#        tar xvzf osa10.2-bin-linux64.tar.gz && \
#        rm -fv osa10.2-bin-linux64.tar.gz && \
#        mv osa10.2 osa; \
#    else \
#        wget https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-binary-tarball/CentOS_7.5.1804_x86_64/${OSA_VERSION}/build-latest/osa-${OSA_VERSION}-CentOS_7.5.1804_x86_64.tar.gz && \
#        tar xvzf osa-${OSA_VERSION}-CentOS_7.5.1804_x86_64.tar.gz && \
#        rm -fv osa-${OSA_VERSION}-CentOS_7.5.1804_x86_64.tar.gz && \
#        mv osa11 osa; \
#    fi 

ARG isdc_ref_cat_version=42.0

#RUN wget https://www.isdc.unige.ch/integral/download/osa/cat/osa_cat-${isdc_ref_cat_version}.tar.gz && \
#    tar xvzf osa_cat-${isdc_ref_cat_version}.tar.gz && \
#    mkdir -pv /data/ && \
#    mv osa_cat-${isdc_ref_cat_version}/cat /data/ && \
#    rm -rf osa_cat-${isdc_ref_cat_version}

#RUN wget http://ds9.si.edu/download/centos7/ds9.centos7.8.0.1.tar.gz && \
#    tar xvfz ds9.centos7.8.0.1.tar.gz && \
#    chmod a+x ds9 && \
#    mv ds9 /usr/local/bin && \
#    rm -f ds9.centos7.8.0.1.tar.gz

ADD init.sh /init.sh



RUN yum install -y  gcc gcc-c++ make git patch openssl-devel zlib-devel readline-devel sqlite-devel bzip2-devel libffi-devel zlib python36u-tkinter.x86_64 

RUN git clone git://github.com/yyuu/pyenv.git /pyenv

ARG python_version=3.6.5

RUN echo 'export PYENV_ROOT=/pyenv; export PATH="/pyenv/bin:$PATH"' >> /etc/pyenvrc && \
    echo 'eval "$(pyenv init -)"' >> /etc/pyenvrc

RUN source /etc/pyenvrc && which pyenv && PYTHON_CONFIGURE_OPTS="--enable-shared"  CFLAGS="-fPIC" CXXFLAGS="-fPIC" pyenv install $python_version && pyenv versions
RUN source /etc/pyenvrc && pyenv shell $python_version && pyenv global $python_version && pyenv versions && pyenv rehash

RUN echo 'source /etc/pyenvrc' >> /init.sh

RUN yum install -y wcslib-devel swig

ARG heasoft_version=6.20

COPY heasoft-${heasoft_version}src_no_xspec_modeldata.tar.gz /heasoft-${heasoft_version}src_no_xspec_modeldata.tar.gz

ADD build-heasoft.sh /build-heasoft.sh
RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    rm -rf /opt/heasoft && \
    bash build-heasoft.sh build
    


#RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
#    source /init.sh && \
#    git clone https://github.com/volodymyrss/heasoft-heasp.git /heasoft-heasp && \
#    cd /heasoft-heasp/python && \
#    swig -python -c++ -classic heasp.i && \
#    hmake install && \
#    cd /heasoft-heasp && \
#    hmake install

#RUN rsync -avu /osa-deployment/CentOS_7.5.1804_x86_64/heasoft/ /opt/heasoft/

#RUN ls -lotr /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/lib/python/xspec/chain.py

RUN yum install -y libyaml-devel 

RUN echo 'export HEADAS=/opt/heasoft/x86_64-unknown-linux-gnu-libc2.17/; source $HEADAS/headas-init.sh' >> /init.sh

#ADD Xspec /dist/Xspec
#ADD heacore /dist/heacore
#ADD heatools /dist/heatools
#ADD attitude /dist/attitude

#ADD install-xspec.sh /install-xspec.sh

#RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
#    source /init.sh && \
#    bash  /install-xspec.sh

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    python -c 'import xspec; print(xspec.__file__)' && \
    pip install numpy scipy ipython jupyter matplotlib pandas astropy==2.0.11


#RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
#    source /init.sh && \
#    pip install git+https://github.com/threeML/astromodels.git && \
#    pip install git+https://github.com/threeML/threeML.git && \
#    pip install git+https://github.com/threeML/astromodels.git

#RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
#    source /init.sh && \
#    python -c 'import astromodels; print(astromodels.__file__)' 



RUN git clone https://github.com/threeML/astromodels.git



RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    ls -lotr && \
    cd /astromodels/ && python setup.py install && pip install .

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    python -c 'import astromodels.xspec; print(astromodels.xspec.__file__)' 
