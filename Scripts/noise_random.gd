class_name NoiseRandom
extends Object

static var noise: FastNoiseLite


static func set_seed(value: int) -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	noise.frequency = 30
	noise.fractal_octaves = 2
	noise.fractal_gain = 0.1
	noise.seed = value


static func randi_in_range(sample: float, output_start: int, output_end: int) -> int:
	return floori(remap(noise.get_noise_1d(sample), -1.0, 1.0, float(output_start), float(output_end + 1)))


static func randf_in_range(sample: float, output_start: float, output_end: float) -> float:
	return remap(noise.get_noise_1d(sample), -1.0, 1.0, output_start, output_end)
