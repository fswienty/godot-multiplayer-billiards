# MIT License
#
# Copyright (c) 2020-2022 Macaroni Studios AB
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class_name _GotmScoreLocal
#warnings-disable

const _global = {"scores": null}

const FILE_NAME := "scores.json"

static func _get_scores() -> Dictionary:
	if _global.scores != null:
		return _global.scores

	var file = File.new()
	file.open(_Gotm.get_local_path(FILE_NAME), File.READ)
	var content = file.get_as_text() if file.is_open() else ""
	file.close()
	if content:
		_global.scores = parse_json(content)
		if !_global.scores:
			_global.scores = {}
	else:
		_global.scores = {}
	return _global.scores

static func _write_scores() -> void:
	var file = File.new()
	file.open(_Gotm.get_local_path(FILE_NAME), File.WRITE)
	file.store_string(to_json(_get_scores()))
	file.close()

static func create(api: String, data: Dictionary):
	yield(_GotmUtility.get_tree(), "idle_frame")
	var score = {
		"path": _GotmUtility.create_resource_path(api),
		"author": _GotmAuthLocal.get_user(),
		"name": data.name,
		"value": data.value,
		"props": data.props if data.get("props") else {},
		"created": _GotmUtility.get_iso_from_unix_time()
	}
	_get_scores()[score.path] = score
	_write_scores()
	return _format(score)
#
static func update(id: String, data: Dictionary):
	yield(_GotmUtility.get_tree(), "idle_frame")
	if !(id in _get_scores()):
		return
	var score = _get_scores()[id]
	for key in data:
		score[key] = data[key]
	_write_scores()
	return _format(score)

static func delete(id: String) -> void:
	yield(_GotmUtility.get_tree(), "idle_frame")
	_get_scores().erase(id)
	_write_scores()

static func fetch(path: String, query: String = "", params: Dictionary = {}, authenticate: bool = false) -> Dictionary:
	yield(_GotmUtility.get_tree(), "idle_frame")
	var path_parts = path.split("/")
	var api = path_parts[0]
	var id = path_parts[1]
	if api == "stats" && id == "rank" && query == "rankByScoreSort":
		return {"path": _GotmStore.create_request_path(path, query, params), "value": _fetch_rank(params)}
	return _format(_get_scores().get(path))

static func list(api: String, query: String, params: Dictionary = {}, authenticate: bool = false) -> Array:
	yield(_GotmUtility.get_tree(), "idle_frame")
	if api == "scores" && query == "byScoreSort":
		return _fetch_by_score_sort(params)
	if api == "stats" && query == "countByScoreSort":
		return _fetch_counts(params)
	return []

static func clear_cache(path: String) -> void:
	pass

static func _fetch_counts(params) -> Array:
	var fetch_params = _GotmUtility.copy(params, {})
	fetch_params.descending = true
	fetch_params.erase("limit")
	var scores = _fetch_by_score_sort(fetch_params)
	var stats := []
	for i in range(0, params.limit):
		stats.append({"value": 0})
	
	if scores.empty():
		return stats
	
	var min_value = params.get("min")
	var max_value = params.get("max")
	if !(min_value is float):
		min_value = scores[scores.size() - 1].value
	if !(max_value is float):
		max_value = scores[0].value
	var step = (max_value - min_value) / params.limit
	for i in range(0, params.limit):
		var is_last = i == params.limit - 1
		var start = min_value + step * i
		var end = max_value if is_last else min_value + step * (i + 1)
		for score in scores:
			if score.value >= start && (score.value <= end if is_last else score.value < end):
				stats[i].value += 1

	return stats

static func _fetch_rank(params) -> int:
	params = _GotmUtility.copy(params, {})
	params.descending = true
	var scores = _fetch_by_score_sort(params)
	var match_score
	if params.get("score"):
		match_score = _get_scores()[params.score]
	elif params.get("value") is float:
		match_score = {"value": params.value, "created": _GotmUtility.get_iso_from_unix_time(), "path": _GotmUtility.create_resource_path("scores")}
	match_score = _format(match_score)
	if !match_score:
			return 0
	var rank = 1
	var predicate := ScoreSearchPredicate.new()
	predicate.is_oldest_first = !!params.get("isOldestFirst")
	for score in scores:
		if match_score.path == score.path || (predicate.is_less_than(match_score, score) if params.get("isInverted") else predicate.is_greater_than(match_score, score)):
			return rank
		rank += 1
	return rank

static func _match_props(subset, superset) -> bool:
	if typeof(subset) != typeof(superset):
		return false
	if subset is Dictionary:
		if subset.size() > superset.size():
			return false
		for key in subset:
			if !(key in superset) || !_match_props(subset[key], superset[key]):
				return false
		return true
	if subset is Array:
		if subset.size() > superset.size():
			return false
		for i in range(0, subset.size()):
			if !_match_props(subset[i], superset[i]):
				return false
		return true
	return subset == superset

static func _get_range_from_period(period: String) -> Array:
	match period:
		GotmPeriod.TimeGranularity.ALL:
			return [null, null]
		GotmPeriod.TimeGranularity.YEAR, GotmPeriod.TimeGranularity.MONTH, GotmPeriod.TimeGranularity.WEEK, GotmPeriod.TimeGranularity.DAY:
			return [_GotmUtility.get_iso_from_unix_time(GotmPeriod.sliding(period).to_unix_time()), null]

	if period.begins_with(GotmPeriod.TimeGranularity.WEEK):
		var week_number = int(period.substr(GotmPeriod.TimeGranularity.WEEK.length(), period.length() - GotmPeriod.TimeGranularity.WEEK.length()))
		if week_number > 0:
			var ms_per_day = 1000 * 60 * 60 * 24
			var unix_time =  ms_per_day * 7 * week_number
			return [_GotmUtility.get_iso_from_unix_time(unix_time - ms_per_day * 3), _GotmUtility.get_iso_from_unix_time(unix_time + ms_per_day * 4 - 1)]

	var parts = period.split("-")
	var year = parts[0] if parts.size() >= 1 else ""
	var month = parts[1] if parts.size() >= 2 else ""
	var day = parts[2] if parts.size() >= 3 else ""
	var granularity: String = ""
	if day:
		granularity = GotmPeriod.TimeGranularity.DAY
		year = int(year)
		month = int(month)
		day = int(day)
	elif month:
		granularity = GotmPeriod.TimeGranularity.MONTH
		year = int(year)
		month = int(month)
		day = 1
	elif year:
		granularity = GotmPeriod.TimeGranularity.YEAR
		year = int(year)
		month = 1
		day = 1
	if granularity:
		var start = 1000 * OS.get_unix_time_from_datetime({"year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0})
		var end_datetime = {"year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0}
		end_datetime[granularity] += 1
		var end = 1000 * OS.get_unix_time_from_datetime(end_datetime) - 1
		return [_GotmUtility.get_iso_from_unix_time(start), _GotmUtility.get_iso_from_unix_time(end)]

	return [null, null]

static func _match_score(score, params) -> bool:
	if params.name != score.name && params.get("author") && params.author != score.author:
		return false
	if params.get("min") is float && score.value < params.get("min"):
		return false
	if params.get("max") is float && score.value > params.get("max"):
		return false
	if params.get("props") && !_match_props(params.props, score.props):
		return false
	if params.get("period"):
		var period_range = _get_range_from_period(params.period)
		var start = period_range[0]
		var end = period_range[1]
		if start && score.created < start || end && score.created > end:
			return false
	return true

class ScoreSearchPredicate:
	var is_oldest_first: bool = false
	
	func is_less_than(a, b) -> bool:
		if a.value is String && b.value is String:
			if a.value.length() < b.value.length() || a.value.length() == b.value.length() && a.value.casecmp_to(b.value) < 0:
				return true
		else:
			if a.value < b.value:
				return true
		
		if a.value != b.value:
			return false
		if a.created == b.created && a.path < b.path:
			return true
			
		if is_oldest_first:
			return a.created > b.created
		return a.created < b.created

	func is_greater_than(a, b) -> bool:
		if a.value is String && b.value is String:
			if a.value.length() > b.value.length() || a.value.length() == b.value.length() && a.value.casecmp_to(b.value) > 0:
				return true
		else:
			if a.value > b.value:
				return true
				
		if a.value != b.value:
			return false
		if a.created == b.created && a.path > b.path:
			return true
		
		if is_oldest_first:
			return a.created < b.created
		return a.created > b.created

static func _fetch_by_score_sort(params) -> Array:
	var matches := []
	var scores_per_author := {}
	var descending = params.get("descending")
	if params.get("isInverted"):
		descending = !descending
	for score_path in _get_scores():
		var score = _get_scores()[score_path]
		if _match_score(score, params):
			if params.get("isUnique"):
				var existing_score = scores_per_author.get(score.author)
				if !existing_score || score.created > existing_score.created:
					scores_per_author[score.author] = score
			else:
				matches.append(score)
	if params.get("isUnique"):
		matches = scores_per_author.values()
		
	var predicate := ScoreSearchPredicate.new()
	predicate.is_oldest_first = !!params.get("isOldestFirst")
	matches.sort_custom(predicate, "is_greater_than" if descending else "is_less_than")
	for i in range(0, matches.size()):
		matches[i] = _format(matches[i])
	if params.get("after"):
		var cursor = _decode_cursor(params.after)
		var cursor_score = {"value": cursor[0], "path": cursor[1], "created": 0}
		var after_matches := []
		for i in range(0, matches.size()):
			var m = matches[i]
			m = {"value": _GotmScoreUtility.encode_cursor_value(m.value, m.created)._bigint, "path": m.path, "created": m.created}
			if cursor_score.path == m.path && cursor_score.value == m.value:
				continue
			var a = cursor_score.value < m.value
			if descending && predicate.is_greater_than(cursor_score, m) || !descending && predicate.is_less_than(cursor_score, m):
				after_matches.append(matches[i])
		matches = after_matches
	elif params.get("afterRank"):
		for i in range(0, params.afterRank):
			if matches.empty():
				break
			matches.pop_front()
	if params.get("limit"):
		while matches.size() > params.limit:
			matches.pop_back()
	return matches


static func _decode_cursor(cursor: String) -> Array:
	var decoded := _GotmUtility.decode_cursor(cursor)
	decoded[0] = decoded[0]._bigint
	var target: String = decoded[1]
	if target:
		decoded[1] = target.substr(0, target.length() - 1).replace("-", "/")
	return decoded

static func _format(data: Dictionary):
	if !data:
		return
	data = _GotmUtility.copy(data, {})
	data.created = _GotmUtility.get_unix_time_from_iso(data.created)
	return data
