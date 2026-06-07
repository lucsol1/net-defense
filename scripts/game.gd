extends Node2D
const CARD_SCENE = preload("res://scenes/card.tscn")
@onready var hud1: ServerHUD = $server1/ServerHud
@onready var hud2: ServerHUD = $server2/ServerHud
@onready var panel = $panel_transition
@onready var panel_label = $panel_transition/label
@onready var pass_button = $pass_turn

func _ready() -> void:
	var p1 = Player.new(0, "Player 1")
	var p2 = Player.new(1, "Player 2")
	var s1 = Server.new()
	var s2 = Server.new()
	hud1.server = s1
	hud2.server = s2
	s1.hp = 1000
	s2.hp = 1000
	$field1.owner_id = 0
	$field2.owner_id = 1
	p1.build_deck()
	p2.build_deck()
	for i in 5:
		p1.draw_card()
		p2.draw_card()
	GameManager.start_game(p1, p2, s1, s2)
	
	var is_p1_turn = GameManager.current_index == 0
	_spawn_hand(p1, $hand1, not is_p1_turn)
	_spawn_hand(p2, $hand2, is_p1_turn)
	
	panel.hide()
	pass_button.pressed.connect(_on_pass_turn)
	$panel_transition/pass_ready.pressed.connect(_on_ready_pressed)
	
func _on_pass_turn() -> void:
	print("pass turn - current antes: ", GameManager.current_index)
	var next_index = (GameManager.current_index + 1) % 2
	panel_label.text = "Passe o controle para\n" + GameManager.players[next_index].player_name
	panel.show()
	
func _on_ready_pressed() -> void:
	print("ready pressed - current antes: ", GameManager.current_index)
	panel.hide()
	GameManager.end_turn()
	print("ready pressed - current depois: ", GameManager.current_index)
	_rebuild_hands()
	
func _rebuild_hands() -> void:
	for child in $hand1.get_children():
		child.queue_free()
	for child in $hand2.get_children():
		child.queue_free()
	var p1 = GameManager.players[0]
	var p2 = GameManager.players[1]
	var is_p1_turn = GameManager.current_index == 0

	# cartas no field ficam sempre visíveis
	for card in $field1.get_children():
		if card is Card:
			card.flip(false)
			_connect_field_card(card)
	for card in $field2.get_children():
		if card is Card:
			card.flip(false)
			_connect_field_card(card)

	# só a mão do adversário fica face_down
	if is_p1_turn:
		_spawn_hand(p1, $hand1, false)
		_spawn_hand(p2, $hand2, true)
	else:
		_spawn_hand(p1, $hand1, true)
		_spawn_hand(p2, $hand2, false)

func _connect_field_card(card: Card) -> void:
	# desconecta tudo antes para evitar duplicatas
	if card.card_activated.get_connections().size() == 0:
		card.card_activated.connect(func(id): GameManager.activate_card(id))
	if card.card_discarded.get_connections().size() == 0:
		card.card_discarded.connect(func(id): GameManager.discard_card(id))

func _spawn_hand(player: Player, hand_node: Node2D, face_down: bool = false) -> void:
	var spacing = 120
	for i in player.hand.size():
		var card = CARD_SCENE.instantiate()
		hand_node.add_child(card)
		card.setup(player.hand[i], face_down)
		card.position = Vector2(i * spacing, 0)
		if not face_down:
			card.card_played.connect(func(id): GameManager.play_card(id))
			card.card_activated.connect(func(id): GameManager.activate_card(id))
			card.card_discarded.connect(func(id): GameManager.discard_card(id))
