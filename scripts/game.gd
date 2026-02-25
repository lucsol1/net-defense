extends Node2D

const CARD_SCENE = preload("res://scenes/card.tscn")

func _ready() -> void:
	var p1 = Player.new(0, "Player 1")
	var p2 = Player.new(1, "Player 2")
	var s1 = Server.new()
	var s2 = Server.new()
	s1.hp = 1000
	s2.hp = 1000

	# Dá cartas iniciais pro jogador 1
	p1.add_card(1)
	p1.add_card(2)
	p1.add_card(1)

	GameManager.start_game(p1, p2, s1, s2)
	_spawn_hand(p1)

func _spawn_hand(player: Player) -> void:
	print("Spawning hand, cartas: ", player.hand.size())
	var hand_node = $Hand
	var spacing = 120  # distância entre cartas
	
	for i in player.hand.size():
		var card = CARD_SCENE.instantiate()
		hand_node.add_child(card)
		card.setup(player.hand[i])
		card.position = Vector2(i * spacing, 0)
		card.card_played.connect(func(id): GameManager.play_card(id))
