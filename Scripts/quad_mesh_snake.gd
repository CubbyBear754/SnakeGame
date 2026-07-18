extends Node2D

@export var deadzone = 15
@export_range(500,3600,50) var speed :float = 800 
@export var stroke_width: float = 4.0
@export var stroke_color: Color = Color.DARK_RED
@export var fill_color: Color = Color.WHITE
@export var eye_color: Color = Color.RED
@export var startlocation : Node2D
@export var segments : int = 46
@export var segmentsize : float = 25
@export var controls : PlayerControls = null
@export var instance : int = 0
var label : Label
var camera : Camera2D
var last_random : float = .0
var angles : float = PI/6
var elapsed_time: float = 0.0

func setcamera(cam : Camera2D) -> void:
	camera = cam
	$MultiMeshInstance2D.camera = cam
	
func _ready() -> void:
	$MultiMeshInstance2D.instance = instance
	$MultiMeshInstance2D.deadzone = deadzone
	$MultiMeshInstance2D.speed = speed
	$MultiMeshInstance2D.stroke_width = stroke_width
	$MultiMeshInstance2D.stroke_color = stroke_color
	$MultiMeshInstance2D.fill_color = fill_color
	$MultiMeshInstance2D.eye_color = eye_color
	$MultiMeshInstance2D.startlocation = startlocation
	$MultiMeshInstance2D.segments = segments
	$MultiMeshInstance2D.segmentsize = segmentsize
	$MultiMeshInstance2D.spine = AIChain.new()
	#add_child(spine)
	$MultiMeshInstance2D.spine.z_index = -1
	$MultiMeshInstance2D.spine.populate(startlocation.position,segments,segmentsize,PI/4)
	
	$MultiMeshInstance2D.spineless = $MultiMeshInstance2D.spine.joints.size() - 15

var moved = .0

func _physics_process(delta: float) -> void:
	if $MultiMeshInstance2D.spine.joints.size() < 2:
		if $MultiMeshInstance2D.spine.joints.size() > 0:
			$MultiMeshInstance2D.spine.clear_joints()
			queue_redraw()
		return
	if moved < 0.3 || controls == null && moved < 0.0001 * speed:
		var direction = startlocation.position.direction_to(Vector2(3500,2000))
		$MultiMeshInstance2D.resolve(direction, delta)
		moved += delta
	elif controls == null : #|| controls.player_index != 0:
		var random_angle = last_random + randf_range(-angles, angles)
		last_random = random_angle
		var random_direction = Vector2.RIGHT.rotated(random_angle)
		$MultiMeshInstance2D.resolve(random_direction, delta)
	else :
		var h_axis = Input.get_axis(controls.move_left,controls.move_right)
		var v_axis = Input.get_axis(controls.move_up,controls.move_down)
		var direction = Vector2(h_axis,v_axis).normalized()
		$MultiMeshInstance2D.resolve(direction, delta)
	#debugDisplay()
	#$MultiMeshInstance2D.update_snake_mesh()
	elapsed_time += delta
	queue_redraw()

func _draw() -> void:
	var points := PackedVector2Array()
	var joint_count : int = $MultiMeshInstance2D.spine.joints.size()
	if joint_count < 2:
		return
	# Draw the main tongue line
	# 1. Find the base angle facing the original target
	var base_pos: Vector2 = $MultiMeshInstance2D.spine.joints[0]
	var base_angle: float = ($MultiMeshInstance2D.tonguetarget - base_pos).angle()

	# 2. Calculate the swing offset using a sine wave
	# Convert range to radians and swing between -half and +half of the range
	var angle_offset: float = sin(elapsed_time * $MultiMeshInstance2D.rstwicebypi) * deg_to_rad($MultiMeshInstance2D.rotation_range / 2.0)
	var current_angle: float = base_angle + angle_offset

	# 3. Create the final direction vector from the rotated angle
	var target_dir: Vector2 = Vector2.from_angle(current_angle)

	# 4. Calculate oscillating length (3-second period)
	var length_wave: float = (sin(elapsed_time * $MultiMeshInstance2D.tauthird) + 1.0) / 2.0
	var current_length: float = lerp($MultiMeshInstance2D.min_tongue_length, $MultiMeshInstance2D.max_tongue_length, length_wave)

	# 5. Calculate the dynamic tongue tip position
	var current_tip: Vector2 = base_pos + (target_dir * current_length)

	# Draw the main tongue line
	draw_line(base_pos, current_tip, Color.GREEN, stroke_width, true)

	# 6. Calculate vectors for the fork based on the new rotated direction
	var tongue_perp: Vector2 = Vector2(-target_dir.y, target_dir.x)
	var fork_length: float = 15.0
	var fork_spread: float = 8.0

	var left_fork: Vector2 = current_tip + (target_dir * fork_length) + (tongue_perp * fork_spread)
	var right_fork: Vector2 = current_tip + (target_dir * fork_length) - (tongue_perp * fork_spread)

	# Draw the two fork lines
	draw_line(current_tip, left_fork, Color.GREEN, stroke_width, true)
	draw_line(current_tip, right_fork, Color.GREEN, stroke_width, true)

	# Draw the two fork lines
	draw_line(current_tip, left_fork, Color.GREEN, stroke_width, true)
	draw_line(current_tip, right_fork, Color.GREEN, stroke_width, true)
	
	# === 2. DRAW ROUNDED HEAD CAP ===
	var head_points := PackedVector2Array()
	head_points.append(Vector2(get_pos_x(0, $MultiMeshInstance2D.halfpi, 0.0), get_pos_y(0, $MultiMeshInstance2D.halfpi, 0.0)))
	head_points.append(Vector2(get_pos_x(0, PI / 6.0, 0.0), get_pos_y(0, PI / 6.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, 0.0, 0.0), get_pos_y(0, 0.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, -PI / 6.0, 0.0), get_pos_y(0, -PI / 6.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, -$MultiMeshInstance2D.halfpi, 0.0), get_pos_y(0, -$MultiMeshInstance2D.halfpi, 0.0)))
	
	draw_polygon(head_points, PackedColorArray([fill_color]))
	# === 3. DRAW SNAKE EYES ===
	var eye_radius := 8.0
	var left_eye_center  := Vector2(get_pos_x(0, $MultiMeshInstance2D.halfpi, -6.0), get_pos_y(0, $MultiMeshInstance2D.halfpi, -6.0))
	var right_eye_center := Vector2(get_pos_x(0, -$MultiMeshInstance2D.halfpi, -6.0), get_pos_y(0, -$MultiMeshInstance2D.halfpi, -6.0))
	
	# Left Eye
	draw_circle(left_eye_center, eye_radius, eye_color)
	draw_arc(left_eye_center, eye_radius, 0, TAU, 12, Color.WHITE, 4, true)
	
	# Right Eye
	draw_circle(right_eye_center, eye_radius, eye_color)
	draw_arc(right_eye_center, eye_radius, 0, TAU, 12, Color.WHITE, 4, true)

func get_pos_x(i : int, angleOffset: float, lengthOffset: float) -> float:
	return $MultiMeshInstance2D.spine.joints[i].x + cos($MultiMeshInstance2D.spine.angles[i] + angleOffset) * (30 + lengthOffset)
	
func get_pos_y(i : int, angleOffset: float, lengthOffset: float) -> float:
	return $MultiMeshInstance2D.spine.joints[i].y + sin($MultiMeshInstance2D.spine.angles[i] + angleOffset) * (30 + lengthOffset)

func Head() -> Vector2:
	if $MultiMeshInstance2D.spine.joints.size() == 0:
		return Vector2(-10000,-10000)
	return $MultiMeshInstance2D.spine.joints[0]
	
func dataset() -> SnakeMesh:
	return $MultiMeshInstance2D

func check_for_hits(incoming_global_position: Vector2) -> int:
	var points = $MultiMeshInstance2D.spine.joints
	# Iterate through the points of your line representing the snake body
	for i in range(1,points.size(),1):
		var global_point_pos = global_position + points[i]		
		# Check if an incoming projectile or damage point hits a specific circle
		if Geometry2D.is_point_in_circle(incoming_global_position, global_point_pos, segmentsize):
			# Cut the snake at point 'i'
			truncate_snake(i)
			return 1
	return check_for_hits_on_lost(incoming_global_position)

func check_for_hits_on_lost(incoming_global_position: Vector2) -> int:
	var lost = $MultiMeshInstance2D.lost
	var result = 0
	var totruncate : Array[int] = []
	for i in range(lost.size()):
		var global_point_pos = global_position + lost[i]		
		# Check if an incoming projectile or damage point hits a specific circle
		if Geometry2D.is_point_in_circle(incoming_global_position, global_point_pos, segmentsize):
			# Cut the snake at point 'i'
			totruncate.append(i)
			result += 1
	if result > 0:
		truncate_lost(totruncate)
	return result

func truncate_lost(cut_indexs: Array[int]) -> void:
	for index in range(cut_indexs.size(),1,-1):
		$MultiMeshInstance2D.lost.remove_at(cut_indexs[index])

func truncate_snake(cut_index: int) -> void:
	# Shrink the Line2D array to only include points from the head to the cut_index	
	if cut_index == 0:
		return 
	var was = $MultiMeshInstance2D.spine.joints.size()
	$MultiMeshInstance2D.lost.append_array($MultiMeshInstance2D.spine.joints.slice(cut_index + 1, was))
	$MultiMeshInstance2D.spine.joints = $MultiMeshInstance2D.spine.joints.slice(0, cut_index)
	$MultiMeshInstance2D.spine.angles = $MultiMeshInstance2D.spine.angles.slice(0, cut_index)
	label.text = str($MultiMeshInstance2D.spine.joints.size())
	#$MultiMeshInstance2D.eattail(cut_index,was)

func addhits(hits : Array[int]) -> void:
	if $MultiMeshInstance2D.spine.joints.size() < 2:
		return
	var total: int = hits.reduce(func(accum, number): return accum + number, 0)
	if total > 0:
		for i in range(total):
			$MultiMeshInstance2D.spine.joints.append(Vector2(0,0))
			$MultiMeshInstance2D.spine.angles.append(0.0)
		label.text = str($MultiMeshInstance2D.spine.joints.size())
