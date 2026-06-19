shader_type canvas_item;

void fragment() {
	vec4 silhouette = vec4(vec3(.8, .8, .8), COLOR.a);
	COLOR = mix(silhouette, COLOR, COLOR.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
