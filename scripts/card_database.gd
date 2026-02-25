extends Node
class_name CardDatabase

enum EffectType {
	DAMAGE,
	HEAL,
	DRAW
}

const CARDS := {
	1: {
		"name": "Mago do Roteamento",
		"sprite": "res://assets/cards/roteador.png",
		"effect": EffectType.DAMAGE,
		"value": 5,
		"cost": 3
	},
	2: {
		"name": "Firewall Arcano",
		"sprite": "res://assets/cards/firewall.png",
		"effect": EffectType.HEAL,
		"value": 3,
		"cost": 1
	}
}

static func get_card(card_id: int) -> Dictionary:
	return CARDS.get(card_id, {})

static func apply_effect(card_id: int, player: Player, own_server: Server, enemy_server: Server) -> void:	
	var card = get_card(card_id)
	if card.is_empty():
		return
	match card["effect"]:
		EffectType.DAMAGE:
			print("Causando dano:", card.value)
			enemy_server.hp -= card["value"]
		EffectType.HEAL:
			print("Curando:", card.value)
			own_server.hp += card["value"]
		EffectType.DRAW:
			print("Comprando carta")
			player.add_card(randi_range(1, 2))
