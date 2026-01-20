# how to implement OasisDialogue

As stated in the project [readme](/README.md), all OasisDialogue does is provide an interface to write dialogue that is then exported to `.csv` (and `.json`), which is one of Godot's [built-in solutions](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html#) for handling localization.

To get started, add the imported **.translation** files via `Project > Project Settings > Localization > Add...`

Once your localization files are configured, you'll work with the classes OasisDialogue provides to handle dialogue. Of those classes, there are 3 main ones that you need to be familiar with:

* OasisCharacter
  * Entry point from your game to dialogue
  * Set members in inspector and call `start()`
* OasisTraverser
  * Returned from `OasisCharacter.start()`
  * Connect to signals and call `next()` until dialogue is finished
* OasisManager
  * The only place you need to code
  * Must extend and override
  * Add to scene or autoload
  * Manages one to many `OasisCharacters`

With that in mind, I would recommend downloading and/or taking a look at the [example](/example) implementation, which is also documented, so you can see how simple it is. When you're ready to implement OasisDialogue yourself, the class docs will fill in the details. All classes you'll be using can be found in the [addons public/ folder](/addons/oasis_dialogue/public/), and are searchable via Godot's `Help > Search Help...`.
