extends PopupPanel


signal find_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	setID("")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func activate(param):
	position = param
	visible = true


func setID(id):
	$VBoxContainer/LineEdit.text = str(id)
	return id

func getID():
	var regex = RegEx.new()
	regex.compile("/[^\\d+]/g")
	var idVal = regex.sub($VBoxContainer/LineEdit.text,"")
	if idVal == "":
		return 0
	return setID(int(idVal))


func _on_button_pressed():
	find_pressed.emit(getID())
	setID("")
