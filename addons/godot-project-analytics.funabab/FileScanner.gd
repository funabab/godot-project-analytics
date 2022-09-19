
extends Reference
var root;

var scanned_files = [];
var scanned_dirs = [];
const IGNORE_DIRS = ["res://addons", "res://.git", "res://.idea", "res://.import"];
const IGNORE_FILES = ["res://engine.cfg", "res://export.cfg"];
const IGNORE_EXT = ["flags", "import"];

var dir;
var process:Thread
signal completed;
var code_scanner = preload("res://addons/godot-project-analytics.funabab/CodeScanner.gd").CodeScanner.new();


func _init():
	dir = Directory.new();
	pass


func is_running():
	return process and process.is_alive()


func start(path):
	process = Thread.new();
	process.start(self, "scan_path", path)


func scan_path(path):
	dir.open(path);
	dir.list_dir_begin();
	var filename;
	var result;
	while(true):
		filename = dir.get_next();
		while(filename == "." || filename == ".."):
			filename = dir.get_next();
		if (filename == ""):
			if (dir.get_current_dir() == path):
				dir.list_dir_end()
				result = analyse_files(scanned_files) ## finished scanning files 
				break;
			else:
				scanned_dirs.push_back(dir.get_current_dir());
				dir.list_dir_end();
				dir.change_dir("..");
				dir.list_dir_begin();
				continue;
		else:
			if (dir.current_is_dir() && !IGNORE_DIRS.has(dir.get_current_dir().plus_file(filename)) && !scanned_dirs.has(dir.get_current_dir().plus_file(filename))):
				dir.list_dir_end();
				dir.change_dir(filename);
				dir.list_dir_begin();
				continue;
			elif (!dir.current_is_dir()):
				var filepath = dir.get_current_dir().plus_file(filename);
				if (!scanned_files.has(filepath) && !IGNORE_FILES.has(filepath) && !IGNORE_EXT.has(filepath.get_extension())):
					scanned_files.push_back(filepath)
	on_completed(result);
	return result;


func analyse_files(scanned_files):
	var result = {
		"file sizes": {},
		"file counts": {},
		"source code": {},
	}
	var file_extension;
	var file_type_name;
	var filesize;
	var file = File.new();
	for i in range(scanned_files.size()):
		file_extension = scanned_files[i].get_extension();
		file_type_name = "_." + file_extension + " files";
		if (file_extension == scanned_files[i]):
			continue;
		file.open(scanned_files[i], file.READ);
		filesize = file.get_len();
		file.close();
		if (!result["file counts"].has(file_type_name)):
			result["file counts"][file_type_name] =  0;
		if (!result["file sizes"].has(file_type_name)):
			result["file sizes"][file_type_name] =  0;
		result["file counts"][file_type_name] += 1;
		result["file sizes"][file_type_name] +=  filesize;
		if (file_extension == "gd"):
			var src_scan_result = code_scanner.scan_file(scanned_files[i]);
			var result_keys = src_scan_result.keys();
			for key in result_keys:
				if (src_scan_result[key] == 0):
					continue;
				if (!result["source code"].has(key)):
					result["source code"][key] = 0;
				result["source code"][key] += src_scan_result[key];
	## format size properly
	var file_types = result["file sizes"].keys()
	for type in file_types:
		result["file sizes"][type] = get_file_size_text(result["file sizes"][type])
	return result

func get_file_size_text(byte_size):
	if (byte_size >= 1073741824):
		return str(float(byte_size) / 1073741824.00).pad_decimals(2) + " GB";
	elif (byte_size >= 1048576):
		return str(float(byte_size) / 1048576.00).pad_decimals(2) + " MB";
	elif (byte_size >= 1024):
		return str(float(byte_size) / 1024.00).pad_decimals(2) + " KB";
	else:
		return str(byte_size) + " bytes";

func on_completed(result):
	emit_signal("completed", result)
	process.call_deferred('wait_to_finish')
