extends Control

func _ready() -> void:
	Engine.max_fps = 30

func _on_play_pressed() -> void:
	Engine.max_fps = 0
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://EatEmUp/Scenes/Menus/Options_Menu.tscn")

func _on_unplay_pressed() -> void:
	get_tree().quit()

func _on_unplay_2_pressed() -> void:
	get_tree().quit()

func _on_player_selection_pressed() -> void:
	get_tree().change_scene_to_file("res://EatEmUp/Scenes/Menus/PlayerSetup.tscn")
