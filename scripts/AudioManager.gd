extends Node

class_name AudioManager

onready var bass = $bass as AudioStreamPlayer
onready var scratch = $scratch as AudioStreamPlayer
onready var hihat = $hihat as AudioStreamPlayer
onready var rewind = $rewind as AudioStreamPlayer
onready var clap = $clap as AudioStreamPlayer
onready var snare = $snare as AudioStreamPlayer

onready var house_01 = $house_01 as AudioStreamPlayer

func internal_play(sound: AudioStreamPlayer):
	sound.play()

func play(sound: String):
	match sound:
		"bass": internal_play(bass);
		"scratch": internal_play(scratch);
		"hihat": internal_play(hihat);
		"rewind": internal_play(rewind);
		"clap": internal_play(clap);
		"snare": internal_play(snare);
		_: printerr("invalid sound: " + sound)

func play_song(song: String):
	match song:
		"house_01": internal_play(house_01)
		_: printerr("invalid song: " + song)
