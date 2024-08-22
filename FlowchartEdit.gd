extends GraphNode

#{"id": flowId, "name": flowName, "type": type, "projectParent":projectParent}
const types = ["Flowchart","Subroutine"]
var flowData = {}

signal switch_flow

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setID(id):
	$IdEdit.text = str(id)
	return id

func getID():
	var regex = RegEx.new()
	regex.compile("/[^\\d+]/g")
	var idVal = regex.sub($IdEdit.text,"")
	if idVal == "":
		return 0
	return setID(int(idVal))

func setName(label):
	$NameEdit.text = label
	return label

func getName():
	var regex = RegEx.new()
	regex.compile("/[\"^\"]/g")
	var idVal = regex.sub($NameEdit.text,"")
	return setName(idVal)


func loadFromData(data,dict,projects):
	
	flowData = data
	flowData.name = dict[flowData.name]
	
	#{"id":projId,"name":projName}
	var index = 0
	for a in projects:
		$ProjectChoose.add_item(dict[projects[a].name])
		
		if str(projects[a].id) == str(data.projectParent):
			$ProjectChoose.selected = index
		index += 1
	
	setName(data.name)
	setID(data.id)
	
	$TypeChoose.selected = types.find(data.type)

func checkEnable(names):
	$JumpButton.disabled = true
	for a in names:
		if a == flowData.name:
			$JumpButton.disabled = false
			return


func _on_jump_button_pressed():
	switch_flow.emit(flowData)
