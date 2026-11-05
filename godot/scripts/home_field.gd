extends Control
## Opening still of the Expo Home playing field (camp tile, tower ring, party).
## There is no Lamp Room in the Expo app. This scene does not simulate play
## and does not read or write little-keep-save-v1.

const VIEW_MIN := 20.0
const VIEW_SPAN := 60.0

const MEADOW := Color("6fbf73")
const MEADOW_DEEP := Color("3e9a4a")
const FOREST := Color("2f6f3c")
const GOLD := Color("f2c14e")
const GOLD_DEEP := Color("d4a017")
const CREAM := Color("fff8e8")
const INK := Color("2b3a42")
const INK_SOFT := Color("5a6b73")
const CORAL := Color("f0785a")

const TOWER_SLOTS: Array[Vector2] = [
	Vector2(36.5, 36.5),
	Vector2(63.5, 36.5),
	Vector2(36.5, 63.5),
	Vector2(63.5, 63.5),
]

# Same local offsets as src/game/world.ts FOREST_LAYOUT. Camp (1,1) has no pines.
const FOREST_LAYOUT: Array = [
	{"c": 0, "r": 0, "trees": [[0.22, 0.28], [0.48, 0.2], [0.72, 0.32], [0.3, 0.55], [0.62, 0.58], [0.4, 0.78], [0.78, 0.72]]},
	{"c": 1, "r": 0, "trees": [[0.18, 0.3], [0.42, 0.18], [0.7, 0.26], [0.28, 0.58], [0.58, 0.5], [0.78, 0.68], [0.48, 0.8]]},
	{"c": 2, "r": 0, "trees": [[0.24, 0.22], [0.55, 0.3], [0.78, 0.2], [0.32, 0.52], [0.68, 0.55], [0.2, 0.75], [0.6, 0.78]]},
	{"c": 0, "r": 1, "trees": [[0.2, 0.22], [0.45, 0.18], [0.28, 0.48], [0.18, 0.7], [0.5, 0.62], [0.38, 0.82], [0.68, 0.78]]},
	{"c": 2, "r": 1, "trees": [[0.3, 0.2], [0.62, 0.18], [0.78, 0.4], [0.55, 0.52], [0.28, 0.6], [0.7, 0.72], [0.42, 0.82]]},
	{"c": 0, "r": 2, "trees": [[0.22, 0.24], [0.5, 0.2], [0.78, 0.32], [0.3, 0.5], [0.62, 0.48], [0.2, 0.75], [0.58, 0.78]]},
	{"c": 1, "r": 2, "trees": [[0.2, 0.22], [0.48, 0.28], [0.75, 0.2], [0.32, 0.52], [0.65, 0.55], [0.22, 0.78], [0.7, 0.75]]},
	{"c": 2, "r": 2, "trees": [[0.28, 0.2], [0.55, 0.28], [0.78, 0.22], [0.22, 0.5], [0.6, 0.52], [0.4, 0.75], [0.72, 0.78]]},
]

var _display: Font
var _body: Font


func _ready() -> void:
	_display = _load_font("res://fonts/Fredoka-Bold.ttf")
	_body = _load_font("res://fonts/Nunito-SemiBold.ttf")
	var world := Control.new()
	world.name = "World"
	world.set_anchors_preset(Control.PRESET_FULL_RECT)
	world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world)
	_paint_world(world)
	_paint_hud()


func _load_font(path: String) -> Font:
	if ResourceLoader.exists(path):
		var font := load(path) as Font
		if font != null:
			return font
	return ThemeDB.fallback_font


func _paint_world(world: Control) -> void:
	for r in 3:
		for c in 3:
			var tile := ColorRect.new()
			tile.color = MEADOW if c == 1 and r == 1 else FOREST
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_tile_rect(tile, c, r)
			world.add_child(tile)
			if c != 1 or r != 1:
				var fog := ColorRect.new()
				fog.color = Color(40.0 / 255.0, 70.0 / 255.0, 50.0 / 255.0, 0.55)
				fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
				_tile_rect(fog, c, r)
				world.add_child(fog)

	_pad(world, 41.4, 51.4, "Farm")
	_pad(world, 58.6, 51.4, "Woodshed")
	_pad(world, 50.0, 57.4, "Store")

	for slot in TOWER_SLOTS:
		_gold_square(world, slot.x, slot.y)

	var pine_tex := load("res://art/pine.png") as Texture2D
	var back: Array[Vector2] = []
	var front: Array[Vector2] = []
	for tile in FOREST_LAYOUT:
		for pair in tile["trees"]:
			var at := _local_to_world(int(tile["c"]), int(tile["r"]), float(pair[0]), float(pair[1]))
			if at.y <= 54.0:
				back.append(at)
			else:
				front.append(at)
	for at in back:
		_sprite(world, pine_tex, at.x, at.y, 52, 96)
	_sprite(world, load("res://art/hut.png"), 50.0, 49.2, 118, 118)
	_court(world, "res://art/mira.png", 45.2, 54.0, "Mira")
	_court(world, "res://art/blink.png", 54.8, 54.0, "Blink")
	_court(world, "res://art/nana.png", 50.0, 56.6, "Nana")
	_sprite(world, load("res://art/pip.png"), 50.0, 52.4, 64, 64)
	for at in front:
		_sprite(world, pine_tex, at.x, at.y, 52, 96)
	_flag(world, 50.0, 61.2)


func _paint_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "Hud"
	add_child(hud)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)

	var bar := _panel(CREAM, GOLD_DEEP, 16)
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.offset_left = 12
	bar.offset_top = 12
	bar.offset_right = -12
	bar.offset_bottom = 52
	root.add_child(bar)
	var resources := _label("Food 22    Wood 4    Stars 0", 16, INK, _body)
	resources.set_anchors_preset(Control.PRESET_FULL_RECT)
	resources.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resources.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(resources)

	var chip := _panel(Color(1, 0.973, 0.91, 0.94), Color(43.0 / 255.0, 58.0 / 255.0, 66.0 / 255.0, 0.12), 14)
	chip.set_anchors_preset(Control.PRESET_TOP_WIDE)
	chip.offset_left = 12
	chip.offset_top = 60
	chip.offset_right = -12
	chip.offset_bottom = 112
	root.add_child(chip)
	var hint := _label("Find all four towers first (0/4). Walls go up when every corner is planted.", 15, INK, _body)
	hint.set_anchors_preset(Control.PRESET_FULL_RECT)
	hint.offset_left = 10
	hint.offset_right = -10
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chip.add_child(hint)

	var strip := HBoxContainer.new()
	strip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	strip.offset_left = 12
	strip.offset_top = -168
	strip.offset_right = -12
	strip.offset_bottom = -96
	strip.alignment = BoxContainer.ALIGNMENT_CENTER
	strip.add_theme_constant_override("separation", 8)
	root.add_child(strip)
	_portrait(strip, "res://art/pip.png", "Knight", true)
	_portrait(strip, "res://art/mira.png", "Ranger", false)
	_portrait(strip, "res://art/blink.png", "Fairy", false)
	_portrait(strip, "res://art/nana.png", "Cleric", false)

	var stick := _panel(Color(0.949, 0.757, 0.306, 0.35), GOLD_DEEP, 48)
	stick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	stick.offset_left = 16
	stick.offset_top = -84
	stick.offset_right = 96
	stick.offset_bottom = -4
	root.add_child(stick)
	var nub := _panel(GOLD, GOLD_DEEP, 22)
	nub.set_anchors_preset(Control.PRESET_CENTER)
	nub.offset_left = -18
	nub.offset_top = -18
	nub.offset_right = 18
	nub.offset_bottom = 18
	stick.add_child(nub)

	var action := _panel(CREAM, GOLD, 28)
	action.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	action.offset_left = -84
	action.offset_top = -84
	action.offset_right = -12
	action.offset_bottom = -8
	root.add_child(action)
	var action_label := _label("Action", 14, INK, _display)
	action_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	action.add_child(action_label)


func _local_to_world(c: int, r: int, lx: float, ly: float) -> Vector2:
	return Vector2((float(c) + lx) / 3.0 * 100.0, (float(r) + ly) / 3.0 * 100.0)


func _tile_rect(node: Control, c: int, r: int) -> void:
	var x0 := float(c) / 3.0 * 100.0
	var y0 := float(r) / 3.0 * 100.0
	var x1 := float(c + 1) / 3.0 * 100.0
	var y1 := float(r + 1) / 3.0 * 100.0
	node.anchor_left = (x0 - VIEW_MIN) / VIEW_SPAN
	node.anchor_top = (y0 - VIEW_MIN) / VIEW_SPAN
	node.anchor_right = (x1 - VIEW_MIN) / VIEW_SPAN
	node.anchor_bottom = (y1 - VIEW_MIN) / VIEW_SPAN
	node.offset_left = 0
	node.offset_top = 0
	node.offset_right = 0
	node.offset_bottom = 0


func _pin(node: Control, x_pct: float, y_pct: float, w: float, h: float) -> void:
	var ax := (x_pct - VIEW_MIN) / VIEW_SPAN
	var ay := (y_pct - VIEW_MIN) / VIEW_SPAN
	node.anchor_left = ax
	node.anchor_top = ay
	node.anchor_right = ax
	node.anchor_bottom = ay
	node.offset_left = -w * 0.5
	node.offset_top = -h * 0.5
	node.offset_right = w * 0.5
	node.offset_bottom = h * 0.5
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _sprite(parent: Node, texture: Texture2D, x_pct: float, y_pct: float, w: float, h: float) -> void:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pin(rect, x_pct, y_pct, w, h)
	parent.add_child(rect)


func _panel(fill: Color, border: Color, radius: int) -> Panel:
	var panel := Panel.new()
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(2)
	box.set_corner_radius_all(radius)
	panel.add_theme_stylebox_override("panel", box)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _label(text: String, size: int, color: Color, font: Font) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _pad(parent: Node, x_pct: float, y_pct: float, caption: String) -> void:
	var panel := _panel(Color(1, 0.973, 0.91, 0.16), Color(1, 0.973, 0.91, 0.7), 12)
	_pin(panel, x_pct, y_pct, 56, 40)
	parent.add_child(panel)
	var label := _label(caption, 11, CREAM, _body)
	label.position = Vector2(-8, 34)
	label.size = Vector2(72, 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(label)


func _gold_square(parent: Node, x_pct: float, y_pct: float) -> void:
	var panel := _panel(Color(0.949, 0.757, 0.306, 0.2), GOLD, 10)
	_pin(panel, x_pct, y_pct, 72, 72)
	parent.add_child(panel)
	var label := _label("8 wood", 12, INK, _body)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)


func _court(parent: Node, art_path: String, x_pct: float, y_pct: float, caption: String) -> void:
	var rect := TextureRect.new()
	rect.texture = load(art_path)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.modulate = Color(1, 1, 1, 0.55)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pin(rect, x_pct, y_pct, 48, 48)
	parent.add_child(rect)
	var label := _label(caption, 11, CREAM, _body)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pin(label, x_pct, y_pct + 2.2, 64, 16)
	parent.add_child(label)


func _flag(parent: Node, x_pct: float, y_pct: float) -> void:
	var pole := ColorRect.new()
	pole.color = GOLD_DEEP
	pole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pin(pole, x_pct, y_pct, 4, 36)
	parent.add_child(pole)
	var pennant := ColorRect.new()
	pennant.color = CORAL
	pennant.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pin(pennant, x_pct + 1.1, y_pct - 0.8, 18, 12)
	parent.add_child(pennant)


func _portrait(strip: HBoxContainer, art_path: String, role: String, active: bool) -> void:
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.custom_minimum_size = Vector2(72, 64)
	strip.add_child(col)
	var frame := _panel(CREAM, GOLD if active else MEADOW_DEEP, 12)
	frame.custom_minimum_size = Vector2(56, 56)
	col.add_child(frame)
	var rect := TextureRect.new()
	rect.texture = load(art_path)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.offset_left = 4
	rect.offset_top = 4
	rect.offset_right = -4
	rect.offset_bottom = -4
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not active:
		rect.modulate = Color(1, 1, 1, 0.45)
	frame.add_child(rect)
	var tag := _label(role, 12, INK if active else INK_SOFT, _body)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(tag)
