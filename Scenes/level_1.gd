extends Node2D

@export var p1_label : Label
@export var p2_label : Label
@export var p3_label : Label
@export var p4_label : Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Snake.label = p1_label
	$Snake2.label = p2_label
	$Snake3.label = p3_label
	$Snake4.label = p4_label
	var snakes = [$Snake, $Snake2, $Snake3, $Snake4]
	for i in range(PlayersData.players.size()):
		var controls = PlayersData.players[i]
		var snake = snakes[i]
		snake.controls = controls
		
	
