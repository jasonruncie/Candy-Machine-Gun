#!/bin/bash

# Load environemnt entries
source ~/.bashrc

######################
## Install Candy-Machine-Mint
cd /app/
git clone https://github.com/exiled-apes/candy-machine-mint.git
# gh repo fork https://github.com/exiled-apes/candy-machine-mint.git --clone=true
cd candy-machine-mint


# sed -i "s/\"private\"\: true,/\"private\"\: true, \"homepage\": \"https:\/\/$GH_USER.github.com\/candy-machine-mint\/\"/g" package.json
# sed -i "s/\"start\"\: \"react-scripts start\",/\"start\"\: \"react-scripts start\",\"predeploy\"\: \"npm run build\", \"deploy\"\: \"gh-pages -d build\", /g" package.json

# The below command is called out by the yarn install as something that should be run to keep browser data up to date.
npx browserslist@latest --update-db

yarn install
#yarn build
