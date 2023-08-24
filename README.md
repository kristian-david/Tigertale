# Tigertale
### Kristian David, 2023

## Game Summary
### Tigertale is a captivating action-adventure game for the Game Boy that utilizes a unique pseudo-3D visual style to immerse players in a world where they play as a powerful tiger during World War II. The game's narrative progression is divided into three chapters, each presenting distinct challenges and moral dilemmas that contribute to a rich and thought-provoking gameplay experience.

## Overworld
### The game's core is an overworld reminiscent of Pokémon, featuring grid-based movement. Unlike Pokémon's 2-tile vertical movement, both horizontal and vertical movements in Tigertale cover 1 tile. The character, akin to Pokémon still, employs 6 sprite tiles: 3 for static poses and 3 for animated versions. By flipping sprites horizontally, we optimize with 3 tiles instead of 4 for all 4 directions. Future plans include enhancing the overworld with 8-way grid-based movement, amplifying player freedom.

## Dialogue
### Interactions with NPCs are integral, allowing conversations with 4 response options: "Yes/Agree," "No/Disagree," "What?/(Clarify)," and "(Joke)/(Rude)/(Sarcastic)/Miscellaneous." These choices are mapped to D-pad directions: Right, Left, Up, Down. Respectively. This dialogue system employs a tree structure and pointers, linking to subsequent functions. Notably, these choices can significantly impact the game or story, requiring various specific variables to be set.

## 3D
### This intricate segment remains entirely unimplemented. When interacting with NPCs, the game shifts from the overworld to a simple Pseudo-3D environment. Although turning is absent due to its complexity, the player can still move around using the DPAD. The combat gameplay dynamics draw inspiration from Superhot's time-movement mechanics, providing the player more time to think about their move. It's important to note that due to the Game Boy's limitations, we're opting for a faux 3D approach.

## Future
### Unimplemented features include saving and loading mechanics, including Autosave at designated points, plus Quicksave and Quickload functionality. By pressing select, Quicksave occurs; a hold of over 2 seconds initiates Quickload. In terms of NPC interactions, if a non-hostile NPC is engaged, subsequent encounters would display direct conversation in the overworld view. Notably, hostile NPCs display '!' upon spotting the player, while non-hostile ones exhibit '?'. Moving forward, the game adopts a reputation system commencing in the second chapter. If 3 clan members are slain, vilification occurs, resulting in them attacking on sight.
