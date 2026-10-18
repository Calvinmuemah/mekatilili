@tool
extends SceneTree

func _init() -> void:
	print("--- Debugging Android Export Preset ---")
	var f = ConfigFile.new()
	var err = f.load("res://export_presets.cfg")
	if err != OK:
		print("Could not load export_presets.cfg: ", err)
		quit(1)
		return
		
	for section in f.get_sections():
		print("\n[" + section + "]")
		for key in f.get_section_keys(section):
			print(key, " = ", f.get_value(section, key))
			
	quit(0)
