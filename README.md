# Description

Shooty Game is a 2D battle arena based shooter where players are assigned to teams and try to kill the other team with infinite respawns.

# Base Game Setup:

The base game and server are separate projects intentionally. The base game is in the “main” branch of this repository and the server is in the “server” branch of this repository.

Clone the “main” branch from this repository.

Open the “project.godot” file in Godot.

Set up the export format of the project. 

1. Go to Project > Export (top of the program).
2. Click “Add…” (top of the section).
3. Choose the target operating system to export to.
4. Under the export options on the right side of the section, make sure that “Binary Format” and “Embedded Pck” is enabled.

To export the project go to Project > Export (top of program) and click the “Export Project” button which will ask you where to save the target executable file to.

# Multiplayer Setup

Since the server and base game are separate in Shooty Game, you have to export them as separate projects. The server acts as the middleman between all players in the multiplayer game.

1. Follow the same steps as above for setting up the project except clone from the “server” branch.

2. Run the executable file for the server to run the multiplayer server.
   1. The IP Address to the server will be the IP Address of the router that the server is being hosted on.
      1. To change the default address of the main server go to “src/main/server/server.gd” in the base game and edit the “MAIN_HOST” constant.
      2. You can host servers in various ways (see “Hamachi Setup” and “Cloud Server Setup”).
   2. The port to the server is hardcoded inside of the program and can be found (and changed). When changing it, it has to be changed in both the base game and server.
      1. For the base game, go to “src/main/server/server.gd” to find the constant “MAIN_PORT”.
      2. For the server, go to “src/main/server/server.gd” to find the constant “_PORT”.
   
3. Run the base game and connect to the server by going to Multiplayer.

   1. Click the “Main Server” button to connect to the hardcoded host and port in the base game found in “src/main/server/server.gd”.

   2. Click the “Direct Connect” button to be able to enter in your own IP Address and Port separated by a colon and press “Direct Connect” again to connect to the entered server.

      

## Hamachi Setup

If you don’t want to set up the game server on cloud services and want to host the server yourself, you have to open a port on your router to allow external connections to it so that players can connect to the game server. Hamachi is a program that easily allows multiple routers to connect to each other through open ports.

Video Tutorial (its for Minecraft but the principle still applies):[(273) ☑️How to host a Minecraft 1.16.3 Server || Using Hamachi - YouTube](https://www.youtube.com/watch?v=iN1eNo-BKWQ)

1. Go to [VPN.net – Hamachi by LogMeIn](https://www.vpn.net/) and download Hamachi from there. 
2. Once you do that and finish installing the program, it will ask you to login. Create an account (a free plan is good enough for testing) and login with it 
   1. COMMON ISSUE: Sometimes Hamachi won’t start and you’ll end up with something like this: ![img](https://lh3.googleusercontent.com/wBfT-QiuDNm6NE8-XleHHGlifqrTCgfv-syGeIDTItPQ8iGO-zJ6Q9m6BzzZ6XahPMh0pBIyp-L6P6v4yzm8gCwt40MOIlNXCU-I6oXOOwcKJmp6qASV3JTlntNfR9uF0qw-B7kG)In that case, go check this link: [Solved: Hamachi: service stopped - LogMeIn Community](https://community.logmein.com/t5/LogMeIn-Hamachi-Discussions/Hamachi-service-stopped/td-p/132889)
3. Once you’ve got Hamachi set up, make sure to press the power on button.
4. Now you want to create a network. Go up to “Network” in the top of the program, then in the drop down pick “Create a new network.”
5. Put in whatever you want for the network id and password, but make sure its something easy to remember so you can share it with the people who you want to test the game with.
6. Once the people have joined your network, all you have to do is launch the server and connect to it! Make sure that the people who want to connect to your server have your IP address.

## Cloud Server Setup

You first will want to take a look at this link -> [GCPTutorial/GCPTut.md · master · menip / Godot Multiplayer Tutorials · GitLab](https://gitlab.com/menip/godot-multiplayer-tutorials/-/blob/master/GCPTutorial/GCPTut.md)
It mostly covers everything you need to know, but with a few caveats.

1. First, you only want to get the .pck file compiled from the server branch.
2.  Second, you have to store the .pck file online in such a way that you can download it off of a website. We did this by uploading it onto discord and then copying the download link.
3. Third, in the VM, you want to do wget (the link to the pck) to download the pck.
4. The rest should just follow whatever is in the tutorial, but make sure you have the latest version of the Godot server executable instead of 3.1.1

# Known Bugs

Sally's sprites don't show up in Local Multiplayer but they do in Server Multiplayer

# Resources

## General Game Stuff

How to make a good platformer:(https://www.youtube.com/watch?v=vFsJIrm2btU)

Introduction to State Machines:https://gameprogrammingpatterns.com/state.html

## General Networking:

Networked Physics:https://www.gafferongames.com/post/introduction_to_networked_physics/

Also the full website is pretty cool (General Networking Bible)https://gafferongames.com/

## Godot Networking:

Basic multiplayer documentation: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html

Multiplayer Tutorials: Used to build the prototype[Files · master · menip / Godot Multiplayer Tutorials · GitLab](https://gitlab.com/menip/godot-multiplayer-tutorials/-/tree/master)

First video in a series on how to do dedicated servers in Godot.[Godot Multiplayer Server-Client Tutorial | Godot Dedicated Server #1 - YouTube](https://www.youtube.com/watch?v=lnFN6YabFKg)

Very minimalistic tutorial on how to set up a godot dedicated server.https://mrminimal.gitlab.io/2018/07/26/godot-dedicated-server-tutorial.html

## General Godot Stuff:

How to format your gdscript code: https://github.com/Scony/godot-gdscript-toolkit

How to use the tileset editor:https://www.youtube.com/watch?v=V9OoaOlXc_4

How to do camera on multiple people:https://www.youtube.com/watch?v=W7WsL3qaPqg

## FPS Networking:

Source Engine Networking (Valve):https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking

Overwatch Networking:https://www.youtube.com/watch?v=W3aieHjyNvw

Halo Reach Networking:https://www.youtube.com/watch?v=h47zZrqjgLc

Quake Cheats: http://www.catb.org/esr/writings/quake-cheats.html

Tribes Networking Model:https://www.gamedevs.org/uploads/tribes-networking-model.pdf

Extrapoliation/Dead Reckoning:https://www.gabrielgambetta.com/entity-interpolation.html

MMO Networking (I Think): http://ithare.com/contents-of-development-and-deployment-of-massively-multiplayer-games-from-social-games-to-mmofps-with-stock-exchanges-in-between/
