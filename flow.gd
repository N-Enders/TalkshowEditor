extends Control

@export var label: PackedScene
@export var goto: PackedScene
@export var input: PackedScene
@export var reference: PackedScene
@export var returnc: PackedScene

@export var unknown: PackedScene


func createFlowchartFromData(preData):
	var dict = preData["dict"].split("^")
		
	var connectionsToMake = []
	var cellIdsToName = {}
		
	for a in preData["cells"].split("^"):
		var cell = ""
		match a.split("|")[2]:
			"I":
				cell = input.instantiate()
				cell.remove_branch.connect(_remove_branch)
				cell.add_branch.connect(_add_branch)
				cell.moved_branch.connect(_branch_moved)
			"R":
				cell = reference.instantiate()
				cell.remove_branch.connect(_remove_branch)
				cell.add_branch.connect(_add_branch)
				cell.moved_branch.connect(_branch_moved)
			"L":
				cell = label.instantiate()
			"G":
				cell = goto.instantiate()
			"N":
				cell = returnc.instantiate()
			_:
				cell = unknown.instantiate()
		
			#Cell controls flow attachments
		if cell.has_signal(StringName("request_switch_flow")):
			cell.request_switch_flow.connect(_cell_requests_flow_switch)
	
		#Cell requests data connects
		if cell.has_signal(StringName("request_data")):
			cell.request_data.connect(_request_data)
		
		
		cell.node_selected.connect(_on_node_selected.bind(cell))
		cell.node_deselected.connect(_on_node_deselected.bind(cell))
		var returnValues = cell.fromCellData(a, dict)
		
		$GraphEdit.add_child(cell)
		cellIdsToName[str(a.split("|")[0])] = cell.name
		
		for b in returnValues["connections"]:
			connectionsToMake.append({"from_node": cell.name, "from_port": b["from_port"], "to_node": b["to_cell"]})
	
	
	for a in connectionsToMake:
		if(a["to_node"] in cellIdsToName.keys()):
			$GraphEdit.connect_node(a["from_node"], a["from_port"], cellIdsToName[a["to_node"]], 0)
	await sort_all()


var node_index = 0
var select_all_nodes = false

var start_data

# Called when the node enters the scene tree for the first time.
func _ready():
	$GraphEdit.add_valid_left_disconnect_type(0)


func add_data(data):
	start_data = data


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#Replace with new shit
func create_specific_cell(type):
	
	var node
	var id = getNextID()
	
	match type:
		0:
			node = label.instantiate()
			node.loadData({"id":id,"position":Vector2(0,0),"data":{"labelValue":""}})
		1:
			node = input.instantiate()
			node.loadData({"id":id,"position":Vector2(0,0),"data":{}})
			node.remove_branch.connect(_remove_branch)
			node.add_branch.connect(_add_branch)
			node.moved_branch.connect(_branch_moved)
		2:
			node = reference.instantiate()
			node.loadData({"id":id,"var":"","data":[],"location":Vector2(0,0)})
			node.remove_branch.connect(_remove_branch)
			node.add_branch.connect(_add_branch)
			node.moved_branch.connect(_branch_moved)
	
	
	#Cell controls flow attachments
	if node.has_signal(StringName("request_switch_flow")):
		node.request_switch_flow.connect(_cell_requests_flow_switch)
	
	#Cell requests data connects
	if node.has_signal(StringName("request_data")):
		node.request_data.connect(_request_data)
	
	
	var tempZoom = $GraphEdit.zoom
	$GraphEdit.zoom = 1
	node.position_offset += $GraphEdit.scroll_offset
	$GraphEdit.zoom = tempZoom
	node.node_selected.connect(_on_node_selected.bind(node))
	node.node_deselected.connect(_on_node_deselected.bind(node))
	$GraphEdit.add_child(node)
	node_index += 1


func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
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


var nodeLengths = {}

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
	var oldConnectionList = $GraphEdit.get_connection_list()
	var newConnectionList = []
	for b in minimalConnections:
		var connectionsToCheck = [b]
		var connectionsChecked = []
		while len(connectionsToCheck) > 0:
			var curName = connectionsToCheck.pop_front()
			if curName in connectionsChecked:
				continue
			connectionsChecked.append(curName)
			var preConnections = []
			for a in oldConnectionList:
				if a["from_node"] == curName:
					preConnections.append(a)
					connectionsToCheck.append(a["to_node"])
			preConnections.sort_custom(sort)
			newConnectionList.append_array(preConnections)
	select_all()
	for a in minimalConnections:
		var node
		for b in $GraphEdit.get_children():
			if b.name == a:
				node = b
		getNodeLength(node,newConnectionList)
	select_all()
	$GraphEdit.zoom = 1
	var scrollVec = $GraphEdit.scroll_offset + ($GraphEdit.size / 2)
	var y = scrollVec.y
	for a in minimalConnections:
		var node
		for b in $GraphEdit.get_children():
			if b.name == a:
				node = b
		y = moveNode(node,Vector2(scrollVec.x,y),newConnectionList).max()
	unselect_all()
	nodeLengths = {}

func combineListsForMax(list1,list2):
	print("list1 " + str(list1))
	print("list2 " + str(list2))
	var newList = list1
	if list2.size() > list1.size():
		newList = list2
	for a in min(list1.size(),list2.size()):
		newList[a] = max(list1[a],list2[a])
	print("listN " + str(newList))
	return newList

func moveNode(node,vec,connections):
	if not node.selected:
		return [0]
	node.position_offset = vec
	node.selected = false
	var posX = vec.x
	var posY = vec.y
	var connect = getNodeConnection(node,connections)
	var nodeSize = node.size.y + 100 + posY
	var newestSize = posY
	var iterations = 0
	var nodeSizes = [posY]
	var newSizes = [posY]
	for a in connect:
		iterations += 1
		for b in $GraphEdit.get_children():
			if (b.name == a.to_node and b.selected):
				if iterations > 1:
					print(b.name)
					print(nodeLengths[b.name])
					for c in nodeLengths[b.name]:
						if c >= nodeSizes.size():
							break
						if nodeSizes[c] > newestSize:
							newestSize = nodeSizes[c]
				var newNodePos = Vector2(posX + node.size.x + 100,newestSize)
				newSizes = moveNode(b,newNodePos,connections)
				nodeSizes = combineListsForMax(nodeSizes,newSizes)
				break
	var newNewNewNodeSizes = [nodeSize]
	for a in nodeSizes:
		newNewNewNodeSizes.append(a)
	if(iterations > 1):
		print("super size " + str(len(nodeSizes)))
	return newNewNewNodeSizes

func getNodeLength(node,connections):
	if not node.selected:
		return 0
	node.selected = false
	var connect = getNodeConnection(node,connections)
	var iterations = 0
	var length = 0
	for a in connect:
		iterations += 1
		for b in $GraphEdit.get_children():
			if (b.name == a.to_node and b.selected):
				var newLength = getNodeLength(b,connections)
				if newLength > length:
					length = newLength
				break
	nodeLengths[node.name] = length + 1
	return length + 1

func getNodeConnection(node,connections):
	var connection = []
	for a in connections:
		if a["from_node"] == node.name:
			connection.append(a)
	return connection



func _remove_branch(node,index_deleted):
	var connections = getNodeConnection(node,$GraphEdit.get_connection_list())
	for a in connections:
		if (a["from_port"] >= (index_deleted - 1)):
			$GraphEdit.disconnect_node(a["from_node"],a["from_port"],a["to_node"],a["to_port"])
		if(a["from_port"] > (index_deleted - 1)):
			$GraphEdit.connect_node(a["from_node"],a["from_port"] - 1,a["to_node"],a["to_port"])

func _add_branch(node,no_match):
	var connections = getNodeConnection(node,$GraphEdit.get_connection_list())
	for a in connections:
		if(a["from_port"] >= (no_match-1)):
			$GraphEdit.disconnect_node(a["from_node"],a["from_port"],a["to_node"],a["to_port"])
			$GraphEdit.connect_node(a["from_node"],a["from_port"] + 1,a["to_node"],a["to_port"])


func getNextID():
	var currentID = 1
	for a in $GraphEdit.get_children():
		var nextId = a.getID()
		if nextId >= currentID:
			currentID = nextId + 1
	return currentID


func _on_graph_edit_delete_nodes_request(nodes):
	$ConfirmationDialog.activate()



var selected_nodes = {}

func _on_node_selected(node):
	selected_nodes[node] = true

func _on_node_deselected(node):
	selected_nodes[node] = false

func _on_confirmation_dialog_confirmed():
	for node in selected_nodes.keys():
		if selected_nodes[node]:
			remove_connections_to_node(node)
			node.queue_free()
	selected_nodes = {}

func remove_connections_to_node(node):
	for con in $GraphEdit.get_connection_list():
		if con.to_node == node.name or con.from_node == node.name:
			$GraphEdit.disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)

func _branch_moved(node,oldPort,newPort):
	var oldPortConnection
	var newPortConnection
	oldPort -= 1
	newPort -= 1
	for con in $GraphEdit.get_connection_list():
		if con.from_node == node.name:
			match con.from_port:
				oldPort:
					oldPortConnection = con
					$GraphEdit.disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)
				newPort:
					newPortConnection = con
					$GraphEdit.disconnect_node(con.from_node, con.from_port, con.to_node, con.to_port)
	if(oldPortConnection):
		$GraphEdit.connect_node(node.name, newPort, oldPortConnection.to_node, oldPortConnection.to_port) #old to new
	if(newPortConnection):
		$GraphEdit.connect_node(node.name, oldPort, newPortConnection.to_node, newPortConnection.to_port) #new to old


func _send_action_data_to_node(node,actionID):
	var raw_action = start_data["actions"][actionID]
	var dict = start_data["dict"]
	var action = {"id":raw_action.id,"name":dict[raw_action.name],"params":[]}
	for a in raw_action.params:
		action["params"].append({"name":dict[a.name],"type":a.type})
	node.set_action(action)


func _send_list_of_actions_to_node(node):
	node.set_action_names(_get_action_names())


func _get_action_names():
	var actions = start_data["actions"]
	var dict = start_data["dict"]
	var actionNames = {}
	for a in actions:
		actionNames[dict[actions[a]["name"]]] = a
	return actionNames


func _on_graph_node_find(node,cellToFind):
	for a in $GraphEdit.get_children():
		if cellToFind == str(a.getID()):
			var posShift = a.position_offset
			for b in $GraphEdit.get_children():
				b.position_offset = b.position_offset - posShift
			$GraphEdit.scroll_offset = Vector2(0,0)


func _on_graph_edit_popup_request(position):
	print(position)
	$PopupMenu.activate(position)


func _on_popup_menu_find_pressed(position):
	$PopupPanel.activate(position)


func _on_popup_menu_sort_pressed():
	sort_all()


signal request_data
signal request_returned #used locally
var returnedData = {}
var dataAwaiting = ""

func _request_data(requestType,cell,type,value):
	dataAwaiting = requestType
	request_data.emit(requestType,self,type,value)
	await request_returned
	cell.returnData(returnedData)

func returnData(data,typeReturned):
	if dataAwaiting == typeReturned:
		returnedData = data
		request_returned.emit()


signal switch_flow

func _cell_requests_flow_switch(newFlowData):
	switch_flow.emit(newFlowData)
