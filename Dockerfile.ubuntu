MAINTAINER Ryan Olson rolson@nvidia.com

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential ruby-dev libpam0g-dev libmysqlclient-dev \
        libmunge-dev libmysqld-dev wget python-minimal && \
    rm -rf /var/lib/apt/lists/*

RUN gem install fpm

ARG SLURM_VERSION
ARG PKG_VERSION

RUN wget https://www.schedmd.com/downloads/latest/slurm-$SLURM_VERSION.tar.bz2 \
 && tar xvjf slurm-$SLURM_VERSION.tar.bz2 -C / \
 && rm -f slurm-$SLURM_VERSION.tar.bz2 \
 && cd /slurm-$SLURM_VERSION \
 && ./configure --prefix=/tmp/slurm-build --sysconfdir=/etc/slurm \
 && make -j \
 && make -j contrib \
 && make -j install 

RUN cp /slurm-$SLURM_VERSION/contribs/pam/.libs/pam_slurm.so /tmp/slurm-build/lib

COPY ./generate_dependencies.sh /tmp/
RUN /tmp/generate_dependencies.sh 2>/dev/null
# Create Depends list
# for each directory in bin, lib, sbin run the following:
# objdump -p ./* | grep NEEDED | tr -s ' ' | cut -d ' ' -f3 | sort | uniq | xargs -n1 dpkg -S | cut -d ' ' -f 1 | sort | uniq | tr ':' ' ' | cut -d ' ' -f 1 >> /tmp/depends

RUN mkdir -p /tmp/slurm-build/share/doc/slurm/ \
 && cp /slurm-$SLURM_VERSION/COPYING /tmp/slurm-build/share/doc/slurm/copyright

RUN mkdir -p /tmp/slurm-build/share/pkgconfig \
 && mkdir -p /tmp/slurm-build/lib/pkgconfig 

COPY slurm.pc /tmp/slurm-build/share/pkgconfig/slurm.pc
COPY slurm.pc /tmp/slurm-build/lib/pkgconfig/slurm.pc

RUN fpm -s dir -t deb -n slurm -v ${SLURM_VERSION} --iteration ${PKG_VERSION} --prefix=/usr -C /tmp/slurm-build \
        $(for pkg in $(cat /tmp/slurm-packages); do echo --depends $pkg; done) . 
