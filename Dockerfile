#
# revised September 2019 with updated ubuntu,gromacs and plumed
# added ISDB (python scripts for SAXS processing using MARTINI form factors)
#
# GROMED : GRO[macs] + [plu]MED
#
# For many reasons we need to fix the ubuntu release.
# This version underwent the apt update; apt upgrade ; apt install ..
# torture 
#
FROM 	rinnocente/ubuntu-18.04-homebrew
#
LABEL	maintainer="roberto innocente <inno@sissa.it>" \
	version="2.0"
#
#
ARG \
	DEBIAN_FRONTEND=noninteractive
#
# gromacs-5.1.4 gets crazy with AVX_512 flag, removed
#ARG GR_SIMD="None SSE2 SSE4.1 AVX_256 AVX2_256 AVX_512"
# Automatic builds on docker cloud cant compile all these
# versions. We leave only SSE2
#ARG GR_SIMD="None SSE2 SSE4.1 AVX_256 AVX2_256"
#
ARG  \
	GR_SIMD="SSE2"
#
# we create the user 'gromed' and add it to the list of sudoers
RUN \ 
	adduser -q --disabled-password --gecos gromed gromed  \
	&& printf "\ngromed ALL=(ALL:ALL) NOPASSWD:ALL" >>/etc/sudoers.d/gromed  \
	&& (echo "gromed:mammamia"|chpasswd)
#
# disable  ssh strict mode
#
RUN \
	sed -i 's#^StrictModes.*#StrictModes no#' /etc/ssh/sshd_config \
	&& service   ssh  restart  
#
# download and compile sources.
#
ENV     GR_HD="/home/gromed" \
   	GR_VER="2018.6" \
   	PL_VER="2.5.2"  \
	ISDB_VER="2"
#
# ftp://ftp.gromacs.org/pub/gromacs/gromacs-2018.5.tar.gz
# https://github.com/plumed/plumed2/releases/download/v2.5.2/plumed-src-2.5.1.tgz
# https://www.plumed.org/doc-v2.5/user-doc/html/tutorial-resources/isdb-2.tar.gz
#
WORKDIR "$GR_HD"
#
# First : setup PLUMED
# Second : setup GROMACS
# Third :  copy ISDB 
#
RUN     wget https://github.com/plumed/plumed2/releases/download/v"${PL_VER}"/plumed-src-"${PL_VER}".tgz \
	&& tar xfz plumed-src-"${PL_VER}".tgz \
   	&& (cd plumed-"${PL_VER}" ;\
               ./configure --prefix=/usr --exec-prefix=/usr CXXFLAGS=-O3; \
               make -j $(nproc) ;\
               make install ) \
	&& wget http://ftp.gromacs.org/pub/gromacs/gromacs-"${GR_VER}".tar.gz \
	&& tar xfz gromacs-"${GR_VER}".tar.gz \
	&& ( cd gromacs-"${GR_VER}" ; \
	        plumed patch -p -e gromacs-"${GR_VER}" ; \
	        for item in $GR_SIMD; do \
		     mkdir -p build-"$item" ; \
		     (cd build-"$item"; cmake .. \
			-DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON \
			 -DGMX_SIMD="$item" -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx  \
			 -DGMX_THREAD_MPI:BOOL=OFF -DGMX_MPI:BOOL=ON ; make -j $(nproc) ); \
	        done ;\
	        (cd build-SSE2; make install)) \
	&&  echo export PATH=/usr/local/gromacs/bin:"${PATH}" >>"${GR_HD}"/.bashrc \
	&&  echo "source /usr/local/gromacs/bin/GMXRC" >>"${GR_HD}"/.bashrc \
	&& wget https://www.plumed.org/doc-v2.5/user-doc/html/tutorial-resources/isdb-"${ISDB_VER}".tar.gz \
	&& tar xfz isdb-"${ISDB_VER}".tar.gz 

#
# move tarballs in downloads/ directory
#
RUN    	\
	mkdir downloads \
	&& mv gromacs-"${GR_VER}".tar.gz isdb-"${ISDB_VER}".tar.gz  plumed-src-"${PL_VER}".tgz downloads/
#
COPY	tune-gromacs.sh ${GR_HD}/gromacs-"${GR_VER}"/
#
# change owner to gromed:gromed
#
RUN  	\
	chown -R gromed:gromed /home/gromed
#
#
EXPOSE 22
#
USER gromed
#
# the container can be now reached via ssh
CMD [ "sudo","/usr/sbin/sshd","-D" ]


