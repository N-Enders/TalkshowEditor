extends Control

@export var flow: PackedScene

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
	if offset >= size.x - 100:
		$HSplitContainer.split_offset = size.x - 100
	print(offset)

func loadInfo(data):
	pass

func loadFlowchart(data):
	pass

func decompFlowchart(main,code):
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
		await newFlow.createFlowchartFromData(preData)
		


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
