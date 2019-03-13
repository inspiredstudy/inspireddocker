FROM centos:7
ADD sct_v3.1.1.tar.gz /opt
WORKDIR /opt/sct
RUN yum -y -q install bzip2 && \
    yum -y -q clean all && \
    /opt/sct/install_sct
ADD fsl-5.0.11-1.el7.centos.x86_64.rpm /tmp
COPY ants-2.1.0.tar.bz2 /tmp
ADD niftyreg-1.5-0.20172411.el7.centos.x86_64.rpm /tmp
ADD niftyseg-1.0.0-1.20190109.el7.centos.x86_64.rpm /tmp
ADD mstools.tar.gz /opt/mstools
ADD seg_GIF /usr/local/bin
ADD girona-1.0.3-1.20180602.el7.centos.x86_64.rpm /tmp
COPY csa_auto_preproc.sh /usr/local/bin
COPY niftkMTPDbc /usr/local/bin
COPY segbamos-1.0.2-1.20180605.el7.centos.x86_64.rpm /tmp
COPY BaMoS_WMH_010618.sh /usr/local/bin/bamos.sh
COPY thicknessWrapper.py /usr/local/bin
COPY calculateCTVol.py /usr/local/bin
COPY direct_wm_gm_label.py /usr/local/bin
COPY separate_cortex_from_gif_parcellation.py /usr/local/bin
COPY gif.xml /usr/local/share
COPY tasks.py /usr/local/bin
COPY worker /usr/local/bin
COPY niftkLayers /tmp/niftkLayers
WORKDIR /opt
RUN yum -y -q install epel-release && \
    yum -y -q install https://centos7.iuscommunity.org/ius-release.rpm && \
    yum -y -q install vtk python36u python36u-devel python36u-pip gcc && \
    yum -y -q localinstall /tmp/fsl-5.0.11-1.el7.centos.x86_64.rpm && \
    yum -y -q localinstall /tmp/niftyreg-1.5-0.20172411.el7.centos.x86_64.rpm && \
    yum -y -q localinstall /tmp/niftyseg-1.0.0-1.20190109.el7.centos.x86_64.rpm && \
    yum -y -q localinstall /tmp/girona-1.0.3-1.20180602.el7.centos.x86_64.rpm && \
    yum -y -q localinstall /tmp/segbamos-1.0.2-1.20180605.el7.centos.x86_64.rpm && \
    localedef -i en_GB -f UTF-8 en_GB.UTF-8 && \
    tar --transform "s/ants-2.1.0-redhat/ants/g" -xf /tmp/ants-2.1.0.tar.bz2 && \
    chmod ugo+rx /usr/local/bin/csa_auto_preproc.sh && \
    chmod ugo+rx /usr/local/bin/niftkMTPDbc && \
    chmod ugo+rx /usr/local/bin/seg_GIF && \
    find /opt -type d -exec chmod 755 {} \; && \
    find /opt -type f -exec chmod ugo+r {} \; && \
    python3.6 -m pip install snakemake && \
    chmod ugo+rx /usr/local/bin/bamos.sh && \
    python3.6 -m pip install redis rq numpy nibabel pandas && \
    chmod 755 /usr/local/bin/worker && \
    chmod 644 /usr/local/bin/tasks.py && \
    chmod 755 /usr/local/bin/thicknessWrapper.py && \
    chmod 755 /usr/local/bin/calculateCTVol.py && \
    chmod 755 /usr/local/bin/direct_wm_gm_label.py && \
    chmod 755 /usr/local/bin/separate_cortex_from_gif_parcellation.py && \
    chmod 644 /usr/local/share/gif.xml && \
    chmod 755 /usr/bin/seg_FillLesions && \
    make -C /tmp/niftkLayers && \
    mkdir /data && \
    rm -rf /tmp/* && yum -y -q clean all
COPY seg_FillLesions /usr/bin
RUN chmod 755 /usr/bin/seg_FillLesions && \
    ln -s /usr/bin/reg_aladin /usr/local/bin/reg_aladin && \
    ln -s /usr/bin/reg_resample /usr/local/bin/reg_resample
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	yum -y install epel-release; \
	yum -y install wget dpkg; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /tmp/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /tmp/gosu.asc /usr/bin/gosu; \
	rm -r "$GNUPGHOME" /tmp/gosu.asc; \
	\
	chmod +x /usr/bin/gosu; \
# verify that the binary works
	gosu nobody true; \
	\
	yum -y remove wget dpkg; \
	yum clean all
ENV PYTHONPATH=/opt/mstools \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/ants:/opt/fsl/bin:/opt/girona:/opt/mstools:/opt/sct/bin \
    FSLDIR=/opt/fsl \
    FSLOUTPUTTYPE=NIFTI_GZ \
    LC_ALL=en_GB.utf8 \
    LANG=en_GB.utf8
RUN yum -y -q install git && yum clean all
COPY calculate_diffusion_maps.py /usr/local/bin
COPY mrtrix-3.0.0-1.20190308.el7.centos.x86_64.rpm /tmp
RUN python3.6 -m pip install dipy && \
    yum -y -q localinstall /tmp/mrtrix-3.0.0-1.20190308.el7.centos.x86_64.rpm && \
    rm /tmp/mrtrix-3.0.0-1.20190308.el7.centos.x86_64.rpm && \
    python3.6 -m pip install https://github.com/MIC-DKFZ/TractSeg/archive/v1.9.zip && \
    python3.6 -m pip install https://download.pytorch.org/whl/cpu/torch-1.0.1.post2-cp36-cp36m-linux_x86_64.whl && \
    chmod 755 /usr/local/bin/calculate_diffusion_maps.py
WORKDIR /data
COPY setup.sh /
ENTRYPOINT ["/bin/bash", "/setup.sh"]
CMD ["/bin/bash"]
