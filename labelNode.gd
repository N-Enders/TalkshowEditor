extends GraphNode

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func selectNode():
	selected = true

func getData():
	return {
				"type":"label",
				"labelValue":$TextEdit.text, 
				"position": 
					{"x": position_offset.x , 
					"y": position_offset.y }
			}

func loadValues(dict):
	$TextEdit.text = dict["labelValue"]
	position_offset = Vector2(dict["x"],dict["y"])
