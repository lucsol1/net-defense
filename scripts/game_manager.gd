extends Node

signal turn_started(player: Player)
signal phase_changed(phase: Phase)
signal packets_processed(player: Player, packets: Array[Packet])
signal game_over(winner: Player)

enum Phase { PACKET, MAIN, END }

var players: Array[Player] = []
var servers: Array[Server] = []
var current_index: int = 0
var current_phase: Phase = Phase.PACKET
var turn: int = 1

const PACKETS_PER_TURN := 4
const MALICIOUS_CHANCE := 0.3

func start_game(p1: Player, p2: Player, s1: Server, s2: Server) -> void:
	players = [p1, p2]
	servers = [s1, s2]
	current_index = 0
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

	var server = current_server()
	var packets = _generate_packets()

	for packet in packets:
		if packet.is_malicious:
			var blocked = server.firewall > 0
			if blocked:
				server.firewall -= 1
			else:
				server.hp -= packet.damage
		else:
			server.processing_power += packet.throughput_value

	packets_processed.emit(current_player(), packets)
	_check_game_over()

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

	# Avança jogador
	current_index = (current_index + 1) % players.size()
	if current_index == 0:
		turn += 1

	_start_turn()

func play_card(card_id: int) -> bool:
	var player = current_player()
	var server = current_server()

	var card = CardDatabase.get_card(card_id)
	if card.is_empty():
		return false

	# Verifica custo de throughput
	if server.processing_power < card.get("cost", 0):
		return false

	server.processing_power -= card.get("cost", 0)

	# Aplica efeito (passa o servidor inimigo como alvo)
	var opponent_server = servers[1 - current_index]
	CardDatabase.apply_effect(card_id, player, server, opponent_server)

	player.remove_card(card_id)
	return true

func _generate_packets() -> Array[Packet]:
	var result: Array[Packet] = []
	for i in PACKETS_PER_TURN:
		var p = Packet.new()
		p.is_malicious = randf() < MALICIOUS_CHANCE
		if p.is_malicious:
			p.damage = randi_range(5, 15)
			p.throughput_value = 0
		else:
			p.throughput_value = randi_range(1, 4)
			p.damage = 0
		result.append(p)
	return result

func current_player() -> Player:
	return players[current_index]

func current_server() -> Server:
	return servers[current_index]

func _check_game_over() -> void:
	for i in servers.size():
		if servers[i].hp <= 0:
			game_over.emit(players[1 - i])
			get_tree().paused = true
