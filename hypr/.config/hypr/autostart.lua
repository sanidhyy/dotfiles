-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- enable auto switch to nightlight
o.launch_on_start("hyprsunset")

-- empty the trash once every day
o.exec_on_start("trash-empty 30")

-- remind myself to turn on cooling stand
o.exec_on_start(
  "omarchy-notification-wait && omarchy-notification-send"
    .. " --app-name 'Hardware Reminder'"
    .. " -u critical -t 0"
    .. " 'Cooling Stand'"
    .. " 'Did you turn on the cooling stand?'"
)
