extends GraphNode

signal delete
signal moved

# Called when the node enters the scene tree for the first time.
func _ready():
	setMoveState("disabled")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Base Node Functions
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


#Branch methods
func getData():
	return {"type":"mcfib","id":getID(),"FibMCType":getMcFibType(),"input":getInputText()}


func getMcFibType():
	if $mcFibContainer/McFibCheck.button_pressed:
		return "F"
	return "M"


func setMcFibType(type):
	$mcFibContainer/McFibCheck.button_pressed = false
	if type == "F":
		$mcFibContainer/McFibCheck.button_pressed = true


func getInputText():
	return $InputEdit.text


func setInputText(text):
	$InputEdit.text = text

#default {"type":"mcfib","id":0,"FibMCType":"M","input":""}
func loadData(data):
	setID(data["id"])
	setInputText(data["input"])
	setMcFibType(data["FibMCType"])
