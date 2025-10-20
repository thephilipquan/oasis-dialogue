@abstract
extends RefCounted

## Use as a dummy key for isolated data that [i]use a header as their key[/i].
const DUMMY := "value"

@abstract
class Character:
	const DISPLAY_NAME := "display_name"

	@abstract
	class Config:
		const BRANCH_POSITION_OFFSETS := "branch_position_offsets"
		const GRAPH := "graph"
		@abstract
		class Graph:
			const SCROLL_OFFSET := "graph_scroll_offset"
			const ZOOM := "graph_zoom"

@abstract
class Project:
	const ACTIONS := "actions"
	const CONDITIONS := "conditions"
	const CHARACTERS := "characters"

	const SESSION := "session"
	@abstract
	class Session:
		const ACTIVE := "active"
