extends Node

func rand_range(min_val: int, max_val: int) -> int:
	return randi() % (max_val - min_val) + min_val

func rand_range_float(min_val: float, max_val: float) -> float:
	return randf() * (max_val - min_val) + min_val

func cubic_ease_out(t: float) -> float:
	var f = (t - 1)
	return f * f * f + 1

# global flags that persist inbetween games
var FLAGS=[]

var num_enemies_killed := 0
