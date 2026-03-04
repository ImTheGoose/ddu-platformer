shader_type canvas_item;

uniform vec2 direction;
uniform float speed;
uniform vec2 offset;

void vertex() {
    UV.x -= TIME * direction.x * speed;
    UV.y -= TIME * direction.y * speed;

    UV += offset;
}
