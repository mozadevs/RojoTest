# ALL UPDATES & COMMITS HAPPENED WITHIN THE 24 HOUR TIMELINE I WAS GIVEN

# OPEN ENDED QUESTION:

I would Split it into 2 module scripts

MatchPad (Component): iterates each Teams Folder slots children, and connects .Touched on each, when stepped on, reports to matchservice: "This Pad, this Player, This Team, Etc" and also reports release when stepped off

MatchService (Service): tracks claimed slots per pad, when every slot in every team is filled, we start the match, clears the slots after the match starts.


# Explination To why I chose to do it this way

I chose to do it with components because it already gives a per instance lifecycle (Construct / Stop ), and also a Conveyor Belt is a world object / per-instance behavior on a tagged model. Thats exactly what Tag Driven Components are for, if i use components that means i dont have to do any manual clean up code, no manual loop scanning the workspace, and i get automatic handling of the conveyor belt during runtime.

# GAME LINK: 
https://www.roblox.com/games/134914165841630/TestRojo
