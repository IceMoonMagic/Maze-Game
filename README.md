# Maze Game
A simple maze game in to learn Godot.

## Top Down Maze
A simple 2D Maze. The appearance can basically be completely customized, from changing the colors to the thicknesses of lines.

As the player moves, there it leaves two lines behind it.
1. To show everywhere explored
2. To show the direct path from the start to current position.

When finishing a maze, removes ability to move and shows pause screen.

There are two buttons that let you re-watch traveling everywhere or the "final" path.

### Controls
Move - WASD / ↑←↓→ / Left Stick / D-Pad / Swipe

Quick New Maze - 1 / RB

Quick Restart - 2 / LB

Pause - Esc / Start / Hold Screen (1 Sec)

Move Camera - Click and Drag / Right Stick

Zoom In - Mouse Wheel Up / RT

Zoom Out - Mouse Wheel Down / LT


## First Person Maze
Same generation as the top down, but exploring in first person.

The "default" aesthetic uses some assets from the [Chill Vibes Art Jam](https://itch.io/jam/chill-vibes-art-jam-4),
going for a hedge maze (in space, I guess).
Turning on "Simple Aesthetic" makes it look like the top down mazes.

### Controls
Same as Top Down, but touch isn't supported.


## Licenses
- All the source code in this repo is under the MIT License.
- Assets under 3rd-Party have credit / licenses in their respective sub-dirs
	- [McGravel's Assets](https://mcgravel.itch.io/assorted-dated-looking-textures):
	CC BY-SA 4.0
	- [PGComai's Asset](https://pgcomai.itch.io/jam-assets-for-chill-vibes-art-jam-4):
	No License Stated - Assume All Rights Reserved except for usage in the
	[Chill Vibes Game Jam](https://itch.io/jam/chill-vibes-game-jam-4).


## Final Notes
This was basically just and excuse to learn Godot.
I made this by basically just winging it and looking at documentation to figure out how to do what I was already trying to do.
There are many aspects of this project that I ended up not liking the implementation of,
but am also to lazy to bother refactoring it
(e.g. how settings are done, how the pause menus are siblings to the thing they are pausing, etc.)

My original thought was this would eventually turn into like a little arcade of minigames,
but it'll probably just get abandoned.

I had slightly grander plans for the 3D / first person maze
(such as adding assets like lantern posts / benches to go for a more park vibe,
sounds / music, snow fall, etc),
but I kinda don't want to deal with that
(assets require procedural placement, sounds / music require *even more* settings).
