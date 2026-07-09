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
	$QuadMeshSnake.label = p1_label
	$QuadMeshSnake.setcamera(p1_camera)
	$QuadMeshSnake2.label = p2_label
	$QuadMeshSnake2.setcamera(p2_camera)
	$QuadMeshSnake3.label = p3_label
	$QuadMeshSnake3.setcamera(p3_camera)
	$QuadMeshSnake4.label = p4_label
	$QuadMeshSnake4.setcamera(p4_camera)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
