extends Control
@export var player_label: PackedScene = null
var selectedcontrols : Array[PlayerControls] = []
@export var playeroptions : Array[PlayerControls] = []
@onready var playercontainer : HBoxContainer = $MarginContainer/VBoxContainer/PlayersContainer
func _ready() -> void:
	Engine.max_fps = 30
	if GlobalData.players.size() > 0:
		selectedcontrols = GlobalData.players
		for i in range(selectedcontrols.size()):
			addplayerlabels(i)
	
func _input(event: InputEvent) -> void:
	for i in range(playeroptions.size()):
		if Input.is_action_just_pressed(playeroptions[i].action):
			if selectedcontrols.size() > 0:
				for x in range(selectedcontrols.size()):
					if selectedcontrols[x].action == playeroptions[i].action:
						#could mark players ready here
						return;
			selectedcontrols.append(playeroptions[i])
			addplayerlabels(selectedcontrols.size()-1)
			return
	var toremove : Array[int] = []
	for i in range(selectedcontrols.size()):
		if Input.is_action_just_pressed(selectedcontrols[i].leave):
			toremove.append(i)
	if toremove.size() > 0:
		for i in range(toremove.size()-1, -1, -1):
			selectedcontrols.remove_at(toremove[i])
			var childnode = playercontainer.get_child(toremove[i])
			if is_instance_valid(childnode):
				childnode.queue_free()
				playercontainer.remove_child(childnode)
				var newindex = 1
				for child in playercontainer.get_children():
					child.setplayerid(newindex)
					newindex += 1
	if Input.is_action_just_pressed("global_action"):
		GlobalData.players = selectedcontrols
		Engine.max_fps = 0
		get_tree().change_scene_to_packed(GlobalData.nextscene)
		

func addplayerlabels(index : int) -> void:
	var selected = selectedcontrols[index]
	if selected == null:
		return
	var pl = player_label.instantiate()
	pl.playerid = str(index+1)
	pl.deviveid = selected.deviceid
	pl.leaveaction = get_first_keycode_string(selected.leave)
	playercontainer.add_child(pl)

func get_first_keycode_string(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventKey:
			return event.as_text_physical_keycode()
		elif event is InputEventJoypadButton:
			return "PS(O) or XBOX(B)"
	return "..."
