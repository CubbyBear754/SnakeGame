extends Node2D


class_name AIChain

var my_thread: Thread


var joints: Array[Vector2] = []
var angles: Array[float] = []
var link_size: int
var angle_constraint: float

func clear_joints() -> void:
	joints = []

# Constructor / Initialiser
func populate(origin: Vector2, joint_count: int, p_link_size: int, p_angle_constraint: float) -> void:
	var target_location = Vector2(3500, 2000)
	var direction = origin.direction_to(target_location) * link_size
	
	self.link_size = p_link_size
	self.angle_constraint = p_angle_constraint
	
	joints.append(origin)
	angles.append(0.0)
	
	
	for i in range(1, joint_count):
		# Generates next joint relative to previous joint position
		joints.append(joints[i - 1] - direction)
		angles.append(0.0)
	
	my_thread = Thread.new() # Initialize the thread object

func resolve_async(pos: Vector2, speed: float) -> void:
	my_thread.start(resolve.bind(pos,speed))
	my_thread.wait_to_finish()
# Forward kinematics solver with angle constraints
func resolve(pos: Vector2, speed: float) -> void:
	
	#angles[0] = (pos - joints[0]).angle()
	#joints[0] = pos
	
	# 1. Calculate the target angle the joint wants to look at
	var target_angle: float = (pos - joints[0]).angle()
	
	# 2. Get the shortest angular distance between current angle and target angle
	var angle_diff: float = angle_difference(angles[0], target_angle)
	
	# 3. Clamp the movement so it cannot exceed your maximum speed per frame
	var clamped_diff: float = clamp(angle_diff, -0.2, 0.2)
	
	# 4. Apply the constrained change to the base angle
	angles[0] += clamped_diff
	
	# 5. Lock the joint to the target position
	joints[0]  += Vector2.from_angle(angles[0]) * speed
	
	for i in range(1, joints.size()):
		var cur_angle: float = (joints[i - 1] - joints[i]).angle()
		angles[i] = constrain_angle(cur_angle, angles[i - 1], angle_constraint)
		joints[i] = joints[i - 1] - Vector2.from_angle(angles[i]) * link_size

# FABRIK inverse kinematics solver
func fabrik_resolve(pos: Vector2, anchor: Vector2) -> void:
	# Forward pass
	joints[0] = pos
	for i in range(1, joints.size()):
		joints[i] = constrain_distance(joints[i], joints[i - 1], link_size)
	
	# Backward pass
	joints[joints.size() - 1] = anchor
	for i in range(joints.size() - 2, -1, -1):
		joints[i] = constrain_distance(joints[i], joints[i + 1], link_size)

# Built-in Godot node function for rendering graphics
func _draw() -> void:
	if joints.is_empty():
		return
		
	# Draw lines and circles between joints
	for i in range(joints.size() - 1):
		var start_joint: Vector2 = joints[i]
		var end_joint: Vector2 = joints[i + 1]
		
		# Draw segment line (thickness 4.0 pixels)
		draw_line(start_joint, end_joint, Color.BLACK, 4.0)
		
		# Draw joint visual indicators
		draw_circle(joints[i], 30, Color.BLACK)

# Helper placeholder logic for distance locking
func constrain_distance(point: Vector2, target: Vector2, distance: float) -> Vector2:
	return target + (point - target).normalized() * distance

# Helper placeholder logic for angle clamping
func constrain_angle(angle: float, anchor: float, constraint: float) -> float:
	var diff: float = angle_difference(anchor, angle)
	return anchor + clamp(diff, -constraint, constraint)
