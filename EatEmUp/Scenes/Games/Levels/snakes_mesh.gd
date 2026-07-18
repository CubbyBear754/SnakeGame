extends MultiMeshInstance2D

func _ready() -> void:
	multimesh.instance_count = 8000
	#z_index = 1
	
func update_snake_mesh(datasets : Array[Snake], delta : float) -> void:
	var current_instance_index: int = 0
	var outline_thickness: float = 0.2
	for dataset in datasets:
		var positions: Array[Vector2] = dataset.spine.joints
		var color_to_assign: Color = dataset.fill_color
		var custom_data = Color(dataset.stroke_color.r, dataset.stroke_color.g, dataset.stroke_color.b, outline_thickness)
		var diameter = dataset.segmentsize * 1.5	
		var offset = Vector2(diameter/2,diameter/2)
		for i in range(dataset.lost.size()-1, -1, -1):
			var pos = dataset.lost[i]
			if not GlobalData.borderrect.has_point(pos):
				pos = pos.lerp(GlobalData.centerofmap, delta/8)
				dataset.lost[i] = pos
			var xform: Transform2D = Transform2D.IDENTITY
			xform = xform.scaled(Vector2(diameter, diameter))
			xform.origin = pos # - offset
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
				xform.origin = pos #- Vector2(35.5,35.5)
			else:
				xform = xform.scaled(Vector2(diameter, diameter))
				xform.origin = pos #- offset
			multimesh.set_instance_transform_2d(current_instance_index, xform) 
			multimesh.set_instance_color(current_instance_index, color_to_assign)		
			# Pass the outline data to the shader
			multimesh.set_instance_custom_data(current_instance_index, custom_data)
			current_instance_index += 1
	
	if current_instance_index < multimesh.instance_count:
		multimesh.visible_instance_count = current_instance_index
