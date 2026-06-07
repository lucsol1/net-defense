extends Node2D
class_name FloatingText

var velocity: Vector2 = Vector2(0, -80)
var lifetime: float = 1.5
var elapsed: float = 0.0

func setup(text: String, color: Color, pos: Vector2) -> void:
	global_position = pos
	$Label.text = text
	$Label.modulate = color

func _process(delta: float) -> void:
	elapsed += delta
	position += velocity * delta
	modulate.a = 1.0 - (elapsed / lifetime)
	if elapsed >= lifetime:
		queue_free()
