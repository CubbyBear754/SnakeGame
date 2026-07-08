extends Node2D

@export var p1_label : Label
@export var p2_label : Label
@export var p3_label : Label
@export var p4_label : Label
@export var p1_camera : Camera2D
@export var p2_camera : Camera2D
@export var p3_camera : Camera2D
@export var p4_camera : Camera2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Snake.label = p1_label
	$Snake.camera = p1_camera
	$Snake2.label = p2_label
	$Snake2.camera = p2_camera
	$Snake3.label = p3_label
	$Snake3.camera = p3_camera
	$Snake4.label = p4_label
	$Snake4.camera = p4_camera

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
