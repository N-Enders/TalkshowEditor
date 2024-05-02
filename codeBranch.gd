extends GraphNode

signal delete

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
