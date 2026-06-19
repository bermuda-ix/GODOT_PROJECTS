shader_type canvas_item;



void fragment() {
	vec4 silhouette = vec4(vec3(0, 1.0, 1.0), COLOR.a);
	COLOR = mix(silhouette, COLOR, COLOR.a);
}