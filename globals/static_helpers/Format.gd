extends Node

class_name Format

static func get_height_string(h: float, height_precision: float = 1.0) -> String:
	var meters :float = get_meters(h)
	var kilometers :float = get_kilometers(h)
	
	var heigt_string :String = ""
	if kilometers >= 1:
		heigt_string += str( int(kilometers)) + "km "
	if height_precision == 1.0:
		heigt_string += str( int(meters)) + "m "
	else:
		heigt_string += str( snappedf(meters, height_precision)) + "m "
	return heigt_string

static func get_meters(h: float) -> float:
	var kmts :float = floor(h/1000)
	return h - (kmts * 1000)

static func get_kilometers(h: float) -> float:
	return floor(h/1000)

static func get_time_string(t: float, second_precision: float = 0.1) -> String:	
	var seconds :float = get_seconds(t)
	var minutes :float = get_minutes(t)
	var hours :float = get_hours(t)
	var days :float = get_days(t)
	
	var time_string :String = ""
	if days >= 1:
		time_string += str( int(days)) + "d "
	if hours >= 1:
		time_string += str( int(hours)) + "h "
	if minutes >= 1:
		time_string += str( int(minutes)) + "m "
	if second_precision == 1.0:
		time_string += str( int(seconds)) + "s "
	else:
		var snapped_time_string :String = str(snappedf(seconds, second_precision))
		var decimal_count :int = step_decimals(second_precision)
		snapped_time_string.pad_decimals(decimal_count)
			
		time_string += snapped_time_string + "s "
	return time_string


static func get_seconds(t: float) -> float:
	var mnts :float = floor(t/60)
	return t - (mnts * 60)

static func get_minutes(t: float) -> float:
	t = floor(t)
	var hrs :float = floor(t/3600)
	return floor((t - (hrs * 3600))/60)

static func get_hours(t: float) -> float:
	t = floor(t)
	var dys :float = floor(t/86400)
	return floor((t - (dys * 86400))/3600)

static func get_days(t: float) -> float:
	return floor(t/86400)
