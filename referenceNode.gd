extends GraphNode

@export var codeBranch: PackedScene
@export var hitlistBranch: PackedScene

signal add_branch
signal remove_branch

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
	newCode.delete.connect(_deleted_option.bind(newCode))
	add_branch.emit(self)

func createHitlistBranch(details):
	var branches = get_child_count() - 4
	var newHitlist = hitlistBranch.instantiate()
	newHitlist.loadHitList(details)
	add_child(newHitlist)
	move_child(newHitlist,branches)
	set_slot(branches + 1,false,0,Color.WHITE,true,0,Color.RED)
	newHitlist.delete.connect(_deleted_option.bind(newHitlist))
	add_branch.emit(self)

############
############ REDO
############
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
	set_slot(get_child_count()-3,false,0,Color.WHITE,false,0,Color.RED)
	remove_branch.emit(self,num)
	size.y = 0

func no_match_idx():
	return get_child_count() - 4

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

func setID(id):
	$cellDetails/VBoxContainer/CellID.text = str(id)

func getID():
	return int($cellDetails/VBoxContainer/CellID.text)

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
