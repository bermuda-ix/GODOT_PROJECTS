shader_type canvas_item;

uniform vec4 glow_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_power: hint_range(0.0, 8.0, 0.1) = 2.0;
uniform float glow_shift: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float glow_radius: hint_range(1.0, 10.0, 1.0) = 1.0;

void fragment() {
	vec4 glow = vec4(0.0);
	float count = 0.0;
	for (float x = -glow_radius; x <= glow_radius; x++){
		for (float y = -glow_radius; y <= glow_radius; y++){
			vec2 offset = vec2(x, y) * glow_shift * TEXTURE_PIXEL_SIZE;
			glow += texture(TEXTURE, UV + offset) * glow_color;
			count ++;
		}
	}
	//vec4 pixal = texture(TEXTURE, UV);
	//vec4 glow = pixal * glow_color * glow_power;
	glow *= glow_power/count;
	vec4 pixal = texture(TEXTURE, UV);
	COLOR = mix(pixal, glow, glow.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
