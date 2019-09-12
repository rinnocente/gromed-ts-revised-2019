GROMED = GRO[macs] + PLU[med]

GROMACS [2018.3] is a well known package for molecular dynamics, 
PLUMED [2.5.2] is an open source library for free energy calculations.

Added ISDB [2] ( pythons script for SAXS using MARTINI form factors).

More info on : [gromacs site] (http://www.gromacs.org/) , [plumed site] (http://www.plumed.org/home)
and [isdb_pages] (https://www.plumed.org/doc-v2.5/user-doc/html/_i_s_d_b.html)

# ftp://ftp.gromacs.org/pub/gromacs/gromacs-2018.3.tar.gz
# https://github.com/plumed/plumed2/releases/download/v2.5.2/plumed-src-2.5.2.tgz
# https://www.plumed.org/doc-v2.5/user-doc/html/tutorial-resources/isdb-2.tar.gz

This container contains both sources and parallel binaries.

### There are 2 possible ways to use the container

1. Locally : simply type
```
$ docker run -it rinnocente/gromed-ts-revised-2019  /bin/bash 
```

2. Locally or remotely via ssh
`    `
> If you want to use X from the container(gnuplot or vmd), or you want to share it with colleagues or you
> want to access it directly via the net then you need to start the
> container with the ssh-server and map its port on a port on your host.
```
 $ CONT=`docker run -P -d -t rinnocente/gromed-ts-revised-2019`
```
> in this way (-P) the std ssh port (=22) is mapped on a free port of the host. We can access the container 
> discovering the port of the host on which the container ssh service is mapped :
```
  $ PORT=`docker port $CONT 22 |sed -e 's#.*:##'`
  $ ssh  -X -p $PORT gromed@127.0.0.1
```
> Change the password, that initially is set to *mammamia* , with the **passwd** command.

### Use of vector instruction sets (SIMD)

By default the installed binary and libraries of gromacs  are compiled for the SSE2 simd instructions, 
that by now, should be supported by everything.
If you have a more perfomant SIMD instruction set like 
**SSE4.1 AVX_256 AVX2_256 AVX_512**
 you can compile and install in an easy way a better suited version :
```
cd gromacs-5.1.4
bash tune-gromacs.sh
```
this script uses sudo to install gromacs.

### Tree of directories in /home/gromed :

```
.
|-- downloads
|   |-- gromacs-2018.3.tar.gz
|   |-- isdb-2.tar.gz
|   `-- plumed-src-2.5.2.tgz
|-- gromacs-2018.3
|   |-- AUTHORS
|   |-- CMakeLists.txt
|   |-- COPYING
|   |-- CPackInit.cmake
|   |-- CTestConfig.cmake
|   |-- INSTALL
|   |-- Plumed.cmake -> /usr/lib/plumed/src/lib/Plumed.cmake.shared
|   |-- Plumed.h -> /usr/include/plumed/wrapper/Plumed.h
|   |-- Plumed.inc -> /usr/lib/plumed/src/lib/Plumed.inc.shared
|   |-- README
|   |-- admin
|   |-- build-SSE2
|   |-- cmake
|   |-- docs
|   |-- scripts
|   |-- share
|   |-- src
|   |-- tests
|   `-- tune-gromacs.sh
|-- others
|   `-- isdb-2
`-- plumed-2.5.2
    |-- CHANGES
    |-- COPYING.LESSER
    |-- Makefile
    |-- Makefile.conf
    |-- Makefile.conf.in
    |-- PEOPLE
    |-- README.md
    |-- VERSION
    |-- astyle
    |-- conda
    |-- config.log
    |-- config.status
    |-- configure
    |-- configure.ac
    |-- docker
    |-- macports
    |-- patches
    |-- python
    |-- release.sh
    |-- scripts
    |-- sourceme.sh
    |-- sourceme.sh.in
    |-- src
    |-- stamp-h
    |-- stamp-h.in
    |-- test
    `-- vim
```


