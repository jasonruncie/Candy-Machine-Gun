# The below are just some aliases I am used to. 
echo "alias ll='ls -l'" >> ~/.bashrc 
echo "alias l='ls -lA'" >> ~/.bashrc 

# Install NVM so that we can run a specific version of node.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 14.17
npm install --global yarn

######################
## Install Metaplex 

# Clone the latest metaplex repo
git clone https://github.com/metaplex-foundation/metaplex.git /app/metaplex

######################
## If you need a specific commit 
# cd /app/metaplex
# git checkout 6364c1e7c4136474b1df03eca47be497ea160a38

######################
## If you need a specific pull request
cd /app/metaplex
## Using my improved verify code
git fetch origin pull/985/head:betterverify
git checkout betterverify


# Make a copy of the cli package to work with 
cp /app/metaplex/js/packages/cli /app/cm -r
cd /app/cm

# Install dependencies and build metaplex.
# This may take a while and have some warnings, but should succeed overall
yarn install
yarn build


######################
## Install Candy-Machine-Mint
cd /app/
git clone https://github.com/exiled-apes/candy-machine-mint.git candy-machine-mint
cd candy-machine-mint
# The below command is called out by the yarn install as something that should be run to keep browser data up to date.
npx browserslist@latest --update-db
yarn install

#yarn build
