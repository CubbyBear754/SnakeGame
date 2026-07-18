extends HSplitContainer

@export var playerid : String
@export var deviveid : String
@export var leaveaction : String

@onready var pidlabel = $VBoxContainer2/PlayerID
@onready var cidlabel = $VBoxContainer2/ControllerID
@onready var qalabel = $VBoxContainer2/RemoveAction
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pidlabel.text = playerid
	cidlabel.text = deviveid
	qalabel.text = leaveaction
	
func setplayerid(newid : int) -> void:
	playerid = str(newid)
	pidlabel.text = playerid
