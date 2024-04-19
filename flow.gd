extends Control

@export var label: PackedScene
@export var goto: PackedScene
@export var input: PackedScene

var initialPos = Vector2(40,40)
var node_index = 0
var select_all_nodes = false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_button_pressed():
	var node
	match $OptionButton.selected:
		0:
			node = label.instantiate()
		1:
			node = input.instantiate()
			node.createBranch("1")
			node.createBranch("2")
			node.remove_branch.connect(_remove_branch)
			node.add_branch.connect(_add_branch)
	node.position_offset += initialPos + (node_index * Vector2(10,10))
	$GraphEdit.add_child(node)
	node_index += 1



func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	print($GraphEdit.get_connection_list())
	for a in $GraphEdit.get_connection_list():
		if (a["from_node"] == from_node) and (a["from_port"] == from_port):
			$GraphEdit.disconnect_node(a["from_node"],a["from_port"],a["to_node"],a["to_port"])
	$GraphEdit.connect_node(from_node,from_port,to_node,to_port)



func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	$GraphEdit.disconnect_node(from_node,from_port,to_node,to_port)



func _on_select_all_in_line_pressed():
	select_all_nodes = true



func select_all():
	for child in $GraphEdit.get_children():
		child.selected = true



func unselect_all():
	for child in $GraphEdit.get_children():
		child.selected = false



func sort(a, b):
	return a["from_port"] < b["from_port"]



func sort_all():
	if(len($GraphEdit.get_children()) == 0):
		return
	select_all()
	var x = 0;
	var connectionCounts = {}
	for a in $GraphEdit.get_children():
		connectionCounts[a.name] = 0
	for a in $GraphEdit.get_connection_list():
		connectionCounts[a["to_node"]] = connectionCounts[a["to_node"]] + 1
	var minimalConnections = []
	var min = 100
	for a in connectionCounts:
		if connectionCounts[a] < min:
			minimalConnections = []
			min = connectionCounts[a]
		if connectionCounts[a] == min:
			minimalConnections.append(a)
	var validChildren = $GraphEdit.get_children()
	for a in validChildren:
		if not a.name in minimalConnections:
			validChildren.erase(a)
	var currentFirst = validChildren[0]
	min = currentFirst.position_offset
	for a in validChildren:
		if a.position_offset < min:
			currentFirst = a
			min = currentFirst.position_offset
	var oldConnectionList = $GraphEdit.get_connection_list()
	print(oldConnectionList)
	var connectionsToCheck = [currentFirst.name]
	var connectionsChecked = []
	var newConnectionList = []
	while len(connectionsToCheck) > 0:
		var curName = connectionsToCheck.pop_front()
		if curName in connectionsChecked:
			continue
		connectionsChecked.append(curName)
		var preConnections = []
		print("Checking " + curName)
		for a in oldConnectionList:
			print(a)
			print(a["from_node"] + " = " + curName)
			if a["from_node"] == curName:
				preConnections.append(a)
				connectionsToCheck.append(a["to_node"])
		preConnections.sort_custom(sort)
		print("Yknow what happens " + str(preConnections))
		newConnectionList.append_array(preConnections)
	print(newConnectionList)
	print(posNode(currentFirst,Vector2(0,0),newConnectionList))
	unselect_all()

func posNode(node,vec,connections,alreadyPlaced = []):
	print(alreadyPlaced)
	if node.name in alreadyPlaced:
		return {"newPosY": vec.y, "alreadyPlaced": alreadyPlaced}
	node.position_offset = vec
	alreadyPlaced.append(node.name)
	var posX = vec.x
	var posY = vec.y
	var newPosY = posY
	var stuff = getNodeConnection(node,connections)
	var iteration = 0
	for a in stuff:
		iteration += 1
		for b in $GraphEdit.get_children():
			if (b.name == a["to_node"]) and not (b.name in alreadyPlaced):
				var returningData = posNode(b,Vector2(posX + node.size.x + 100,newPosY),connections, alreadyPlaced)
				posY = newPosY
				newPosY = returningData["newPosY"]
				alreadyPlaced = returningData["alreadyPlaced"]
	return {"newPosY": posY + node.size.y + 100, "alreadyPlaced": alreadyPlaced}

func getNodeConnection(node,connections):
	var connection = []
	print("checcking connections for " + node.name)
	for a in connections:
		print(a)
		if a["from_node"] == node.name:
			connection.append(a)
	print("returning " + str(connection))
	return connection


func _on_sort_all_pressed():
	sort_all()

func _on_get_data_pressed():
	for child in $GraphEdit.get_children():
		print(child.getData())


func _remove_branch(node,index_deleted):
	print(node.name + " just deleted option #"+str(index_deleted))
	var connections = getNodeConnection(node,$GraphEdit.get_connection_list())
	for a in connections:
		if (a["from_port"] >= (index_deleted - 1)):
			$GraphEdit.disconnect_node(a["from_node"],a["from_port"],a["to_node"],a["to_port"])
		if(a["from_port"] > (index_deleted - 1)):
			$GraphEdit.connect_node(a["from_node"],a["from_port"] - 1,a["to_node"],a["to_port"])

func _add_branch(node):
	print(node.name + " just added an option")
	var connections = getNodeConnection(node,$GraphEdit.get_connection_list())
	var no_match = node.no_match_idx()
	print(no_match)
	for a in connections:
		if(a["from_port"] == (no_match-1)):
			$GraphEdit.disconnect_node(a["from_node"],a["from_port"],a["to_node"],a["to_port"])
			$GraphEdit.connect_node(a["from_node"],a["from_port"] + 1,a["to_node"],a["to_port"])
