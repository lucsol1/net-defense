extends Node

signal turn_started(player: Player)
signal phase_changed(phase: Phase)
signal packets_generated(player: Player, packets: Array[Packet])
signal game_over(winner: Player)

enum Phase {
	PACKET,
	MAIN,
	END
}

var players: Array[Player] = []
var servers: Array[Server] = []

var current_index := 0
var current_phase := Phase.PACKET
var turn := 1

const PACKETS_PER_TURN := 4

func _process(delta: float) -> void:

	if current_phase != Phase.MAIN:
		return

	var server = current_server()

	server.update_processing(delta)

	_check_game_over()


func start_game(p1: Player, p2: Player, s1: Server, s2: Server) -> void:
	players = [p1, p2]
	servers = [s1, s2]
	current_index = randi() % 2 
	turn = 1
	_start_turn()


func _start_turn() -> void:

	var player = current_player()

	player.start_turn()

	turn_started.emit(player)

	_packet_phase()


func _packet_phase() -> void:

	current_phase = Phase.PACKET
	phase_changed.emit(current_phase)

	var packets = _generate_packets()

	var server = current_server()

	for packet in packets:
		server.add_packet(packet)

	packets_generated.emit(
		current_player(),
		packets
	)

	_main_phase()


func _main_phase() -> void:

	current_phase = Phase.MAIN
	phase_changed.emit(current_phase)


func end_turn() -> void:

	if current_phase != Phase.MAIN:
		return

	current_phase = Phase.END
	phase_changed.emit(current_phase)

	current_player().end_turn()

	current_index = (
		current_index + 1
	) % players.size()

	if current_index == 0:
		turn += 1

	_start_turn()


func play_card(card_id: int) -> bool:

	var player = current_player()
	var server = current_server()

	var card = CardDatabase.get_card(card_id)

	if card.is_empty():
		return false

	var cost = card.get("cost", 0)

	if server.processing_power < cost:
		return false

	server.processing_power -= cost

	var enemy_server = servers[
		1 - current_index
	]

	CardDatabase.apply_effect(
		card_id,
		player,
		server,
		enemy_server
	)

	player.remove_card(card_id)

	return true


func _generate_packets() -> Array[Packet]:

	var result: Array[Packet] = []

	for i in PACKETS_PER_TURN:

		var packet = Packet.new()

		var roll = randf()

		if roll < 0.15:

			packet.setup(
				Packet.PacketType.DDOS,
				0,
				20,
				8.0,
				true
			)

		elif roll < 0.30:

			packet.setup(
				Packet.PacketType.MALWARE,
				0,
				10,
				4.0,
				true
			)

		elif roll < 0.60:

			packet.setup(
				Packet.PacketType.DATA,
				1,
				0,
				1.0,
				false
			)

		elif roll < 0.85:

			packet.setup(
				Packet.PacketType.VIDEO,
				3,
				0,
				3.0,
				false
			)

		else:

			packet.setup(
				Packet.PacketType.VOICE,
				2,
				0,
				2.0,
				false
			)

		result.append(packet)

	return result

func activate_card(card_id: int) -> void:
	var player = current_player()
	var server = current_server()
	var enemy_server = servers[1 - current_index]
	CardDatabase.apply_effect(card_id, player, server, enemy_server)
	player.remove_card(card_id)

func discard_card(card_id: int) -> void:
	current_player().remove_card(card_id)
	
func current_player() -> Player:
	return players[current_index]


func current_server() -> Server:
	return servers[current_index]


func _check_game_over() -> void:

	for i in servers.size():

		if servers[i].hp <= 0:

			game_over.emit(
				players[1 - i]
			)

			get_tree().paused = true
