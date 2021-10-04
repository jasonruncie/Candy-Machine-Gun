#!/bin/bash

TIMESTAMP=$(date +%s)

########################
## Optional Arguments ##

#   --price       - This is the price that the candy machine will be set to. 
#   --startdate   - This is the start date that the Candy Machine will be set to use. 
#   --num_to_mint - Specify a number of mint_one_token commands to run. 
#   --network     - Specify the network to use. Options are devnet, testnet, or mainnet-beta
#   --cachefile   - Advanced Feature - Pass the path to an existing cacheFile for the Candy Machine to use. 
#                   This can be used to continue a previously interrupted upload or to use a (potentially modified) cache from a previous CM run.
#                   This is not needed if just continueing the most recent run, or if edits were in place at /app/shared/.cache/[cacheFile]
#                   The full path to the file is needed here. The Candy Machine CLI expects the file to be in the format [NETWORK]-[whatever_name]
#                   whatever_name cannot have any dashes or slashes [-/]
#                   To reduce the risk of a rogue script messing up which network you are going to, you will need to ensure the file is named with the network you wish to use it on
#                   If you have a cache file such as "devnet-cache1633279043" that you have modified to re-use on mainnet-beta, you will have to rename it to mainnet-beta-cache1633279043 first.
#                   The same applies for going the other way, or to/from testnet

###########################
## Example direct calls: ##
# bash ./createCandyMachine.sh --network devnet --price 0.1 --num_to_mint 1 --startdate "24 Sep 2021 12:00:00 GMT"
# bash ./createCandyMachine.sh --network mainnet-beta --price 1 --num_to_mint 0 --startdate "24 Sep 2021 12:00:00 GMT"

########################
## Process parameters ##
# Set default values :-here}. 
price=${price:-0.01}
network=${network:-'devnet'}
startdate=${startdate:-''}
num_to_mint=${num_to_mint:-0}
cachefile=${cachefile:-''}

echo "Parameters:"
while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare ${param^^}="$2"
        echo $1 $2 | tee -a /app/shared/$TIMESTAMP-parameters.txt
    fi
    shift
done


##################################
## Prepare Environment for Node ##

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Create new Run directory. You will be able to access files such as logs in this folder through your OS in "shared" in the project directory.

RUNNAME=$NETWORK-$TIMESTAMP
RUNDIR=/app/shared/runs/$RUNNAME
mkdir -p $RUNDIR
echo "Created Run Directory: $RUNDIR"



if [[ $CACHEFILE == "" ]]; then 
    echo "No cachefile parameter passed, so will be generating a new cache file"
    CACHEFILENAME="cache$TIMESTAMP"
else 
    echo "checking passed cache file"
    if [ -f $CACHEFILE ]; then
        echo "Attempting to use exsting cache file $CACHEFILE";
        mkdir -p /app/shared/.cache
        cp -v $CACHEFILE /app/shared/.cache/ > $RUNDIR/0-copyPrevCacheFile.txt
        CACHEFILENAME=$(echo $CACHEFILE | awk -F "/" '{print $NF}' | awk -F "-" '{print $NF}')
    elif [[ -d $1 ]]; then
        echo "Directory passed. This is not yet supported, please pass full path to cache file"
        return -1
    else
        echo "Passed cachefile was not found, please check your command."
        echo "The path should be in the form: /app/shared/runs/whichNet-timeStamp/cacheFile"
        echo "Unless you are using a cache file you manually added somewhere, then it is the absolute path to that."
        echo "Known prior run files:"
        echo l shared/runs/*/*cache*
    fi
fi

# TODO: Add csv->json and layers->images / create art features

#########################
## Check images / json ##
if [[ $(find /app/shared/images/ -type f -name '*.json' |  xargs jq -r '.symbol' | sort | uniq -c | awk '{print length($2)}' | sort -nr | head -n1) -gt 10 ]]; then 
    echo "ALERT! Your images metadata is not correct "
    echo "!!  You have symbols with more than the max 10 characters !!"
    echo "   Num | symbol"
    find ./shared/images/ -type f -name '*.json' |  xargs jq -r '.symbol' | sort | uniq -c
    echo "You need to shorten your symbol"
    exit -1
fi

# The verify_token_metadata command currently has some specific path requirements. 
cd /app
echo "node /app/cm/build/candy-machine-cli.js verify_token_metadata ./shared/images/" > $RUNDIR/1-jsonVerifyLog.txt
node /app/cm/build/candy-machine-cli.js verify_token_metadata ./shared/images/ 2>&1 | tee -a $RUNDIR/1-jsonVerifyLog.txt
# TODO Add verification / checks

# Changing to the shared folder so that the .cache file will be located on the mounted folder and acessible from host OS.
cd /app/shared

##################
## Solana steps ##

# Ensure the config directory exists
mkdir -p /root/.config/solana/

# Check if an id.json was supplied in the shared folder. If not, create a new one.
if [ -f /app/shared/id.json ]; then
    echo "Found existing id.json, copying to default location"
    cp /app/shared/id.json /root/.config/solana/

else
    echo "No wallet was provided."
    echo "Creating new wallet, with the id.json in the shared folder and copied to the default location"
    if [ $NETWORK == "mainnet" ]; then
        echo "You will need to add funds to the wallet before you can upload. Cost is currently about 16.7 SOL / 10,000 files"
    fi
    # Create a new keypair to be the treasury for the Candy Machine
    echo "solana-keygen new --no-passphrase --outfile /app/shared/id.json" > /app/shared/SECRET-$RUNNAME-SolanaKeygenLog.txt
    solana-keygen new --no-passphrase --outfile /app/shared/id.json  2>&1 | tee -a /app/shared/SECRET-$RUNNAME-SolanaKeygenLog.txt
    cp -v /app/shared/id.json /root/.config/solana/ >> /app/shared/SECRET-$RUNNAME-SolanaKeygenLog.txt
fi

# Make a copy of the json named to match the run name. This is so that you can keep track of the accounts associated with each run.
# This file, and any potential keygen logs above, are being placed in /app/shared/ rather than the run directory so that nothing too sensitive is put in those run folders.
# This way the run folders contents could be shared during dev / testing without accidentally sharing private keys.
cp /app/shared/id.json /app/shared/SECRET-$RUNNAME.json

solana config set --url $NETWORK

solana address 2>&1 | tee  $RUNDIR/pub.key
solana balance  2>&1 | tee  $RUNDIR/initialBalance.txt

if [[ $(cat $RUNDIR/initialBalance.txt) == "0 SOL" ]]; then 
    if [[ $NETWORK == mainnet* ]]; then 
        echo "You appear to be using an account with 0 balance on mainnet"
        echo "Transfer some SOL to $(cat $RUNDIR/pub.key) and then re-run"
        exit
    else
        echo "Airdropping 1 SOL, you may need more depending on the number of NFTs you are creating."
        solana airdrop 1  2>&1 | tee  airdrop.txt
    fi
fi

####################
## Metaplex steps ##

# Upload images and json to arweave
echo "Upload files to arweave and create the cache."
echo "node /app/cm/build/candy-machine-cli.js upload /app/shared/images/ --env $NETWORK --keypair /root/.config/solana/id.json -c $CACHEFILENAME -l trace" | tee $RUNDIR/2-uploadLog.txt
node /app/cm/build/candy-machine-cli.js upload /app/shared/images/ --env $NETWORK --keypair /root/.config/solana/id.json -c $CACHEFILENAME -l trace  2>&1 | tee -a $RUNDIR/2-uploadLog.txt

#TODO Check log file
# Potential Errors to watch for:
# Translating error Error: Transaction was not confirmed in 60.01 seconds.


# Veryify uploads
echo "Verify the uploads"
echo "node /app/cm/build/candy-machine-cli.js verify --env $NETWORK --keypair /root/.config/solana/id.json -c $CACHEFILENAME -l trace" | tee $RUNDIR/3-verifyLog.txt
node /app/cm/build/candy-machine-cli.js verify --env $NETWORK --keypair /root/.config/solana/id.json -c $CACHEFILENAME -l trace  2>&1 | tee -a $RUNDIR/3-verifyLog.txt
#TODO Check log file

# Create the Candy Machine
echo "Creating Candy Machine"
echo "node /app/cm/build/candy-machine-cli.js create_candy_machine -e $NETWORK --keypair /root/.config/solana/id.json -p $PRICE -c $CACHEFILENAME -l trace" | tee $RUNDIR/4-createCMLog.txt
node /app/cm/build/candy-machine-cli.js create_candy_machine -e $NETWORK --keypair /root/.config/solana/id.json -p $PRICE -c $CACHEFILENAME -l trace 2>&1 | tee -a $RUNDIR/4-createCMLog.txt
#TODO Check log file

# Get the config id of the Candy Machine from the cache. 
# This will not work if there are more than one cache files. That is the reason we make sure it is cleared at the start.
# If you are using more than one, change cat ./.cache/* to refer to your specific temp file.
echo "Config ID from cache"
cat /app/shared/.cache/$NETWORK-$CACHEFILENAME | jq '.program.config' 2>&1 | tee  $RUNDIR/quotedconfigid.txt
#TODO Check file

# Before setting the start date we can mint tokens directly. The number minted is controlled using the "num_to_mint" argument.
i=0
while [ $i -lt $NUM_TO_MINT ]
do
    # Use this to directly mint one token - mostly for testing, but can be used to mint tokens for special purposes.
    # Should work even before setting start date
    echo "node /app/cm/build/candy-machine-cli.js mint_one_token -e $NETWORK -k /root/.config/solana/id.json -c $CACHEFILENAME -l trace" | tee $RUNDIR/5-mintoneLog-$i.txt
    node /app/cm/build/candy-machine-cli.js mint_one_token -e $NETWORK -k /root/.config/solana/id.json -c $CACHEFILENAME -l trace  2>&1 | tee -a $RUNDIR/5-mintoneLog-$i.txt
    #TODO Check log file
    i=$(( $i + 1 ))
done


if [[ $STARTDATE != '' ]]; then
    # Set the startdate for the Candy Machine
    # A past date is fine if you want access right away
    echo "Setting startdate to $STARTDATE"
    echo "node /app/cm/build/candy-machine-cli.js update_candy_machine -e $NETWORK -k /root/.config/solana/id.json -d $STARTDATE -c $CACHEFILENAME -l trace" | tee $RUNDIR/6-updateStartDateLog.txt
    node /app/cm/build/candy-machine-cli.js update_candy_machine -e $NETWORK -k /root/.config/solana/id.json -d "$STARTDATE" -c $CACHEFILENAME -l trace 2>&1 | tee -a $RUNDIR/6-updateStartDateLog.txt
    #TODO Check log file
else
    echo "No default or passed startdate arg so only mint_one_token commands will be able to mint, unless updated by running the following:"
    echo "node /app/cm/build/candy-machine-cli.js update_candy_machine -e $NETWORK -k /root/.config/solana/id.json -d "YOUR_START_DATE" -c $CACHEFILENAME -l trace "
fi



#######################
## Candy-Machine-Mint

if [[ $STARTDATE != '' ]]; then
    cp /app/.env $RUNDIR/

    # This is from the .cache/temp
    CONFIG=$(cat $RUNDIR/quotedconfigid.txt)
    MACHINE_ID=$(cat $RUNDIR/4-createCMLog.txt | awk '/pubkey/ {print $6}')
    START_DATE=$(cat $RUNDIR/6-updateStartDateLog.txt | awk '/timestamp:/ {print $5}')
    RPC_HOST=$(solana config get | awk '/RPC URL:/ {print $3}')
    NETWORK=$(echo $RPC_HOST | awk -F  "." '/api/ {print $2}')
    ADDRESS=$(cat $RUNDIR/pub.key )

    sed -i "s/CONFIG_PLACEHOLDER/$CONFIG/g" $RUNDIR/.env
    sed -i "s/MACHINE_ID_PLACEHOLDER/\"$MACHINE_ID\"/g" $RUNDIR/.env
    sed -i "s/START_DATE_PLACEHOLDER/${START_DATE}000/g" $RUNDIR/.env
    sed -i "s/NETWORK_PLACEHOLDER/$NETWORK/g" $RUNDIR/.env
    sed -i "s~RPC_HOST_PLACEHOLDER~$RPC_HOST~g" $RUNDIR/.env
    sed -i "s/ADDRESS_PLACEHOLDER/\"$ADDRESS\"/g" $RUNDIR/.env

    cp $RUNDIR/.env /app/candy-machine-mint

    cd /app/candy-machine-mint

    HTTPS=true npm start 
else
    echo "Not starting candy-machine-mint since no start date set."
fi