extends MultiMeshInstance2D
class_name SnakeMesh
var deadzone = 15
var speed :float = 800 
var stroke_width: float = 4.0
var stroke_color: Color = Color.DARK_RED
var fill_color: Color = Color.WHITE
var eye_color: Color = Color.RED
var startlocation : Node2D
var segments : int = 46
var segmentsize : float = 25
var camera : Camera2D = null
var spine : AIChain
var tauthird = (2.0 * PI / 3.0)
var angles = PI/6
var halfpi = PI/2 
var rstwicebypi = 0.0
var spineless = 0
var tonguetarget : Vector2
var max_tongue_length: float = 65.0 # Maximum extension in pixels
var min_tongue_length: float = 55.0  # Minimum retraction in pixels
var rotation_range: float = 30.0     # Total swing angle (e.g., -15 to +15 degrees)
var rotation_speed: float = 2.0      # How many full swings per second
var min_limit = Vector2(0, 0)
var max_limit = Vector2(7000, 4000)
var centerofmap = Vector2(3500,2000)
var borderrect : Rect2
var instance = 0

var lost : Array[Vector2] = []
var last : Vector2 = Vector2.ZERO

func _ready() -> void:
	multimesh.instance_count = 8000
	z_index = -10
	rstwicebypi = rotation_speed * 2.0 * PI
	borderrect = Rect2(min_limit,max_limit)
	
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
	targetPos = targetPos.clamp(min_limit, max_limit)
	tonguetarget = headPos + (targetDir * 100)
	
	#if absx < deadzone && absx > -deadzone && absy < deadzone && absy > -deadzone:
	#	return
	#label.text = "Mouse:" + str(direction) + "Head" + str(headPos) + "Target:" + str(targetPos)
	spine.resolve_async(targetPos, dspeed)
	camera.position = targetPos
#todo rework everything back into the quad mesh snake and add the multimesh to the level
func update_snake_mesh(datasets : Array[SnakeMesh], delta : float) -> void:
	var current_instance_index: int = 0
	var outline_thickness: float = 0.2
	for dataset in datasets:
	
		var positions: Array[Vector2] = dataset.spine.joints
		var color_to_assign: Color = dataset.fill_color
		var custom_data = Color(dataset.stroke_color.r, dataset.stroke_color.g, dataset.stroke_color.b, outline_thickness)
		var diameter = segmentsize * 1.5	
		var offset = Vector2(diameter/2,diameter/2)
		for i in range(dataset.lost.size()-1, -1, -1):
			var pos = dataset.lost[i]
			if not borderrect.has_point(pos):
				pos = pos.lerp(centerofmap, delta/8)
				dataset.lost[i] = pos
			var xform: Transform2D = Transform2D.IDENTITY
			xform = xform.scaled(Vector2(diameter, diameter))
			xform.origin = pos - offset
			multimesh.set_instance_transform_2d(current_instance_index, xform) 
			multimesh.set_instance_color(current_instance_index, Color.DARK_GRAY)		
			# Pass the outline data to the shader
			multimesh.set_instance_custom_data(current_instance_index, Color(1,0.2,0.2,0.2))
			current_instance_index += 1
		
		# Batch update this specific player's 1,000 circles
		for i in range(positions.size()-1, -1, -1):
			var pos = positions[i]	
			var xform: Transform2D = Transform2D.IDENTITY
			if i == 0 :
				xform = xform.scaled(Vector2(75, 75))
				xform.origin = pos - Vector2(35.5,35.5)
			else:
				xform = xform.scaled(Vector2(diameter, diameter))
				xform.origin = pos - offset
			multimesh.set_instance_transform_2d(current_instance_index, xform) 
			multimesh.set_instance_color(current_instance_index, color_to_assign)		
			# Pass the outline data to the shader
			multimesh.set_instance_custom_data(current_instance_index, custom_data)
			current_instance_index += 1
	
	if current_instance_index < multimesh.instance_count:
		multimesh.visible_instance_count = current_instance_index

#func eattail(i : int, was : int) -> void:
	#var eatfrom = (1000 * instance) + i	
	#while eatfrom < was:
		#multimesh.set_instance_transform(eatfrom, Transform2D.IDENTITY)
		#eatfrom += 1

#func update_snake_mesh() -> void:
	#var joint_count: int = spine.joints.size()
	#if joint_count < 2:
		#multimesh.instance_count = 0
		#return
#
	## --- 1. CALCULATE INSTANCE POOL BUFFER SIZE ---
	## Tongue: 3 lines
	## Tail Cap: 2 lines
	## Body segments: (joint_count - 2) * 2 skin lines
	## Head Cap: 1 filled polygon (drawn as 3 triangles using quads) + 4 outline segments
	## Eyes: 2 solid squares + 2 hollow outlines (drawn as 4 segments each)
	#var total_segments: int = 3 + 2 + ((joint_count - 2) * 2) + 7 + 10
	#
	#if multimesh.instance_count != total_segments:
		#multimesh.instance_count = total_segments
#
	#var idx: int = 0
#
	## --- 2. TONGUE GEOMETRY ---
	#var base_pos: Vector2 = spine.joints[0]
	#var base_angle: float = (tonguetarget - base_pos).angle()
	#var angle_offset: float = sin(elapsed_time * rstwicebypi) * deg_to_rad(rotation_range / 2.0)
	#var current_angle: float = base_angle + angle_offset
	#var target_dir: Vector2 = Vector2.from_angle(current_angle)
	#var length_wave: float = (sin(elapsed_time * tauthird) + 1.0) / 2.0
	#var current_length: float = lerp(min_tongue_length, max_tongue_length, length_wave)
	#var current_tip: Vector2 = base_pos + (target_dir * current_length)
#
	## Draw Main Tongue Line
	#_add_line_instance(idx, base_pos, current_tip, stroke_width, Color.GREEN); idx += 1
#
	#var tongue_perp: Vector2 = Vector2(-target_dir.y, target_dir.x)
	#var fork_length: float = 15.0
	#var fork_spread: float = 8.0
	#var left_fork: Vector2 = current_tip + (target_dir * fork_length) + (tongue_perp * fork_spread)
	#var right_fork: Vector2 = current_tip + (target_dir * fork_length) - (tongue_perp * fork_spread)
#
	## Draw Left/Right Tongue Forks
	#_add_line_instance(idx, current_tip, left_fork, stroke_width, Color.GREEN); idx += 1
	#_add_line_instance(idx, current_tip, right_fork, stroke_width, Color.GREEN); idx += 1
#
	## --- 3. SNAKE BODY SEGMENTS ---
	#for i in range(joint_count - 1, 0, -1):
		#var curr_idx = i
		#var next_idx = i - 1
		#
		#var right_curr = Vector2(get_pos_x(curr_idx, halfpi, 0.0), get_pos_y(curr_idx, halfpi, 0.0))
		#var left_curr  = Vector2(get_pos_x(curr_idx, -halfpi, 0.0), get_pos_y(curr_idx, -halfpi, 0.0))
		#var left_next  = Vector2(get_pos_x(next_idx, -halfpi, 0.0), get_pos_y(next_idx, -halfpi, 0.0))
		#var right_next = Vector2(get_pos_x(next_idx, halfpi, 0.0), get_pos_y(next_idx, halfpi, 0.0))
		#
		#if i == joint_count - 1:
			#_add_line_instance(idx, spine.joints[i], right_next, stroke_width, stroke_color); idx += 1
			#_add_line_instance(idx, spine.joints[i], left_next, stroke_width, stroke_color); idx += 1
		#else:
			#_add_line_instance(idx, right_curr, right_next, stroke_width, stroke_color); idx += 1
			#_add_line_instance(idx, left_curr, left_next, stroke_width, stroke_color); idx += 1
#
	## --- 4. ROUNDED HEAD CAP OUTCROP ---
	#var h_pts: Array[Vector2] = [
		#Vector2(get_pos_x(0, halfpi, 0.0), get_pos_y(0, halfpi, 0.0)),
		#Vector2(get_pos_x(0, PI / 6.0, 0.0), get_pos_y(0, PI / 6.0, 0.0)),
		#Vector2(get_pos_x(0, 0.0, 0.0), get_pos_y(0, 0.0, 0.0)),
		#Vector2(get_pos_x(0, -PI / 6.0, 0.0), get_pos_y(0, -PI / 6.0, 0.0)),
		#Vector2(get_pos_x(0, -halfpi, 0.0), get_pos_y(0, -halfpi, 0.0))
	#]
	#
	## Simulate Fill Polygon by stitching quads to center pivot point
	#var center_head: Vector2 = spine.joints[0]
	#for i in range(h_pts.size() - 1):
		#_add_line_instance(idx, center_head, (h_pts[i] + h_pts[i+1])/2.0, (h_pts[i] - h_pts[i+1]).length(), fill_color); idx += 1
	#
	## Head Polyline Stroke outlines
	#for i in range(h_pts.size() - 1):
		#_add_line_instance(idx, h_pts[i], h_pts[i+1], stroke_width, stroke_color); idx += 1
#
	## --- 5. SNAKE EYES ---
	#var eye_radius := 8.0
	#var left_eye_center  := Vector2(get_pos_x(0, halfpi, -6.0), get_pos_y(0, halfpi, -6.0))
	#var right_eye_center := Vector2(get_pos_x(0, -halfpi, -6.0), get_pos_y(0, -halfpi, -6.0))
	#
	## Render Left and Right Solid Eye Cores
	#_add_box_instance(idx, left_eye_center, Vector2(eye_radius * 1.5, eye_radius * 1.5), eye_color); idx += 1
	#_add_box_instance(idx, right_eye_center, Vector2(eye_radius * 1.5, eye_radius * 1.5), eye_color); idx += 1
	#
	## Render Left Eye Rings (Approximated clear square outline)
	#_add_box_outline(idx, left_eye_center, eye_radius * 2.0, 4.0, Color.WHITE); idx += 4
	#_add_box_outline(idx, right_eye_center, eye_radius * 2.0, 4.0, Color.WHITE); idx += 4
#
## --- HELPER FORMULAIC GRAPHICS BUILDERS ---
#
func _add_line_instance(instance_id: int, from: Vector2, to: Vector2, width: float, color: Color) -> void:
	var diff: Vector2 = to - from
	var length: float = diff.length()
	var angle: float = diff.angle()
	
	# Scale X along line distance, scale Y by stroke thickness width
	var scale: Vector2 = Vector2(length, width)
	# Center alignment adjustment offset so lines draw correctly from target source
	var offset_from: Vector2 = from - Vector2(0, width / 2.0).rotated(angle)
	
	var xform: Transform2D = Transform2D(angle, scale, 0.0, offset_from)
	multimesh.set_instance_transform_2d(instance_id, xform)
	multimesh.set_instance_color(instance_id, color)

#func _add_box_instance(instance_id: int, center: Vector2, size: Vector2, color: Color) -> void:
	#var xform: Transform2D = Transform2D(0.0, size, 0.0, center - (size / 2.0))
	#multimesh.set_instance_transform_2d(instance_id, xform)
	#multimesh.set_instance_color(instance_id, color)
#
#func _add_box_outline(start_idx: int, center: Vector2, size: float, thickness: float, color: Color) -> void:
	#var h_size = size / 2.0
	#var tl = center + Vector2(-h_size, -h_size)
	#var tr = center + Vector2(h_size, -h_size)
	#var bl = center + Vector2(-h_size, h_size)
	#var br = center + Vector2(h_size, h_size)
	#
	#_add_line_instance(start_idx,     tl, tr, thickness, color)
	#_add_line_instance(start_idx + 1, tr, br, thickness, color)
	#_add_line_instance(start_idx + 2, br, bl, thickness, color)
	#_add_line_instance(start_idx + 3, bl, tl, thickness, color)
#
## Dummy placeholders linking your dynamic trigonometric offsets
#func get_pos_x(_idx: int, _angle: float, _offset: float) -> float: return position.x
#func get_pos_y(_idx: int, _angle: float, _offset: float) -> float: return position.y
