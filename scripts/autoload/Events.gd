extends Node

signal skull_lost(player, skull_type)
signal skull_count_updated(player, skulls)

signal player_health_updated(player, new_value)
signal player_died(player, color, death_positon)

signal skull_spawned(skull)
signal skull_collected(skull)

signal player_id_assigned(player, id)

signal chest_spawned(chest)
signal chest_shattered(chest)
