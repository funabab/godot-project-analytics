class DictionaryHelper:
##Godot have a built-in method, but i dont like how it works
	static func keys(dictionary):
		var keys = dictionary.keys();
		keys.sort();
		return keys;
		pass

