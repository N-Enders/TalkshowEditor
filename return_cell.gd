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

func setRVal(label):
	$cellDetails/VBoxContainer/labelBox.text = label
	return label

func getRVal():
	var regex = RegEx.new()
	regex.compile("/[\"^\"]/g")
	var idVal = regex.sub($cellDetails/VBoxContainer/CellID.text,"")
	return setLabel(int(idVal))


func getData():
	return {
				"type":"return",
				"id": getID(),
				"position": position_offset,
				"labelValue":getLabel(),
				"data":{
					"returnValue":getRVal()
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

#CHANGE TO RECOMPILE
func toCellData(cellConnections):
	var datas = []
	var dict = []
	var dictLoc = getDictLocation(dict,getLabel())
	dict = dictLoc["dict"]
	datas.append(str(getID()))
	datas.append("[[DictValue#"+dictLoc["location"]+"]]")
	datas.append("N")
	dictLoc = getDictLocation(dict,getRVal())
	dict = dictLoc.dict
	datas.append("[[DictValue#"+dictLoc["location"]+"]]")
	var childId = 0
	return {"data":"|".join(datas),"dict":dict}

func fromCellData(cellData, dict):
	var datas = Array(cellData.split("|"))
	setID(datas.pop_front())
	setLabel(dict[int(datas.pop_front())])
	datas.pop_front()
	setRVal(dict[int(datas.pop_front())])
	return {"connections":[]}


func canCompile():
	if not getID() > 0:
		return {"reasons":["Id must be greater than 0"]}
	return {"reasons":[]}

