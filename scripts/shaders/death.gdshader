shader_type canvas_item;
// 239 249 214
const vec4 white = vec4(0.941, 0.9803, 0.8425, 1.0);
uniform bool active = false;

void fragment() {
	if (texture(TEXTURE, UV).w == 0.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else if (active) {
		COLOR = white;
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
