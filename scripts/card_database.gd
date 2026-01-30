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
		"sprite": "",
		"effect": EffectType.DAMAGE,
		"value": 5
	},
	2: {
		"name": "Firewall Arcano",
		"sprite": "",
		"effect": EffectType.HEAL,
		"value": 3
	}
}

static func get_card(card_id: int) -> Dictionary:
	return CARDS.get(card_id, {})

static func apply_effect(card_id: int, player: Player) -> void:
	var card = get_card(card_id)
	if card.is_empty():
		return
	
	match card.effect:
		EffectType.DAMAGE:
			print("Causando dano:", card.value)
		EffectType.HEAL:
			print("Curando:", card.value)
		EffectType.DRAW:
			print("Comprando carta")
