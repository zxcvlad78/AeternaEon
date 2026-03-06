shader_type canvas_item;

uniform float time = 0.0;
uniform float frequency = 0.038;
uniform int octaves = 3;
uniform float lacunarity = 2.0;
uniform float gain = 0.5;
uniform int noise_seed = 0;
uniform float alpha = 0.5;
uniform float contrast = 1.0;
uniform float brightness = 0.0;
uniform vec3 color1 = vec3(0.0, 0.0, 1.0);
uniform vec3 color2 = vec3(1.0, 1.0, 0.0);
uniform float animation_speed = 1.0;

// Фрактальные параметры
uniform int fractal_type = 0; // 0=Standard, 1=Ridged, 2=Billowed, 3=Hybrid
uniform float fractal_weight = 1.0;
uniform float fractal_offset = 1.0;
uniform float fractal_threshold = 0.5;
uniform bool fractal_invert = false;

// Движение
uniform vec2 movement_direction = vec2(1.0, 0.0);
uniform bool enable_rotation = false;
uniform float rotation_speed = 0.0;
uniform bool enable_scaling = false;
uniform float scale_speed = 0.0;

// Улучшенная хэш-функция
vec2 hash(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), 
	         dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453123);
}

// Функция для плавного минимального расстояния
float cellular_noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float min_dist1 = 1.0;
	float min_dist2 = 1.0;
	
	for(int y = -1; y <= 1; y++) {
		for(int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 point = hash(i + neighbor + vec2(float(noise_seed)));
			
			vec2 diff = neighbor + point - f;
			float dist = dot(diff, diff);
			
			if (dist < min_dist1) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (dist < min_dist2) {
				min_dist2 = dist;
			}
		}
	}
	
	return min_dist2 - min_dist1;
}

// Ridged multi-fractal
float ridged_multifractal(vec2 coord, int octaves_count, float lac, float gn, float offset) {
	float value = 0.0;
	float freq = 1.0;
	float amp = 1.0;
	float weight = 1.0;
	float signal = 0.0;
	
	for(int i = 0; i < octaves_count; i++) {
		signal = cellular_noise(coord * freq);
		signal = abs(signal);
		signal = offset - signal;
		signal *= signal;
		signal *= weight;
		weight = signal * fractal_weight;
		weight = clamp(weight, 0.0, 1.0);
		
		value += signal * amp;
		amp *= gn;
		freq *= lac;
	}
	
	return value;
}

// Billowed (turbulence) fractal
float billowed_fractal(vec2 coord, int octaves_count, float lac, float gn) {
	float value = 0.0;
	float freq = 1.0;
	float amp = 1.0;
	
	for(int i = 0; i < octaves_count; i++) {
		float signal = abs(cellular_noise(coord * freq));
		value += signal * amp;
		amp *= gn;
		freq *= lac;
	}
	
	return value;
}

// Hybrid multi-fractal (комбинация стандартного и ridged)
float hybrid_multifractal(vec2 coord, int octaves_count, float lac, float gn, float offset) {
	float value = 0.0;
	float freq = 1.0;
	float amp = 1.0;
	float weight = 1.0;
	float signal = 0.0;
	
	// Первая октава - стандартная
	signal = cellular_noise(coord * freq);
	value = signal * amp;
	weight = signal * fractal_weight;
	
	amp *= gn;
	freq *= lac;
	
	// Последующие октавы - ridged
	for(int i = 1; i < octaves_count; i++) {
		if (weight > 1.0) weight = 1.0;
		signal = cellular_noise(coord * freq);
		signal = abs(signal);
		signal = offset - signal;
		signal *= signal;
		value += signal * amp * weight;
		weight = signal * fractal_weight;
		amp *= gn;
		freq *= lac;
	}
	
	return value;
}

// Стандартный фрактальный шум
float standard_fractal(vec2 coord, int octaves_count, float lac, float gn) {
	float value = 0.0;
	float amp = 1.0;
	float freq = 1.0;
	float max_value = 0.0;
	
	for(int i = 0; i < octaves_count; i++) {
		value += cellular_noise(coord * freq) * amp;
		max_value += amp;
		freq *= lac;
		amp *= gn;
	}
	
	return value / max_value;
}

// Основная фрактальная функция
float fractal_cellular(vec2 coord) {
	float noise_value = 0.0;
	
	if (fractal_type == 0) {
		// Standard fractal
		noise_value = standard_fractal(coord, octaves, lacunarity, gain);
	} else if (fractal_type == 1) {
		// Ridged multifractal
		noise_value = ridged_multifractal(coord, octaves, lacunarity, gain, fractal_offset);
	} else if (fractal_type == 2) {
		// Billowed fractal
		noise_value = billowed_fractal(coord, octaves, lacunarity, gain);
	} else if (fractal_type == 3) {
		// Hybrid multifractal
		noise_value = hybrid_multifractal(coord, octaves, lacunarity, gain, fractal_offset);
	}
	
	// Применяем порог и инверсию
	if (fractal_threshold != 0.5) {
		noise_value = smoothstep(fractal_threshold - 0.1, fractal_threshold + 0.1, noise_value);
	}
	
	if (fractal_invert) {
		noise_value = 1.0 - noise_value;
	}
	
	return noise_value;
}

// Функция для коррекции контраста и яркости

// Функция вращения координат
vec2 rotate_coord(vec2 coord, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	mat2 rotation_matrix = mat2(vec2(c, -s), vec2(s, c));
	return rotation_matrix * coord;
}

void fragment() {
	vec2 base_coord = UV * frequency;
	
	// Применяем движение - сдвигаем координаты
	vec2 movement = movement_direction * time * animation_speed * 0.1;
	base_coord -= movement;
	
	// Применяем вращение
	if (enable_rotation) {
		float angle = time * rotation_speed * 0.1;
		base_coord = rotate_coord(base_coord, angle);
	}
	
	// Применяем масштабирование
	if (enable_scaling) {
		float scale_factor = 1.0 + sin(time * scale_speed * 0.1) * 0.5;
		base_coord *= scale_factor;
	}
	
	// Генерируем фрактальный шум
	float noise = fractal_cellular(base_coord);
	
	// Нормализуем и применяем коррекции
	noise = (noise + 1.0) * 0.5; // Приводим к диапазону 0-1
	//noise = adjust_contrast_brightness(noise, contrast, brightness);
	
	// Создаем цветовой градиент
	vec3 color = mix(color1, color2, noise);
	
	COLOR = vec4(color, alpha * noise);
}