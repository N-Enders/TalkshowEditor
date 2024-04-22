extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	setNewMenuVisible(false)
	setMainMenuVisible(true)
	setLoadingVisible(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setNewMenuVisible(vis):
	$newmenulabel.visible = vis
	$newmenucode.visible = vis
	if vis:
		$newmenucode.text = ""

func setMainMenuVisible(vis):
	$Label.visible = vis
	$Load.visible = vis
	$New.visible = vis

func setLoadingVisible(vis):
	$LoadingLabel.visible = vis

func _on_new_pressed():
	setNewMenuVisible(true)
	setMainMenuVisible(false)
	setLoadingVisible(false)

func _on_newmenucode_text_changed():
	var text = $newmenucode.text
	var list = text.split('\n')
	if list[0] == "package":
		$LoadingLabel.setDetails("Creating a new project")
		list.reverse()
		decompStart(list)
		setLoadingVisible(true)
		setNewMenuVisible(false)
		setMainMenuVisible(false)
	else:
		$newmenucode.text = ""
		$newmenulabel.text = "Paste entire \"ExportMain\" class from start.swf (invalid class)"


func getDataType(data,type):
	match type:
		"int":
			return int(data)
		"String":
			return data.left(-1).right(-1)
		"Array":
			return JSON.parse_string(data)
		_:
			print("whoopsie")

func decompStart(start):
	var startData = {}
	var preData = {}
	for a in start:
		if "=" in a:
			var line = a.split("=")
			var type = line[0].strip_edges().split(' ')[2].split(":")
			var dataType = type[1]
			type = type[0]
			line.remove_at(0)
			var data = "=".join(line).strip_edges().split(';')[0]
			preData[type] = getDataType(data,dataType)
	var dict = preData["dict"].split("^")
	preData.erase("dict")
	startData["startingFlowchart"] = preData["f"]
	preData.erase("f")
	startData["startingCell"] = preData["c"]
	preData.erase("c")
	startData["projectName"] = dict[preData["p"]]
	preData.erase("p")
	startData["workspaceName"] = dict[preData["w"]]
	preData.erase("w")
	$LoadingLabel.setDetails("Parsing data for " + startData["workspaceName"])
	startData["timeStamp"] = preData["timeStamp"]
	preData.erase("timeStamp")
	
	print("mk")
	
