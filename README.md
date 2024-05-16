# Super Alien
This is a coursework project from Harvard University`s CS50G.

# Implemented Features

Safe Spawning: No more unwelcome surprises! The player now always spawns above solid ground at the beginning of each level, ensuring a safe starting position.

Colorful Challenge: Each level introduces a new hurdle with a randomly generated colored lock block.

Key to Success: Players must find a matching colored key, also randomly generated within the level.

Unlocking Progress: Colliding with the correct key removes the lock block, allowing the player to proceed.

Goal in Sight: Once the lock is removed, a segmented goal post (flag and pole) triumphantly appears at the end of the level, signifying the path to completion.

Level Up!: Touching the goal post triggers a satisfying level reload. The player respawns at the beginning, but with an extra challenge – the level length increases, providing a sense of progression and growing difficulty.

Persistent Performance: The PlayState:enter function receives an upgrade with new parameters. These parameters keep track of the current level the player has reached and persistently store the player's score throughout the gameplay, allowing them to pick up where they left off.
