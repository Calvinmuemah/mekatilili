extends Node

signal flag_changed(flag_name: String, value: Variant)
signal journal_updated(category: String, title: String)
signal collectible_added(item_id: String, item_data: Dictionary)
signal community_support_changed(new_value: int)

var story_flags: Dictionary = {}
var community_support: int = 0
var collectibles: Array[Dictionary] = []

var journal_data: Dictionary = {
	"story": [],
	"history": [],
	"collectibles": []
}

func _ready() -> void:
	_init_default_journal()

func _init_default_journal() -> void:
	# Initial historical baseline entry
	add_journal_entry(
		"history",
		"Mekatilili wa Menza & The Agiriama",
		"Mekatilili wa Menza was an elder, prophetess, and resistance leader of the Giriama people of coastal Kenya. In 1913, she organized her community to resist British colonial forced labor, hut taxation, and displacement from ancestral lands."
	)
	add_journal_entry(
		"history",
		"The Sacred Kayas",
		"The Kayas are ancient fortified forest sanctuaries of the Mijikenda peoples, harboring ancestral shrines and council grounds of the elders. Kaya Fungo served as the spiritual and political heart of the Giriama resistance."
	)

func set_flag(key: String, val: Variant) -> void:
	story_flags[key] = val
	flag_changed.emit(key, val)

func get_flag(key: String, default_val: Variant = false) -> Variant:
	return story_flags.get(key, default_val)

func has_flag(key: String) -> bool:
	return story_flags.has(key) and bool(story_flags[key])

func add_journal_entry(category: String, title: String, content: String) -> void:
	if not journal_data.has(category):
		journal_data[category] = []
	for entry in journal_data[category]:
		if entry.get("title", "") == title:
			return # Avoid duplicates
	journal_data[category].append({
		"title": title,
		"content": content,
		"timestamp": Time.get_datetime_string_from_system()
	})
	journal_updated.emit(category, title)

func add_collectible(item_id: String, item_name: String, desc: String, icon_path: String, historical_note: String) -> void:
	for c in collectibles:
		if c.get("id", "") == item_id:
			return # Already collected
	var item_dict := {
		"id": item_id,
		"name": item_name,
		"description": desc,
		"icon": icon_path,
		"historical_note": historical_note
	}
	collectibles.append(item_dict)
	
	# Also record in Journal
	add_journal_entry("collectibles", item_name, desc + "\n\nHistorical Note: " + historical_note)
	collectible_added.emit(item_id, item_dict)
	
	if AudioManager != null:
		AudioManager.play_sfx("sfx_item_collect")

func add_community_support(amount: int) -> void:
	community_support = clampi(community_support + amount, 0, 100)
	community_support_changed.emit(community_support)

func set_community_support(amount: int) -> void:
	community_support = clampi(amount, 0, 100)
	community_support_changed.emit(community_support)

func serialize_journal() -> Dictionary:
	return journal_data.duplicate(true)

func deserialize_journal(data: Dictionary) -> void:
	journal_data = data.duplicate(true)

func reset_state() -> void:
	story_flags.clear()
	community_support = 0
	collectibles.clear()
	journal_data = {"story": [], "history": [], "collectibles": []}
	_init_default_journal()
