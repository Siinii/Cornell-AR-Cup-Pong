# Cornell-AR-Cup-Pong
AR Cup Pong Game with a Cornell Theme, Made with ARKit

## Contributors:
- Blaze Ezlakowski (be96@cornell.edu)
- Devansh Agarwal (da398@cornell.edu)
- Josh Zheng (jz786@cornell.edu)

## [Demo Video](https://www.youtube.com/watch?v=8T9dHF3K8V4)
- Please excuse the high-pitched voice - the video speed needed to be increased in order to fit a 5 minute time limit.


## Features Implemented:
- Ball Throwing Mechanism: balls can be thrown using a swiping motion. The direction of
the swipe changes the direction that the ball will be thrown in. The speed of the swipe
will also determine the amount of force that the ball will have when thrown. – Scenekit by
default gives us a UIPanGestureRecognizer, which we used to detect the Pan gesture.
After this we calculate the velocity, use trigonometry to calculate the force vector,
transform this based on the camera's transform and then scale it to make the game
more playable and fun.
- Placing Cups on Table Surface: at the beginning of the game, a set of cups can be
placed onto a real-world table, by tapping on the table. We detect a flat surface, we
calculate the size of the plane, then we detect the tap gesture of the player, cast a ray
from the camera to figure out where the user tapped and where it intersects with the flat
surface, then we place the cups at the point of intersection. The Arkit provided basic
detection and gesture recognition.
- Ball collisions with table and cups: balls bounce off all tables that are detected, and
bounce against the side of the cups. When a ball lands in a cup, both the cup and ball
disappear. We had to add physics, geometry and collision detection to all the objects.
But we had no way to tell which objects collided with each other, so we had to create bit
masks, which would tell us the collision entities.
- Score and HighScore system: The number of balls thrown is kept track of, as well as the
number of cups eliminated. At the end of the game, when all cups are eliminated,
throwing a lower amount of balls than the previous best score, makes a new best score.
This best score is kept track of across sessions, even when closing out of the app and
opening it again.
- Obstacles: To make the game more fun and make the AR experience more real, we
added obstacles. The obstacles will randomly spawn at different locations to obstruct the
player. Also added a particle system to the obstacles to make it look more fancy. Particle
system is provided by the platform, but we had to tune its parameters.
- Easy Mode and Hard Mode: Easy mode is a game of cup pong with one obstacle the
entire game. On the other hand, clicking on hard mode makes it so that as more cups
are eliminated, more obstacles appear, which also change position after every throw of a
ball.
- Sounds and Victory Screen: A sound is played whenever a ball reaches a cup, or when
all of the cups have been successfully eliminated. Also, text is displayed that notifies you
of your victory when all cups are eliminated, as well as if a new best score has been
reached. Sound player is provided by the platform but it’s pretty trashy with a bunch of
lag, so we had to figure out pre-loading of sound and create events at the required time.
- UI With buttons: The beginning of the game has a loading screen, after which appears a
menu where the player can choose to play easy mode, hard mode, or look at the game
tutorial. Bunch of basic UI components are given by the platform but we had to put them
together and make it work coherently, including setting up gesture listeners, functions,
and connecting them together.

## Resources Used:

-  ARKit
-  [Tracking and Visualizing Planes in ARKit](https://developer.apple.com/documentation/arkit/arkit_in_ios/content_anchors/tracking_and_visualizing_planes)
-  [Creating a Multiuser experience](https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience)
-  [Saving and Loading a Highscore (Swift in Xcode)](https://www.youtube.com/watch?v=CLmOoHzIekw))
-  [Throwing a Projectile in SceneKit](https://stackoverflow.com/questions/47464555/how-to-correctly-implement-throwing-a-projectile-in-scenekit-based-on-user-gestu)
-  [BeerPongAR](https://github.com/richieszemeredi/BeerPongAR)
-  [BeerGamesAR](https://github.com/brianpvo/BeerGamesAR)
