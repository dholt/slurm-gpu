

## Overview

Slurm overview: https://slurm.schedmd.com/overview.html

> Slurm is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system for large and small Linux clusters. Slurm requires no kernel modifications for its operation and is relatively self-contained. As a cluster workload manager, Slurm has three key functions. First, it allocates exclusive and/or non-exclusive access to resources (compute nodes) to users for some duration of time so they can perform work. Second, it provides a framework for starting, executing, and monitoring work (normally a parallel job) on the set of allocated nodes. Finally, it arbitrates contention for resources by managing a queue of pending work. Optional plugins can be used for accounting, advanced reservation, gang scheduling (time sharing for parallel jobs), backfill scheduling, topology optimized resource selection, resource limits by user or bank account, and sophisticated multifactor job prioritization algorithms.

## GPU resource scheduling in Slurm

Slurm supports scheduling GPUs as a consumable resource 

### Kernel configuration

Using memory cgroups to restrict jobs to allocated memory resources requires setting kernel parameters

On Ubuntu systems this is configurable via `/etc/default/grub`

> GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"


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
