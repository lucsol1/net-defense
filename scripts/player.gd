extends Node

class_name Player

# informaçoes basicas do player	
var id: int
var player_name: String
var is_bot: bool = false

var hand: Array[int] = []
var can_play: bool = false

func _init(_id: int = 0, _player_name: String = "Player")->void:
	id = _id
	player_name = _player_name
	
func add_card(card_id: int)->void:
	hand.append(card_id)
	
func remove_card(card_id: int)->void:
	if card_id in hand:
		hand.erase(card_id)
		
func has_card(card_id: int)->bool:
	return card_id in hand
		
# to do - principal methods play_card, 	start_turn, end_turn
