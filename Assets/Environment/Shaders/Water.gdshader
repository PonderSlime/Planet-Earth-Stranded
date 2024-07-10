shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D tex_vtx_4;
uniform vec4 ColorParameter : source_color = vec4(0.066150, 0.254866, 0.431543, 1.000000);
uniform sampler2D tex_frg_3;
uniform sampler2D tex_frg_7;
uniform sampler2D depth_tex_frg_14 : hint_depth_texture;



void vertex() {
// Input:2
	float n_out2p0 = TIME;


// UVFunc:3
	vec2 n_in3p1 = vec2(0.10000, 0.10000);
	vec2 n_out3p0 = vec2(n_out2p0) * n_in3p1 + UV;


// Texture2D:4
	vec4 n_out4p0 = texture(tex_vtx_4, n_out3p0);


// Input:6
	vec3 n_out6p0 = NORMAL;


// VectorOp:8
	vec3 n_in8p1 = vec3(0.20000, 0.20000, 0.20000);
	vec3 n_out8p0 = n_out6p0 * n_in8p1;


// Input:5
	vec3 n_out5p0 = VERTEX;


// MultiplyAdd:7
	vec4 n_out7p0 = fma(n_out4p0, vec4(n_out8p0, 0.0), vec4(n_out5p0, 0.0));


// Output:0
	VERTEX = vec3(n_out7p0.xyz);


}

void fragment() {
// ColorParameter:2
	vec4 n_out2p0 = ColorParameter;


// Input:6
	float n_out6p0 = TIME;


// UVFunc:5
	vec2 n_in5p1 = vec2(0.10000, 0.10000);
	vec2 n_out5p0 = vec2(n_out6p0) * n_in5p1 + UV;


// Texture2D:3
	vec4 n_out3p0 = texture(tex_frg_3, n_out5p0);


// Input:9
	float n_out9p0 = TIME;


// UVFunc:8
	vec2 n_in8p1 = vec2(-0.10000, -0.10000);
	vec2 n_out8p0 = vec2(n_out9p0) * n_in8p1 + UV;


// Texture2D:7
	vec4 n_out7p0 = texture(tex_frg_7, n_out8p0);


// VectorOp:10
	vec4 n_out10p0 = n_out3p0 * n_out7p0;


// VectorOp:11
	vec4 n_in11p1 = vec4(1.25000, 1.25000, 1.25000, 1.25000);
	vec4 n_out11p0 = pow(n_out10p0, n_in11p1);


// VectorOp:4
	vec4 n_out4p0 = n_out2p0 + n_out11p0;


	float n_out14p0;
// ProximityFade:14
	float n_in14p0 = 0.50000;
	{
		float __depth_tex = texture(depth_tex_frg_14, SCREEN_UV).r;
		vec4 __depth_world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, __depth_tex, 1.0);
		__depth_world_pos.xyz /= __depth_world_pos.w;
		n_out14p0 = clamp(1.0 - smoothstep(__depth_world_pos.z + n_in14p0, __depth_world_pos.z, VERTEX.z), 0.0, 1.0);
	}


// FloatFunc:15
	float n_out15p0 = 1.0 - n_out14p0;


// Input:18
	float n_out18p0 = TIME;


// MultiplyAdd:26
	float n_in26p1 = 0.50000;
	float n_out26p0 = fma(n_out18p0, n_in26p1, n_out15p0);


// FloatOp:24
	float n_in24p1 = 4.00000;
	float n_out24p0 = n_out26p0 * n_in24p1;


// FloatFunc:17
	float n_out17p0 = sin(n_out24p0);


// FloatFunc:20
	float n_out20p0 = abs(n_out17p0);


// FloatOp:21
	float n_out21p0 = n_out15p0 * n_out20p0;


// FloatOp:22
	float n_in22p1 = 24.00000;
	float n_out22p0 = pow(n_out15p0, n_in22p1);


// FloatOp:23
	float n_out23p0 = n_out21p0 + n_out22p0;


// Mix:27
	vec3 n_in27p1 = vec3(1.00000, 1.00000, 1.00000);
	vec3 n_out27p0 = mix(vec3(n_out4p0.xyz), n_in27p1, vec3(n_out23p0));


// FloatConstant:12
	float n_out12p0 = 0.800000;


// FloatConstant:13
	float n_out13p0 = 0.000000;


// Output:0
	ALBEDO = n_out27p0;
	ALPHA = n_out12p0;
	ROUGHNESS = n_out13p0;
	EMISSION = vec3(n_out11p0.xyz);


}
