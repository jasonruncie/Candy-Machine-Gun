### Candy-Machine-Gun

[![Quick Demo](https://img.youtube.com/vi/2zzf8YrcEbo/hqdefault.jpg)](https://youtu.be/2zzf8YrcEbo)

This project's purpose is to automate most of the process for launching a Candy Machine, just point and shoot. Hopefully this simplification of the process can lead to more advancements in the feaures around it, like the new art generator that is part of the metaplex repo.

The process was developed with guidance from many resources; especially:
* https://hackmd.io/@levicook/HJcDneEWF
* https://twitter.com/redacted_j/ (particularly his office hours)
* https://github.com/exiled-apes/candy-machine-mint
* https://nippycodes.com/coding/candy-machine-instructions/

And a special thanks to https://twitter.com/sadbearsnft for sponsoring this project!

Someone with just a little familiarity with VSCode or Docker or a Terminal/Shell should be able to follow this README and the  comments in the Dockerfile/createCandyMachine.sh and be able to deploy a Candy Machine without needing to understand how it works or even what a smart contract / solana program is. Everything is done with official repos and the only code is in two bash scripts that should be relatively simple to follow.

You can use this as a launching point to start with a working Candy Machine solution, and then work your way through all of the steps to gain an understanding of what everything does if that is your goal.

It is meant to be run with Docker (Compose), which can be downloaded from https://docs.docker.com/engine/install/.

																																																												  

*Don't skip the Post-installation options. Particularly on linux:*
```bash
 sudo groupadd docker
 sudo usermod -aG docker $USER
 newgrp docker
```
## Docker
Docker works by running commands that are written in the Dockerfile to produce an image that can then be run as a container / instance. I am not a Docker expert, so there may be better ways to do some of the processes I'm doing, but it makes sense to me and more importantly, it works. 

There are many details in the comments of the Dockerfile. The Dockerfile could be built directly, but using docker-compose is best. The using compose will automatically run the container with the shared folder configured so that it will be accessible to both your host OS and the container. You can run the Dockerfile with volume options directly if you prefer.

## Not Using Docker
If you are comfortable with a bash shell you should be able to follow the steps involved and run the process directly on your system instead of in Docker. Systems other than Ubuntu/Debian will likely require minor changes to various commands. 

## VSCode
I have primarily used VSCode https://code.visualstudio.com/ for developing this, so this has all been built / tested using that. VSCode is not required, but if you aren't familiar with any of these tools or types of files then you should get VSCode. There is an extension (https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) for VSCode that simplifies working with Docker, which is helpful if you aren't familiar with it. 

With Docker and the Docker extension installed, after opening the project folder in VSCode, simply right click on "docker-compose.yml" in the Explorer, or inside the editor after opening it, and choose "Compose Up" to launch a demo Candy Machine and local Candy-Machine-Mint page.

The build process will create a new instance of the official Solana image, install additional software, and (if createCandyMachine.sh is in the ENTRYPOINT) create your new Candy Machine. It will take a while the first time you build it, but future builds will use cached layers and be much faster. 

It may look like it is "Done ..." at times, but that is just an individual step completing. In VSCode, the terminal that is running will display the following when it actually completes:

> Creating candy-machine-gun_cm_1 ... done
>
> "**Terminal will be reused by tasks, press any key to close it.**" 

Once completed, in the Docker extension explorer there will be a new Image and a running Container: candy-machine-gun_cm[_1]. 

Right clicking on the container and choosing "View Logs" (after it has started) will let you see the script processing, and eventually the local link to the mint page. Depending on your system, the localhost or the IP based link may work better, so if one fails to connect, try the other.  The app requires SSL, but I have not added support for that yet, so you may get a security warning from your browser. You may need to expand "Advanced" or "More info..." to confirm that you do wish to proceed to the page. On a real hosted website with SSL certificates this would not be the case.

In VSCode in the context (right-click) menu for the container, there is also an option to "Attach Shell" which will bring you to a Terminal inside your running container. In that Terminal you can inspect the results of the build process and run solana / metaplex commands.

## Shared Folder
The shared folder allows you to easily use one copy of data/files/images throughout several iterations of building / testing docker containers and Candy Machines. Then you can switch out the files for creating new Candy Machines without re-building the image. Every run of the createCandyMachine.sh script will create a folder in shared/runs that will hold details and logs produced during the run.

## Solana wallet
A funded Solana wallet is needed to create a Candy Machine.  You can add an existing id.json file to ./shared or a new one will be created for you using `solana-keygen new` during the first run.

On devnet, the script will airdrop 1 SOL for you if there is no balance, however the airdrop is limited and may. not always complete. The accout in the id.json file will be retained and reused for additional runs, even if you requild the image, unless you remove it from ./shared. You can send more SOL to that wallet (which will be displayed in the logs) using https://www.spl-token-ui.com/#/sol-airdrop or transfer from another wallet. 

*Note: This project does not include an id.json file in it.*

If you do not have an id.json file you've been working with, just look in ./shared a little bit after running "Compose Up" and there will be a new one there. This is what will be the authoitative key for the Candy Machine.  To use this wallet in Phantom, open it with a text editor, there will be a bunch of numbers in brackets [1 2 3 ... 234 235]

Copy the whole thing, including the brackets. Go to Phantom, click the 3-bars/hamburger button in the top-left, click Add / Connect Wallet.
Click on Import Private Key, then paste that string into the Private Key field, and give it a name you will recognize, such as candywallet.
Then click on the gear in the bottom-right of Phantom, scroll down to Change Network, click that, then click Devnet - assuming you are testing on devnet.

Then when you are ready for mainnet, just send some SOL to the wallet you are using and change "devnet" to "mainnet-beta" in the createCandyMachine.sh call. You can run the script yourself in the Terminal, or use Compose Restart to cause the script to run again with the arguments in the Dockerfile ENTRYPOINT. 

You should test to confirm that everything is as desired using devnet, then run the whole thing a few more times on devnet, then go to mainnet-beta. The actual mainnet-beta network is less stable than devnet, so some transactions will likely run into timeouts at some points, unless you are using dedicated resources (RPC Servers.) I will be continueing to test and add more checks \ fault-tolerance over time.


## Signing
By default, the Candy Machine program will sign the NFTs created, however all creators involved should sign them as well. I am still building up an understanding of this process, more to come...

## Minting
If you pass a number greater than 0 to the createCandyMachine.sh call for num_to_mint, then before even setting a start date, the process will mint that many tokens, which will go into the id.json account. By default, this project will create two NFTs (the sample files,) and use mint_one_token to mint one of them to the Treasury wallet, and launch the Candy-Machine-Mint web button so that you can mint one from any browser wallet.

I plan to expand the minting options, but this works as a good first POC.

## Images
Your images and JSON files should all go in ./shared/images 
I have included fully functioning example files in this project, which can be used to test and model your metadata after. Your image files should be named 0.png through n-1.png, unless you *know* what you are doing.

The JSON files should be the same, one for one, except with .json instead of .png as the extension.
Inside the JSON files, there is an "image" key. This (along with an entry in files) should be set to "image.png" if you want metaplex to handle uploading the files. You can set to a URL to skip uploading and use existing links.

By default arweave is used.  Support has been added for IPFS, but I have not tried it.


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
