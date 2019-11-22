# BASE IMAGE
FROM centos:7 AS base

# Base packages to python development
RUN yum install epel-release -y \
    && yum install -y \
        gcc gcc-c++ kernel-devel \
        python-devel python-pip libxslt-devel libffi-devel openssl-devel git \
    && yum autoremove -y && rm -rf /var/cache/yum && yum clean all

ENV PATH=/root/.local/bin:$PATH

# Install Pydeface in base
RUN pip install pip --upgrade \
    && pip install setuptools -U \
    && pip install --user xnat \
    && rm -rf /root/.cache

# Preparing nifti2dicom
# RUN wget ftp://ftp.pbone.net/mirror/li.nux.ro/download/nux/dextop/el6Client/x86_64/tclap-devel-1.2.0-7.el6.nux.noarch.rpm && \
#     yum install tclap-devel-1.2.0-7.el6.nux.noarch.rpm && \
#     rm tclap-devel-1.2.0-7.el6.nux.noarch.rpm && \
#     yum groupinstall 'Development Tools' -y && \
#     yum install -y cmake itk-devel 

# FINAL IMAGE
FROM institutodor/pydeface
LABEL Author="Bruno Melo <bruno.melo@idor.org>"

RUN yum install pigz zip -y && \
    yum install -y fftw libjpeg62 libjpeg libpng libpng12 libtiff libGLU libSM libXt freetype  && \
    yum autoremove -y && rm -rf /var/cache/yum && yum clean all && \
    cp /usr/lib64/libtiff.so.5 /usr/lib64/libtiff.so.3

COPY --from=base /root/.local /root/.local
COPY facemask.nii.gz /root/.local/lib/python2.7/site-packages/pydeface/data/facemask.nii.gz
COPY bin /bin/
COPY scripts /root/scripts

WORKDIR /root/scripts
ENTRYPOINT [ "./run.py" ]

# XNAT COMMAND
LABEL org.nrg.commands="[{\"name\": \"deface\", \"label\": \"deface\", \"description\": \"Basic pipeline to run on a session.\", \"version\": \"1.1\", \"schema-version\": \"1.0\", \"image\": \"institutodor/deface:latest\", \"type\": \"docker\", \"command-line\": \"--input /input #RM-DCMS# #SAVE-NII# #RENAME-TYPES# #DEFACE#\", \"override-entrypoint\": false, \"mounts\": [{\"name\": \"in\", \"writable\": false, \"path\": \"/input\"}], \"environment-variables\": {\"XNAT_SESSION\": \"[SESSION]\"}, \"ports\": {}, \"inputs\": [{\"name\": \"remove-dcms\", \"description\": \"Remove DICOM files?\", \"type\": \"boolean\", \"default-value\": true, \"required\": true, \"replacement-key\": \"#RM-DCMS#\", \"command-line-flag\": \"--remove-dicoms\"}, {\"name\": \"save-nifti\", \"description\": \"Save NIFTI files?\", \"type\": \"boolean\", \"default-value\": true, \"required\": true, \"replacement-key\": \"#SAVE-NII#\", \"command-line-flag\": \"--save-nifti\"}, {\"name\": \"rename-types\", \"description\": \"Rename scans types (pattern based on BIDS)?\", \"type\": \"boolean\", \"default-value\": true, \"required\": true, \"replacement-key\": \"#RENAME-TYPES#\", \"command-line-flag\": \"--rename-types\"}, {\"name\": \"deface\", \"description\": \"Deface anatomical images?\", \"type\": \"boolean\", \"default-value\": true, \"required\": true, \"replacement-key\": \"#DEFACE#\", \"command-line-flag\": \"--deface\"}], \"xnat\": [{\"name\": \"deface-session\", \"label\": null, \"description\": \"Run the defacing on anatomical scans.\", \"contexts\": [\"xnat:imageSessionData\"], \"external-inputs\": [{\"name\": \"session\", \"description\": \"Input session\", \"type\": \"Session\", \"matcher\": null, \"default-value\": null, \"required\": true, \"replacement-key\": null, \"sensitive\": null, \"provides-value-for-command-input\": null, \"provides-files-for-command-mount\": \"in\", \"via-setup-command\": null, \"user-settable\": null, \"load-children\": false}], \"derived-inputs\": [{\"name\": \"session-id\", \"description\": \"Session ID\", \"type\": \"string\", \"required\": true, \"replacement-key\": \"[SESSION]\", \"user-settable\": false, \"load-children\": false, \"derived-from-wrapper-input\": \"session\", \"derived-from-xnat-object-property\": \"id\"}]}]}]"
