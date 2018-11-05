MAINTAINER Jonathan Lefman jlefman@nvidia.com

RUN yum groupinstall -y "Development Tools"
RUN yum install -y bzip2 wget ruby-devel libmunge-devel pam-devel perl-devel
RUN wget https://repo.mysql.com//mysql80-community-release-el7-1.noarch.rpm && \
    rpm -i mysql80-community-release-el7-1.noarch.rpm && \
    yum install -y mysql-community-devel && \
    rm mysql80-community-release-el7-1.noarch.rpm 
RUN gem install fpm

ARG SLURM_VERSION
ARG PKG_VERSION

RUN wget https://www.schedmd.com/downloads/latest/slurm-$SLURM_VERSION.tar.bz2 \
 && tar xvjf slurm-$SLURM_VERSION.tar.bz2 -C / \
 && rm -f slurm-$SLURM_VERSION.tar.bz2 
RUN cd /slurm-$SLURM_VERSION \
 && ./configure --prefix=/tmp/slurm-build --sysconfdir=/etc/slurm 

RUN cd /slurm-$SLURM_VERSION \
 && make -j 
RUN cd /slurm-$SLURM_VERSION \
 && make -j contrib 
RUN cd /slurm-$SLURM_VERSION \
 && make -j install 

RUN cp /slurm-$SLURM_VERSION/contribs/pam/.libs/pam_slurm.so /tmp/slurm-build/lib

COPY slurm.pc /tmp/slurm-build/share/pkgconfig/slurm.pc
COPY slurm.pc /tmp/slurm-build/lib/pkgconfig/slurm.pc

RUN mkdir -p /tmp/slurm-build/share/pkgconfig \
 && mkdir -p /tmp/slurm-build/lib/pkgconfig 

RUN cd /tmp/slurm-build && fpm -s dir -t rpm -n slurm -v ${SLURM_VERSION} --iteration=${PKG_VERSION} --prefix=/usr -C /tmp/slurm-build 
