shader_type canvas_item;

uniform float time = 0.0;
uniform float frequency = 0.0385;
uniform int noise_seed = 0;
uniform float alpha = 0.25;

// Функция для генерации случайных точек
vec2 hash(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453);
}

float cellular_noise(vec2 coord, int seed) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	float min_dist = 1.0;

	for(int y = -1; y <= 1; y++) {
		for(int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 point = hash(i + neighbor + vec2(float(seed)));
			vec2 diff = neighbor + point - f;
			float dist = length(diff);
			min_dist = min(min_dist, dist);
		}
	}

	return min_dist;
}

void fragment() {
	vec2 base_coord = UV * frequency;
	base_coord.x -= time;

	// Seamless: берем несколько samples и смешиваем
	vec2 coord1 = base_coord;
	vec2 coord2 = base_coord + vec2(1.0, 0.0);
	vec2 coord3 = base_coord + vec2(0.0, 1.0);
	vec2 coord4 = base_coord + vec2(1.0, 1.0);

	float noise1 = cellular_noise(coord1, noise_seed);
	float noise2 = cellular_noise(coord2, noise_seed);
	float noise3 = cellular_noise(coord3, noise_seed);
	float noise4 = cellular_noise(coord4, noise_seed);

	// Интерполяция для seamless эффекта
	vec2 blend = fract(base_coord);
	blend = smoothstep(0.0, 1.0, blend);

	float noiseA = mix(noise1, noise2, blend.x);
	float noiseB = mix(noise3, noise4, blend.x);
	float final_noise = mix(noiseA, noiseB, blend.y);

	COLOR = vec4(vec3(final_noise), alpha);
}