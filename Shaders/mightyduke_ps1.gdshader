shader_type spatial;
render_mode vertex_lighting,
	skip_vertex_transform,
	specular_disabled,
	shadows_disabled,
	diffuse_lambert_wrap;
//render_mode blend_mix,
//	cull_disabled,
//	depth_prepass_alpha,
//	shadows_disabled,
//	specular_disabled,
//	vertex_lighting;

uniform sampler2D albedo: source_color, filter_nearest;

global uniform float vertex_jitter: hint_range(0.0, 1.0) = 0.5;
uniform bool jitter_z_coordinate = true;
uniform bool jitter_depth_independent = true;
global uniform bool affine_mapping = true;
uniform float alpha_scissor: hint_range(0.0, 1.0) = 1.0;

void vertex() {
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float z_orig = VERTEX.z;
	float i = (1.0 - vertex_jitter) * min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 2.0;

	vec4 clip = PROJECTION_MATRIX * vec4(VERTEX, 1.0);

	if (jitter_depth_independent) {
		float w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
		VERTEX = round(VERTEX / w * i) / i * w;
	} else {
		VERTEX = round(VERTEX * i) / i;
	}

	if (!jitter_z_coordinate) {
		VERTEX.z = z_orig;
	}
	POSITION = PROJECTION_MATRIX * vec4(VERTEX, 1.0);
	if (affine_mapping) {

		POSITION /= abs(POSITION.w);
		//UV *= VERTEX.z;
	}
}

void fragment() {
	vec2 uv = UV;

	//if (affine_texture_mapping) {
	//	uv /= VERTEX.z;
	//}

	ALBEDO = texture(albedo, uv).rgb;
	ALPHA = texture(albedo, uv).a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
}