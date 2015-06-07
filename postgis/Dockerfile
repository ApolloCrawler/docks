FROM ubuntu:14.04

MAINTAINER Tomas Korcak <korczis@gmail.com>

# Use bash instead of sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man subversion sudo unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

# Copy sudo settings
COPY etc/sudoers /etc/sudoers

ENV USER docker

# Create docker user
RUN useradd docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN mkdir -p /home/docker && chown -R docker:docker /home/docker

# Add files.
ADD root/.bashrc /root/.bashrc
ADD root/.gitconfig /root/.gitconfig
ADD root/.scripts /root/.scripts

# Set environment variables.
# ENV HOME /root

# Define working directory.
# WORKDIR /root

# Set locale
RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN apt-get update -qy && apt-get -qy install postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 postgis postgresql-server-dev-9.3 libpq-dev libregexp-assemble-perl libpcre3-dev

# Expose port
EXPOSE 5432

# Postgresql conf files
ADD etc/postgresql/9.3/main/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
ADD etc/postgresql/9.3/main/postgresql.conf /etc/postgresql/9.3/main/postgresql.conf

# Install script
ADD scripts/install.sh install.sh
RUN chmod 0755 ./install.sh

# Start script
ADD scripts/start.sh start.sh
RUN chmod 0755 ./start.sh
RUN mkdir /gisdata

# Generic states settings
ADD scripts/loader_states.sh loader_states.sh
RUN chmod 0755 ./loader_states.sh

# GENERATOR: loader_generate_census_script.sh
ADD scripts/run_loader_generate_census_script.sh run_loader_generate_census_script.sh
RUN chmod 0755 ./run_loader_generate_census_script.sh

# GENERATOR: loader_generate_script.sh
ADD scripts/run_loader_generate_script.sh run_loader_generate_script.sh
RUN chmod 0755 ./run_loader_generate_script.sh

# GENERATOR: loader_generate_nation_script.sh
ADD scripts/run_loader_generate_nation_script.sh run_loader_generate_nation_script.sh
RUN chmod 0755 ./run_loader_generate_nation_script.sh

# Add placeholder folder for SQL cripts
ADD sql sql/

ADD scripts/loader_generate_script.sh loader_generate_script.sh
RUN chmod 0755 ./loader_generate_script.sh

# MAGIC: Start postgres, create user, import data
RUN service postgresql start \
 && /bin/su postgres -c "createuser -d -s -r -l docker" \
 && /bin/su postgres -c "psql postgres -c \"ALTER USER docker WITH ENCRYPTED PASSWORD 'docker'\"" \
 && ./install.sh \
 && ./run_loader_generate_census_script.sh \
 && ./loader_generate_script.sh \ # Enable this, if you want tho have geonames data loaded into container. This is HUGE. Talking about tens of gigs! You have been warned!
 && ./run_loader_generate_nation_script.sh \

# Stop postgresql daemon
RUN service postgresql stop

CMD ["./start.sh"]