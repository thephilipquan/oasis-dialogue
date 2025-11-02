# Oasis Dialogue Syntax

## Quickstart

Here is an example of a normal piece of dialogue.

```
@prompt
Woah there. Haven't seen you around these parts.
Where do you come from?
@response
Just moved in.
Been here my whole life.
Mind your business.
```

Dialogue with conditions...

```
@prompt
The storm was tough huh.
{ has_health 70 } but I guess not so much for you.
What do you want to see?
@response
Just the usual.
{ has_gold 500 } Got anything special today?
```

Dialogue with actions...

```
@prompt
Are you hurt?
Come here real quick. { full_heal }
There you go.
@prompt
You didn't need to do that.
Thanks.
```

And a combination of both...

```
@prompt
{ health_lt 30 } Dude, I told you it would be difficult.
{ health_gt 70 } Wow you actually did it.
@response
```

## Terminology

A **character** is an npc in your game that the player can talk to. Branches you create for a character only belong to that character and none other.
A **branch** is a unit of dialogue that must contain a **prompt** or a **response**. A branch may contain both, along with **annotations**.
An **annotation** changes the behavior of a branch. For example, by default, prompts are displayed one line at a time. If you use the `@rng` annotation, then **only 1** prompt is shown and chosen at random at runtime.
A **prompt** is a line that is spoken by the character. A prompt may have any number of **conditions** and **actions**.
A **response** is a choice that may be selected by the player. A response may have any number of **conditions** and **actions**.
A **condition** is a writer-defined variable that if `true` at runtime, will display the line or consider it to be displayed (when @rng is in effect).
An **action** is a writer-defined variable that executes at runtime after the prompt is displayed or response is chosen by the player.

> Both conditions and actions are defined by the user. Once the dialogue is exported, it is the game developers job to map the writer-defined condition and action to the game-defined method/variable. This separation gives the writer total freedom and the game developer minimal work to implementing dialogue in the game.

## Creating a Character

You can create a character via the `Character > New...` on the top left, or by **double clicking** an empty space in the character view on the left.

Oasis Dialogue has a custom domain language (DSL) to quickly and efficiently write branching dialogue for your game or other media.

There are 3 main parts to every branch.


STOPPING HERE. - This is a fine start, but users will learn best by gifs of the dialogue side by side with the result of the dialogue being displayed in game. 
