extends GraphNode


const paramTypes = ["Audio","Boolean","Graphic","List","Number","String","Text"]


#{"id":actionId, "name":actionName, "packageParent": packageParentId, "params": params}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_option_button_item_selected(index):
	print(index)


func loadFromData(data,packageData,dict):
	$ActionIdEdit.text = str(data.id)
	$ActionNameEdit.text = dict[data.name]
	
	var packageIdsList = []
	for a in packageData:
		packageIdsList.append(int(a.id))
		$OptionButton.add_item( dict[a.name] )
		
	$OptionButton.selected = packageIdsList.find(int(data.packageParent))
	
	for a in data.params:
		createParamValue(dict[a.name],a.type)

func createParamValue(paramName,value):
	var container = VBoxContainer.new()
	
	var lineedit = LineEdit.new()
	var dropdown = OptionButton.new()
	
	for a in paramTypes:
		dropdown.add_item(a)
	
	$ParamsContainer/ParamsContainer.add_child(container)
	$ParamsContainer/ParamsContainer.add_child(container)
	
	lineedit.text = paramName
	dropdown.selected = paramTypes.find(value)
	
	container.add_child(Label.new())
	container.add_child(lineedit)
	container.add_child(dropdown)

func setID(id):
	$ActionIdEdit.text = str(id)
	return id

func getID():
	var regex = RegEx.new()
	regex.compile("/[^\\d+]/g")
	var idVal = regex.sub($ActionIdEdit.text,"")
	if idVal == "":
		return 0
	return setID(int(idVal))

func setLabel(label):
	$ActionNameEdit.text = label
	return label

func getLabel():
	var regex = RegEx.new()
	regex.compile("/[\"^\"]/g")
	var idVal = regex.sub($ActionNameEdit.text,"")
	return setLabel(idVal)




func runFilter(text):
	text = text.to_lower()
	visible = true
	if text in str(getID()).to_lower():
		return
	if text in getLabel().to_lower():
		return
	if text in $OptionButton.get_item_text($OptionButton.selected).to_lower():
		return
	for a in $ParamsContainer/ParamsContainer.get_children():
		for b in a.get_children():
			if b is LineEdit:
				if text in b.text.to_lower():
					return
	visible = false
