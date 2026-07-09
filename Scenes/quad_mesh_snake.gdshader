shader_type canvas_item;

void fragment() {
    // Calculate distance from the center of the quad mesh
    float dist = distance(UV, vec2(0.5));
    
    // Smooth the edges to avoid pixelation/aliasing
    float alpha = smoothstep(0.5, 0.48, dist);
    
    // Mix the vertex color (assigned per instance in GDScript) with the alpha mask
    COLOR = vec4(COLOR.rgb, COLOR.a * alpha);
}
