extends GraphNode

@export var editableText: PackedScene

signal delete
signal moved

# Called when the node enters the scene tree for the first time.
func _ready():
	setMoveState("disabled")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setID(id):
	$BranchID.text = str(id)
	return id


func getID():
	var regex = RegEx.new()
	regex.compile("/[^\\d+]/g")
	var idVal = regex.sub($BranchID.text,"")
	if idVal == "":
		return -1
	return setID(int(idVal))


func loadHitList(data):
	setID(data["id"])
	for a in data["list"]:
		createText(a)


func createText(defVal):
	var newText = editableText.instantiate()
	newText.setText(defVal)
	add_child(newText)
	
	var branches = len(get_children()) - 2
	move_child(newText,branches)
	
	newText.deleted.connect(_branch_deleted.bind(newText))



func _branch_deleted(branch):
	var num = get_children().find(branch,0)
	remove_child(branch)



func getData():
	return {"type":"hitlist","id":getID(),"list":getHitlist()}



func getHitlist():
	var values = []
	for a in get_children():
		if a.has_method("getText"):
			values.append(a.getText())
	return values



func _on_add_text_pressed():
	createText("")



func _on_delete_button_pressed():
	delete.emit()


func setMoveState(state):
	var stateData
	match state:
		"first":
			stateData = [false,true]
		"middle":
			stateData = [true,true]
		"last":
			stateData = [true,false]
		"disabled":
			stateData = [false,false]
	$HBoxContainer/MoveUp.disabled = not stateData[0]
	$HBoxContainer/MoveDown.disabled = not stateData[1]

func moveUpEnabled():
	return not $HBoxContainer/MoveUp.disabled

func moveDownEnabled():
	return not $HBoxContainer/MoveDown.disabled


func _on_move_up_pressed():
	moved.emit(self,-1)


func _on_move_down_pressed():
	moved.emit(self,1)
