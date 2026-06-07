extends Node
class_name CardDatabase

enum EffectType {
	DAMAGE,
	HEAL,
	DRAW,
	GENERATE,
	FIREWALL,
	DRAIN
}

const CARDS := {
	0: {
		"name": "Beta, o Access Point Arcano",
		"description": "Causa 2 de dano ao servidor inimigo.",
		"sprite": "res://assets/cards/beta.png",
		"effect": EffectType.DAMAGE,
		"value": 2,
		"cost": 1,
		"activate_cost": 1
	},
	1: {
		"name": "Nekros, o Switch Profano",
		"description": "Gera 2 pacotes DATA no seu servidor.",
		"sprite": "res://assets/cards/nekros.png",
		"effect": EffectType.GENERATE,
		"value": 2,
		"cost": 2,
		"activate_cost": 1
	},
	2: {
		"name": "Oráculo DNS",
		"description": "Adiciona 2 de firewall ao seu servidor.",
		"sprite": "res://assets/cards/dns.png",
		"effect": EffectType.FIREWALL,
		"value": 2,
		"cost": 1,
		"activate_cost": 1
	},
	3: {
		"name": "Ransomware Espectral",
		"description": "Remove 3 de processing power do servidor inimigo.",
		"sprite": "res://assets/cards/ransomware.png",
		"effect": EffectType.DRAIN,
		"value": 3,
		"cost": 2,
		"activate_cost": 2
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
			enemy_server.hp -= card["value"]
		EffectType.HEAL:
			own_server.hp += card["value"]
		EffectType.DRAW:
			player.add_card(randi_range(0, 3))
		EffectType.GENERATE:
			for i in card["value"]:
				var packet = Packet.new()
				packet.setup(Packet.PacketType.DATA, 1, 0, 1.0, false)
				own_server.add_packet(packet)
		EffectType.FIREWALL:
			own_server.add_firewall(card["value"])
		EffectType.DRAIN:
			enemy_server.processing_power = max(0, enemy_server.processing_power - card["value"])
