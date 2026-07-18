extends Node

@onready var viewport_1 = $VSplitContainer/SplitContainer/SVPC1/SVP
@onready var viewport_2 = $VSplitContainer/SplitContainer/SVPC2/SVP
@onready var viewport_3 = $VSplitContainer/SplitContainer2/SVPC3/SVP
@onready var viewport_4 = $VSplitContainer/SplitContainer2/SVPC4/SVP
@onready var countdown_label: Label = $Camera2D/UICanvas/CountDownLabel

func _ready() -> void:
	var world = viewport_1.find_world_2d()
	viewport_2.world_2d = world
	viewport_3.world_2d = world
	viewport_4.world_2d = world
	start_pregame_countdown()

func start_pregame_countdown() -> void:
	await get_tree().create_timer(0.2, true, false, true).timeout
	# 1. Freeze the gameplay nodes
	get_tree().paused = true
	await get_tree().create_timer(1.0, true, false, true).timeout
	# 3. Clear text and unpause gameplay
	countdown_label.text = "GO!"
	get_tree().paused = false
	await get_tree().create_timer(1.0, true, false, true).timeout
	countdown_label.visible = false	
	
