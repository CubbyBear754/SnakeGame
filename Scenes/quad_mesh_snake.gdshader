shader_type canvas_item;

//void fragment() {
    //// Calculate distance from the center of the quad mesh
    //float dist = distance(UV, vec2(0.5));
    //
    //// Smooth the edges to avoid pixelation/aliasing
    //float alpha = smoothstep(0.5, 0.48, dist);
    //
    //// Mix the vertex color (assigned per instance in GDScript) with the alpha mask
    //COLOR = vec4(COLOR.rgb, COLOR.a * alpha);
//}
// Create a varying to pass data from vertex to fragment
varying vec4 v_custom_data;

void vertex() {
	// Capture the MultiMesh custom data in the vertex shader
	v_custom_data = INSTANCE_CUSTOM;
}

void fragment() {
    // Get UV coordinates centered from -1.0 to 1.0
    vec2 uv = UV * 2.0 - 1.0;
    
    // Calculate distance from the center of the mesh instance
    float dist = length(uv);
    
    // Smooth anti-aliasing factor
    float af = fwidth(dist);
    
    // Extract outline data from script
   	vec3 outline_color = v_custom_data.rgb;
    float thickness = v_custom_data.a; // e.g., 0.1
    
    // Calculate boundaries
    float outer_edge = 1.0;
    float inner_edge = 1.0 - thickness;
    
    // Circle masks using smoothstep for crisp, anti-aliased edges
    float circle_mask = smoothstep(outer_edge, outer_edge - af, dist);
    float inner_mask = smoothstep(inner_edge, inner_edge - af, dist);
    float outline_mask = circle_mask - inner_mask;
    
    // Mix the base instance color and outline color
    vec3 final_rgb = mix(COLOR.rgb, outline_color, outline_mask);
    
    // Apply final color and clip alpha outside the circle
    COLOR = vec4(final_rgb, circle_mask * COLOR.a);
}
