extends GraphNode

@export var editableText: PackedScene

signal add_branch
signal remove_branch
signal moved_branch

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func createBranch(value):
	var branches = get_child_count() - 3
	var newText = editableText.instantiate()
	newText.setText(str(value))
	add_child(newText)
	move_child(newText,branches)
	set_slot(branches + 1,false,0,Color.WHITE,true,0,Color.RED)
	newText.deleted.connect(_deleted_option.bind(newText))
	add_branch.emit(self)

func createMcFibBranch(data):
	pass

func createTimeoutBranch(data):
	pass



func _on_add_normal_branch_pressed():
	createBranch("")



func _deleted_option(option):
	var num = get_children().find(option,0)
	remove_child(option)
	set_slot(get_child_count()-1,false,0,Color.WHITE,false,0,Color.RED)
	remove_branch.emit(self,num)
	size.y = 0

func no_match_idx():
	return get_child_count() - 4


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
		if children[index].has_method("getText"):
			returnValue["data"][index] = children[index].getText()
		elif children[index].name == "No Match Branch":
			returnValue["data"][index] = "NoMatch"
	return returnValue

func loadData(data):
	setID("id")
	for a in data["data"]:
		if(a != "NoMatch"):
			match data["data"][a]["type"]:
				"mc","fib":
					createMcFibBranch(data["data"][a])
