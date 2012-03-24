-- kmawesome: My configuration of awesome window manager
-- Copyright (c) 2012 Kazuki Maeda <kmaeda@users.sourceforge.jp>

require('awful')
require('awful.autofocus')
require('awful.rules')
require('beautiful')
require('naughty')

-- http://git.sysphere.org/vicious/
require('vicious')

require('kmawesome.layout.split')
require('kmawesome.widget.tasklist')

beautiful.init('/home/kmaeda/.config/awesome/kmawesome/theme.lua')

local modkey = 'Mod4'
local shiftkey = 'Shift'
local controlkey = 'Control'

local terminal = 'evilvte'
local editor = 'sh -c "XMODIFIERS=@im=none emacs"'
local webbrowser = 'firefox'
local mua = 'sylpheed'
local musicplayer = 'audacious'
local xsetb = 'xset -b'
local xsetr = 'xset r rate 250 25'
local xmodmap = 'xmodmap /home/kmaeda/.Xmodmap'
local xcompmgr = 'xcompmgr'
local hsetroot = 'hsetroot -solid black'
local xscreensaver = 'xscreensaver -no-splash'
local uim = 'uim-xim'
local sleepcommand = "sh -c 'echo mem > /sys/power/state'"


local layouts = {
   kmawesome.layout.split.v,
   awful.layout.suit.max.fullscreen
}

local tags = awful.tag({'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Editor', 'Web', 'Mail', 'Music'}, s, layouts[1])

awful.tag.viewonly(tags[11])

local function launchprogram(program, tagnum)
   if #tags[tagnum]:clients() == 0 then
      awful.util.spawn(program)
      tags[tagnum].selected = true
   end
end

local function tagtoggle(tagnum)
   if #tags[tagnum]:clients() == 0 then
      tags[tagnum].selected = true
   else
      awful.tag.viewtoggle(tags[tagnum])
   end
end

local function tagviewonly(tagnum)
   for i = 1, 10 do
      tags[i].selected = false
   end
   tags[tagnum].selected = true
end

local autorun = {
   xsetb,
   xsetr,
   xmodmap,
   xcompmgr,
   hsetroot,
   xscreensaver,
   uim,
}

for app = 1, #autorun do
   awful.util.spawn(autorun[app])
end

local waw = screen[1].workarea.width
local ew = 615
if waw < 1700 then ew = 530 end
for i = 1, 14 do
   awful.tag.setmwfact(ew/waw, tags[i])
end
kmawesome.layout.split.setfact(ew/waw)
mouse.coords({x = 2000, y = 2000})

local mytextclock = awful.widget.textclock({align = 'right', ellipsize='start'}, '%a %b %d, %Y; %H:%M:%S', 0.1)
local mysystray = widget({type = 'systray'})

local memwidget = awful.widget.graph()
memwidget:set_width(32)
memwidget:set_height(16)
memwidget:set_background_color('#494B4F')
memwidget:set_border_color('#000000')
memwidget:set_color('#AECF96')
memwidget:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
vicious.register(memwidget, vicious.widgets.mem, '$1', 1)

local cpuwidget = awful.widget.graph()
cpuwidget:set_width(32)
cpuwidget:set_height(16)
cpuwidget:set_background_color('#494B4F')
cpuwidget:set_color('#FF5656')
cpuwidget:set_border_color('#000000')
cpuwidget:set_gradient_colors({ '#FF5656', '#88A175', '#AECF96' })
vicious.register(cpuwidget, vicious.widgets.cpu, '$1', 1)

-- http://awesome.naquadah.org/wiki/Acpitools-based_battery_widget
local mybattmon = widget({ type = "textbox", name = "mybattmon", align = "right" })
function battery_status ()
   local output={} --output buffer
   local fd=io.popen("acpitool -b", "r") --list present batteries
   local line=fd:read()
   while line do --there might be several batteries.
      local battery_num = string.match(line, "Battery \#(%d+)")
      local battery_load = string.match(line, " (%d*\.%d+)%%")
      local time_rem = string.match(line, "(%d+\:%d+)\:%d+")
      if time_rem == "00:00" then time_rem = nil end
      local discharging
      if string.match(line, "discharging")=="discharging" then --discharging: always red
         discharging="<span color=\"#CC7777\">"
      elseif tonumber(battery_load)>85 then --almost charged
         discharging="<span color=\"#77CC77\">"
      else --charging
         discharging="<span color=\"#CCCC77\">"
      end
      if battery_num and battery_load and time_rem then
         table.insert(output,discharging.."BAT#"..battery_num.." "..battery_load.."% "..time_rem.."</span>")
      elseif battery_num and battery_load then --remaining time unavailable
         table.insert(output,discharging.."BAT#"..battery_num.." "..battery_load.."%</span>")
      end --even more data unavailable: we might be getting an unexpected output format, so let's just skip this line.
      line=fd:read() --read next line
   end
   return table.concat(output," ") --FIXME: better separation for several batteries. maybe a pipe?
end
if os.execute("acpitool") == 0 then
   mybattmon.text = " " .. battery_status() .. " "
   my_battmon_timer=timer({timeout=30})
   my_battmon_timer:add_signal("timeout", function()
                                             mybattmon.text = " " .. battery_status() .. " "
                                          end)
   my_battmon_timer:start()
end

local mywibox = awful.wibox({position = 'top', height=16})
mywibox.widgets = {
   mytextclock,
   mybattmon,
   mysystray,
   cpuwidget,
   memwidget,
   kmawesome.widget.tasklist(function(c)
                                return kmawesome.widget.tasklist.label.currenttags(c, 1)
                             end),
   layout = awful.widget.layout.horizontal.rightleft
}

local globalkeys = awful.util.table.join(
   awful.key({}, 'XF86AudioLowerVolume', function () awful.util.spawn('amixer set Master 1-') end),
   awful.key({}, 'XF86AudioMute', function () awful.util.spawn('amixer set Master toggle') end),
   awful.key({}, 'XF86AudioRaiseVolume', function () awful.util.spawn('amixer set Master 1+') end),
   awful.key({}, 'XF86Display', function () awful.util.spawn('/home/kmaeda/vga.sh') end),
   awful.key({}, 'XF86ScreenSaver', function () awful.util.spawn('xscreensaver-command -lock') end),
   awful.key({}, 'XF86Sleep', function () awful.util.spawn(sleepcommand) end),

   awful.key({modkey}, 'e', function () launchprogram(editor, 11); awful.tag.viewonly(tags[11]) end),
   awful.key({modkey}, 'm', function () launchprogram(musicplayer, 14); awful.tag.viewonly(tags[14]) end),
   awful.key({modkey}, 'n', function () awful.client.focus.byidx(1); if client.focus then client.focus:raise() end end),
   awful.key({modkey}, 'p', function () awful.client.focus.byidx(-1); if client.focus then client.focus:raise() end end),
   awful.key({modkey}, 's', function () launchprogram(mua, 13); awful.tag.viewonly(tags[13]) end),
   awful.key({modkey}, 'w', function () launchprogram(webbrowser, 12); awful.tag.viewonly(tags[12]) end),
   awful.key({modkey}, 'Return', function () awful.util.spawn(terminal) end),
   awful.key({modkey}, 'space', function () awful.layout.inc(layouts, 1) end),

   awful.key({modkey, shiftkey}, 'n', function () awful.client.swap.byidx(1) end),
   awful.key({modkey, shiftkey}, 'p', function () awful.client.swap.byidx(-1) end),

   awful.key({modkey, controlkey}, 'b', function () awful.util.spawn('audtool playlist-advance') end),
   awful.key({modkey, controlkey}, 'c', function () awful.util.spawn('audtool playlist-clear') end),
   awful.key({modkey, controlkey}, 'e', function () tagtoggle(11); launchprogram(editor, 11) end),
   awful.key({modkey, controlkey}, 'm', function () tagtoggle(14); launchprogram(musicplayer, 14) end),
   awful.key({modkey, controlkey}, 'n', function () kmawesome.layout.split.incfact(0.01) end),
   awful.key({modkey, controlkey}, 'p', function () kmawesome.layout.split.incfact(-0.01) end),
   awful.key({modkey, controlkey}, 'r', awesome.restart),
   awful.key({modkey, controlkey}, 's', function () tagtoggle(13); launchprogram(mua, 13) end),
   awful.key({modkey, controlkey}, 'v', function () awful.util.spawn('audtool playback-stop') end),
   awful.key({modkey, controlkey}, 'w', function () tagtoggle(12); launchprogram(webbrowser, 12) end),
   awful.key({modkey, controlkey}, 'x', function () awful.util.spawn('audtool playback-play') end),
   awful.key({modkey, controlkey}, 'z', function () awful.util.spawn('audtool playlist-reverse') end)
)

local clientkeys = awful.util.table.join(
   awful.key({modkey}, 'c', function (c) c:kill() end),
   awful.key({modkey, controlkey}, 'space', awful.client.floating.toggle),
   awful.key({modkey, controlkey}, 'Return', function (c) c:swap(awful.client.getmaster()) end))

for i = 0, 9 do
   local j
   if i == 0 then j = 10 else j = i end
   globalkeys = awful.util.table.join(globalkeys,
                                      awful.key({modkey}, tostring(i), function () tagviewonly(j) end),
                                      awful.key({modkey, controlkey}, tostring(i), function () awful.tag.viewtoggle(tags[j]) end),
                                      awful.key({modkey, shiftkey}, tostring(i),
                                                function ()
                                                   if client.focus
                                                      and client.focus:tags()[1] ~= tags[11]
                                                      and client.focus:tags()[1] ~= tags[12]
                                                      and client.focus:tags()[1] ~= tags[13]
                                                      and client.focus:tags()[1] ~= tags[14] then
                                                      local focus = client.focus
                                                      awful.client.movetotag(tags[j])
                                                      tags[j].selected = true
                                                      client.focus = focus
                                                   end
                                                end))
end

local clientbuttons = awful.util.table.join(
   awful.button({}, 1, function (c) client.focus = c; c:raise() end),
   awful.button({modkey}, 1, awful.mouse.client.move),
   awful.button({modkey}, 3, function (c) awful.mouse.client.resize(c, 'bottom_right') end))

root.keys(globalkeys)

awful.rules.rules = {
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = true,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    tag = tags[10]} },
   { rule = { class = "Emacs" },
     properties = { tag = tags[11] } },
   { rule = { class = "Firefox" },
     properties = { tag = tags[12] } },
   { rule = { class = "Sylpheed" },
     properties = { tag = tags[13] } },
   { rule = { class = "Audacious" },
     properties = { tag = tags[14] } },
   { rule = { class = "fontforge" },
     properties = { floating = true } },
}



client.add_signal("manage",
                  function (c)
                     c.size_hints_honor = false
                     c.opacity = 0.5
                     if client.focus == c then c.opacity = 1 end

                     if c:tags()[1] == tags[10] then
                        for i = 1, 9 do
                           if #tags[i]:clients() == 0 then
                              c:tags({tags[i]})
                              break
                           end
                        end
                        if not c:tags()[1].selected then
                           c:tags()[1].selected = true
                        end
                        client.focus = c
                        c:raise()
                     end

                     if c:tags()[1] == tags[12] and #tags[12]:clients() > 1 then
                        awful.client.floating.set(c, true)
                     end

                     awful.client.setslave(c)
                     if not c.size_hints.user_position and not c.size_hints.program_position then
                        awful.placement.no_overlap(c)
                        awful.placement.no_offscreen(c)
                     end
                  end)

client.add_signal("focus",
                  function(c)
                     c.border_color = beautiful.border_focus
                     c.opacity = 1
                  end)
client.add_signal("unfocus",
                  function(c)
                     c.border_color = beautiful.border_normal
                     c.opacity = 0.5
                  end)
