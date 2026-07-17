extends Control

func _ready() -> void:
	Engine.max_fps = 0
	visible = false
	get_tree().paused = false

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://EatEmUp/Scenes/Menu.tscn")

func _on_resume_pressed() -> void:
	Engine.max_fps = 0
	visible = false
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("global_pause"):
		if get_tree().paused:
			Engine.max_fps = 0
			visible = false
			get_tree().paused = false
		else:
			Engine.max_fps = 30
			visible = true
			get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
