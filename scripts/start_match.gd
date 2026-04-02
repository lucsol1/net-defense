# start_match.gd
extends Node

func _ready() -> void:
	# Cria os dois jogadores
	var p1 = Player.new(0, "Player 1")
	var p2 = Player.new(1, "Player 2")

	# Cria os dois servidores
	var s1 = Server.new()
	var s2 = Server.new()
	s1.hp = 1000
	s2.hp = 1000

	# Entrega tudo pro GameManager iniciar
	GameManager.start_game(p1, p2, s1, s2)
