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
	return id

func getID():
	var regex = RegEx.new()
	regex.compile("/[^\\d+]/g")
	var idVal = regex.sub($cellDetails/VBoxContainer/CellID.text,"")
	if idVal == "":
		return -1
	return setID(int(idVal))



func setLabel(label):
	$cellDetails/VBoxContainer/labelBox.text = label

func getLabel():
	return $cellDetails/VBoxContainer/labelBox.text


func getData():
	return {
				"type":"label",
				"id": getID(),
				"position": position_offset,
				"data":{
					"labelValue":getLabel()
				}
			}

#{"type":"label","id":0,"position":Vector2(0,0),"data":{"labelValue":""}}
func loadData(dict):
	setLabel(dict["data"]["labelValue"])
	position_offset = dict["position"]
	setID(dict["id"])

func getDictLocation(dict,value):
	if value in dict:
		return {"dict":dict,"location":dict.find(value)}
	dict.append(value)
	return {"dict":dict,"location":dict.find(value)}

func toCellData(cellConnections):
	var datas = []
	var dict = []
	var dictLoc = getDictLocation(dict,getLabel())
	dict = dictLoc["dict"]
	datas.append(str(getID()))
	datas.append("[[DictValue#"+dictLoc["location"]+"]]")
	datas.append("L")
	datas.append(cellConnections[0]["cellID"])
	return {"data":"|".join(datas),"dict":dict}

func canCompile():
	pass

