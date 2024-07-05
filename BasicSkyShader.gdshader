shader_type sky;

uniform vec3 skyColor : source_color;
uniform vec3 horizonColor : source_color;

uniform sampler2D cloud_texture;
uniform sampler2D cloud_texture2;
uniform vec2 cloud_direction;
uniform vec2 cloud_direction2;
uniform vec2 cloud_scale;
uniform float cloud_distance;
uniform float cloud_speed;
uniform float cloud_speed2;

void sky() {
	float col = clamp(EYEDIR.y / 0.05, 0.0, 1.0);
	vec3 finalColor = mix(horizonColor, skyColor, col);
	
	vec2 sky_uv = EYEDIR.xz / EYEDIR.y;
	vec3 clouds = texture(cloud_texture, sky_uv * cloud_scale + TIME * cloud_direction * cloud_speed * 0.01).rgb - texture(cloud_texture2, sky_uv * cloud_scale + TIME * cloud_direction2 * cloud_speed2 * 0.01).rgb;
	clouds = clouds - smoothstep(0.0, EYEDIR.y, cloud_distance);
	clouds = clamp(clouds, 0.0, 1.0);
	finalColor += clouds;
	
	COLOR = finalColor * LIGHT0_ENERGY;
	
}