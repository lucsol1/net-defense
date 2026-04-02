extends Node2D
class_name Card

signal card_played(card_id)

var card_id: int
var original_position: Vector2
var dragging := false
var face_down: bool = false          
@export var back_texture: Texture2D 

@onready var card_image: Sprite2D = $CardImage
@onready var area: Area2D = $Area2D

var original_scale: Vector2
var original_z: int

var preview: Node2D = null

func _ready() -> void:
	area.input_event.connect(_on_area_input)

func _on_area_input(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			
			if face_down:
				return
				
			dragging = true
			original_position = global_position
			z_index = 100
		else:
			dragging = false
			z_index = 0
			_check_drop()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			_show_details()
		else:
			_hide_details()

func _show_details() -> void:
	if face_down:
		return
	preview = duplicate()
	get_tree().root.add_child(preview)
	preview.scale = Vector2(3, 3)
	preview.global_position = get_viewport().get_visible_rect().size / 2
	preview.z_index = 200

func _hide_details() -> void:
	if preview:
		preview.queue_free()
		preview = null

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()

func setup(_card_id: int, _face_down: bool = false) -> void:
	card_id = _card_id
	face_down = _face_down
	
	if face_down:
		card_image.texture = back_texture
		return
	
	var data = CardDatabase.get_card(card_id)
	
	if data.get("sprite", "") != "":
		card_image.texture = load(data["sprite"])
		
		card_image.scale = Vector2(
			120.0 / card_image.texture.get_size().x,
			160.0 / card_image.texture.get_size().y
		)

func _check_drop() -> void:
	var overlapping = area.get_overlapping_areas()
	for other_area in overlapping:
		if other_area.is_in_group("play_area"):
			var field = other_area.get_parent()
			
			if field.owner_id != GameManager.current_index:
				global_position = original_position
				return
				 
			if not field.is_slot_free(other_area):
				global_position = original_position
				return
			
			field.occupy_slot(other_area)
			
			var old_parent = get_parent()
			old_parent.remove_child(self)
			field.add_child(self)
			
			# encaixa no slot
			global_position = other_area.global_position
			z_index = 1
			
			# redimensiona pro tamanho do slot
			var target_size = Vector2(field.SLOT_WIDTH, field.SLOT_HEIGHT)
			var sprite_size = get_sprite_size()
			scale = Vector2(target_size.x / sprite_size.x, target_size.y / sprite_size.y)
			
			print("sprite_size: ", get_sprite_size())
			print("target_size: ", target_size)
			print("scale calculado: ", scale)
			
			dragging = false
			area.input_event.disconnect(_on_area_input)
			
			emit_signal("card_played", card_id)
			return

	global_position = original_position

func get_sprite_size() -> Vector2:
	if card_image.texture:
		return card_image.texture.get_size() * card_image.scale
	return Vector2(100, 140)
