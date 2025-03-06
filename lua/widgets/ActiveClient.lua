local astal = require("astal")
local Widget = require("astal.gtk3").Widget
local Variable = astal.Variable
local bind = astal.bind
local cjson = require("cjson")
local utf8 = require("lua-utf8")
local Debug = require("lua.lib.debug")
local Managers = require("lua.lib.managers")

local function sanitize_utf8(text)
	if not text then
		return ""
	end
	return utf8.gsub(text, "[%z\1-\31\127]", "")
end

local function truncate_text(text, length)
	if not text then
		return ""
	end
	text = sanitize_utf8(text)
	if utf8.len(text) > length then
		return utf8.sub(text, 1, length) .. "..."
	end
	return text
end

local function get_active_window()
	local out, err = astal.exec("niri msg --json windows")
	if err then
		Debug.error("ActiveClient", "Failed to get window data: %s", err)
		return nil
	end

	local success, windows = pcall(function()
		return cjson.decode(out)
	end)

	if not success then
		Debug.error("ActiveClient", "Failed to decode window data")
		return nil
	end

	for _, window in ipairs(windows) do
		if window.is_focused then
			return window
		end
	end

	return nil
end

local function ActiveClientWidget()
	local active_window = Variable({}):poll(400, function()
		return get_active_window() or {}
	end)

	Managers.VariableManager.register(active_window)

	local window_binding = bind(active_window)
	Managers.BindingManager.register(window_binding)

	return Widget.Box({
		class_name = "ActiveClient",
		Widget.Box({
			orientation = "VERTICAL",
			Widget.Label({
				class_name = "app-id",
				label = window_binding:as(function(window)
					return sanitize_utf8(window.app_id or "Desktop")
				end),
				halign = "START",
			}),
			Widget.Label({
				class_name = "window-title",
				label = window_binding:as(function(window)
					return truncate_text(window.title or "niri", 40)
				end),
				ellipsize = "END",
				halign = "START",
			}),
		}),
		on_destroy = function()
			Managers.BindingManager.cleanup_all()
			Managers.VariableManager.cleanup_all()
		end,
	})
end

return function()
	return ActiveClientWidget()
end
