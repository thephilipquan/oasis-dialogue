extends RefCounted


static func call_group_under_parent(parent: Node, group: StringName, method: StringName, ...arguments: Array) -> void:
	for node: Node in parent.get_tree().get_nodes_in_group(group):
		if parent.is_ancestor_of(node):
			if method in node:
				node.callv(method, arguments)


static func find_type(root: Node, type: Variant) -> Node:
	var queue: Array[Node] = [root]
	var result: Node = null
	while queue and not result:
		var current: Node = queue.pop_front()
		for child in current.get_children():
			if is_instance_of(child, OasisManager):
				result = child
				break
			else:
				queue.push_back(child)
	return result
