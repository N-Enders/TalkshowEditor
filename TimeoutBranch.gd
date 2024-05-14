extends GraphNode

signal delete
signal moved

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Base Node Functions
func _on_delete_button_pressed():
	delete.emit()


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

func isTimeout():
	pass

func getData():
	return {"type":"timeout","id":getID(),"TimeoutData":{"type":getStartType(),"time":getTimerText()}}

func getStartType():
	if $StartTimer.button_pressed:
		return "E"
	return "S"


func setStartType(type):
	$StartTimer.button_pressed = false
	if type == "S":
		$StartTimer.button_pressed = true


func setTimerText(text):
	$TimerText.text = str(text)
	return text

func getTimerText():
	var regex = RegEx.new()
	regex.compile("/[^\\d.+]/g")
	var timerVal = regex.sub($TimerText.text,"")
	if timerVal == "":
		return setTimerText(0.0)
	return setTimerText(timerVal)


#default {"type":"timeout","id":0,"TimeoutData":{"type":"E","time":0.0}}
func loadData(data):
	setID(data["id"])
	setStartType(data["TimeoutData"]["type"])
	setTimerText(data["TimeoutData"]["time"])
