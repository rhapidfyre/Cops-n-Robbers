| MASTER | [DEV BRANCH](https://github.com/rhapidfyre/Cops-n-Robbers/tree/dev) |
|---------|--------|
|[![Build Status](https://travis-ci.com/rhapidfyre/Cops-n-Robbers.svg?token=YQuixjt64y8Lxxz9tvQ5&branch=master)](https://travis-ci.com/rhapidfyre/Cops-n-Robbers)|[![Build Status](https://travis-ci.com/rhapidfyre/Cops-n-Robbers.svg?token=YQuixjt64y8Lxxz9tvQ5&branch=dev-build)](https://travis-ci.com/rhapidfyre/Cops-n-Robbers)|

![](git_banner.jpg)

# 5M Cops and Robbers (5M:CNR)
### A Cops and Robbers Gamemode for [FiveM](https://fivem.net/). 

## Headers

**Discord Invite:** [Join us on Discord](https://discord.gg/jaxxkKp)  
Official Test Server: **www.rhapidfyre.com:30120**

## Gamemode Information (Section 1)

## Current Controls

Please keep in mind this gamemode is fluid and controls can change at any time.
PLEASE review the control list every time the master is updated!

* (F2): Issue a ticket (For now, it also arrests the nearby player)
* (E): Interaction Key (For all interactive functions in the game)
* Rob Store: Point a gun

### Repository Information

This repository is the collection of the latest version of Cops and Robbers for
FiveM. This gamemode is written in Lua, with graphical interface written in 
HTML, CSS and Javascript(JQuery).

### Gamemode Information 

Cops and Robbers (hereforth 'CNR') is a game where regular civilians can choose
to either commit a crime and run from the cops, live a legitimate life, or 
join the force and chase the bad guys. The CNR game does NOT focus on quality
of life, such as realistic naming or licensing. The point of the game is to 
have quick action, run from the cops, chase bad guys, shoot people, and gain
cash.

### Self-Sufficient Gamemode / Dependencies

The goal is to be a self-sufficient gamemode. This means, while currently we
use the base resources and GHMattiMySQL, the intention is that we will over time
have our own integration with SQL, and handle our own chat and spawning events.
In the interest of time, we're using dependencies.

If you do not want to use GHMattiMySQL, spawnmanager, or any of those other
resources while you contribute, simply change the dependencies in the base
gamemode resource (cnrobbers).

## Installation Instructions (Section 2)

### SQL DATABASE

You will need to download [GHMattiMySQL](https://github.com/GHMatti/ghmattimysql) 
which is a FiveM Resource for interacting with the MySQL Database.
You can find GHMattiMySQL by clicking [on Github](https://github.com/GHMatti/ghmattimysql)
Currently, 5M:CNR is dependent upon this resource as there is a heavy use of 
databasing for preserving player information. 

To install the database, ensure you have a valid MySQL Connection with GHMattiMySQL.
Using either the command prompt, or an interactive program such as MYSQL Workbench or PHPMyAdmin,
import the SQL file given in the repository. This file is the latest version of 
the SQL instructions on establishing the database for the gamemode.

### Game Script

The game script as of the current version is reliable on a few base resources.
FiveM is installed with these resources, you just have to activate them.
* Spawn Manager `start spawnmanager`
* Base Events `start baseevents`
* FiveM Chat `start chat`

The gamemode will not start without these resources running, and connecting
players will not be able to join.

## Developer Information (Section 3)

If you wish to contribute or help in the development of this gamemode, you can 
create your own fork of the project. If you wish to test the script on your own
server, you will need to provide an SQL database.

Please note the coding convention at the bottom of this ReadMe before submitting
a pull request.

An SQL file has been provided for you to be able to run your own server. Simply
import the file into an SQL database, and use a resource to connect to it. Once
impoted, the game mode will do the rest. Be sure to restart the server after 
importing the database.

### Resource Files

All details of what each individual resource controls and is used for
is located in the header of the __resource.lua file.

  * [Blips & Radar Info](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_blips)
  * [Cash & Banking](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_cash)
  * [Character Creation](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_charcreate)
  * [Chat & Notifications](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_chat)
  * [Clans](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_clans)
  * [Death](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_death)
  * [Law Enforcement](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_police)
  * [Robberies & Heists](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_robberies)
  * [Scoreboard](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_scoreboard)
  * [Wanted Script](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_wanted)
  
### Pull Requests

To submit your code to the master branch, the coding convention must be (mostly)
followed. I'll put some extra work in for your first few contributions, but if it becomes
a reocurring issue, I will stop accepting pull requests from you. If you make any 
changes to the DATABASE, be sure to include an updated SQL file, so we can update
our databases to match, or there will be errors and inconsistencies.

TL;DR - Any changes to SQL schema must be included in your pull request.

### Code Convention

Any notes made that require revisiting or changing later must be exactly "-- DEBUG -",
which is the search term we will look for when finalizing a script. There should 
be NO "--DEBUG -" comments on the finished product.

Ensure that your comments and descriptions are in accordance with
http://keplerproject.github.io/luadoc/ for when we move to a wiki page
(this is a Lua parser). This parser will use the format given in LDoc
to generate a wiki page. LDoc is based off of Doxygen.

On top of complying with LDoc, all code submitted must conform to the following:
* Double spacing between all functions and variables
* Space at the top of the file before the first line of code
* Code not easy to decipher must have accompanying comments
* All resources must either have
** 1) a README file to explain what exports are available, OR 
** 2) a detailed explanation of what exports are available in the resource file

Try to keep to an 80 character maximum per line, but do not sacrifice easily-readable code for a spacing requirement.
I.e: It is not necessary to break a print string into 3 lines just to fit within 80 chars

# Copyright Information

Anyone is free to create their own servers with the files in this repository. 
All files in the repository have an open license and can be used in any way. FiveM
terms of use prohibit any profit from using their service, and this gamemode is 
provided for the community to host a unique game. All credit, if given, should
go to the original creator as well as the contributors as applicable.
