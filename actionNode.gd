extends GraphNode

@export var actionBranch: PackedScene

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
		return 0
	return setID(int(idVal))

func setLabel(label):
	$cellDetails/VBoxContainer/labelBox.text = label
	return label

func getLabel():
	var regex = RegEx.new()
	regex.compile("/[\"^\"]/g")
	var idVal = regex.sub($cellDetails/VBoxContainer/CellID.text,"")
	return setLabel(int(idVal))


func getData():
	return {
				"type":"action",
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
	var childId = 0
	if 0 in cellConnections:
		childId = cellConnections[0]["cellID"]
	datas.append(cellConnections[0]["cellID"])
	return {"data":"|".join(datas),"dict":dict}

func fromCellData(cellData, dict):
	var datas = Array(cellData.split("|"))
	setID(datas.pop_front())
	setLabel(dict[int(datas.pop_front())])
	datas.pop_front()
	return {"connections":[{"from_port":0,"to_cell":datas.pop_front()}]}


func canCompile():
	if not getID() > 0:
		return {"reasons":["Id must be greater than 0"]}
	return {"reasons":[]}

