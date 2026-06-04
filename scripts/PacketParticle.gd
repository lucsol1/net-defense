extends Node2D
class_name PacketParticle

var lifetime: float = 1.0
var elapsed: float = 0.0
var target: Vector2 = Vector2.ZERO
var packet_type: int = 0

const TYPE_COLORS = {
	0: Color(0.2, 0.6, 1.0),
	1: Color(0.8, 0.4, 1.0),
	2: Color(0.2, 1.0, 0.6),
	3: Color(1.0, 0.3, 0.3),
	4: Color(1.0, 0.6, 0.0),
}

func setup(from: Vector2, to: Vector2, p_type: int) -> void:
	global_position = from
	target = to
	packet_type = p_type
	lifetime = randf_range(0.5, 1.0)

func _process(delta: float) -> void:
	elapsed += delta
	var t = elapsed / lifetime
	global_position = global_position.lerp(target, delta * 6.0)
	modulate.a = 1.0 - t
	queue_redraw()
	if elapsed >= lifetime:
		queue_free()

func _draw() -> void:
	var color = TYPE_COLORS.get(packet_type, Color.WHITE)
	draw_circle(Vector2.ZERO, 14.0, color)
	draw_circle(Vector2.ZERO, 7.0, color.lightened(0.5))
