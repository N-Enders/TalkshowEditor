extends GraphNode

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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


func setFlowchartID(id):
	$ConnectingData/Flowchart/TextEdit.text = str(id)
	return id

func getFlowchartID():
	var regex = RegEx.new()
	regex.compile("/[^\\d+]/g")
	var idVal = regex.sub($ConnectingData/Flowchart/TextEdit.text,"")
	if idVal == "":
		return 0
	return setID(int(idVal))

func setChildCellID(id):
	$ConnectingData/Cell/TextEdit.text = str(id)
	return id

func getChildCellID():
	var regex = RegEx.new()
	regex.compile("/[^\\d+]/g")
	var idVal = regex.sub($ConnectingData/Cell/TextEdit.text,"")
	if idVal == "":
		return 0
	return setID(int(idVal))


func fromCellData(cellData, dict):
	var datas = Array(cellData.split("|"))
	setID(datas.pop_front())
	setLabel(dict[int(datas.pop_front())])
	datas.pop_front()
	var flowchartId = datas.pop_front()
	var childCell = datas.pop_front()
	setFlowchartID(flowchartId)
	setChildCellID(childCell)
	return {"connections":[]}
