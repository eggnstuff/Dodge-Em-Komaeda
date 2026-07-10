extends Node

@export var mob_scene: PackedScene
var score
var lives

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	if score > high_score:
		high_score = score
		save_high_score()
		$HUD.update_high_score(high_score)
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	lives = 3
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_lives(lives)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	$Music.play()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	$HUD.update_score(score)
	
func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _ready():
	$Player.hit.connect(_on_hit)
	load_high_score()
	$HUD/DodgeFreeButton.pressed.connect(_on_dodge_free_button_pressed)

func _on_hit():
	print("HIT RECEIVED")
	lives -= 1
	$HUD.update_lives(lives)
	if lives <= 0:
		game_over()
	else:
		$Player.respawn()
		
var high_score = 0

func load_high_score():
	if FileAccess.file_exists("user://highscore.save"):
		var file = FileAccess.open("user://highscore.save", FileAccess.READ)
		high_score = file.get_var()
		file.close()
	$HUD.update_high_score(high_score)

func save_high_score():
	var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	file.store_var(high_score)
	file.close()

var dodge_free_mode = false

func _on_dodge_free_button_pressed():
	dodge_free_mode = !dodge_free_mode
	if dodge_free_mode:
		$MobTimer.stop()
		$ScoreTimer.stop()
		get_tree().call_group("mobs", "queue_free")  # clear existing mobs
	else:
		$MobTimer.start()
		$ScoreTimer.start()
	$HUD.update_dodge_free_button(dodge_free_mode)
