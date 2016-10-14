
##A simple time msec parser, godot can handle this but i just want a custom one
class TimeManager:
	var hours;
	var minutes;
	var seconds;

	var prev_time;
	var timestamp;
	var time_values = {}; ##used by parse_ functions

	func _init(timestamp = 0):
		self.timestamp = timestamp;
		reset_prev_time();
		reset_time_text_values();
		pass

	func reset_time_text_values():
		self.time_values = {};
		pass

	func parse_hour_time_from_secs(secs = self.timestamp):
		reset_time_text_values();
		if (secs >= 360000):
			return "Over " + str(int(secs/3600)) + " hours";
		else:
			secs = get_hours(secs);
			secs = get_minutes(secs);
			secs = get_seconds(secs);
			return time_values.hours + ":" + time_values.minutes + ":" + time_values.seconds;
		pass

	func parse_datetime_from_secs(secs = self.timestamp):
		reset_time_text_values();
		secs = get_years(secs, false);
		secs = get_months(secs, false);
		secs = get_weeks(secs, false);
		secs = get_days(secs, false);
		secs = get_hours(secs, false);
		secs = get_minutes(secs, false);
		secs = get_seconds(secs);
		return self.time_values;
		pass

	func get_years(secs, dont_ignore_if_less = true):
		## (60x60)x24x7x4x12
		##Sorry.... no leap year :) #
		if (secs < 29030400):
			if (dont_ignore_if_less):
				time_values["years"] = "0";
			return secs;
		time_values["years"] = str(int(secs / 29030400));
		return int(fmod(secs, 29030400));
		pass

	func get_months(secs, dont_ignore_if_less = true):
		## (60x60)x24x7x4
		if (secs < 2419200):
			if (dont_ignore_if_less):
				time_values["months"] = "0";
			return secs;
		time_values["months"] = str(int(secs / 2419200));
		return int(fmod(secs, 2419200));
		pass

	func get_weeks(secs, dont_ignore_if_less = true):
		## (60x60)x24x7
		if (secs < 604800):
			if (dont_ignore_if_less):
				time_values["weeks"] = "0";
			return secs;
		time_values["weeks"] = str(int(secs / 604800));
		return int(fmod(secs, 604800));
		pass

	func get_days(secs, dont_ignore_if_less = true):
		## (60x60)x24
		if (secs < 86400):
			if (dont_ignore_if_less):
				time_values["days"] = "0";
			return secs;
		time_values["days"] = str(int(secs / 86400));
		return int(fmod(secs, 86400));
		pass

	func get_hours(secs, dont_ignore_if_less = true):
		#60x60
		if (secs < 3600):
			if (dont_ignore_if_less):
				time_values["hours"] = "00";
			return secs;
		time_values["hours"] = self.pad_digits(int(secs / 3600));
		return int(fmod(secs, 3600));

	func get_minutes(secs, dont_ignore_if_less = true):
		if (secs < 60):
			if (dont_ignore_if_less):
				time_values["minutes"] = "00";
			return secs;
		time_values["minutes"] = self.pad_digits(int(secs/60));
		return int(fmod(secs, 60));
		pass

	func get_seconds(secs):
		time_values["seconds"] = self.pad_digits(secs);
		return 0;

	func get_timestamp():
		return timestamp;

	func update_timestamp():
		var msecs = OS.get_unix_time();
		timestamp = timestamp + (msecs - prev_time);
		prev_time = msecs;
		pass

	func reset_prev_time():
		prev_time = OS.get_unix_time();
		pass

	func pad_digits(digit):
		var value = str(digit);
		if (digit < 10):
			value = "0" + value;
		return value;
		pass

