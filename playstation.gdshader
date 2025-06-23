shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform int resolution_scale : hint_range(1, 64) = 1;

uniform float dither_spread = 1.0;
uniform float dither_gamma = 1.0;


void fragment() {
	vec2 tex_size = vec2(textureSize(SCREEN_TEXTURE, 0));
	ivec2 texel_coord = ivec2(floor(UV * tex_size / float(resolution_scale)));
	vec3 color = texelFetch(SCREEN_TEXTURE, texel_coord * resolution_scale, 0).rgb;

	int ps1_dither_matrix[16] = {
		-4, 0, -3, 1,
		2, -2, 3, -1,
		-3, 1, -4, 0,
		3, -1, 2, -2
	};

	// Index 1D dither matrix based on 2D screen coordinates
	float noise = float(ps1_dither_matrix[(int(texel_coord.x) % 4) + (int(texel_coord.y) % 4) * 4]);

	// Apply dithering and quantize 24 bit srgb to 15 bit srgb according to https://psx-spx.consoledev.net/graphicsprocessingunitgpu/
	color = pow(color, vec3(1.0 / dither_gamma)); // Convert to srgb cause it imo looks better and is probably correct idk looks more correct than linear quantization
	color = round(color * 255.0 + noise); // Convert to 0-255 and add dither noise
	color = clamp(round(color), vec3(0), vec3(255)); // Clamp to 0-255 in case of overflow
	color = clamp(color / 8.0, vec3(0), vec3(31)); // Convert to 0-31 range
	color /= 31.0; // Convert back to 0-1 range

	color = pow(color, vec3(dither_gamma)); // Convert back to linear

	COLOR = vec4(color, 1.0);
}