@tool
extends Window


#region DEFS
var selected_locale: String = "Invalid" : set = _set_selected_locale
var available_languages: PackedStringArray = []
var available_countries: PackedStringArray = []
var selected_language: PackedStringArray = [] : set = _set_selected_language
var selected_country: PackedStringArray = [] : set = _set_selected_country


const default_country_code: String = "[Default]"


@onready var languages_list: ItemList = %LanguagesList
@onready var countries_list: ItemList = %CountriesList
@onready var select_button: Button = %SelectButton
@onready var selected_locale_value: Label = %SelectedLocaleValue


signal locale_changed(new_locale: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	available_languages = TranslationServer.get_all_languages()
	var new_available_countries: PackedStringArray = [default_country_code]
	new_available_countries.append_array(TranslationServer.get_all_countries())
	available_countries = new_available_countries
	_render_languages_list()
	_render_countries_list()
	selected_language = []
	selected_country = []
	selected_locale = "Invalid"
#endregion


#region SETTERS
func _set_selected_locale(new_selected_locale: String) -> void:
	selected_locale = new_selected_locale
	_render_selected_locale_value()


func _set_selected_language(new_selected_language: PackedStringArray) -> void:
	selected_language = new_selected_language
	_render_select_button()
	var locale: String = _compile_locale()
	selected_locale = locale if locale else "Invalid"


func _set_selected_country(new_selected_country: PackedStringArray) -> void:
	selected_country = new_selected_country
	_render_select_button()
	var locale: String = _compile_locale()
	selected_locale = locale if locale else "Invalid"
#endregion


#region RENDERERS
func _render_languages_list() -> void:
	if languages_list:
		languages_list.clear()
		for language_code: String in available_languages:
			var item: String = "%s [%s]" % [TranslationServer.get_language_name(language_code), language_code]
			var _result: int = languages_list.add_item(item)


func _render_countries_list() -> void:
	if countries_list:
		countries_list.clear()
		for country_code: String in available_countries:
			var item: String
			if country_code == default_country_code:
				item = default_country_code
			else:
				item = "%s [%s]" % [TranslationServer.get_country_name(country_code), country_code]
			var _result: int = countries_list.add_item(item)


func _render_select_button() -> void:
	if select_button:
		select_button.disabled = false if _is_locale_valid() else true


func _render_selected_locale_value() -> void:
	if selected_locale_value:
		selected_locale_value.text = selected_locale
#endregion


#region SIGNALS
func _on_languages_list_item_selected(index: int) -> void:
	if index < 0:
		return
	# This is needed to stop weird overflow bug with item search
	if index >= available_languages.size():
		index = index % available_languages.size()
	var language: String = available_languages[index]
	selected_language = [language]


func _on_countries_list_item_selected(index: int) -> void:
	if index < 0:
		return
	# This is needed to stop weird overflow bug with item search
	if index >= available_countries.size():
		index = index % available_countries.size()
	var country: String = available_countries[index]
	selected_country = [country]


func _on_cancel_button_pressed() -> void:
	hide()


func _on_select_button_pressed() -> void:
	var compiled_locale: String = _compile_locale(true)
	if not compiled_locale:
		return
	locale_changed.emit(TranslationServer.standardize_locale(compiled_locale))
	hide()
#endregion


#region UTILS
func _is_locale_valid() -> bool:
	return selected_language.size() == 1


func _compile_locale(should_log: bool = false) -> String:
	if not _is_locale_valid():
		if should_log:
			push_warning(ParleyUtils.log.warn_msg("Unable to compile locale for testing Dialogue Sequences with: Invalid (language: %s, country: %s)" % [",".join(selected_language), ",".join(selected_country)]))
		return ""

	var locale: String = selected_language[0]
	if selected_country.size() > 0 and selected_country[0] != default_country_code:
			locale += "_%s" % selected_country[0]
	return locale
#endregion
