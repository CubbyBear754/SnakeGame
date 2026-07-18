extends Control

func _ready() -> void:
	Engine.max_fps = 30

func _on_play_pressed() -> void:
	GlobalData.nextscene = load("res://Scenes/Game.tscn")
	get_tree().change_scene_to_file("res://EatEmUp/Scenes/Menus/PlayerSetup.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://EatEmUp/Scenes/Menus/Options_Menu.tscn")

func _on_unplay_pressed() -> void:
	get_tree().quit()

func _on_unplay_2_pressed() -> void:
	get_tree().quit()

func _on_player_selection_pressed() -> void:
	GlobalData.nextscene = load("res://Scenes/Game1.tscn")
	get_tree().change_scene_to_file("res://EatEmUp/Scenes/Menus/PlayerSetup.tscn")


func _on_level_3_pressed() -> void:
	GlobalData.nextscene = load("res://EatEmUp/Scenes/Games/EatEm.tscn")
	get_tree().change_scene_to_file("res://EatEmUp/Scenes/Menus/PlayerSetup.tscn")
