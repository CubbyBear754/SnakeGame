extends Node2D
class_name Snake
@export var deadzone = 15
@export_range(500,3600,50) var speed :float = 500 
@export var stroke_width: float = 4.0
@export var stroke_color: Color = Color.DARK_RED
@export var fill_color: Color = Color.WHITE
@export var eye_color: Color = Color.RED
@export var startlocation : Node2D
@export var segments : int = 46
@export var segmentsize : float = 25
@export var controls : PlayerControls = null
@export_range(50,200,5) var max_tongue_length: float = 65.0
@export_range(25,100,5) var min_tongue_length: float = 55.0

var spineless
var label : Label
var last_random : float = .0
var elapsed_time: float = 0.0
var spine : AIChain
var tonguetarget : Vector2
var lost : Array[Vector2] = []
var last : Vector2 = Vector2.ZERO
var moved = .0
	
func _ready() -> void:
	spine = AIChain.new()
	#add_child(spine)
	spine.z_index = -1
	spine.populate(startlocation.position,segments,segmentsize,PI/4)	
	spineless = spine.joints.size() - 15

func _physics_process(delta: float) -> void:
	if spine.joints.size() < 2:
		if spine.joints.size() > 0:
			lost.append_array(spine.joints)
			if is_instance_valid(label):
				label.text = "DEAD"
			spine.clear_joints()
			queue_redraw()
		return
	if moved < 0.3 || controls == null && moved < 0.0001 * speed:
		var direction = startlocation.position.direction_to(Vector2(3500,2000))
		resolve(direction, delta)
		moved += delta
	elif controls == null : #|| controls.player_index != 0:
		var random_angle = last_random + randf_range(-GlobalData.angles, GlobalData.angles)
		last_random = random_angle
		var random_direction = Vector2.RIGHT.rotated(random_angle)
		resolve(random_direction, delta)
	else :
		var h_axis = Input.get_axis(controls.move_left,controls.move_right)
		var v_axis = Input.get_axis(controls.move_up,controls.move_down)
		var direction = Vector2(h_axis,v_axis).normalized()
		resolve(direction, delta)
	#debugDisplay()
	elapsed_time += delta
	queue_redraw()

func _draw() -> void:
	var points := PackedVector2Array()
	var joint_count : int = spine.joints.size()
	if joint_count < 2:
		return
	# Draw the main tongue line
	# 1. Find the base angle facing the original target
	var base_pos: Vector2 = spine.joints[0]
	var base_angle: float = (tonguetarget - base_pos).angle()

	# 2. Calculate the swing offset using a sine wave
	# Convert range to radians and swing between -half and +half of the range
	var angle_offset: float = sin(elapsed_time * GlobalData.rstwicebypi) * deg_to_rad(GlobalData.rotation_range / 2.0)
	var current_angle: float = base_angle + angle_offset

	# 3. Create the final direction vector from the rotated angle
	var target_dir: Vector2 = Vector2.from_angle(current_angle)

	# 4. Calculate oscillating length (3-second period)
	var length_wave: float = (sin(elapsed_time * GlobalData.tauthird) + 1.0) / 2.0
	var current_length: float = lerp(min_tongue_length, max_tongue_length, length_wave)

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
	head_points.append(Vector2(get_pos_x(0, GlobalData.halfpi, 0.0), get_pos_y(0, GlobalData.halfpi, 0.0)))
	head_points.append(Vector2(get_pos_x(0, PI / 6.0, 0.0), get_pos_y(0, PI / 6.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, 0.0, 0.0), get_pos_y(0, 0.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, -PI / 6.0, 0.0), get_pos_y(0, -PI / 6.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, -GlobalData.halfpi, 0.0), get_pos_y(0, -GlobalData.halfpi, 0.0)))
	
	draw_polygon(head_points, PackedColorArray([fill_color]))
	# === 3. DRAW SNAKE EYES ===
	var eye_radius := 8.0
	var left_eye_center  := Vector2(get_pos_x(0, GlobalData.halfpi, -6.0), get_pos_y(0, GlobalData.halfpi, -6.0))
	var right_eye_center := Vector2(get_pos_x(0, -GlobalData.halfpi, -6.0), get_pos_y(0, -GlobalData.halfpi, -6.0))
	
	# Left Eye
	draw_circle(left_eye_center, eye_radius, eye_color)
	draw_arc(left_eye_center, eye_radius, 0, TAU, 12, Color.WHITE, 4, true)
	
	# Right Eye
	draw_circle(right_eye_center, eye_radius, eye_color)
	draw_arc(right_eye_center, eye_radius, 0, TAU, 12, Color.WHITE, 4, true)

func resolve(direction: Vector2, delta:float) -> void:
	if direction != Vector2.ZERO:
		last = direction
	else:
		direction = last
	var headPos = spine.joints[0]
	var targetDir = direction
	var dspeed = speed * delta
	var targetPos = headPos + (targetDir * dspeed)	
	targetPos = targetPos.clamp(GlobalData.min_limit, GlobalData.max_limit)
	tonguetarget = headPos + (targetDir * 100)
	spine.resolve_async(targetPos, dspeed)
	
func get_pos_x(i : int, angleOffset: float, lengthOffset: float) -> float:
	return spine.joints[i].x + cos(spine.angles[i] + angleOffset) * (30 + lengthOffset)
	
func get_pos_y(i : int, angleOffset: float, lengthOffset: float) -> float:
	return spine.joints[i].y + sin(spine.angles[i] + angleOffset) * (30 + lengthOffset)

func Head() -> Vector2:
	if spine.joints.size() == 0:
		return Vector2(-10000,-10000)
	return spine.joints[0]

func check_for_hits(incoming_global_position: Vector2) -> int:
	var points = spine.joints
	for i in range(1,points.size(),1):
		var global_point_pos = global_position + points[i]
		if Geometry2D.is_point_in_circle(incoming_global_position, global_point_pos, segmentsize):
			truncate_snake(i)
			return 1
	return check_for_hits_on_lost(incoming_global_position)

func check_for_hits_on_lost(incoming_global_position: Vector2) -> int:
	var result = 0
	var totruncate : Array[int] = []
	for i in range(lost.size()):
		var global_point_pos = global_position + lost[i]
		if Geometry2D.is_point_in_circle(incoming_global_position, global_point_pos, segmentsize):
			totruncate.append(i)
			result += 1
	if result > 0:
		truncate_lost(totruncate)
	return result

func truncate_lost(cut_indexs: Array[int]) -> void:
	for index in range(cut_indexs.size()-1,-1,-1):
		lost.remove_at(cut_indexs[index])

func truncate_snake(cut_index: int) -> void:
	if cut_index == 0:
		return 
	var was = spine.joints.size()
	lost.append_array(spine.joints.slice(cut_index + 1, was))
	spine.joints = spine.joints.slice(0, cut_index)
	spine.angles = spine.angles.slice(0, cut_index)	
	if is_instance_valid(label):
		label.text = str(spine.joints.size())

func addhits(hits : Array[int]) -> void:
	if spine.joints.size() < 2:
		return
	var total: int = hits.reduce(func(accum, number): return accum + number, 0)
	if total > 0:
		for i in range(total):
			spine.joints.append(Vector2(0,0))
			spine.angles.append(0.0)
		if is_instance_valid(label):
			label.text = str(spine.joints.size())
			
func gettotal() -> int:
	return spine.joints.size() + lost.size()
