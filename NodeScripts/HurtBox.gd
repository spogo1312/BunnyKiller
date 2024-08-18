class_name  HurtBox
extends Area2D

func  _init() -> void:
	collision_layer = 0
	collision_mask = 8
	
func _ready() -> void:
	connect("area_entered", self._on_area_entered)

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null:
		return
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	if owner.has_method("knock_back"):
		var source_global_position = hitbox.global_position
		var value = hitbox.knockBack
		owner.knock_back(source_global_position, value)
