#!/bin/bash

# Load environemnt entries
source ~/.bashrc

######################
## Install Metaplex 

# Clone the latest metaplex repo
git clone https://github.com/metaplex-foundation/metaplex.git /app/metaplex

######################
## If you need a specific commit 
# cd /app/metaplex
# git checkout 37218713d8587dcf18e3c70907d7f1d5545545f8
 
######################
## If you need a specific pull request
cd /app/metaplex
git fetch origin pull/985/head:betterverify
git checkout betterverify


# Install dependencies and build metaplex.
# This may take a while and have some warnings, but should succeed overall
cd /app/metaplex/js/packages/cli
yarn install
yarn build

