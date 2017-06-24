

## Overview

Slurm overview: https://slurm.schedmd.com/overview.html

> Slurm is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system for large and small Linux clusters. Slurm requires no kernel modifications for its operation and is relatively self-contained. As a cluster workload manager, Slurm has three key functions. First, it allocates exclusive and/or non-exclusive access to resources (compute nodes) to users for some duration of time so they can perform work. Second, it provides a framework for starting, executing, and monitoring work (normally a parallel job) on the set of allocated nodes. Finally, it arbitrates contention for resources by managing a queue of pending work. Optional plugins can be used for accounting, advanced reservation, gang scheduling (time sharing for parallel jobs), backfill scheduling, topology optimized resource selection, resource limits by user or bank account, and sophisticated multifactor job prioritization algorithms.

## GPU resource scheduling in Slurm

### Simple GPU scheduling with exclusive node access

Slurm supports scheduling GPUs as a consumable resource just like memory and disk. If you're not interested in allowing multiple jobs per compute node, you many not nessesarily need to make Slurm aware of the GPUs in the system, and the configuration can be greatly simplified.

One way of scheduling GPUs without making use of GRES (Generic REsource Scheduling) is to create partitions or queues for logical groups of GPUs. For example, grouping nodes with P100 GPUs into a P100 partition:

```console
$ sinfo -s
PARTITION AVAIL  TIMELIMIT   NODES(A/I/O/T)  NODELIST
p100     up   infinite         4/9/3/16  node[212-213,215-218,220-229]
```

Partition configuration via Slurm configuration file `slurm.conf`:

```console
NodeName=node[212-213,215-218,220-229]
PartitionName=p100 Default=NO DefaultTime=01:00:00 State=UP Nodes=node[212-213,215-218,220-229]
```

### Scheduling resources at the per GPU level

Slurm can be made aware of GPUs as a consumable resource to allow jobs to request any number of GPUs.

This feature requires job accounting to be enabled first; for more info, see: https://slurm.schedmd.com/accounting.html

The Slurm configuration file needs parameters set to enable cgroups for resource management and GPU resource scheduling:

`slurm.conf`:

```console
# General
ProctrackType=proctrack/cgroup
TaskPlugin=task/cgroup

# Scheduling
SelectType=select/cons_res
SelectTypeParameters=CR_Core_Memory

# Logging and Accounting
AccountingStorageTRES=gres/gpu
DebugFlags=CPU_Bind,gres                # show detailed information in Slurm logs about GPU binding and affinity
JobAcctGatherType=jobacct_gather/cgroup
```

Partition information in `slurm.conf` defines the available GPUs for each resource:

```console
# Partitions
GresTypes=gpu
NodeName=slurm-node-0[0-1] Gres=gpu:2 CPUs=10 Sockets=1 CoresPerSocket=10 ThreadsPerCore=1 RealMemory=30000 State=UNKNOWN
PartitionName=compute Nodes=ALL Default=YES MaxTime=48:00:00 DefaultTime=04:00:00 MaxNodes=2 State=UP DefMemPerCPU=3000
```

Cgroups require a seperate configuration file:

`cgroup.conf`:

```console
CgroupAutomount=yes 
CgroupReleaseAgentDir="/etc/slurm/cgroup" 

ConstrainCores=yes 
ConstrainDevices=yes
ConstrainRAMSpace=yes
#TaskAffinity=yes
```

GPU resource scheduling requires a configuration file to define the available GPUs and their CPU affinity

`gres.conf`:

```console
Name=gpu File=/dev/nvidia0 CPUs=0-4
Name=gpu File=/dev/nvidia1 CPUs=5-9
```

Running jobs utilizing GPU resources requires the `--gres` flag; for example, to run a job requiring a single GPU:

```console
$ srun --gres=gpu:1 nvidia-smi
```

### Kernel configuration

Using memory cgroups to restrict jobs to allocated memory resources requires setting kernel parameters

On Ubuntu systems this is configurable via `/etc/default/grub`

> GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"


## Building newer versions of Slurm from source as .deb packages for Ubuntu

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
wget http://www.schedmd.com/downloads/latest/slurm-17.02.5.tar.bz2
tar xvjf slurm-17.02.5.tar.bz2
./configure --prefix=/tmp/slurm-build --sysconfdir=/etc/slurm
make -j
make -j contrib
make -j install
```

### Package Slurm install directory as a Debian package using FPM

> Modify version via `-v` flag when building new versions so that APT will detect updated packages

```console
cd
fpm -s dir -t deb -v 1.0 -n slurm-17.02.5 --prefix=/usr -C /tmp/slurm-build .
dpkg --contents slurm-17.02.5_1.0_amd64.deb

## Build with docker
```
make`
```
