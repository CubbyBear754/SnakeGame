extends Node

@onready var countdown_label: Label = $Camera2D/TimerCanvas/CountDownLabel
@onready var level: Node2D = $Level_One

func _ready() -> void:
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
	
