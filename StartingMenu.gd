extends Control

var wait = 0

signal data_recieved

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
	return
	var text = $newmenucode.text
	if "ExportMain" in text:
		var list = text.split('\n')
		for a in list:
			if len(a) >= 900000:
				$newmenucode.text = ""
				$newmenulabel.text = "Paste entire \"ExportMain\" class from start.swf (class excedes limits)"
				return
		$LoadingLabel.setDetails("Creating a new project")
		setLoadingVisible(true)
		setNewMenuVisible(false)
		setMainMenuVisible(false)
		list.reverse()
		
		data_recieved.emit({"startData":await decompStart(list),"flows":[]})
		
		$LoadingLabel.setDetails("Project decompiled")
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



func waitTime():
	wait += 1
	if ((wait % 200) == 0):
		await get_tree().create_timer(1.0).timeout




func decompStart(start):
	var startData = {}
	var preData = {}
	for a in start:
		if "=" in a:
			var pos = a.find("=")
			var line = [a.substr(0,pos),a.substr(pos+1)]
			var type = line[0].strip_edges().split(' ')[2].split(":")
			var dataType = type[1]
			type = type[0]
			line.remove_at(0)
			var data = "=".join(line).strip_edges().split(';')[0]
			preData[type] = getDataType(data,dataType)
	
	
	startData["dict"] = preData["dict"].split("^")
	preData.erase("dict")
	var dict = Array(startData["dict"])
	startData["startingFlowchart"] = preData["f"]
	preData.erase("f")
	startData["startingCell"] = preData["c"]
	preData.erase("c")
	startData["projectName"] = preData["p"]
	preData.erase("p")
	startData["workspaceName"] = preData["w"]
	preData.erase("w")
	startData["childsubroutines"] = preData["childsubroutines"]
	preData.erase("childsubroutines")
	startData["childtemplates"] = preData["childtemplates"]
	preData.erase("childtemplates")
	$LoadingLabel.setDetails("Parsing data for " + dict[int(startData["workspaceName"])])
	startData["timeStamp"] = preData["timeStamp"]
	preData.erase("timeStamp")
	
	
	$LoadingLabel.setDetails(dict[startData["workspaceName"]] + " parsing projects")
	startData["projects"] = {}
	for a in preData["projects"].split("^"):
		if a != "":
			await waitTime()
			var splitData = Array(a.split("|"))
			var projName = int(splitData[1])
			var projId = splitData[0]
			startData["projects"][projId] = {"id":projId,"name":projName}
	preData.erase("projects")
	
	$LoadingLabel.setDetails(dict[startData["workspaceName"]] + " parsing packages")
	startData["packages"] = {}
	for a in preData["packages"].split("^"):
		await waitTime()
		var splitData = Array(a.split("|"))
		var packName = int(splitData[0])
		var packId = splitData[1]
		var packType
		match splitData[2]:
			"I":
				packType = "Internal"
			"S":
				packType = "SWF"
			"C":
				packType = "Code"
		var projectParent = int(splitData[3])
		startData["packages"][packId] = {"id":packId,"name":packName,"type":packType,"projectParent":projectParent}
	preData.erase("packages")
	
	$LoadingLabel.setDetails(dict[startData["workspaceName"]] + " parsing flowcharts")
	startData["flowcharts"] = {}
	for a in preData["flowcharts"].split("^"):
		await waitTime()
		var splitData = Array(a.split("|"))
		var flowId = splitData[0]
		var flowName = int(splitData[1])
		var type
		if splitData[2] == "1":
			type = "Subroutine"
		else:
			type = "Flowchart"
		var projectParent = int(splitData[3])
		startData["flowcharts"][str(flowId)] = {"id": flowId, "name": flowName, "type": type, "projectParent":projectParent}
	preData.erase("flowcharts")
	
	$LoadingLabel.setDetails(dict[startData["workspaceName"]] + " parsing actions")
	startData["actions"] = {}
	for a in preData["actions"].split("^"):
		await waitTime()
		var splitData = Array(a.split("|"))
		var actionId = splitData.pop_front()
		var actionName = int(splitData.pop_front())
		var packageParentId = int(splitData.pop_front())
		var params = []
		while(len(splitData) > 0):
			var paramName = int(splitData.pop_front())
			var type
			match splitData.pop_front():
				"A":
					type = "Audio"
				"B":
					type = "Boolean"
				"G":
					type = "Graphic"
				"L":
					type = "List"
				"N":
					type = "Number"
				"S":
					type = "String"
				"T":
					type = "Text"
			params.append({"name":paramName,"type":type})
		startData["actions"][actionId] = {"id":actionId, "name":actionName, "packageParent": packageParentId, "params": params}
	preData.erase("actions")
	
	$LoadingLabel.setDetails(dict[startData["workspaceName"]] + " parsing templates")
	startData["templates"] = {}
	if preData["templates"].split("^")[0] != "":
		for a in preData["templates"].split("^"):
			await waitTime()
			var splitData = Array(a.split("|"))
			var tempId = splitData.pop_front()
			var tempParent = int(splitData.pop_front())
			var tempName = int(splitData.pop_front())
			var params = []
			for b in splitData.pop_front().split("!"):
				params.append(int(b))
			var fields = {}
			for b in splitData.pop_front().split("!"):
				var fieldData = Array(b.split(","))
				var fieldId = fieldData.pop_front()
				var fieldName = int(fieldData.pop_front())
				var fieldType
				var defaultVal
				match fieldData.pop_front():
					"A":
						fieldType = "Audio"
						defaultVal = fieldData.pop_front()
					"B":
						fieldType = "Boolean"
						defaultVal = int(fieldData.pop_front())
					"G":
						fieldType = "Graphic"
						defaultVal = fieldData.pop_front()
					"N":
						fieldType = "Number"
						defaultVal = int(fieldData.pop_front())
					"S":
						fieldType = "String"
						defaultVal = int(fieldData.pop_front())
				var variable = fieldData.pop_front()
				if (variable == ""):
					variable = "0"
				variable = int(variable)
				fields[fieldId] = {"id": fieldId, "name":fieldName, "type": fieldType, "defaultValue": defaultVal, "variable": variable}
			startData["templates"][tempId] = {"id": tempId, "name": tempName, "projectParent": tempParent, "params": params, "fields": fields}
	preData.erase("templates")
	
	$LoadingLabel.setDetails(dict[startData["workspaceName"]] + " parsing media")
	startData["media"] = {}
	startData["containsLocale"] = true
	var shoot = Array(preData["media"].split("^")[0].split("|"))
	shoot.pop_front()
	shoot.pop_front()
	var num = int(shoot.pop_front())
	if ((num*4) == len(shoot)):
		startData["containsLocale"] = false
	for a in preData["media"].split("^"):
		waitTime()
		var splitData = Array(a.split("|"))
		var mediaId = splitData.pop_front()
		var mediaType
		match splitData.pop_front():
			"A":
				mediaType = "Audio"
			"G":
				mediaType = "Graphic"
			"T":
				mediaType = "Text"
			_:
				print("Invalid media type")
		var mediaAmount = int(splitData.pop_front())
		var miniMedias = []
		for b in range(0,mediaAmount):
			var miniId = splitData.pop_front()
			var locale
			if startData["containsLocale"]:
				locale = splitData.pop_front()
			var miniTags = int(splitData.pop_front())
			var miniDict = int(splitData.pop_front())
			var miniType = splitData.pop_front().split(",")
			if startData["containsLocale"]:
				miniMedias.append({"id":miniId,"locale":locale,"tags":miniTags,"dict":miniDict,"type":miniType})
			else:
				miniMedias.append({"id":miniId,"tags":miniTags,"dict":miniDict,"type":miniType})
		startData["media"][mediaId] = {"id":mediaId, "type": mediaType, "amount": mediaAmount, "medias": miniMedias}
	preData.erase("media")
	
	return startData
