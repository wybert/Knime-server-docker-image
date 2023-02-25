FROM        ubuntu:20.04
# update the base image
RUN apt-get update

# install openjdk 11 and libgtk-3-0
RUN apt-get install -yq openjdk-11-jdk libgtk-3-0

# install other useful tool like wget, git, vim, tmux and sudo
RUN apt-get install -yq wget git vim tmux sudo

# create a user for knime server setup
RUN useradd -d /opt/knime -m -s /bin/bash knime

RUN chown knime /opt/knime 
USER knime
WORKDIR /opt/knime

# install python and packages
# download python
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh  -O Mambaforge-Linux-x86_64.sh 
# install python
RUN bash Mambaforge-Linux-x86_64.sh -b -p mambaforge
# remove the installer
RUN rm Mambaforge-Linux-x86_64.sh
RUN conda clean --tarballs --index-cache --packages --yes && conda clean --force-pkgs-dirs --all --yes
# configure the python env
ENV CONDA_DIR /opt/knime/mambaforge
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH
RUN  echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> /etc/skel/.bashrc &&     echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ~/.bashrc # buildkit
RUN ./mambaforge/bin/conda init
RUN ./mambaforge/bin/mamba env create -f python_env.yml

# Download and install knime server and rename it as knime_installer.jar
RUN wget https://download.knime.com/server/4.16/4.16.0/knime-server-installer-4.16.0.0129-aea6215f.jar -O /opt/knime/knime_installer.jar

RUN java -jar knime_installer.jar auto-install.xml

RUN chmod 744 /opt/knime/knime_server/knime_executor/start-executor.sh
# RUN cp -rf executor.epf /opt/knime/knime_server/workflow_repository/config/client-profiles/executor/
# RUN cp -rf preferences.epf /opt/knime/knime_server/knime_executor/configuration/

# VOLUME   ["/opt/knime/knime_server/workflow_repository/workflows"]

USER root
RUN chown knime /opt/knime/knime_server/workflow_repository/workflows

EXPOSE  8080 8443
# knimeadmin/k-82dn
