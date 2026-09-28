-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Samsung 32" 4K on the dock: "auto" picks scale 1 here, which makes waybar and text tiny.
-- 1.5 gives a 2560x1440 logical desktop (scales must divide 3840x2160 evenly: 1.5, 1.6, 1.666667, 2).
hl.monitor({
    output   = "desc:Samsung Electric Company U32R59x",
    mode     = "preferred",
    position = "auto",
    scale    = 1.5,
})

-- Both laptops call their internal panel eDP-1 but want different scales for it, and this
-- repo is one tree shared between them and macOS, so an eDP-1 rule written here would
-- follow the wrong machine home. NixOS generates the host's own rules into
-- /etc/xdg/hypr/lattice.lua instead -- lattice.display.monitors, in
-- modules/nixos/display.nix -- and they are loaded here, last, so they win over the rules
-- above. There is no such file on macOS or on a host that overrides nothing, hence the
-- guard: loadfile returns nil rather than raising when the path isn't there.
local latticeMonitors = loadfile("/etc/xdg/hypr/lattice.lua")
if latticeMonitors then
    latticeMonitors()
end


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "ghostty"
local fileManager = "thunar"
local menu        = "rofi -show drun"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("HYPRCURSOR_SIZE", "16")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(89b4faff)", "rgba(b4befeff)"}, angle = 45 }, -- Catppuccin Mocha blue/lavender
            inactive_border = "rgba(45475aaa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee11111b,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,

            -- new_optimizations caches the blur of unchanged surfaces instead of
            -- recomputing it per frame; xray samples the wallpaper rather than the
            -- window stack underneath. Both make blur cheaper, not prettier.
            new_optimizations = true,
            xray              = true,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Layer-Rules/
-- Blur the shell surfaces. Namespaces verified live with `hyprctl layers`:
-- waybar -> "waybar", rofi -> "rofi", mako -> "notifications", swayosd -> "swayosd".
-- ignore_alpha skips blurring pixels below that alpha, so waybar's transparent
-- gutter between pills doesn't get blurred along with the pills themselves.
-- xray per-layer keeps these sampling the wallpaper, so the cost doesn't grow
-- with however many windows happen to be stacked underneath. Only the surfaces
-- pinned to a screen edge get it -- see the rofi rule below for why.
for _, ns in ipairs({ "waybar", "notifications", "swayosd" }) do
    hl.layer_rule({
        name         = "blur-" .. ns,
        match        = { namespace = ns },
        blur         = true,
        blur_popups  = true,
        xray         = true,
        ignore_alpha = 0.2,
    })
end

-- rofi opens centred on top of whatever window you are working in, so it is the one
-- shell surface xray gets visibly wrong: sampling the wallpaper erases the window that
-- is actually underneath, and the menu reads as a hole punched through to the desktop.
-- It is one small, short-lived surface, so blurring the real window stack costs little.
hl.layer_rule({
    name         = "blur-rofi",
    match        = { namespace = "rofi" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0.2,
})

-- wlogout calls its layer "logout_dialog", not "wlogout" (checked with `hyprctl layers`
-- while it was open). It gets its own rule rather than joining the loop above: it is a
-- fullscreen modal, so xray would replace everything behind it with blurred wallpaper
-- instead of frosting the desktop that is actually there. ignore_alpha stays below the
-- 0.72 scrim in /etc/xdg/wlogout/style.css so the whole overlay blurs, not just the
-- buttons.
hl.layer_rule({
    name         = "blur-logout_dialog",
    match        = { namespace = "logout_dialog" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0.2,
})

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only": a lone tiled window (or a lone fullscreen one)
-- drops its gaps, border and rounding, so a single window sits flush to the screen.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

-- Keep the workspaces on the bar even when empty, so the pills stop reflowing as windows
-- come and go and the SUPER+[1-9,0] binds always have a visible target. Persistence belongs
-- to Hyprland, not waybar -- waybar 0.15's hyprland/workspaces has no
-- persistent-workspaces option, it just reflects these rules and tags the empty ones with
-- a .empty class (styled muted in ~/.dotfiles/waybar/.config/waybar/style.css).
--
-- Five per screen and not ten: each pill is ~32px and the bar only has room before the
-- centred clock. That still holds with both blocks defined, because waybar leaves
-- all-outputs at its default false -- each bar renders only the workspaces of the output it
-- is on, so it is five pills on the laptop and five on the Samsung, never ten on either.
--
-- Pinning the two blocks with `monitor` is what makes SUPER+[1-9,0] mean a place rather
-- than just a number. Unpinned, workspace ids are a single global pool owned by whichever
-- monitor happened to create them: 1-5 were instantiated on whichever output came up first
-- at login, the dock's Samsung took 6 as the lowest free id, and SUPER+1 from the external
-- warped focus back to the laptop instead of switching screen-locally.
--
-- The internal panel is eDP-1 on both laptops and wants the same 1-5 on both, so this rule
-- is generic enough to live here; it is only the scales that differ per host and therefore
-- have to be generated into /etc/xdg/hypr/lattice.lua by lattice's modules/nixos/display.nix.
local internal = "eDP-1"
local external = "desc:Samsung Electric Company U32R59x"

for i = 1, 5 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = internal,
        persistent = true,
        default    = i == 1, -- what the laptop opens on, rather than the lowest id it owns
    })
end

-- 6-10 on the dock's Samsung. Booting undocked needs nothing extra: Hyprland skips a
-- persistent workspace whose pinned monitor is absent -- a rule naming an output that does
-- not exist creates no workspace at all -- so starting up with the dock unplugged leaves
-- only 1-5, and the laptop bar looks exactly as it did before this block. A workspace still holding
-- windows when the monitor goes away is moved to the laptop rather than destroyed, and the
-- id returns to the Samsung on the next reconnect once it is empty again.
for i = 6, 10 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = external,
        persistent = true,
        default    = i == 6,
    })
end

-- Booting undocked already gives exactly 1-5: at config load Hyprland creates no persistent
-- workspace for a monitor that isn't there. A monitor that goes away *while running* is the
-- one case it doesn't settle on its own -- by then 6-10 are live workspace objects, so they
-- are rehomed to the laptop and then kept alive by their own `persistent`, leaving ten pills
-- on a bar with room for five. Reloading re-runs the load-time pass, which drops the empty
-- orphans, so undocking is just a reload. There is no reload dispatcher to hl.dispatch, hence
-- hyprctl; spawning it is what makes this land after the rehoming rather than in the middle of
-- it, so no hl.timer is needed to defer it.
hl.on("monitor.removed", function()
    hl.exec_cmd("hyprctl reload")
end)

hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        background_color        = 0xff1e1e2e,
        force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = -0.1, -- -1.0 - 1.0, 0 means no modification. Mostly the touchpad: the
                            -- MX Master below is the only other pointer, and it overrides this.

        touchpad = {
            natural_scroll = true,

            -- default 1.0; lower = slower scrolling. 0.2 rather than something nearer
            -- 1.0 because rofi scales row movement off the scroll distance, and a
            -- trackpad flick carries far more of it than a wheel detent does -- at 0.8
            -- the wifi dropdown and the launcher both shot past whatever was aimed at.
            -- The MX Master overrides this with its own factor below, so this number is
            -- the trackpad's alone.
            scroll_factor  = 0.2,

            -- The pad is a clickpad: one physical button under the whole surface, and
            -- BTN_LEFT is the only key code it reports. Which button a click *means* is
            -- therefore libinput's to decide, and it has two ways to decide it. Button
            -- areas cuts the bottom of the pad into invisible left/middle/right
            -- rectangles; clickfinger ignores position and counts fingers instead -- one
            -- left, two right, three middle -- which is what macOS does, and what the
            -- two-finger *tap* here already did, since tap_button_map defaults to lrm.
            --
            -- libinput's own default for an Apple-vendor clickpad is clickfinger, but
            -- Hyprland forces one method or the other from this flag rather than leaving
            -- the default in place, so leaving it unset meant button areas. A two-finger
            -- press came out left while a two-finger tap came out right, and right-click
            -- was a corner with no edge you could feel. Setting it puts press and tap back
            -- in agreement and matches the Mac.
            --
            -- The one place this still departs from a stock Mac is tap-to-click, which
            -- macOS ships off and Hyprland ships on; `tap-to-click = false` here is the
            -- whole difference if the click is ever wanted as the only click.
            clickfinger_behavior = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- Logitech MX Master 3 over Bluetooth (name from `hyprctl devices`)
hl.device({
    name          = "logitech-wireless-mouse-mx-master-3-1",

    -- DPI is the only speed knob for this mouse; these two exist to get out of its way.
    --
    -- accel_profile "flat" turns off libinput's pointer acceleration, which otherwise
    -- scales gain by how fast the hand is moving. With it on there is no single "speed"
    -- to tune -- the same setting feels right on slow tracking and too loose on a quick
    -- flick -- which is what makes too-fast and too-sensitive impossible to tell apart.
    -- Flat makes pointer travel strictly proportional to hand travel, so DPI means one
    -- thing. Drop this line to get the accelerated feel back.
    accel_profile = "flat",

    -- 0 = no modification. Anything negative here would discard motion counts the sensor
    -- already reported, buying slowness at the cost of precision; the DPI in
    -- ~/.config/solaar/config.yaml moves it at the source instead. See the solaar block
    -- in lattice's modules/nixos/profiles/graphical.nix.
    sensitivity   = 0,

    scroll_factor = 0.5,  -- default 1.0; lower = slower scrolling. Unrelated to DPI.
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
-- Session menu: lock, log out, suspend, hibernate, reboot, shut down. Themed and wired up
-- in the lattice flake (modules/nixos/profiles/graphical.nix); the wrapper is what passes
-- wlogout its config, so don't call bare `wlogout` here.
hl.bind("CTRL + " .. mainMod .. " + Q", hl.dsp.exec_cmd("lattice-power"))
-- Lock the screen; the session and its apps keep running behind hyprlock. Calls hyprlock
-- straight out rather than going through `loginctl lock-session`, which only asks logind
-- to emit a Lock signal that hypridle then has to act on -- nothing happens at all if
-- hypridle is down. `pidof` first so holding the bind can't stack a second lock screen.
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p clipboard -display-columns 2 | cliphist decode | wl-copy"))

-- Notifications, all four through makoctl, mako's CLI. Hyprland execs these with the
-- session PATH rather than any wrapper's, which is why lattice puts mako itself in
-- systemPackages (modules/nixos/profiles/graphical.nix) -- the systemd unit alone installs
-- the daemon and not the tool that drives it.
--
-- N takes down the banner in front of you and SHIFT the whole stack. CTRL brings the last
-- one back, which is mostly for having cleared a critical banner before reading it: mako's
-- `restore` pops the newest off the history ring, so it is the undo for the two above.
-- ALT opens the browser over everything that has already expired -- lattice's
-- lattice-notifications, shaped like the clipboard bind above, Enter copying the body.
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("makoctl dismiss"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss --all"))
hl.bind(mainMod .. " + CTRL + N",  hl.dsp.exec_cmd("makoctl restore"))
hl.bind(mainMod .. " + ALT + N",   hl.dsp.exec_cmd("lattice-notifications"))

-- Do not disturb, the same toggle the bar pill runs -- lattice-dnd flips mako's `dnd` mode
-- and signals waybar, so the pill follows a keypress and the keypress follows a click. D
-- rather than a fourth modifier on N: this one is a state you leave on for a while, not a
-- one-shot action on what is currently on screen.
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("lattice-dnd toggle"))

-- Calculator, as a launcher mode rather than an app: rofi's calc plugin, whose engine is
-- qalculate -- so units and bases convert in place (`0xff to bin`, `1 GiB to MB`) and
-- solve/diff/matrices work. The plugin is built into the rofi wrapper by lattice, in
-- modules/nixos/profiles/graphical.nix; bare `rofi` from anywhere else won't have it.
-- -modes is needed because ~/.dotfiles/rofi/config.rasi enables only drun,run, and rofi
-- refuses to -show a mode that isn't enabled. Enter copies the result to the clipboard.
hl.bind("ALT + SHIFT + SPACE", hl.dsp.exec_cmd([[rofi -show calc -modes calc -calc-command "echo -n '{result}' | wl-copy"]]))

-- Screenshot: HyprQuickFrame's selection overlay, then satty. The script and its desktop
-- entry are lattice's, in modules/nixos/profiles/graphical.nix.
--
-- Print is the external keyboard's key (NuPhy Halo65 V2, remapped in its own firmware, so
-- it emits a real KEY_SYSRQ on both hosts). The Mac's internal keyboard has no Print at
-- all -- hid-apple puts it on the magic_keyboard_2021_and_2024 fn table, which carries no
-- KEY_SYSRQ on either layer -- so the bind is simply unreachable there, which is why the
-- launcher entry stays: "Screenshot" in rofi is the form that works with no keyboard
-- plugged in.
hl.bind("Print", hl.dsp.exec_cmd("lattice-screenshot"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move the focused window with mainMod + SHIFT + arrow keys (crosses onto the next monitor at the edge)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Send the whole current workspace to the monitor on the left/right with mainMod + CTRL + arrow keys
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.workspace.move({ monitor = "r" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Swallow middle click (BTN_MIDDLE = 274) so it never reaches apps: no paste-on-middle-click,
-- no middle-click-closes-tab. The clickpad has only a physical left button; libinput invents
-- middle clicks from three-finger taps and three-finger presses, so they land by accident (a
-- three-finger workspace swipe that doesn't travel far enough is a paste). Under the
-- clickfinger_behavior above there is no longer a bottom-centre click zone to add a third way.
-- Binds are global, so this covers the MX Master too - delete the line to get middle click back.
-- No { mouse = true }: that flag is for press-and-hold drag dispatchers (drag/resize above).
hl.bind("mouse:274", hl.dsp.no_op())

-- Fullscreen the focused window
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Keyboard resize: hold mainMod+R to enter, arrows to resize in steps, Escape/Enter to exit
-- ("" is the root/default submap - there is no submap literally named "default")
-- Note: -1 does NOT mean "persistent" for notify's duration (unlike its icon arg) -
-- it underflows and the notification vanishes almost instantly. Use a long explicit
-- duration instead; it gets dismissed early anyway when the submap exits.
local resizeModeNotify = "hyprctl notify 2 600000 \"rgb(89b4fa)\" \"  RESIZE MODE  —  arrows to resize, Esc/Enter to exit\""
hl.define_submap("resize", function()
    hl.bind("left",   hl.dsp.window.resize({ x = -20, y = 0,  relative = true }))
    hl.bind("right",  hl.dsp.window.resize({ x = 20,  y = 0,  relative = true }))
    hl.bind("up",     hl.dsp.window.resize({ x = 0,   y = -20, relative = true }))
    hl.bind("down",   hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }))
    hl.bind("escape", hl.dsp.exec_cmd("hyprctl dismissnotify"))
    hl.bind("escape", hl.dsp.submap(""))
    hl.bind("return", hl.dsp.exec_cmd("hyprctl dismissnotify"))
    hl.bind("return", hl.dsp.submap(""))
end)
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(resizeModeNotify))
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

-- Laptop multimedia keys for volume and LCD brightness, shown with swayosd
--
-- The two mute keys go through lattice-deck rather than straight at swayosd-client, which
-- runs the same swayosd call and then repaints the Stream Deck's key for it. Nothing else
-- tells the deck: waybar watches PipeWire for itself, but streamdeck-ui only knows what it
-- is told, so a mute from here would otherwise leave the deck showing sound until its
-- five-minute sync came round. Volume up and down stay direct -- they do not change the
-- state the key draws, and a press that repeats on hold should not spawn a script each tick.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise --max-volume 100"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),                  { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("lattice-deck mute"),                                     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("lattice-deck mic"),                                      { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("swayosd-client --brightness raise"),                     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("swayosd-client --brightness lower"),                     { locked = true, repeating = true })

-- Keyboard backlight, on the LCD brightness keys under mainMod. No laptop here has a key
-- of its own for it -- the MacBook's 2021+ function row simply hasn't got one, and macOS
-- puts it in Control Center rather than on the keyboard.
--
-- Bound to the keysym rather than to mainMod + F1/F2: hid-apple runs this keyboard in
-- fkeyslast mode, so the physical F1 already *is* XF86MonBrightnessDown and mainMod + F1
-- would mean holding Fn as well. Going through the keysym also keeps this on whichever
-- keys carry brightness on the other machine. swayosd raises the pill by itself here,
-- watching the LED, so there is no --brightness call to make.
hl.bind(mainMod .. " + XF86MonBrightnessUp",  hl.dsp.exec_cmd("lattice-kbd-backlight raise"),            { locked = true, repeating = true })
hl.bind(mainMod .. " + XF86MonBrightnessDown",hl.dsp.exec_cmd("lattice-kbd-backlight lower"),            { locked = true, repeating = true })

-- Requires playerctl. Play/pause goes through lattice-deck for the same reason the mute
-- keys above do: it is the one of the four that changes what the deck's key draws.
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("lattice-deck play"),    { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("lattice-deck play"),    { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Qalculate! opens floating. Its keypad is a fixed grid with a natural size (766x540
-- here), and tiling stretches it: given half a workspace the buttons grow to fill the
-- height and the result area above them becomes a 350px void. The app has no say in it --
-- nothing in its layout sets a maximum -- so the window manager is the only place to fix
-- it. Matched on class, which `hyprctl clients` reports as qalculate-gtk.
--
-- Deliberately no `size` rule: qalculate remembers its own width in
-- ~/.config/qalculate/qalculate-gtk.cfg and rewrites that file every time it quits, so a
-- size pinned here would quietly override whatever the window was last resized to. Float
-- and centre only, and it opens at the size it remembers.
hl.window_rule({
    name  = "float-calculator",
    match = { class = "qalculate-gtk" },

    float  = true,
    center = true,
})
