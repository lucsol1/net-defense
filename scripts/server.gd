extends Resource
class_name Server

signal packet_processed(packet: Packet)
signal packet_added(packet: Packet)
signal server_damaged(amount: int)
signal throughput_gained(amount: int)

# =========================
# ATRIBUTOS PRINCIPAIS
# =========================

var hp: int = 1000

# protege contra pacotes maliciosos
var firewall: int = 0

# recurso para jogar cartas
var processing_power: int = 0

# quantidade total processada
var processed_packets: int = 0

# tamanho máximo da fila
var buffer_size: int = 10

# velocidade de processamento
var processing_speed: float = 1.0

# fila de pacotes
var buffer: Array[Packet] = []


# =========================
# BUFFER
# =========================

func add_packet(packet: Packet) -> bool:

	if buffer.size() >= buffer_size:
		return false

	buffer.append(packet)
	packet_added.emit(packet)

	return true


func remove_packet(packet: Packet) -> void:
	buffer.erase(packet)


func buffer_usage() -> float:

	if buffer_size == 0:
		return 0.0

	return float(buffer.size()) / float(buffer_size)


func is_buffer_full() -> bool:
	return buffer.size() >= buffer_size


# =========================
# PROCESSAMENTO
# =========================

func update_processing(delta: float) -> void:

	if buffer.is_empty():
		return

	var multiplier := get_processing_multiplier()

	for packet in buffer:
		packet.remaining_time -= delta * processing_speed * multiplier

	var completed: Array[Packet] = []

	for packet in buffer:
		if packet.remaining_time <= 0:
			completed.append(packet)

	for packet in completed:
		_finish_packet(packet)


func _finish_packet(packet: Packet) -> void:

	buffer.erase(packet)

	if packet.is_malicious:

		if firewall > 0:
			firewall -= 1
		else:
			hp -= packet.damage
			server_damaged.emit(packet.damage)

	else:

		processing_power += packet.throughput_value
		processed_packets += 1

		throughput_gained.emit(packet.throughput_value)

	packet_processed.emit(packet)


# =========================
# CONGESTIONAMENTO
# =========================

func get_processing_multiplier() -> float:

	var usage := buffer_usage()

	if usage >= 1.0:
		return 0.4

	if usage >= 0.8:
		return 0.6

	if usage >= 0.6:
		return 0.8

	return 1.0


# =========================
# MELHORIAS
# =========================

func add_firewall(amount: int) -> void:
	firewall += amount


func add_processing_speed(amount: float) -> void:
	processing_speed += amount


func add_buffer(amount: int) -> void:
	buffer_size += amount


# =========================
# UTILIDADES
# =========================

func get_status() -> Dictionary:

	return {
		"hp": hp,
		"firewall": firewall,
		"processing_power": processing_power,
		"processed_packets": processed_packets,
		"buffer_current": buffer.size(),
		"buffer_max": buffer_size,
	}
	
func can_afford(cost: int) -> bool:
	return processing_power >= cost
