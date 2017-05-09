

GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"


Building Slurm packages from source for Ubuntu

```console
sudo apt-get install build-essential ruby-dev libpam0g-dev libmysqlclient-dev libmunge-dev libmysqld-dev
# fpm - https://github.com/jordansissel/fpm
sudo gem install fpm
wget http://www.schedmd.com/downloads/latest/slurm-17.02.1-2.tar.bz2
tar xvjf slurm-17.02.1-2.tar.bz2
./configure --prefix=/tmp/slurm-build --sysconfdir=/etc/slurm
make -j
make -j contrib
make -j install
cd
# add "-v 1.1" for version if desired, requires changing puppet manifest
# probably need to uprev or it won't be re-installed
# add name to var in main site.pp
fpm -s dir -t deb -v 1.0 -n slurm-17.02.1-2 --prefix=/usr -C /tmp/slurm-build .
dpkg --contents slurm-17.02.1-2_1.0_amd64.deb
# copy to puppet
```
