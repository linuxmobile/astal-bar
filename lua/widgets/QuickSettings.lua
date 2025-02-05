local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local bind = astal.bind
local Wp = astal.require("AstalWp")
local Network = astal.require("AstalNetwork")
local Battery = astal.require("AstalBattery")
local PowerProfiles = astal.require("AstalPowerProfiles")

local function PowerProfile()
	local profiles = PowerProfiles.get_default()

	return Widget.Box({
		class_name = "PowerProfile",
		Widget.Icon({
			icon = bind(profiles, "icon-name"),
			tooltip_text = bind(profiles, "active-profile"):as(function(profile)
				return profile and ("Current profile: " .. profile) or "No profile"
			end),
			css = "padding-right: 10pt;",
		}),
	})
end

local function Microphone()
	local mic = Wp.get_default().audio.default_microphone

	return Widget.Box({
		class_name = "Microphone",
		Widget.Icon({
			icon = bind(mic, "volume-icon"),
			css = "padding-right: 10pt;",
		}),
	})
end

local function Audio()
	local speaker = Wp.get_default().audio.default_speaker

	return Widget.Box({
		class_name = "Audio",
		Widget.Icon({
			icon = bind(speaker, "volume-icon"),
			css = "padding-right: 10pt;",
		}),
	})
end

local function Wifi()
	local network = Network.get_default()
	local wifi = bind(network, "wifi")

	return Widget.Box({
		visible = wifi:as(function(v)
			return v ~= nil
		end),
		wifi:as(function(w)
			return Widget.Icon({
				tooltip_text = bind(w, "ssid"):as(tostring),
				class_name = "Wifi",
				css = "padding-right: 10pt;",
				icon = bind(w, "icon-name"),
			})
		end),
	})
end

local function BatteryLevel()
	local bat = Battery.get_default()

	return Widget.Box({
		class_name = "Battery",
		visible = bind(bat, "is-present"),
		Widget.Icon({
			icon = bind(bat, "battery-icon-name"),
			css = "padding-right: 5pt;",
		}),
		Widget.Label({
			label = bind(bat, "percentage"):as(function(p)
				return tostring(math.floor(p * 100)) .. " %"
			end),
		}),
	})
end

local function QuickSettings()
	return Widget.Box({
		class_name = "QuickSettings",
		PowerProfile(),
		Microphone(),
		Wifi(),
		Audio(),
		BatteryLevel(),
	})
end

return function()
	return QuickSettings()
end
