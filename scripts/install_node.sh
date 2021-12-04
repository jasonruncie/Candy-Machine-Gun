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

npm install -g ts-node