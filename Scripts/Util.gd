extends Node

func rand_range(min_val: int, max_val: int) -> int:
    return randi() % (max_val - min_val) + min_val

func rand_range_float(min_val: float, max_val: float) -> float:
    return randf() * (max_val - min_val) + min_val