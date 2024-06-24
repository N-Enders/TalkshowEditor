extends GraphNode

@export var codeBranch: PackedScene
@export var hitlistBranch: PackedScene

signal add_branch
signal remove_branch
signal moved_branch

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func createCodeBranch(details):
	var branches = get_child_count() - 4
	var newCode = codeBranch.instantiate()
	newCode.setBranchId(str(details["id"]))
	add_child(newCode)
	move_child(newCode,branches)
	set_slot(branches + 1,false,0,Color.WHITE,true,0,Color.RED)
	update_branch_states()
	newCode.delete.connect(_deleted_option.bind(newCode))
	newCode.moved.connect(_move_branch)
	add_branch.emit(self,no_match_idx())

func createHitlistBranch(details):
	var branches = get_child_count() - 4
	var newHitlist = hitlistBranch.instantiate()
	newHitlist.loadHitList(details)
	add_child(newHitlist)
	move_child(newHitlist,branches)
	set_slot(branches + 1,false,0,Color.WHITE,true,0,Color.RED)
	update_branch_states()
	newHitlist.delete.connect(_deleted_option.bind(newHitlist))
	newHitlist.moved.connect(_move_branch)
	add_branch.emit(self,no_match_idx())


func getData():
	var index = 0
	var returnValue = {"type":"reference","id":getID(),"data":{},"location":position_offset}
	var children = get_children()
	while index < len(children) - 1:
		index += 1
		if children[index].has_method("getData"):
			returnValue["data"][index] = children[index].getData()
		elif children[index].name == "No Match Branch":
			returnValue["data"][index] = "NoMatch"
	return returnValue


func _deleted_option(option):
	var num = get_children().find(option,0)
	remove_child(option)
	update_branch_states()
	set_slot(get_child_count()-3,false,0,Color.WHITE,false,0,Color.RED)
	remove_branch.emit(self,num)
	size.y = 0

func _move_branch(branch,direction):
	var currentChildLocation = get_children().find(branch,0)
	var newChildLocation = currentChildLocation + direction
	move_child(branch,newChildLocation)
	moved_branch.emit(self,currentChildLocation,newChildLocation)
	update_branch_states()

func update_branch_states():
	var children = get_children()
	if((len(children)-5) <= 1):
		if((len(children)-5) == 1):
			children[1].setMoveState("disabled")
		return
	var lastIdx = len(children)-5
	for a in range(1,lastIdx + 1):
		match a:
			1:
				children[a].setMoveState("first")
			lastIdx:
				children[a].setMoveState("last")
			_:
				children[a].setMoveState("middle")

func no_match_idx():
	return get_child_count() - 5

func getNextBranchID():
	var id = 1;
	for a in get_children():
		if a.has_method("getID"):
			var nextId = a.getID()
			print(nextId)
			if nextId >= id:
				id = nextId + 1
	return id


func _on_add_code_branch_pressed():
	createCodeBranch({"id":getNextBranchID()})


func _on_add_hit_list_branch_pressed():
	createHitlistBranch({"id":getNextBranchID(),"list":[]})

func setLabel(label):
	$cellDetails/VBoxContainer/labelBox.text = label
	return label

func getLabel():
	var regex = RegEx.new()
	regex.compile("/[\"^\"]/g")
	var idVal = regex.sub($cellDetails/VBoxContainer/CellID.text,"")
	return setLabel(int(idVal))

func setID(id):
	$cellDetails/VBoxContainer/CellID.text = str(id)
	return id

func getID():
	var regex = RegEx.new()
	regex.compile("/[^\\d+]/g")
	var idVal = regex.sub($cellDetails/VBoxContainer/CellID.text,"")
	if idVal == "":
		return -1
	return setID(int(idVal))

func setVar(varname):
	$cellDetails/VBoxContainer/varName.text = varname

func getVar():
	return $cellDetails/VBoxContainer/varName.text

#empty = {"id":"","var":"","data":[],"location":Vector2(0,0)}
func loadData(data):
	setID(data["id"])
	setVar(data["var"])
	position_offset = data["location"]
	for a in data["data"]:
		if(a != "NoMatch"):
			match data["data"][a]["type"]:
				"code":
					createCodeBranch(data["data"][a])
				"hitlist":
					createHitlistBranch(data["data"][a])

func _input(event):
	pass


func _on_delete_request():
	print("delete")


func fromCellData(cellData, dict):
	var connections = [] # [{"from_port":0,"to_cell":datas.pop_front()}]
	var childIds = []
	var nomatch = {"exists":false}
	var datas = Array(cellData.split("|"))
	setID(datas.pop_front())
	setLabel(dict[int(datas.pop_front())])
	datas.pop_front()
	setVar(dict[int(datas.pop_front())])
	for a in datas.pop_front().split("~"):
		var branchData = a.split("!")
		match branchData[2]:
			"C":
				createCodeBranch({"id":branchData[0]})
				childIds.append(branchData[1])
			"N":
				nomatch.exists = true
				nomatch.childId = branchData[1]
			_:
				createHitlistBranch({"id":branchData[0],"list":dict[int(branchData[3])].split("^")})
				childIds.append(branchData[1])
	var port = -1
	for a in childIds:
		port += 1
		connections.append({"from_port":port,"to_cell":a})
	if nomatch.exists:
		port += 1
		connections.append({"from_port":port,"to_cell":nomatch.childId})
	return {"connections":connections}
