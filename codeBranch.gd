extends GraphNode

signal delete
signal moved

# Called when the node enters the scene tree for the first time.
func _ready():
	setMoveState("disabled")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setBranchId(newId):
	$Id.text = newId

func getID():
	return int($Id.text)

func getData():
	return {"type":"code","id":getID()}


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
