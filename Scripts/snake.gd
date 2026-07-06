extends Node2D

var spine : AIChain
var deadzone = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spine = AIChain.new()
	#add_child(spine)
	spine.populate(Vector2.ZERO,300,28,PI/4)

func resolve(delta:float) -> void:
	var headPos = spine.joints[0]
	var mousePos = get_global_mouse_position()
	var targetDir = headPos.direction_to(mousePos)
	var absx = abs((mousePos-headPos).x)
	var absy = abs((mousePos-headPos).y)
	if absx < deadzone && absx > -deadzone && absy < deadzone && absy > -deadzone:
		return
	var speed = 1800 * delta
	var targetPos = headPos + (targetDir * speed)
	
	%Label.text = "Mouse:" + str(mousePos) + "Head" + str(headPos) + "Target:" + str(targetPos)
	spine.resolve(targetPos, speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _draw() -> void:
	# Styling setup
	var stroke_color := Color.DARK_RED
	var stroke_width := 4.0
	var fill_color := Color8(172, 57, 49) # #AC3931
	var eye_color := Color.BLACK
	
	var points := PackedVector2Array()
	var joint_count : int = spine.joints.size()
	if joint_count < 2:
		return

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
	resolve(delta)
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
