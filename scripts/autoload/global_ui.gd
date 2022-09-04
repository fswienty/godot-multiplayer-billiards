extends CanvasLayer

var show_error_anim: AnimationPlayer

onready var error_label: Label = $ErrorLabel
onready var error_label_timer: Timer = error_label.get_node("Timer")
onready var console: TextEdit = $ConsoleTextEdit

var __


func _ready():
	__ = error_label_timer.connect("timeout", self, "_slide_out_error_label")

	show_error_anim = Animations.slide_in_anim(error_label, "y", 100, Globals.menu_transition_time)
	hide_error()

	console.text = ""


func _input(event: InputEvent):
	if event.is_action_pressed("console_toggle"):
		console.visible = !console.visible


func set_console_visible(visible: bool):
	console.visible = visible


func hide_error(animated: bool = false):
	if animated and error_label_timer.time_left > 0:
		show_error_anim.play_backwards("anim")
	else:
		error_label.rect_position = Vector2(0, -1000)
	error_label_timer.stop()


func show_error(error_text: String, show_self: bool = true, show_others: bool = false):
	if show_self:
		_show_error(error_text)
	if show_others:
		rpc("_show_error", error_text)


remote func _show_error(error_text: String):
	error_label.text = error_text
	show_error_anim.play("anim")
	error_label_timer.start()


func print_console(text: String):
	print(text)
	console.text = console.text + text + "\n"
	console.scroll_vertical = console.get_line_count()


func _slide_out_error_label():
	show_error_anim.play_backwards("anim")
