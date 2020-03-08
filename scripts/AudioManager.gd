extends Node

class_name AudioManager

onready var bass = $bass as AudioStreamPlayer
onready var scratch = $scratch as AudioStreamPlayer
onready var hihat = $hihat as AudioStreamPlayer
onready var rewind = $rewind as AudioStreamPlayer
onready var clap = $clap as AudioStreamPlayer

func internal_play(sound: AudioStreamPlayer):
	sound.play()

func play(sound: String):
	match sound:
		"bass": internal_play(bass);
		"scratch": internal_play(scratch);
		"hihat": internal_play(hihat);
		"rewind": internal_play(rewind);
		"clap": internal_play(clap);
		_: printerr("invalid sound: " + sound)
