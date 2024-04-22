extends Node

@export var flow: PackedScene
@export var menu: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var flowchart = menu.instantiate()
	add_child(flowchart)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
