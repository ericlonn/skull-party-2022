extends Node

signal skull_lost(player, skull_type, skull_as_ammo)
signal skull_count_updated(player, skulls)

signal player_health_updated(player, new_value)
signal player_powered_up(player)
signal player_powered_down(player)

signal player_death_begun(player)
signal player_died(player, color, death_positon)

signal skull_spawned(skull)
signal skull_collected(skull)

signal player_id_assigned(player)

signal chest_spawned(chest)
signal chest_shattered(chest)
