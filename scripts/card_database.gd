extends Node
class_name CardDatabase

enum EffectType {
	DAMAGE,
	HEAL,
	DRAW
}

const CARDS := {
	0: {
		"name": "Beta, o Access Point Arcano",
		"description": "Causa 5 de dano ao servidor inimigo.",
		"sprite": "res://assets/cards/beta.png",
		"effect": EffectType.DAMAGE,
		"value": 2,
		"cost": 1
	},
	1: {
		"name": "Nekros, o Switch Profano",
		"description": "Sempre que um pacote positivo for processado pelo seu servidor, você pode gerar um pacote positivo adicional neste turno.",
		"sprite": "res://assets/cards/nekros.png",
		"effect": EffectType.DAMAGE,
		"value": 3,
		"cost": 2
	},
	2: {
		"name": "Oráculo DNS",
		"description": "Uma vez por turno, você pode revelar o próximo pacote antes dele chegar ao seu servidor.",
		"sprite": "res://assets/cards/dns.png",
		"effect": EffectType.DAMAGE,
		"value": 2,
		"cost": 1
	},
	3: {
		"name": "Ransomware Espectral",
		"description": "Sempre que um pacote malicioso atingir o servidor adversário, ele perde 1 ponto de processamento no próximo turno.",
		"sprite": "res://assets/cards/ransomware.png",
		"effect": EffectType.DAMAGE,
		"value": 3,
		"cost": 2
	},
}
static func get_all_ids() -> Array[int]:
	var ids: Array[int] = []
	for key in CARDS.keys():
		ids.append(key)
	return ids
	
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
