### Candy-Machine-Gun

[![Quick Demo](https://img.youtube.com/vi/2zzf8YrcEbo/hqdefault.jpg)](https://youtu.be/2zzf8YrcEbo)

This project's purpose is to automate most of the process for launching a Candy Machine.

The process was developed with guidance from many resources; especially:
* https://hackmd.io/@levicook/HJcDneEWF
* https://twitter.com/redacted_j/ (particularly his office hours)
* https://github.com/exiled-apes/candy-machine-mint
* https://nippycodes.com/coding/candy-machine-instructions/

And a special thanks to https://twitter.com/sadbearsnft for sponsoring this project!

# How to use
## 1. Install git ##
If you don't already have Git, you can find install info for your system here: https://git-scm.com/downloads 

- On Windows, just download and run the installer from https://git-scm.com/download/win. Just continue through the setup, leaving the default options, unless you know that you want something different.

- On MacOS, use: ```brew install git```
- On Ubuntu, use: ```sudo apt-get install git```

## 2. Install Docker ##

If you don't already have Docker, you can view installation instructions and download the installer for your OS at https://docs.docker.com/engine/install/. 

- On Windows, the installation is straightforward, just run the installer leaving the default options.

- On MacOS, let me know if you run into any issues or know anything I should add here.

- On Ubuntu, docker provides a scripted install using:
  
  ```bash
  sudo apt  install curl  # If you don't have curl
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh

  # Now add docker-compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ```
  Or read through [the guide](https://docs.docker.com/engine/install/) to use other options, but be sure to also install docker-compose and follow the Post-installation steps, in particular running the following:
  ```bash
  sudo groupadd docker
  sudo usermod -aG docker $USER
  newgrp docker
  ```
  Followed by restarting or log out and back in.

## 3. Install VSCode and the Docker Extension ##

If you don't already have VSCode you can install it from https://code.visualstudio.com/

You should select all options on the Select Additional Tasks screen, especially the two that Add "Open with Code" to your context menu.

On Ubuntu "```sudo snap install code --classic```" is a quick option.

You should also install the "Docker" and "Remote - Containers" extensions from Microsoft. You can search for them in the extensions panel or find them at these links:
 - https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker
 - https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

On Windows, I recommend changing the default terminal profile from Powershell to Git Bash.


## 4. Clone this repo ##

Run this command in the "bash" or "git bash" terminal:

```git clone https://github.com/jasonruncie/Candy-Machine-Gun.git```

## 5. Open the project folder in VSCode ##
You may be prompted to verify that you trust the source of the code. Obviously choose that you do. :)

## 6. Start the Docker image ##
In VSCode, right click on "docker-compose.yml" in the Explorer, or inside the editor after opening it, and choose "Compose Up" to launch a demo Candy Machine and local Candy-Machine-Mint page.

Running compose up may take several minutes, but you will know the image build has completed once the terminal says:
> "**Terminal will be reused by tasks, press any key to close it.**" 

In the Docker extension Explorer there will be a new Image and a running Container: candy-machine-gun. 

Right click on the container and choose "View Logs" (after it has started) to see the script processing, and eventually the local link to the mint page. Depending on your system, the localhost or the IP based link may work better, so if one fails to connect, try the other.  The app requires SSL, so you may get a security warning from your browser due to lack of an actual cert. You may need to expand "Advanced" or "More info..." to confirm that you do wish to proceed to the page. On a real hosted website with SSL certificates this will not be an issue.

Also when you right click on the container, there is an option to "Attach Shell" which will bring you to a Terminal inside your running container. In that Terminal you can inspect the results of the build process and run solana / metaplex commands. 

With the "Remote - Containers" plugin there is also an option to "Attach Vidual Studio Code" which will open an instance of VSCode that is essentially running inside of the container, so you can more easily access the files and terminals. I recommend doing this if you wish to explore CM more.

## 7. Make it your own ##
If you followed these steps as they are, you should now have a complete and working CM system and a small CM on devnet with some of my images.  You can replace the files in shared/assets with your own and in the terminal inside docker, go to /app/shared and run something like the following:

```bash ../createCandyMachine.sh --network mainnet-beta --price 1 --num_to_mint 0 --startdate "24 Sep 2021 12:00:00 GMT"```

To set up your own CM on mainnet, though you should test some of your own assets on devnet to be sure things are how you want. You will also have to send some SOL to the wallet that is created for you (if you don't already have a keyfile wallet to add to the shared folder, with the filename id.json)

If you have benefitted from my work I would love to get one of your NFTs for my collection representing people I have help. You can send one (or more, or SOL:) to my wallet at JASoNvc2K2jpXm13mGMmhN9ktevpS4PDijayrp8sLJrw

Feel free to message me [@Jason_Runcie](https://twitter.com/Jason_Runcie) on twitter, or stop in at my [discord](https://discord.gg/g4EVxqPS) server if you have any questions or issues with this process.

# Additional Info #
## Shared Folder ##
The shared folder allows you to easily use one copy of data/files/images throughout several iterations of building / testing Candy Machines. Then you can switch out the files for creating new Candy Machines without re-building the image. Every run of the createCandyMachine.sh script will create a folder in shared/runs that will hold details and logs produced during the run.

## Solana wallet ##
A funded Solana wallet is needed to create a Candy Machine.  You can add an existing id.json file to ./shared or a new one will be created for you using `solana-keygen new` during the first run.

On devnet, the script will airdrop 1 SOL for you if there is no balance, however the airdrop is limited and may. not always complete. The accout in the id.json file will be retained and reused for additional runs, even if you requild the image, unless you remove it from ./shared. You can send more SOL to that wallet (which will be displayed in the logs) using https://www.spl-token-ui.com/#/sol-airdrop or transfer from another wallet. 

*Note: This project does not include an id.json file in it.*

If you do not have an id.json file you've been working with, just look in ./shared a little bit after running "Compose Up" and there will be a new one there. This is what will be the authoitative key for the Candy Machine.  To use this wallet in Phantom, open it with a text editor, there will be a bunch of numbers in brackets [1 2 3 ... 234 235]

Copy the whole thing, including the brackets. Go to Phantom, click the 3-bars/hamburger button in the top-left, click Add / Connect Wallet.
Click on Import Private Key, then paste that string into the Private Key field, and give it a name you will recognize, such as candywallet.
Then click on the gear in the bottom-right of Phantom, scroll down to Change Network, click that, then click Devnet - assuming you are testing on devnet.

Then when you are ready for mainnet, just send some SOL to the wallet you are using and change "devnet" to "mainnet-beta" in the createCandyMachine.sh call. You can run the script yourself in the Terminal, or use Compose Restart to cause the script to run again with the arguments in the Dockerfile ENTRYPOINT. 

You should test to confirm that everything is as desired using devnet, then run the whole thing a few more times on devnet, then go to mainnet-beta. The actual mainnet-beta network is less stable than devnet, so some transactions will likely run into timeouts at some points, unless you are using dedicated resources (RPC Servers.) I will be continueing to test and add more checks \ fault-tolerance over time.


## Signing ##
By default, the Candy Machine program will sign the NFTs created, however all creators involved should sign them as well. You cannot sign any NFTs until they are minted, but you can run sign or sign_all more than once if desired, as new NFTs are minted.

## Minting ##
If you pass a number greater than 0 to the createCandyMachine.sh call for num_to_mint, then before even setting a start date, the process will mint that many tokens, which will go into the id.json account. By default, this project will create a CM with three assets, then use mint_one_token to mint one of them to the Treasury wallet, and finally launch the Candy-Machine-Mint page so that you can mint one from any browser wallet.

This mint page is just for demo purposes. If you don't already have a minting page solution in mind, the easiest option is to fork https://github.com/exiled-apes/candy-machine-mint, then sign up for a free [Vercel](https://vercel.com/) account and point it to your forked repo. Use the .env file that is produced for your CM and add the values to the vercel environment variables.

## Images ##
Your images and JSON files should all go in ./shared/assets 
I have included fully functioning example files in this project, which can be used to test and model your metadata after. Your image files should be named 0.png through n-1.png, unless you *know* what you are doing.

The JSON files should be the same, one for one, except with .json instead of .png as the extension.
Inside the JSON files, there is an "image" key. This (along with an entry in files) should be set to "image.png" if you want metaplex to handle uploading the files. You can set to a URL to skip uploading and use existing links.

By default arweave is used.  Support has been added for IPFS and AWS, but I have not tried those.

## RPC ##
By default the Candy Machine CLI and minting pages use public RPCs. The RPC is sort of like your internet provider, to connect to the blockchain network. The default RPC is like a public internet connection that is very heavily used and limited. These are okay for small tests, but will quickly rate limit you when trying to upload many files. You can upgrade your connection to Solana by getting your own RPC service. [QuickNode](https://www.quicknode.com?tap_a=67226-09396e&tap_s=2408354-e3e713&utm_source=affiliate&utm_campaign=generic&utm_content=affiliate_landing_page&utm_medium=generic) (I will get a little commission if you get a node using that link) is commonly used and the only I have tried. 

You can sign up for a free trial of the $9/month plan which may be enough for under 1000 assets. You can do much more with the $9 plan if you activate it by paying the $9 to end the free trial. Make sure you set up your node on SOL(ana) not ETH(ereum) which is the default when you create a new node.  The nodes are specific to the network, so if you want to do a large test on devnet, then you should get a Devnet node, but then you will also likely need on one Mainnet Beta. To activate it, go to billing and click the activate link.

Once you have your RPC node, copy the HTTP PROVIDER link and use it in your commands by adding -r HTTP_LINK or if using the script, edit the RPCLINK at the top of createCandyMachine.sh.

## Withdraw ##
Candy Machine now supports withdrawing the SOL that went into the config account.  The config account is what holds the data on-chain that defines the NFTs that will be minted. Once you are done with minting, you can run withdraw to get that SOL back and the config account data will be wiped. 

## Metadata ##

There are limits on some of the metadata values. 
| Field    | Limit |
| -----    | ----- |
| name     | 32 chars |
| symbol   | 10 chars |
| uri      | 200 chars |
| creators | 5 entries |
**Note: The Candy Machine program uses one of the creator entries, so you can only add 4 when using CM**

I have commented the below example, but this is technically not valid JSON. Use the example in shared/images if you want to start with a completed file.
*View the actual spec at https://docs.metaplex.com/nft-standard*

```JavaScript
{
  "name": "Jason Runcie",               // This is what the individual NFT will be named when viewed in most places.  
  "symbol": "{run:c}",                  // This is like "SOL" or "USD" It can be empty: "", and will be displayed in some viewers after the name.
  "description": "Ambigram of my name", // Some text to describe the NFT.
  "seller_fee_basis_points": 10000,     // This is the percentage x 100 of future sales that should be credited to the creators. So 100 is 1%, 10000 is 100%. ~500 seems popular.
  "image": "image.png",                 // This can be an existing URL or just image.png to have CM upload for you.
  "animation_url": "image.png",         // Optional link to animation. Will be replaced with the uploaded file link if image.png
  "external_url": "https://github.com/jasonruncie/Candy-Machine-Gun",    // Optional link to project page or similar. Viewers may require "HTTPS://" for this if supplied
  "attributes": [                       // This is an array of key-value pairs that describe the traits you want displayed when people view your NFT
    {
      "trait_type": "Background",       // trait_type is the general name of the characteristic 
      "value": "Black"                  // value is the specific characteristic of this NFT
    },
    {
      "trait_type": "Text",             // There can be many. Likely different wallets / viewers have a limit of how many they will display
      "value": "Jason Runcie"           // I tested using nested JSON, but that broke the NFT in Phantom.
    },
    {
      "trait_type": "Text Color",       // Experiment on devnet and see how things look in your wallet / viewer of choice.
      "value": "Red + Blue-Green"
    }
  ],
  "collection": {                       // This is more general data about your NFT. I assume different viewers will use these for specific purposes. 
    "name": "Jason Runcie",             // I believe this should be the name of your specific project / drop
    "family": "JR Ambigrams"            // and this could be an overall name for multiple sets.
  },
  "properties": { 
    "files": [                          // This and "creators" below are arrays of key-value pairs just like "attributes", you can add more entries.
      {
        "uri": "image.png",             // Include the image file like above. This will also get changed to the arweave link
        "type": "image/png"
      }                                 // You can include links to other files here as part of your overall product, including videos and custom files.
    ],
    "category": "image",                // This is to indicate the category of the NFT overall. There are several options.
    "creators": [                       
      {                                 // If you found my work helpful for your project, you could include my address below as a co-creator :).
        "address": "JASoNvc2K2jpXm13mGMmhN9ktevpS4PDijayrp8sLJrw",
        "share": 100                    // This is currently limited to 5 creator entries. Only 4 is using Candy Machine. Shares should add up to 100 and 0 is valid. 
      }                                 // This currently does not affect the initial sale, only royalties; on secondary markets that honor it. 
    ]                                   // All of the proceeds collected from minting are deposited into the treasury account that is used to create the candy machine. 
  }                                     // Protect your id.json! 
}
```
