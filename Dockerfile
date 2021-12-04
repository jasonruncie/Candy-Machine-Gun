# Created by Jason Runcie
# https://github.com/jasonruncie/Candy-Machine-Gun

# Requirements:
# docker - https://www.docker.com/get-started
# Or Ubuntu/Deb 
# Or the ability to translate the necessary commands to your OS.

# Unless you know what you are doing, the best way to build this image is with "docker-compose up". 
# In VSCode, right click on docker-compose.yml in the EXPLORER or in an open editor and choose "Compose Up".

# The build process may take several minutes. It pulls down several repos from github. 
# The install of metaplex alone causes the image to be a little over 3GB. There are likely ways to reduce this if needed. 

# Running "Compose Up" will run all of the steps for creating a candy machine and minting tokens, depending on the ENTRYPOINT set.

# If you have an ubuntu system you want to use, you should be able to just run the commands / processes from this file and the scipts and skip docker.
# For MacOS or Windows you may need to make some modifications, depending on the tools you use.


# Start by using the latest stable solana base image. This should be pointing to the official solanalabs/solana docker image.
# When first running Candy-Machine-Gun, the latest stable solana image will be cached.  
# If you want to update to a newer version you can specify the version here or remove the cache.
FROM solanalabs/solana:stable

# The solana docker image exposes ports to be used for running a node. The ENTRYPOINT at the end of this Dockerfile prevents the node from starting, but the ports are still exposed. 
# If that is an issue for you, can change the reference from solana to ubuntu (see below), and uncomment RUN and ENV lines in Install Solana section below
# FROM ubuntu

# Install some required / useful tools, feel free to change nano to your preferred editor if you know what you are doing.
RUN apt update -y && apt install -y \
    git \
    gpg \
    sudo \
    nano \
    curl \
    jq \
    libcurl4-openssl-dev \ 
    software-properties-common \
    python3-pip \
    libssl-dev \
    libnss3-tools \
    pkg-config \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /app

####################
#  Install Solana  #
# Note: You only need to use this if you switched to ubuntu as the base image
# RUN sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
# ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

####################
# Install Node/ENV #

COPY ./scripts/install_node.sh ./configs/* /app/
RUN bash ./install_node.sh

##############################
# Install Candy Machine Mint #
COPY ./scripts/install_cm_mint.sh /app/
RUN bash ./install_cm_mint.sh

####################
# Install Metaplex #
COPY ./scripts/install_metaplex.sh /app/
RUN bash ./install_metaplex.sh


##########################
# Candy Machine Settings #

# This is the port that the candy-machine-mint local server will use by default
EXPOSE 3000

COPY ./scripts/createCandyMachine.sh /app/

# Below entry point automatically builds/deploys the Candy Machine and runs a local instance of the candy-machine-mint project when the container starts.
# See createCandyMachine.sh to learn about the arguments and process.
ENTRYPOINT [ "bash", "./createCandyMachine.sh", "--network", "devnet", "--price", "0.1", "--num_to_mint", "1", "--startdate", "24 Sep 2021 12:00:00 GMT" ]

# If you don't want to automatically run the script when the container starts, use the below entry point instead (comment out the ENTRYPOINT above and uncomment this one)
# At a bash prompt you can run the script ("bash ./createCandyMachine.sh"), or directly call any commands provided by solana or metaplex.
# If you do not specify an ENTRYPOINT then a local solana node will start automatically, unless you change the base image.
#ENTRYPOINT [ "bash"]
