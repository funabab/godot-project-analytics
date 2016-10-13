tool
extends EditorPlugin

var tool_button_control = preload("res://addons/godot-project-analytics.funabab/tool_button.tscn").instance();
var pause_icon          = preload("res://addons/godot-project-analytics.funabab/pause.png");
var play_icon           = preload("res://addons/godot-project-analytics.funabab/play.png");
var file_scanner        = preload("res://addons/godot-project-analytics.funabab/FileScanner.gd").new();
var analysis_dialog     = preload("res://addons/godot-project-analytics.funabab/analysis_dialog.tscn").instance();
var status_icon;
var tool_button;
var editor_tool_button;

var settings = {
"timer_active": true,
"project_time_spent": 0,
"project_duration": 0,
"project_last_analysised": 0,
"project_analysis": {}
};

var time_manager
var settings_manager;

const TOOLBAR_BTN_TITLE = "Project Analytics";
const ANALYSIS_LOADING_DIALOG = "analysis_alert";

func _enter_tree():
	settings_manager = SettingsManager.new(self);
	settings_manager.load_data();
	time_manager = preload("res://addons/godot-project-analytics.funabab/TimeManager.gd").TimeManager.new(settings.project_time_spent);
	file_scanner.connect("completed", self, "_on_analysis_completed");
	
	tool_button = tool_button_control.get_child(0);
	tool_button.connect("pressed", self, "_toggle_timer");
	tool_button_control.get_node("analytic_button").connect("pressed", self, "_on_analytic_btn_pressed");
	status_icon = tool_button.get_child(0);
	get_base_control().add_child(analysis_dialog);
	editor_tool_button = add_control_to_bottom_panel(tool_button_control, TOOLBAR_BTN_TITLE);
	if (!settings_manager.save_exists()):
		settings.project_duration = OS.get_unix_time() - (OS.get_ticks_msec() / 1000);
		pass
	_toggle_timer(!settings.timer_active);
	set_process(true);
	pass

func _process(delta):
	if (settings.timer_active):
		time_manager.update_timestamp();
		pass
	tool_button.set_text("Total time spent: " + time_manager.parse_hour_time_from_secs());
	pass

func _on_analytic_btn_pressed():
#	if (settings.project_analysis.empty()):
#		_start_file_scanning();
#	else:
#		_start_file_scanning();
	_start_file_scanning();
	pass

func _start_file_scanning():
	_delete_analysis_loading_dialog();
	_toogle_analytic_loading_dialog();
	if (file_scanner.is_running()):
		return;
	file_scanner.start("res://");

func _toogle_analytic_loading_dialog(value = null):
	if (get_base_control().has_node(ANALYSIS_LOADING_DIALOG)):
		var alert = get_base_control().get_node(ANALYSIS_LOADING_DIALOG);
		if (value == null):
			value = alert.is_visible();
		alert.set_hidden(value);
	else:
		var alert = AcceptDialog.new();
		alert.set_text("Running Analysis...");
		alert.set_name(ANALYSIS_LOADING_DIALOG);
		alert.set_title("Please wait...");
		alert.set_pos(Vector2((get_base_control().get_viewport_rect().size.x - alert.get_rect().size.x) / 2, (get_base_control().get_viewport_rect().size.y - alert.get_rect().size.y)/2));
		alert.set_exclusive(true);
		get_base_control().add_child(alert);
		if (value != null && value == true):
			get_base_control().get_node(ANALYSIS_LOADING_DIALOG).show();

func _delete_analysis_loading_dialog():
	if (get_base_control().has_node(ANALYSIS_LOADING_DIALOG)):
		get_base_control().get_node(ANALYSIS_LOADING_DIALOG).queue_free();
	pass

func _on_analysis_completed(files_anaysis):
	var current_datatime = OS.get_datetime();
	settings["project_analysis"] = {
		"basic analysis" : {
			"project duration": time_manager.parse_datetime_from_secs(),
			"project lifetime": time_manager.parse_datetime_from_secs(OS.get_unix_time() - settings["project_duration"]),
		},
		"asset analysis": files_anaysis,
	};
	settings_manager.save_data();
	_load_analysis_dialog();
	pass

func _load_analysis_dialog():
	_delete_analysis_loading_dialog();
	analysis_dialog.setup(settings["project_analysis"]);
	analysis_dialog.set_pos(Vector2((get_base_control().get_rect().size.x - analysis_dialog.get_rect().size.x) / 2, (get_base_control().get_rect().size.y - analysis_dialog.get_rect().size.y) / 2));
	analysis_dialog.show();
	pass

func _toggle_timer(value = null):
	var is_active = value;
	if (is_active == null):
		is_active = settings.timer_active;
	if (is_active):
		time_manager.update_timestamp();
		status_icon.set_texture(play_icon);
		editor_tool_button.set_text("Timer: Not Running");
	else:
		time_manager.reset_prev_time();
		status_icon.set_texture(pause_icon);
		editor_tool_button.set_text(TOOLBAR_BTN_TITLE);
	if (value == null):
		settings.timer_active = !settings.timer_active;
	pass

func _exit_tree():
	if (settings.timer_active):
		time_manager.update_timestamp();
	settings.project_time_spent = time_manager.timestamp;
	settings_manager.save_data();
	get_base_control().get_node("analysis_dialog").queue_free();
	remove_control_from_bottom_panel(tool_button_control);
	pass

class SettingsManager:
	var plugin;
	
	func _init(plugin):
		self.plugin = plugin;
		pass

	func load_data():
		var loadfile = File.new();
		if (self.save_exists()):
			loadfile.open("res://addons/godot-project-analytics.funabab/data.json", File.READ);
			plugin.settings.parse_json(loadfile.get_as_text());
			loadfile.close();
		pass

	func save_exists():
		var file = File.new();
		var value = file.file_exists("res://addons/godot-project-analytics.funabab/data.json");
		file.close();
		return value;
		pass

	func save_data():
		var savefile = File.new();
		savefile.open("res://addons/godot-project-analytics.funabab/data.json", savefile.WRITE);
		savefile.store_string(plugin.settings.to_json());
		savefile.close();
		pass
