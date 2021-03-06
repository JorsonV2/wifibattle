extends Node

var characters = []
var char_id = 0
var rand = RandomNumberGenerator.new()
var close_accept_window_val = 0
var audio_on = true
var pause = false
var config_data

func _ready():
	characters.append(character.new(2, 2, 2, "blue"))
	characters.append(character.new(1, 3, 2, "green"))
	characters.append(character.new(3, 2, 1, "red"))
	characters.append(character.new(2, 1, 3, "gray"))
	rand.randomize()
	check_config_file()
	load_config_file()
	pass
	
func _finalize():
	pass 

func _notification(what):
	if OS.get_name() == "Android":
		if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
				show_quit_window()
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		show_quit_window()
	pass
	
func show_quit_window():
	signals.emit_show_accept_window("You're about to quit", "Do you want to do it?", 1)
	yield(signals, "accept_window_closed")
	if close_accept_window_val == 1:
		if not multi_game.peer == null:
			if multi_game.peer.CONNECTION_CONNECTED:
				multi_game.close_connection()
		get_tree().quit()
	pass
	
func change_audio():
	audio_on = !audio_on
	AudioServer.set_bus_mute(0, audio_on)
	signals.emit_audio_change()
	
func change_game_pause():
	pause = !pause
	signals.change_pause()

func save_config_file(highscore = null, best_wave = null):
	if highscore != null:
		if config_data.highscore < highscore:
			config_data.highscore = highscore
	if best_wave != null:
		if config_data.best_wave < best_wave:
			config_data.best_wave = best_wave
	var config_file = File.new()
	config_file.open("user://config_file.save", File.WRITE)
	config_file.store_string(to_json(config_data))
	config_file.close()
	pass

func check_config_file():
	var config_file = File.new()
	if !config_file.file_exists("user://config_file.save"):
		config_file.open("user://config_file.save", File.WRITE)
		var config_dictionary = {
			highscore = 0,
			best_wave = 0,
			unlocked_all = false
		}
		config_file.store_string(to_json(config_dictionary))
	config_file.close()
	pass
	
func load_config_file():
	var config_file = File.new()
	if config_file.file_exists("user://config_file.save"):
		config_file.open("user://config_file.save", File.READ)
		config_data = parse_json(config_file.get_as_text())
	config_file.close()
	pass
	
func char_available():
	if char_id * 25 <= game_config.config_data.best_wave or game_config.config_data.unlocked_all:
		return true
	return false
	pass
