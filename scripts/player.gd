extends Node
class_name Player

var id: int
var player_name: String
var is_bot: bool = false
var hand: Array[int] = []
var deck: Array[int] = []
var can_play: bool = false

func _init(_id: int = 0, _player_name: String = "Player") -> void:
	id = _id
	player_name = _player_name

func start_turn() -> void:
	can_play = true

func end_turn() -> void:
	can_play = false

func add_card(card_id: int) -> void:
	hand.append(card_id)

func remove_card(card_id: int) -> void:
	if card_id in hand:
		hand.erase(card_id)

func has_card(card_id: int) -> bool:
	return card_id in hand

func build_deck() -> void:
	deck = CardDatabase.get_all_ids()
	deck.shuffle()

func draw_card() -> void:
	if deck.is_empty():
		deck = CardDatabase.get_all_ids()
		deck.shuffle()
	var card_id = deck.pop_front()
	add_card(card_id)
