FROM        ubuntu:20.04
# update the base image
RUN apt-get update

# install openjdk 11 and libgtk-3-0
RUN apt-get install -yq openjdk-11-jdk libgtk-3-0

# install other useful tool like wget, git, vim, tmux and sudo
RUN apt-get install -yq wget git vim tmux sudo fish ranger libssl-dev

# install r-base
# update indices
RUN apt update -qq -yq
# install two helper packages we need
RUN apt install -yq --no-install-recommends software-properties-common dirmngr
# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: 298A3A825C0D65DFD57CBB651716619E084DAB9
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN apt install -yq --no-install-recommends r-base


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
# RUN ./mambaforge/bin/conda clean --tarballs --index-cache --packages --yes && conda clean --force-pkgs-dirs --all --yes
# configure the python env
ENV CONDA_DIR /opt/knime/mambaforge
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH
# RUN  echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> /etc/skel/.bashrc &&     echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ~/.bashrc # buildkit
RUN ./mambaforge/bin/conda init
# copy the python env file
COPY python_env.yml /opt/knime/python_env.yml
RUN ./mambaforge/bin/mamba env create -f python_env.yml

# Download and install knime server and rename it as knime_installer.jar
RUN wget https://download.knime.com/server/4.16/4.16.0/knime-server-installer-4.16.0.0129-aea6215f.jar -O /opt/knime/knime_installer.jar

# Copy the auto-install.xml file to the knime server
COPY auto-install.xml /opt/knime/auto-install.xml
# change the ownership of the auto-install.xml file
# RUN sudo chown knime /opt/knime/auto-install.xml
RUN java -jar knime_installer.jar auto-install.xml

RUN chmod 744 /opt/knime/knime_server/knime_executor/start-executor.sh
# copy executor.epf and preferences.epf to the knime server
COPY executor.epf /opt/knime/knime_server/workflow_repository/config/client-profiles/executor/
COPY preferences.epf /opt/knime/knime_server/knime_executor/configuration/
# change the ownership of the files
# RUN chown knime /opt/knime/knime_server/workflow_repository/config/client-profiles/executor/executor.epf
# RUN chown knime /opt/knime/knime_server/knime_executor/configuration/preferences.epf
# RUN cp -rf executor.epf /opt/knime/knime_server/workflow_repository/config/client-profiles/executor/
# RUN cp -rf preferences.epf /opt/knime/knime_server/knime_executor/configuration/
# mount the workflow repository folder
VOLUME   ["/opt/knime/knime_server/workflow_repository/workflows"]

USER root
RUN chown knime /opt/knime/knime_server/workflow_repository/workflows
# RUN cp -r /opt/knime/knime_server/install-data/linux-runlevel-templates/systemd/. /


EXPOSE  8080 8443
# knimeadmin/k-82dn

# start the knime server and executor
CMD bash -c "/opt/knime/knime_server/apache-tomcat-9.0.68/bin/startup.sh && /opt/knime/knime_server/knime_executor/start-executor.sh"
