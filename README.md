# Tap It!

## Overview
Tap It! is an iOS multipeer card game.
Test your observational skills and your reflexes with your friends. A game of fast-paced choices for up to eight players.

![TapIt](Documentation/TapIt.png)

## Game Play

### Rules

Each player sees two cards: the communal card (top card) and their private card (the bottom card). The goal is to find and be the first one to tap the single figure that is repeated on both cards. If you tap faster than all the other players, you get to steal the communal card to yourself and a new communal card is presented to everyone. If you tap the wrong figure, you get blocked for 3 seconds or until any other player find their respective figure. When the communal cards are out, the game ends and wins whoever owns the largest number of cards.

### The Game

Insert your name and wait for yours friends.

![Gameplay 1](Documentation/Gameplay_1.gif)

When everybody is ready, tap the Let's Play button and the game begins.

![Gameplay 2](Documentation/Gameplay_2.gif)

Tapping the correct image:

![Gameplay 3](Documentation/Gameplay_3.gif)

Tapping the wrong image:

![Gameplay 4](Documentation/Gameplay_4.gif)

The final score:

![Gameplay 5](Documentation/Gameplay_5.png)

## Tech Stack

* Swift
* MultipeerConnectivity
* UIKit

### Multipeer Connectivity

The game was made to play offline, between nearby devices. The app choose the best connection option (WiFi or Bluetooth) and create a server for the others players.

### UIKit

As a final project of Lighthouse Labs, we decide to use the UIKit as a challenge and to show that is possible to make a fun game without libraries as GameKit and SpriteKit.

### Binary Data Structure

We decide to use the binary data structure to minimize the data flow between the peers, avoiding lag during the game.

## Future Directions

Features we would like to include in future versions:
* Multi-plataform connectivity (Android)
* History of plays and statistics (e.g. avg time to found, number of wins)


## Contributors
* [Fernando Zanei](https://github.com/fernandozanei)
* [Jonathan Oliveira](https://github.com/jonthejon)
