shader_type particles;

uniform float red = 2.0;
uniform float life = 5.0;

void start() {
	LIFETIME;
}

void process() {
	COLOR.b = red;
}
