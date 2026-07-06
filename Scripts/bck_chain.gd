class_name Chain
extends Node2D

var joints: Array[Vector2]
var linkSize: int
# Only used in non-FABRIK resolution
var angles: Array[float]
var angleConstraint: float #Max angle diff between two adjacent joints, higher = loose, lower = rigid
func _init():
	pass
func new_chain_simple(origin: Vector2, jointCount: int, _linkSize: int ):
	new_chain_with_angle(origin, jointCount, _linkSize, TAU)

func new_chain_with_angle(origin: Vector2, jointCount: int, _linkSize: int, _angleConstraint: float):
	linkSize = _linkSize
	angleConstraint = _angleConstraint
	joints = []
	angles = []
	joints.append(origin)
	angles.append(.0)
	for i in range(1,jointCount):
		var joint = joints[i -1] + Vector2(0,linkSize)
		joints.append(joint)
		angles.append(.0)

func resolve(pos: Vector2, delta: float) -> void:
	#this is radians may need degrees
	angles.set(0, rad_to_deg(joints[0].direction_to(pos).angle()))
	joints.set(0, pos)
	for i in range(1,joints.size()):
		var curAngle = rad_to_deg(joints[i].direction_to(joints[i-1]).angle())
		angles.set(i, constrainAngle(curAngle, angles[i -1], angleConstraint))
		var targetPos = joints[i-1] - (Vector2.from_angle(angles[i])*linkSize)
		if i == 1:
			%Label.text += "Joint" + str(targetPos)
		joints.set(i, targetPos)
		
func fabrikResolve(pos: Vector2, anchor: Vector2) -> void:
	joints.set(0,pos)
	#Forward
	for i in range(1,joints.size()):
		joints.set(i,constrainDistance(joints[i], joints[i-1], linkSize))
	#Backward
	for i in range(joints.size()-2 ,0,-1):
		joints.set(i, constrainDistance(joints[i], joints[i+1], linkSize))

func _draw() -> void:
	var line_color = Color.AQUAMARINE
	var line_width = 5.0
	
	for i in range(0,joints.size()-1):
		var start_point : Vector2 = joints[i]
		var end_point : Vector2 = joints[i+1]
		draw_line(start_point, end_point, line_color, line_width)
	
	#for i in range(0,joints.size()):
		#draw_ellipse(joints[i],32,32,Color.BLUE_VIOLET)
		
func constrainAngle(angle: float, anchor: float, constraint: float) -> float:
	if abs(relativeAngleDiff(angle,anchor)) <= constraint:
		return simplifyAngle(angle)
	if relativeAngleDiff(angle, anchor) > constraint:
		return simplifyAngle(anchor - constraint)
	return simplifyAngle(anchor + constraint)
	
func relativeAngleDiff(angle: float, anchor: float ) -> float:
	return PI - simplifyAngle(angle + PI - anchor)
	
func simplifyAngle(angle: float) -> float:
	while angle >= TAU:
		angle -= TAU
	while angle < 0:
		angle += TAU
	return angle;
	
func constrainDistance(pos: Vector2, anchor: Vector2, constraint : float) -> Vector2:
	return anchor + (pos - anchor).limit_length(constraint)
