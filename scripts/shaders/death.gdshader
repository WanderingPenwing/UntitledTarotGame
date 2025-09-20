shader_type canvas_item;

uniform vec4 white : source_color = vec4(1.0);
uniform vec4 black : source_color = vec4(1.0);

uniform bool hurt = false;
uniform bool blind = false;

void fragment() {
	if (texture(TEXTURE, UV).w == 0.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else if (hurt || length(texture(TEXTURE, UV) - white) < 0.1) {
		COLOR = white;
	} else if (blind) {
		COLOR = black;
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
