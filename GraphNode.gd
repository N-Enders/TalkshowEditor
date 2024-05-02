extends GraphNode

@export var editableText: PackedScene

signal delete

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setId(id):
	$BranchID.text = str(id)


func getID():
	return int($BranchID.text)


func loadHitList(data):
	setId(data["id"])
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
