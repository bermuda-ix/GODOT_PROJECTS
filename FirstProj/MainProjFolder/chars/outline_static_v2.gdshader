shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);

uniform int neighbor_pixels = 1;
uniform int center_distance_cap = 1;

bool has_neighbor(vec2 uv, vec2 texture_pixal_size, sampler2D sprite_texture) {
	
	for (int x = -neighbor_pixels; x < neighbor_pixels + 1; x++){
		for (int y = -neighbor_pixels; y < neighbor_pixels + 1; y++){
			
			if(x==0 && y==0){
				continue;
			}
			
			if (abs(x) + abs(y) > center_distance_cap){
				continue;
			}
			
			vec2 xy = vec2(float(x), float(y));
			vec2 sprite_coord = uv + xy * texture_pixal_size;
			
			if (texture(sprite_texture, sprite_coord).a > 0.0){
				return true;
			}
			
		}
	}
	
	return false;
}


void fragment() {
	if (COLOR.a == 0.0 && has_neighbor(UV, TEXTURE_PIXEL_SIZE, TEXTURE)){
		COLOR = color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
