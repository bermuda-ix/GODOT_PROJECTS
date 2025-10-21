class_name Inventory extends Node


var player_inventory : Dictionary = {
	}
	
func clear_inv() -> void:
	player_inventory.clear()

func add_inv(item : String, amount : int = 1) -> void:
	if player_inventory.has(item):
		player_inventory[item] += amount
		Events.update_inventory.emit(item, player_inventory[item])
	else:
		player_inventory[item] = amount
		Events.add_inventory.emit(item)
		
	print(player_inventory)

func remove_inv(item: String, amount : int = 1) -> void:
	if player_inventory.has(item):
		if amount<player_inventory[item]:
			player_inventory[item] -= amount
			Events.update_inventory.emit(item, player_inventory[item])
		else:
			player_inventory.erase(item)
			Events.remove_inventory.emit(item)
	else:
		print("No item to remove")

func save_inv_data() -> void:
	pass
	
func load_inv_data() -> void:
	pass
