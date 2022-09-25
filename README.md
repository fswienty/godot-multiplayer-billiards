# Pool Together

This is a Godot 3.5 multiplayer pool game. I created it mostly because I wanted to try out a game with networking. Most of the art, excluding fonts and audio, was done by me.

You can play it here: https://gotm.io/vrojak/pooltogether

## How does the multiplayer part work?

This project uses the gotm plugin from https://gotm.io/. It facilitates lobby creation and and setting up peer-to-peer connections to other people without having to go through the hassle of setting up your own signaling server or dealing with NAT hole punching voodoo.

## Running it yourself

You should be able to simply import the repository into Godot 3.5 as an existing project and run it. The Gotm multiplayer package still works fine when run locally. You'll probably want to make an export of the game, since you have to run two instances at once to connect to each other and actually get to the pool part.
