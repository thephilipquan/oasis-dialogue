extends GutTest

const GraphUtils := preload("res://addons/oasis_dialogue/utils/graph_edit_utils.gd")

var graph: GraphEdit = null


func before_each() -> void:
	graph = GraphEdit.new()
	add_child_autofree(graph)


func test_arrange_nodes() -> void:
	var nodes: Array[GraphNode] = [
		GraphNode.new(),
		GraphNode.new(),
		GraphNode.new(),
	]
	nodes.map(func(n: GraphNode): graph.add_child(n))
	nodes[1].selected = true

	var before := nodes.map(func(n: GraphNode): return n.position_offset)
	GraphUtils.arrange_nodes(nodes, graph)
	var after := nodes.map(func(n: GraphNode): return n.position_offset)

	assert_ne_deep(after, before)


func test_arrange_nodes_restores_selected() -> void:
	var nodes: Array[GraphNode] = [
		GraphNode.new(),
		GraphNode.new(),
		GraphNode.new(),
	]
	nodes.map(func(n: GraphNode): graph.add_child(n))
	nodes[1].selected = true

	var before := nodes.map(func(n: GraphNode): return n.selected)
	GraphUtils.arrange_nodes(nodes, graph)
	var after := nodes.map(func(n: GraphNode): return n.selected)

	assert_eq_deep(after, before)
