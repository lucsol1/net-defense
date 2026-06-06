extends Node2D
class_name Card

signal card_played(card_id)
signal card_discarded(card_id)
signal card_activated(card_id)

var in_field: bool = false
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

func _input(event: InputEvent) -> void:
	if not in_field:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var half = Vector2(120.0, 160.0) / 2.0
		var rect = Rect2(global_position - half, Vector2(120.0, 160.0))
		if rect.has_point(get_global_mouse_position()):
			_show_field_menu()
			get_viewport().set_input_as_handled()

func _on_area_input(_viewport, event, _shape_idx) -> void:
	print("area input - in_field: ", in_field, " face_down: ", face_down)
	if in_field:
		return
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
			if not face_down:
				_check_drop()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			_show_details()
		else:
			_hide_details()

func _show_field_menu() -> void:
	if get_node_or_null("/root/FieldMenu"):
		return
	var menu = PopupMenu.new()
	menu.name = "FieldMenu"
	menu.add_item("Ativar poder", 0)
	menu.add_item("Descartar", 1)
	get_tree().root.add_child(menu)
	var screen_pos = get_viewport().get_canvas_transform() * global_position
	menu.position = Vector2i(screen_pos)
	menu.popup()
	menu.id_pressed.connect(func(id):
		if id == 0:
			emit_signal("card_activated", card_id)
		else:
			emit_signal("card_discarded", card_id)
			queue_free()
		menu.queue_free()
	)

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
	if dragging and not in_field and not face_down:
		global_position = get_global_mouse_position()

func flip(_face_down: bool) -> void:
	face_down = _face_down
	if face_down:
		card_image.texture = back_texture
	else:
		var data = CardDatabase.get_card(card_id)
		if data.get("sprite", "") != "":
			card_image.texture = load(data["sprite"])
			card_image.scale = Vector2(
				120.0 / card_image.texture.get_size().x,
				160.0 / card_image.texture.get_size().y
			)

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
			var cost = CardDatabase.get_card(card_id).get("cost", 0)
			if not GameManager.current_server().can_afford(cost):
				global_position = original_position
				return

			field.occupy_slot(other_area)

			# guarda tudo antes de mudar de pai
			var slot_global_pos = other_area.global_position
			var target_size = Vector2(field.SLOT_WIDTH, field.SLOT_HEIGHT)
			# usa tamanho base da imagem sem scale aplicado
			var base_size = card_image.texture.get_size() * card_image.scale
			var new_scale = Vector2(target_size.x / base_size.x, target_size.y / base_size.y)

			var old_parent = get_parent()
			old_parent.remove_child(self)
			field.add_child(self)

			# reseta scale antes de aplicar o novo
			scale = Vector2.ONE
			global_position = slot_global_pos
			scale = new_scale
			z_index = 1
			dragging = false
			in_field = true
			emit_signal("card_played", card_id)
			return
	global_position = original_position

func get_sprite_size() -> Vector2:
	if card_image.texture:
		return card_image.texture.get_size() * card_image.scale
	return Vector2(100.0, 140.0)
