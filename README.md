# Super Alien
This is a coursework project from Harvard University`s CS50G.

# Implemented Features

Safe Spawn: Ensures players start above solid ground at level entry.

Random Locks: Levels introduce colored lock blocks requiring keys to open.

Matching Keys: Keys with matching colors are randomly generated within the level.

Unlock Progress: Colliding with the correct key removes the lock block.

Goal Trigger: Removing the lock spawns a segmented goal post, signifying level completion.

Level Up!: Touching the goal post reloads the level with increased length and restarts the player.

Persistent Stats: PlayState:enter function now tracks current level and player score for persistent saving.
