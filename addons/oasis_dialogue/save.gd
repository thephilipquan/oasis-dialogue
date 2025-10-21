@abstract
extends RefCounted

## Use as a dummy key for isolated data that [i]use a header as their key[/i].
const DUMMY := "value"

class Character:
	const DATA := "data"
	class Data:
		const DISPLAY_NAME := "display_name"
	class Branch:
		const VALUE := "value"
		const POSITION_OFFSET := "position_offset"
	class Config:
		const GRAPH := "graph"
		class Graph:
			const SCROLL_OFFSET := "graph_scroll_offset"
			const ZOOM := "graph_zoom"

class Project:
	const ACTIONS := "actions"
	const CONDITIONS := "conditions"
	const CHARACTERS := "characters"

	const SESSION := "session"
	class Session:
		const ACTIVE := "active"
