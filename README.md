# OasisDialogue

A visual editor to write branching dialogue for games. Write in complete isolation from code. If using Godot - comes with tools for quick and easy integration.

![GIF of Oasis Dialogue example.](src/gif/export/example.gif)

## features

* A visual editor to write dialogue
* Tools (nodes) to implement dialogue in Godot
* Show dialogue based on conditions
* Run code in response to dialogue
* Localization-ready export
* Standalone editor
* Version control friendly file format

## getting started

You can search *Oasis Dialogue* in Godot's Asset Manager, or download the standalone app from the [latest release](https://github.com/thephilipquan/oasis-dialogue/releases/latest).

To learn how to use **OasisDialogue**, view any of the following:
* the [example](example/) provided
* [how to write](docs/how_to_write.md) if you're a writer
* [how to implement](docs/how_to_implement.md) if you're a developer

## when not to use OasisDialogue

Overall, OasisDialogue meets most game needs for dialogue branching. The following situations are when OasisDialogue is not a good fit for your game...

* The player conversates with multiple characters at the same time.

> OasisDialogue provides **intuitive design for conversations between the player and a single character**. It may be possible to make it work with custom [traverser controllers](addons/oasis_dialogue/public/oasis_traverser_controller.gd), but that would require under-the-hood knowledge from the writer to force the architecture to work. If the game dev is also the writer, this may not be a problem, but you may have a better time using a different dialogue tool.

Additionally, you **should not use** OasisDialogue as a means of translating everything in your game. For example...

* *You have a shop keeper that displays items to sell as a text based list. The player can navigate the list, ask the shopkeeper for details of the item, and optionally buy the item.*

> Not every *talking* in a game means its branching dialogue. I don't think this is feasible with OasisDialogue, and if it is, it isn't simple to do.
