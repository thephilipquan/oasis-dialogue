# how to implement oasis dialogue

## summary

1. Extend `OasisManager`, add to your scene, and set its fields.
2. (optional) Add `OasisTraverserControllers` as children of `OasisManager` for every custom annotation in your dialogue.
3. Add an `OasisCharacter` and set its fields.
4. Call `OasisCharacter.start()` -> which returns an `OasisTraverser`.
5. Connect to `OasisTraverser`'s signals and call `OasisTraverser.next()` until `finished` is emitted.

View all classes' documentation for details. All classes you'll be using can be found in the [addons's public/ folder](/addons/oasis_dialogue/public/).
