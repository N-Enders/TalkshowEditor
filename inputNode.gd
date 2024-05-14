extends GraphNode

@export var McFibBranch: PackedScene
@export var TimeoutBranch: PackedScene

signal add_branch
signal remove_branch
signal moved_branch

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_mc_fib_branch(data):
	var branches = get_child_count() - 4 - insert_num()
	var newBranch = McFibBranch.instantiate()
	newBranch.loadData(data)
	add_child(newBranch)
	move_child(newBranch,branches)
	set_slot(branches + 1 + insert_num(),false,0,Color.WHITE,true,0,Color.RED)
	update_branch_states()
	newBranch.delete.connect(_deleted_option.bind(newBranch))
	newBranch.moved.connect(_move_branch)
	add_branch.emit(self,no_match_idx())

func create_timeout_branch(data):
	var branches = get_child_count() - 4
	set_slot(branches + 1,false,0,Color.WHITE,true,0,Color.RED)
	add_branch.emit(self,no_match_idx()+1)
	var newBranch = TimeoutBranch.instantiate()
	newBranch.loadData(data)
	add_child(newBranch)
	move_child(newBranch,branches)
	update_branch_states()
	newBranch.delete.connect(_deleted_option.bind(newBranch))


func insert_num():
	if getTimeout() == null:
		return 0
	return 1


func getNextBranchID():
	var id = 0;
	for a in get_children():
		if a.has_method("getID"):
			var nextId = a.getID()
			print(nextId)
			if nextId >= id:
				id = nextId + 1
	return id



func _on_add_normal_branch_pressed():
	create_mc_fib_branch({"type":"mcfib","id":getNextBranchID(),"FibMCType":"M","input":""})


func _on_add_timeout_branch_pressed():
	create_timeout_branch({"type":"timeout","id":0,"TimeoutData":{"type":"E","time":0.0}})


func _deleted_option(option):
	var num = get_children().find(option,0)
	remove_child(option)
	set_slot(get_child_count() - 3,false,0,Color.WHITE,false,0,Color.RED)
	remove_branch.emit(self,num)
	update_branch_states()
	size.y = 0

func no_match_idx():
	return get_child_count() - 5 - insert_num()


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

func getData():
	var index = 0
	var returnValue = {"type":"input","id":getID(),"position": position_offset,"data":{}}
	var children = get_children()
	while index < len(children) - 1:
		index += 1
		if children[index].has_method("getData"):
			returnValue["data"][index] = children[index].getData()
		elif children[index].name == "No Match Branch":
			returnValue["data"][index] = "NoMatch"
	return returnValue

# {"type":"input","id":id,"position": pos,"data":{}}
func loadData(data):
	setID("id")
	for a in data["data"]:
		if(a != "NoMatch"):
			match data["data"][a]["type"]:
				"mc","fib","mcfib":
					create_mc_fib_branch(data["data"][a])
				"timeout":
					create_timeout_branch(data["data"][a])


func getTimeout():
	for a in get_children():
		if a.has_method("isTimeout"):
			return a
	return null


func update_branch_states():
	var movableChildren = []
	$addTimeoutBranch.disabled = getTimeout() != null
	for a in get_children():
		if a.has_method("setMoveState"):
			movableChildren.append(a)
	if(len(movableChildren) <= 1):
		if(len(movableChildren) == 1):
			movableChildren[0].setMoveState("disabled")
		return
	var lastIdx = len(movableChildren) - 1
	for a in range(0,lastIdx+1):
		match a:
			0:
				movableChildren[a].setMoveState("first")
			lastIdx:
				movableChildren[a].setMoveState("last")
			_:
				movableChildren[a].setMoveState("middle")


func _move_branch(branch,direction):
	var currentChildLocation = get_children().find(branch,0)
	var newChildLocation = currentChildLocation + direction
	move_child(branch,newChildLocation)
	moved_branch.emit(self,currentChildLocation,newChildLocation)
	update_branch_states()
