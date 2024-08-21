extends VBoxContainer




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func runFilter(text):
	var infoToCheck = [$InfoContainer/Actions/Actions]
	if text == "":
		for a in infoToCheck:
			for b in a.get_children():
				b.visible = true
	else:
		for a in infoToCheck:
			for b in a.get_children():
				b.runFilter(text)


func _on_filter_text_changed(new_text):
	runFilter(new_text)
