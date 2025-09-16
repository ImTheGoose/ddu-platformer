shader_type canvas_item;

uniform vec2 direction;
uniform float speed;

void vertex() {
	// Called for every vertex the material is visible on.
	UV.x -= TIME * direction.x * speed;
	UV.y -= TIME * direction.y * speed;
}
