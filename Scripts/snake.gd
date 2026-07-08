extends Node2D
var spine : AIChain
@export var deadzone = 15
@export_range(500,3600,50) var speed :float = 800 
@export var segments : int = 46
@export var segmentsize : float = 25
@export var startlocation : Node2D
@export var stroke_color := Color.DARK_RED
@export	var stroke_width := 4.0
@export	var fill_color := Color8(172, 57, 49) # #AC3931
@export	var eye_color := Color.BLACK
@export var controls : PlayerControls = null
var label : Label
var camera : Camera2D
var tonguetarget : Vector2
var elapsed_time: float = 0.0
var max_tongue_length: float = 65.0 # Maximum extension in pixels
var min_tongue_length: float = 55.0  # Minimum retraction in pixels
var rotation_range: float = 30.0     # Total swing angle (e.g., -15 to +15 degrees)
var rotation_speed: float = 2.0      # How many full swings per second
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spine = AIChain.new()
	#add_child(spine)
	spine.populate(startlocation.position,segments,segmentsize,PI/4)

var last : Vector2 = Vector2.ZERO
func resolve(direction: Vector2, delta:float) -> void:
	if direction != Vector2.ZERO:
		last = direction
	else:
		direction = last
	var headPos = spine.joints[0]
	#var mousePos = get_global_mouse_position()
	var targetDir = direction #headPos.direction_to(mousePos)
	#var absx = abs((mousePos-headPos).x)
	#var absy = abs((mousePos-headPos).y)
	var dspeed = speed * delta
	var targetPos = headPos + (targetDir * dspeed)	
	tonguetarget = headPos + (targetDir * 100)
	elapsed_time += delta
	#if absx < deadzone && absx > -deadzone && absy < deadzone && absy > -deadzone:
	#	return
	label.text = "Mouse:" + str(direction) + "Head" + str(headPos) + "Target:" + str(targetPos)
	spine.resolve(targetPos, dspeed)
	camera.position = targetPos
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
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
	var angle_offset: float = sin(elapsed_time * rotation_speed * 2.0 * PI) * deg_to_rad(rotation_range / 2.0)
	var current_angle: float = base_angle + angle_offset

	# 3. Create the final direction vector from the rotated angle
	var target_dir: Vector2 = Vector2.from_angle(current_angle)

	# 4. Calculate oscillating length (3-second period)
	var length_wave: float = (sin(elapsed_time * (2.0 * PI / 3.0)) + 1.0) / 2.0
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
	
	# === 1. DRAW BODY SEGMENTS INDIVIDUALLY ===
	# Loop backward (Tail to Head) so the head and neck render on top of the tail loops
	for i in range(joint_count - 1, 0, -1):
		var curr_idx = i
		var next_idx = i - 1
		
		# Define 4 corners for this specific body link
		var right_curr = Vector2(get_pos_x(curr_idx, PI/2.0, 0.0), get_pos_y(curr_idx, PI/2.0, 0.0))
		var left_curr  = Vector2(get_pos_x(curr_idx, -PI/2.0, 0.0), get_pos_y(curr_idx, -PI/2.0, 0.0))
		var left_next  = Vector2(get_pos_x(next_idx, -PI/2.0, 0.0), get_pos_y(next_idx, -PI/2.0, 0.0))
		var right_next = Vector2(get_pos_x(next_idx, PI/2.0, 0.0), get_pos_y(next_idx, PI/2.0, 0.0))
		# Cap the very end tip of the tail
		if i == joint_count - 1:
			var segment_points := PackedVector2Array([spine.joints[i], left_next, right_next])		
			#Fill the individual segment box safely
			draw_polygon(segment_points, PackedColorArray([fill_color]))
			draw_line(spine.joints[i], right_next, stroke_color, stroke_width, true)
			draw_line(spine.joints[i], left_next, stroke_color, stroke_width, true)
		else:
			var segment_points := PackedVector2Array([right_curr, left_curr, left_next, right_next])		
			#Fill the individual segment box safely
			draw_polygon(segment_points, PackedColorArray([fill_color]))
			# Draw the left and right outer skins
			draw_line(right_curr, right_next, stroke_color, stroke_width, true)
			draw_line(left_curr, left_next, stroke_color, stroke_width, true)
		
		

	# === 2. DRAW ROUNDED HEAD CAP ===
	var head_points := PackedVector2Array()
	head_points.append(Vector2(get_pos_x(0, PI / 2.0, 0.0), get_pos_y(0, PI / 2.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, PI / 6.0, 0.0), get_pos_y(0, PI / 6.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, 0.0, 0.0), get_pos_y(0, 0.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, -PI / 6.0, 0.0), get_pos_y(0, -PI / 6.0, 0.0)))
	head_points.append(Vector2(get_pos_x(0, -PI / 2.0, 0.0), get_pos_y(0, -PI / 2.0, 0.0)))
	
	draw_polygon(head_points, PackedColorArray([fill_color]))
	draw_polyline(head_points, stroke_color, stroke_width, true)

	# === 3. DRAW SNAKE EYES ===
	var eye_radius := 8.0
	var left_eye_center  := Vector2(get_pos_x(0, PI / 2.0, -6.0), get_pos_y(0, PI / 2.0, -6.0))
	var right_eye_center := Vector2(get_pos_x(0, -PI / 2.0, -6.0), get_pos_y(0, -PI / 2.0, -6.0))
	
	# Left Eye
	draw_circle(left_eye_center, eye_radius, eye_color)
	draw_arc(left_eye_center, eye_radius, 0, TAU, 12, Color.WHITE, 4, true)
	
	# Right Eye
	draw_circle(right_eye_center, eye_radius, eye_color)
	draw_arc(right_eye_center, eye_radius, 0, TAU, 12, Color.WHITE, 4, true)
	
	


func _physics_process(delta: float) -> void:
	if controls == null:
		var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		resolve(random_direction, delta)
	else :
		var h_axis = Input.get_axis(controls.move_left,controls.move_right)
		var v_axis = Input.get_axis(controls.move_up,controls.move_down)
		var direction = Vector2(h_axis,v_axis).normalized()
		resolve(direction, delta)
	queue_redraw()
	#debugDisplay()
	
	
func debugDisplay() -> void:
	spine.queue_redraw()
	
func body_width(i: int) -> float:
	var reduction = 30.0 - (float(i)/12)
	var minsize = 4.0
	match i:
		0:
			return 30.0
		1:
			return 30.0		
		var v when v > (spine.joints.size() - 15):
			var size: float = remap(i, spine.joints.size() - 15, spine.joints.size(),  reduction, minsize)
			size = clamp(size, minsize, reduction)
			return max(minsize, size)
		_:
			return max(minsize, reduction)
			
func get_pos_x(i : int, angleOffset: float, lengthOffset: float) -> float:
	return spine.joints[i].x + cos(spine.angles[i] + angleOffset) * (body_width(i) + lengthOffset)
	
func get_pos_y(i : int, angleOffset: float, lengthOffset: float) -> float:
	return spine.joints[i].y + sin(spine.angles[i] + angleOffset) * (body_width(i) + lengthOffset)
