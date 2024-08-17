extends PopupMenu


signal sortPressed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func activate(param):
	position = param
	visible = true


func _on_id_pressed(id):
	match id:
		1:
			pass
		2:
			sortPressed.emit()
