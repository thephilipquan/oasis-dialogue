extends RefCounted


static func call_group_under_parent(parent: Node, group: StringName, method: StringName, ...arguments: Array) -> void:
	for node: Node in parent.get_tree().get_nodes_in_group(group):
		if parent.is_ancestor_of(node):
			if method in node:
				node.callv(method, arguments)
