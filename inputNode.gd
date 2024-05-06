extends GraphNode

@export var editableText: PackedScene

signal add_branch
signal remove_branch

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func createBranch(value):
	var branches = get_child_count() - 2
	var newText = editableText.instantiate()
	newText.setText(str(value))
	add_child(newText)
	move_child(newText,branches)
	set_slot(branches + 1,false,0,Color.WHITE,true,0,Color.RED)
	newText.deleted.connect(_deleted_option.bind(newText))
	add_branch.emit(self)

func _on_add_normal_branch_pressed():
	createBranch("")




func _deleted_option(option):
	var num = get_children().find(option,0)
	remove_child(option)
	set_slot(get_child_count()-1,false,0,Color.WHITE,false,0,Color.RED)
	remove_branch.emit(self,num)

func no_match_idx():
	return get_child_count() - 4



func setID(id):
	$cellDetails/VBoxContainer/CellID.text = str(id)

func getID():
	return int($cellDetails/VBoxContainer/CellID.text)

func getData():
	var index = 0
	var returnValue = {"type":"input","data":{}}
	var children = get_children()
	while index < len(children) - 1:
		index += 1
		if children[index].has_method("getText"):
			returnValue["data"][index] = children[index].getText()
		elif children[index].name == "No Match Branch":
			returnValue["data"][index] = "NoMatch"
	return returnValue
