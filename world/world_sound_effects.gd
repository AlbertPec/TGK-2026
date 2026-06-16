extends Node2D

@onready var train_audio_player = $TrainSound
@onready var world = get_parent()

@onready var no_combat_st_audio_player  = $NoCombatSoundtrack
@onready var combat_st_audio_player  = $CombatSoundtrack

const MUSIC_VOLUME := -15.0
const MUTED_VOLUME := -35.0
const FADE_TIME := 0.5


func play_fragment(start_time: float, duration: float, fade_duration: float = 0.1):
	train_audio_player.volume_db = -40.0
	train_audio_player.play(start_time)

	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(
		train_audio_player,
		"volume_db",
		0.0,
		fade_duration
	)

	await get_tree().create_timer(duration - 1.0).timeout

	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(
		train_audio_player,
		"volume_db",
		-40.0,
		fade_duration
	)

	await fade_out_tween.finished
	train_audio_player.stop()

func _play_train_entered():
	play_fragment(17.95, 1.9)

func _play_train_running():
	play_fragment(6.0, 10.0, 0.5)
	
# ----------------------------------------
func _on_combat_started() -> void:
	if not combat_st_audio_player.playing:
		combat_st_audio_player.play()
		no_combat_st_audio_player.stop()

	combat_st_audio_player.volume_db = MUSIC_VOLUME
	var tween = create_tween()
	tween.set_parallel(true)

	#tween.tween_property(
		#no_combat_st_audio_player,
		#"volume_db",
		#MUTED_VOLUME,
		#FADE_TIME
	#)

	tween.tween_property(
		combat_st_audio_player,
		"volume_db",
		MUSIC_VOLUME,
		FADE_TIME
	)

func _on_combat_ended() -> void:
	if not no_combat_st_audio_player.playing:
		no_combat_st_audio_player.play()
		combat_st_audio_player.stop()
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		combat_st_audio_player,
		"volume_db",
		MUTED_VOLUME,
		FADE_TIME
	)

	tween.tween_property(
		no_combat_st_audio_player,
		"volume_db",
		MUSIC_VOLUME,
		FADE_TIME
	)
# ----------------------------------------


func _ready() -> void:
	world.train_entered.connect(_play_train_entered)
	world.train_running.connect(_play_train_running)
	
	world.combat_started.connect(_on_combat_started)
	world.combat_ended.connect(_on_combat_ended)
	
	_on_combat_ended() #start playing no combat song
