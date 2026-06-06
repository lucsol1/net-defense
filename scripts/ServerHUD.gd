extends Node2D
class_name ServerHUD

@export var server: Server
@export var spawn_radius: float = 200.0

const PACKET_PARTICLE = preload("res://scenes/PacketParticle.tscn")

const TYPE_COLORS = {
	0: Color(0.2, 0.6, 1.0),
	1: Color(0.8, 0.4, 1.0),
	2: Color(0.2, 1.0, 0.6),
	3: Color(1.0, 0.3, 0.3),
	4: Color(1.0, 0.6, 0.0),
}

const TYPE_LABELS = {
	0: "DAT",
	1: "VID",
	2: "VOI",
	3: "MAL",
	4: "DDS",
}

const BAR_WIDTH    = 1400.0
const BAR_HEIGHT   = 110.0
const BAR_OFFSET_Y = 400.0
const FONT_SIZE    = 72
const SLOT_SIZE    = 80.0
const SLOT_GAP     = 14.0

func _ready() -> void:
	if server:
		server.packet_added.connect(_on_packet_added)

func _on_packet_added(packet: Packet) -> void:
	_spawn_particle(packet)

func _spawn_particle(packet: Packet) -> void:
	var p = PACKET_PARTICLE.instantiate()
	get_tree().root.add_child(p)
	var angle = randf() * TAU
	var from = global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
	p.setup(from, global_position, packet.type)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not server:
		return

	var status = server.get_status()
	var origin = Vector2(-BAR_WIDTH / 2, BAR_OFFSET_Y)
	var row = BAR_HEIGHT + 24

	_draw_bar(origin, float(status["hp"]) / 1000.0,
		Color(0.9, 0.2, 0.2), Color(0.3, 0.05, 0.05),
		"HP: %d" % status["hp"])

	var buf_ratio = float(status["buffer_current"]) / float(status["buffer_max"])
	_draw_bar(origin + Vector2(0, row), buf_ratio,
		Color(0.2, 0.7, 1.0), Color(0.05, 0.15, 0.3),
		"Buffer: %d/%d" % [status["buffer_current"], status["buffer_max"]])

	_draw_bar(origin + Vector2(0, row * 2),
		min(float(status["processed_packets"]) / 20.0, 1.0),
		Color(0.2, 1.0, 0.5), Color(0.05, 0.25, 0.1),
		"Processados: %d" % status["processed_packets"])
	
	_draw_bar(origin + Vector2(0, row * 4),
		min(float(status["processing_power"]) / 10.0, 1.0),
		Color(1.0, 0.85, 0.1), Color(0.25, 0.2, 0.0),
		"Capacidade: %d" % status["processing_power"])
		
	if status["firewall"] > 0:
		_draw_bar(origin + Vector2(0, row * 3),
			min(float(status["firewall"]) / 5.0, 1.0),
			Color(1.0, 0.85, 0.1), Color(0.25, 0.2, 0.0),
			"Firewall: %d" % status["firewall"])

	_draw_buffer_slots(status)

func _draw_bar(pos: Vector2, ratio: float, fill_color: Color, bg_color: Color, label: String) -> void:
	draw_rect(Rect2(pos, Vector2(BAR_WIDTH, BAR_HEIGHT)), bg_color)
	draw_rect(Rect2(pos, Vector2(BAR_WIDTH * clamp(ratio, 0.0, 1.0), BAR_HEIGHT)), fill_color)
	draw_rect(Rect2(pos, Vector2(BAR_WIDTH, BAR_HEIGHT)), Color.WHITE, false, 3.0)
	draw_string(
		ThemeDB.fallback_font,
		pos + Vector2(14, BAR_HEIGHT - 10),
		label,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		FONT_SIZE,
		Color.WHITE
	)

func _draw_buffer_slots(status: Dictionary) -> void:
	if not server:
		return

	var max_slots = status["buffer_max"]
	var slot_w    = 120.0
	var slot_h    = 130.0
	var gap       = 16.0
	var total_w   = max_slots * (slot_w + gap) - gap
	var start     = Vector2(-total_w / 2, BAR_OFFSET_Y + (BAR_HEIGHT + 24) * 3 + 40)

	for i in max_slots:
		var pos = start + Vector2(i * (slot_w + gap), 0)
		var rect = Rect2(pos, Vector2(slot_w, slot_h))

		draw_rect(rect, Color(0.08, 0.08, 0.12), true)
		draw_rect(rect, Color(0.3, 0.3, 0.4, 0.5), false, 1.5)

		if i < server.buffer.size():
			var pkt      = server.buffer[i]
			var col      = TYPE_COLORS.get(pkt.type, Color.WHITE)
			var progress = 1.0 - clamp(pkt.remaining_time / pkt.process_time, 0.0, 1.0)

			draw_rect(rect, Color(col.r, col.g, col.b, 0.25), true)

			var bar_h   = 14.0
			var bar_pos = Vector2(pos.x, pos.y + slot_h - bar_h)
			draw_rect(Rect2(bar_pos, Vector2(slot_w, bar_h)), Color(0.0, 0.0, 0.0, 0.5))
			draw_rect(Rect2(bar_pos, Vector2(slot_w * progress, bar_h)), col)

			var border_w = 4.0 if pkt.is_malicious else 1.5
			draw_rect(rect, col, false, border_w)

			# label do tipo
			draw_string(
				ThemeDB.fallback_font,
				pos + Vector2(slot_w / 2 - 28, slot_h / 2 + 14),
				TYPE_LABELS.get(pkt.type, "???"),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color.WHITE
			)

			# tempo restante
			draw_string(
				ThemeDB.fallback_font,
				pos + Vector2(4, 26),
				"%.1fs" % pkt.remaining_time,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(1, 1, 1, 0.7)
			)

			if pkt.is_malicious:
				var cx  = pos.x + slot_w - 14
				var cy  = pos.y + 14
				var pts = PackedVector2Array([
					Vector2(cx, cy - 10),
					Vector2(cx + 9, cy + 6),
					Vector2(cx - 9, cy + 6),
				])
				draw_colored_polygon(pts, Color(1.0, 0.3, 0.1, 0.9))
				draw_string(
					ThemeDB.fallback_font,
					Vector2(cx - 4, cy + 6),
					"!", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE
				)
		else:
			draw_string(
				ThemeDB.fallback_font,
				pos + Vector2(slot_w / 2 - 10, slot_h / 2 + 10),
				str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.4, 0.4, 0.5, 0.6)
			)
		
