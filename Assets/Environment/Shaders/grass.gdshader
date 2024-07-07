shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;
uniform sampler2D color_gradient;
uniform sampler2D fresnel_gradient;

varying vec3 worldPos;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
void vertex() {
	// Called for every vertex the material is visible on.
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	ALBEDO = mix(color, color2, UV.y) * mix(color,color2, noiseLevel.r);
	if (!FRONT_FACING){
		NORMAL = -NORMAL;
	}
}

void light() {
	float dotproduct = clamp(dot(NORMAL, LIGHT), -0.9, 0.9);
	float sample = clamp((dotproduct + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 shaded = texture(color_gradient, vec2(sample, 0.0));
	DIFFUSE_LIGHT += clamp((shaded.rgb * LIGHT_COLOR), 0.0, 1.0);
	//DIFFUSE_LIGHT += (shaded.rgb * LIGHT_COLOR);
}
