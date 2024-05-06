extends GraphNode

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func selectNode():
	selected = true


func setID(id):
	$cellDetails/VBoxContainer/CellID.text = str(id)

func getID():
	return int($cellDetails/VBoxContainer/CellID.text)


func getData():
	return {
				"type":"label",
				"id": getID(),
				"position": position_offset,
				"data":{
					"labelValue":$TextEdit.text
				}
			}

func loadData(dict):
	$TextEdit.text = dict["data"]["labelValue"]
	position_offset = dict["position"]
	setID(dict["id"])
