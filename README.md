

GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"


## Building Slurm packages from source for Ubuntu

### Install dependencies

```console
sudo apt-get install build-essential ruby-dev libpam0g-dev libmysqlclient-dev libmunge-dev libmysqld-dev
```

### Install FPM packaging tool

> fpm - https://github.com/jordansissel/fpm

```console
sudo gem install fpm
```

### Configure and build Slurm

```console
wget http://www.schedmd.com/downloads/latest/slurm-17.02.1-2.tar.bz2
tar xvjf slurm-17.02.1-2.tar.bz2
./configure --prefix=/tmp/slurm-build --sysconfdir=/etc/slurm
make -j
make -j contrib
make -j install
```

### Package Slurm install directory as a Debian package using FPM

> Modify version via `-v` flag when building new versions so that APT will detect updated packages

```console
cd
fpm -s dir -t deb -v 1.0 -n slurm-17.02.1-2 --prefix=/usr -C /tmp/slurm-build .
dpkg --contents slurm-17.02.1-2_1.0_amd64.deb
```
