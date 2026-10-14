shader_type particles;

uniform vec3 anchor = vec3(0.0);
uniform vec3 field_size = vec3(4.0, 3.0, 4.0);
uniform float drift = 0.25;

uint hash_uint(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

float rand01(uint id, uint salt) {
	return float(hash_uint(id + salt)) / 4294967295.0;
}

void start() {
	uint id = INDEX + RANDOM_SEED;
	CUSTOM = vec4(
		rand01(id, uint(1)),
		rand01(id, uint(27)),
		rand01(id, uint(43)),
		rand01(id, uint(111)) * 6.2831);
	float s = mix(0.02, 0.05, rand01(id, uint(77)));
	TRANSFORM = mat4(
		vec4(s, 0.0, 0.0, 0.0),
		vec4(0.0, s, 0.0, 0.0),
		vec4(0.0, 0.0, s, 0.0),
		vec4(0.0, 0.0, 0.0, 1.0));
}

void process() {
	vec3 base = CUSTOM.xyz * field_size;
	vec3 wander = vec3(
		sin(TIME * 0.4 + CUSTOM.w),
		sin(TIME * 0.3 + CUSTOM.w * 2.0),
		cos(TIME * 0.35 + CUSTOM.w)) * drift;
	vec3 rel = mod(base + wander - anchor + 0.5 * field_size, field_size) - 0.5 * field_size;
	TRANSFORM[3] = vec4(anchor + rel, 1.0);
}