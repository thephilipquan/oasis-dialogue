# OasisDialogue

A Godot plugin and standalone dialogue editor for creating branching dialogue.

![GIF of Oasis Dialogue example.](src/gif/export/example.gif)

## features

* Show dialogue based on conditions
* Run code in response to player's dialogue choices
* Isolation from game code with safe integration 
* CSV export for localization
* Standalone editor
* Version control friendly file format

## getting started

You can download the standalone app from the [latest release](https://github.com/thephilipquan/oasis-dialogue/releases/latest).

You can view the [example](example/) provided, or take a look at [how to use](docs/how_to_use.md) for in-depth explanations.

## when not to use Oasis Dialogue

Overall, OasisDialogue meets most game needs for dialogue branching. The following situations are when OasisDialogue is not a good fit for your game...

* The player conversates with multiple characters at the same time.

> OasisDialogue provides **intuitive design for conversations between the player and a single character**. It may be possible to make it work with custom [traverser controllers](addons/oasis_dialogue/public/oasis_traverser_controller.gd), but that would require under-the-hood knowledge from the writer to force the architecture to work. If the game dev is also the writer, this may not be a problem, but you may have a better time using a different dialogue tool. 

Additionally, you **should not use** OasisDialogue as a means of translating everything in your game. For example...

* *You have a shop keeper that displays items to sell as a text based list. The player can navigate the list, ask the shopkeeper for details of the item, and optionally buy the item.*

> Not every *talking* in a game means its branching dialogue. I don't think this is feasible with OasisDialogue, and if it is, it isn't simple to do.
