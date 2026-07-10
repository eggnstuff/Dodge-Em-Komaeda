extends CanvasLayer
# Notifies `Main` node that the button has been pressed
signal start_game

func _ready():
	$InfoButton.mouse_entered.connect(_on_info_button_mouse_entered)
	$InfoButton.mouse_exited.connect(_on_info_button_mouse_exited)

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	$GameOverPhoto.modulate.a = 0.0  # start fully transparent
	$GameOverPhoto.show()
	var tween = create_tween()
	tween.tween_property($GameOverPhoto, "modulate:a", 1.0, 0.5)
	await $MessageTimer.timeout
	
	await get_tree().create_timer(1.5).timeout
	
	var fade_out = create_tween()
	fade_out.tween_property($GameOverPhoto, "modulate:a", 0.0, 0.5)
	await fade_out.finished
	$GameOverPhoto.hide()
	
	$Message.text = "Dodge 'Em Komaeda!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)
	
func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()

func update_lives(lives):
	$Clover1.visible = lives >= 1
	$Clover2.visible = lives >= 2
	$Clover3.visible = lives >= 3

func _on_pause_button_pressed():
	get_tree().paused = !get_tree().paused

func update_pause_button(is_paused):
	$PauseButton.text = "Play" if is_paused else "Pause"
	
func _unhandled_input(event):
	if event.is_action_pressed("pause") and not $CreditsPanel.visible:
		get_tree().paused = !get_tree().paused
		update_pause_button(get_tree().paused)
		if get_tree().paused:
			get_node("/root/Main/Music").stream_paused = true
		else:
			get_node("/root/Main/Music").stream_paused = false
	elif event.is_action_pressed("Credits"):
		$CreditsPanel.visible = !$CreditsPanel.visible
		get_tree().paused = $CreditsPanel.visible

func update_high_score(high_score):
	$HighScoreLabel.text = "HI: " + str(high_score)

func _on_info_button_mouse_entered():
	if $CreditsPanel.visible:
		return
	$InfoButton/InfoPanel.visible = !$InfoButton/InfoPanel.visible
	get_tree().paused = $InfoButton/InfoPanel.visible
	
func _on_info_button_mouse_exited():
	$InfoButton/InfoPanel.visible = false
	get_tree().paused = false
	
func update_dodge_free_button(is_active):
	$DodgeFreeButton.text = "Mobs: Off" if is_active else "Mobs: On"

var is_muted = false

func _on_mute_button_pressed():
	is_muted = !is_muted
	get_node("/root/Main/Music").volume_db = -80 if is_muted else 0
	$MuteButton.text = "Unmute" if is_muted else "Mute"
