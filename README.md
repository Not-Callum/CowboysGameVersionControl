This game is, so far, a prototype of an idea I had regarding the lasso mechanic. The lasso in it's idea is both a form of crowd control, a source of damage, and an extension of the player. This makes it really engaging to use. I found the idea of swinging enemies into a wall to defeat them to be entertaining and wanted to explore it further. The lasso has two parts, the throwable, and the end part for when an item or enemy is grabbed. The end part exists on the enemy or item at all times and listens out for the lasso throwable, and the lasso throwable listens out for the lasso's end part. This way I could predetermine what is "lassoable" and make it really easy to implement. There is a line that is drawn procedurally between the player and lasso to give off the illusion of the lasso being a tied point between the two, and after having caught something the line is drawn between the player and the target. If it is an enemy that is caught, they have a randomised timer for escaping the lasso, and the player is slowed down whilst they have something in their lasso. If the player is to "yank" and enemy, the enemy has a short amount of time to hit a wall to be defeated. They detect a wall through tile map physics data and will either be defeated or, if they survive, will bounce off the wall doing a large amount of damage which I think is equally satisfying. After having added the weapons (after having added the lasso and being happy with it), I found that the balance and need to use the lasso was too much risk for not much reward. To combat this I added a system that will spawn ammo packs and "life orbs" on enemy death, but I made it so they only have a chance of spawning, unless they were defeated with the lasso in which case it would guarantee that both the ammo packs and life orbs will spawn. My hope is that this will incentivise using it as the reward is especially beneficial for when you are low on health. The lasso also can interact with items, such as the weapons, so that you can grab them from a distance. I find this is not yet really useful as you have no reason to find other weapons, hopefully I can find a way to make it worthwhile as I liked the idea of having it be an option. All of this taught me about interactions between objects in a scene, composition, creating cleaner code and also a lot about the Godot engine. This all took a lot of learning and time, and will probably still take a lot more if I keep messing around with it but I am really proud of it.

The weapons system was my first time doing something like that, I started off with having two variations/scenes of a weapon, one being on the floor and one being in the players hands and it would instantiate when transitioning between the two. However, I then realised a few problems with transferring data about the weapon and how much ammunition is has between these "states" so I made it into one item which is easier to implement and maintain. This means I could keep some data between the states and could also as easily give the weapons to my enemies. The enemy's ammo drops that spawn are dependant on what weapon the enemy has, which was a useful exploration of using metadata. Currently I am working on a "grenadier" who will throw dynamite at the player, the dynamite being lassoable objects that you can then throw back to the enemies. I thought this would be a fun idea as it once again incentivises a use-case for the lasso I worked hard on and gives a fun high risk, high reward counter to this new enemy type. However, that is not fully implemented yet.

My future for this project would be to turn it into a "rougelike" game, as I can see what I have already built suiting that genre greatly and gives it a unique gimick that would distinguish itself from other games.


Controls:
WASD - move
Shoot - Left-Mouse
R - reload
Space - Lasso/Ability
C - Cancel Ability
Shift - Dodge
E - Interact / Pickup
Q - Drop Weapon

Helpful videos/tutorials I followed that helped me build this:

Heartbeast Action RPG in Godot: https://www.youtube.com/watch?v=mAbG8Oi-SvQ&list=PL9FzW-m48fn2SlrW0KoLT4n5egNdX-W9a
Custom Tile Data by DevDuck: https://www.youtube.com/watch?v=k9RsnbP4a0c
