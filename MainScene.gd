extends Node

@export var flow: PackedScene
@export var menu: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	create_menu()


func create_menu():
	remove_all_children()
	var menu = menu.instantiate()
	menu.data_recieved.connect(_handle_recieved_data)
	add_child(menu)


func create_flowchart(data):
	remove_all_children()
	var flowchart = flow.instantiate()
	flowchart.add_data(data)
	add_child(flowchart)


func remove_all_children():
	for a in get_children():
		remove_child(a)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _handle_recieved_data(data):
	create_flowchart(data)
