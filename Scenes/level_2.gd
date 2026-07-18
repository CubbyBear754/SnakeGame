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
	var snakes = [$QuadMeshSnake, $QuadMeshSnake2, $QuadMeshSnake3, $QuadMeshSnake4]
	for i in range(GlobalData.players.size()):
		var controls = GlobalData.players[i]
		var snake = snakes[i]
		snake.controls = controls
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var safe_vector = Vector2(-10000,-10000)
func _physics_process(delta: float) -> void:
	var head1 = $QuadMeshSnake.Head() if is_instance_valid($QuadMeshSnake) else safe_vector
	var head2 = $QuadMeshSnake2.Head() if is_instance_valid($QuadMeshSnake2) else safe_vector
	var head3 = $QuadMeshSnake3.Head() if is_instance_valid($QuadMeshSnake3) else safe_vector
	var head4 = $QuadMeshSnake4.Head() if is_instance_valid($QuadMeshSnake4) else safe_vector
	var oneshits : Array[int] = []
	var twoshits : Array[int] = []
	var threeshits : Array[int] = []
	var fourshits : Array[int] = []
	var datasets : Array[SnakeMesh]
	
	if is_instance_valid($QuadMeshSnake):
		oneshits.append($QuadMeshSnake.check_for_hits_on_lost(head1))
		twoshits.append($QuadMeshSnake.check_for_hits(head2))
		threeshits.append($QuadMeshSnake.check_for_hits(head3))
		fourshits.append($QuadMeshSnake.check_for_hits(head4))
		datasets.append($QuadMeshSnake.dataset())
	if is_instance_valid($QuadMeshSnake2):
		twoshits.append($QuadMeshSnake2.check_for_hits_on_lost(head2))
		oneshits.append($QuadMeshSnake2.check_for_hits(head1))
		threeshits.append($QuadMeshSnake2.check_for_hits(head3))
		fourshits.append($QuadMeshSnake2.check_for_hits(head4))
		datasets.append($QuadMeshSnake2.dataset())
	if is_instance_valid($QuadMeshSnake3):
		threeshits.append($QuadMeshSnake3.check_for_hits_on_lost(head3))
		twoshits.append($QuadMeshSnake3.check_for_hits(head2))
		oneshits.append($QuadMeshSnake3.check_for_hits(head1))
		fourshits.append($QuadMeshSnake3.check_for_hits(head4))
		datasets.append($QuadMeshSnake3.dataset())
	if is_instance_valid($QuadMeshSnake4):
		fourshits.append($QuadMeshSnake4.check_for_hits_on_lost(head4))
		twoshits.append($QuadMeshSnake4.check_for_hits(head2))
		threeshits.append($QuadMeshSnake4.check_for_hits(head3))
		oneshits.append($QuadMeshSnake4.check_for_hits(head1))
		datasets.append($QuadMeshSnake4.dataset())
	
	if is_instance_valid($QuadMeshSnake):
		$QuadMeshSnake.dataset().update_snake_mesh(datasets,delta)
	elif is_instance_valid($QuadMeshSnake2):
		$QuadMeshSnake2.dataset().update_snake_mesh(datasets,delta)
	elif is_instance_valid($QuadMeshSnake3):
		$QuadMeshSnake3.dataset().update_snake_mesh(datasets,delta)
	elif is_instance_valid($QuadMeshSnake4):
		$QuadMeshSnake4.dataset().update_snake_mesh(datasets,delta)
	
	if is_instance_valid($QuadMeshSnake):
		$QuadMeshSnake.addhits(oneshits)
	if is_instance_valid($QuadMeshSnake2):
		$QuadMeshSnake2.addhits(twoshits)
	if is_instance_valid($QuadMeshSnake3):
		$QuadMeshSnake3.addhits(threeshits)
	if is_instance_valid($QuadMeshSnake4):
		$QuadMeshSnake4.addhits(fourshits)
	
	
