extends Control

@export var flow: PackedScene
@export var actionEdit: PackedScene


var projectContent = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#makes sure the user doesn't resize the h-split too much
func _on_h_split_container_dragged(offset):
	if offset <= 100:
		$HSplitContainer.split_offset = 100
	if offset >= 500:
		$HSplitContainer.split_offset = 500
	print(offset)


#{"id":packId,"name":packName,"type":packType,"projectParent":projectParent}
func loadInfo(data):
	projectContent = data.startData
	print(projectContent.keys())
	
	var packages = []
	for a in projectContent.packages:
		packages.append({"id":projectContent.packages[a].id,"name":projectContent.packages[a].name})
	
	
	for a in projectContent.actions:
		var newAction = actionEdit.instantiate()
		$HSplitContainer/VBoxContainer/InfoContainer/Actions/Actions.add_child(newAction)
		print("Adding action " + str(projectContent.actions[a].name))
		newAction.loadFromData(projectContent.actions[a],packages,projectContent.dict)



func loadFlowchart(data):
	pass


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



func dataDecomp():
	if("      public function FlowchartMain()" in str($"HSplitContainer/FlowContainers/Create New Flowchart/main/CodeEdit".text)):
		var cells = []
		var media = []
		var params = []
		var dict = []
		var fname = ""
		var pname = ""
		var c = 0
		var lines = str($"HSplitContainer/FlowContainers/Create New Flowchart/main/CodeEdit".text).split("\n")
		var startData = {}
		var preData = {}
		for a in lines:
			if "=" in a:
				var pos = a.find("=")
				var line = [a.substr(0,pos),a.substr(pos+1)]
				var type = line[0].strip_edges().split(' ')[2].split(":")
				var dataType = type[1]
				type = type[0]
				line.remove_at(0)
				var data = "=".join(line).strip_edges().split(';')[0]
				preData[type] = getDataType(data,dataType)
		var newFlow = flow.instantiate()
		newFlow.name = preData["fname"]
		$HSplitContainer/FlowContainers.add_child(newFlow)
		
		newFlow.request_data.connect(_data_request)
		
		
		await newFlow.createFlowchartFromData(preData)
		
		$HSplitContainer/FlowContainers.current_tab = $HSplitContainer/FlowContainers.get_child_count()-1


func _on_code_edit_text_changed():
	check_imports()


func check_imports():
	var checkPassed = true
	if not "public function FlowchartMain()" in str($"HSplitContainer/FlowContainers/Create New Flowchart/main/CodeEdit".text):
		checkPassed = false
		$"HSplitContainer/FlowContainers/Create New Flowchart/main/CodeEdit".text = ""
	if not "public function FlowchartCode(" in str($"HSplitContainer/FlowContainers/Create New Flowchart/code/CodeEdit".text):
		checkPassed = false
		$"HSplitContainer/FlowContainers/Create New Flowchart/code/CodeEdit".text = ""
	
	if checkPassed:
		await dataDecomp()
		$"HSplitContainer/FlowContainers/Create New Flowchart/main/CodeEdit".text = ""
		$"HSplitContainer/FlowContainers/Create New Flowchart/code/CodeEdit".text = ""



func _switch_flow(toFlowData):
	var children = $HSplitContainer/FlowContainers.get_children()
	var curIndex = 0
	for a in children:
		if a.name == toFlowData["name"]:
			$HSplitContainer/FlowContainers.current_tab = curIndex
		curIndex += 1
	
	$HSplitContainer/FlowContainers.current_tab = 0



func _data_request(requestType,item,type,value):
	match requestType:
		"flow":
			getFlowData(item,type,value)


func getFlowData(item,type,value):
	#{0: {"id": 0, "name": testName, "type": Subroutine/Flowchart, "projectParent":("projects" id)}}
	var flows = projectContent["flowcharts"]
	
	match type:
		"name":
			for a in flows:
				if flows[a]["name"] == value:
					item.returnData(flows[a],"flow")
		"id":
			for a in flows:
				if a == str(value):
					item.returnData(flows[a],"flow")
	
	


func _on_filter_text_changed(new_text):
	pass # Replace with function body.
