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

var safe_vector = Vector2(-10000,-10000)
func _physics_process(delta: float) -> void:
	var head1 = $QuadMeshSnake.Head() if is_instance_valid($QuadMeshSnake) else safe_vector
	var head2 = $QuadMeshSnake2.Head() if is_instance_valid($QuadMeshSnake2) else safe_vector
	var head3 = $QuadMeshSnake3.Head() if is_instance_valid($QuadMeshSnake3) else safe_vector
	var head4 = $QuadMeshSnake4.Head() if is_instance_valid($QuadMeshSnake4) else safe_vector
	if is_instance_valid($QuadMeshSnake):
		$QuadMeshSnake.check_for_hits(head2)
		$QuadMeshSnake.check_for_hits(head3)
		$QuadMeshSnake.check_for_hits(head4)
	if is_instance_valid($QuadMeshSnake2):
		$QuadMeshSnake2.check_for_hits(head1)
		$QuadMeshSnake2.check_for_hits(head3)
		$QuadMeshSnake2.check_for_hits(head4)
	if is_instance_valid($QuadMeshSnake3):
		$QuadMeshSnake3.check_for_hits(head2)
		$QuadMeshSnake3.check_for_hits(head1)
		$QuadMeshSnake3.check_for_hits(head4)
	if is_instance_valid($QuadMeshSnake4):
		$QuadMeshSnake4.check_for_hits(head2)
		$QuadMeshSnake4.check_for_hits(head3)
		$QuadMeshSnake4.check_for_hits(head1)
