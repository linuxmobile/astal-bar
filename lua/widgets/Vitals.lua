local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local bind = astal.bind
local Vitals = require("lua.lib.vitals")
local Debug = require("lua.lib.debug")

local icons_path = os.getenv("PWD") .. "/icons/"

local function create_metric_widget(class_name, icon_name, value_binding)
	local vitals = Vitals.get_default()
	if not vitals then
		Debug.error("VitalsWidget", string.format("Failed to initialize vitals service for %s widget", class_name))
		return Widget.Box({})
	end

	return Widget.Box({
		class_name = class_name,
		Widget.Icon({
			icon = icons_path .. icon_name,
			css = "padding-right: 5pt;",
		}),
		Widget.Label({
			label = bind(value_binding):as(function(usage)
				return string.format("%d%%", usage)
			end),
		}),
	})
end

local function VitalsWidget()
	local vitals = Vitals.get_default()
	if not vitals then
		return Widget.Box({})
	end

	return Widget.Box({
		css = "padding: 0 5pt;",
		class_name = "Vitals",
		spacing = 5,
		create_metric_widget("memory", "memory-symbolic.svg", vitals.memory_usage),
		create_metric_widget("cpu", "cpu-symbolic.svg", vitals.cpu_usage),
		on_destroy = function()
			if vitals.memory_usage then
				vitals.memory_usage:drop()
			end
			if vitals.cpu_usage then
				vitals.cpu_usage:drop()
			end
		end,
	})
end

return function()
	return VitalsWidget()
end
