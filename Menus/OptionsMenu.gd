extends MarginContainer


enum BUS_INDECES { MASTER, MUSIC, SFX }

@export var master_slider : HSlider
@export var music_slider : HSlider
@export var sfx_slider : HSlider


func update() -> void:
	master_slider.ratio = AudioServer.get_bus_volume_linear(BUS_INDECES.MASTER) / 2.0
	music_slider.ratio = AudioServer.get_bus_volume_linear(BUS_INDECES.MUSIC) / 2.0
	sfx_slider.ratio = AudioServer.get_bus_volume_linear(BUS_INDECES.SFX) / 2.0


func _master_volume_changed(new_volume) -> void:
	AudioServer.set_bus_volume_linear(BUS_INDECES.MASTER, master_slider.ratio * 2.0)


func _music_volume_changed(new_volume) -> void:
	AudioServer.set_bus_volume_linear(BUS_INDECES.MUSIC, music_slider.ratio * 2.0)


func _sfx_volume_changed(new_volume) -> void:
	AudioServer.set_bus_volume_linear(BUS_INDECES.SFX, sfx_slider.ratio * 2.0)
