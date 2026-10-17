--!nonstrict
-- Hides every desktop widget while the focused niri workspace has a window.
--
-- Same niri + jq check the cava-vis widget does, but instead of rendering an
-- empty tree for one widget it drives the shell's global desktop-widget
-- visibility, so built-in widgets (weather, sysmon, media_player) disappear
-- too. The IPC call only fires when the window count crosses zero, so a
-- manual `noctalia msg desktop-widgets-show` is not fought every poll.

local HIDE = noctalia.getConfig("hide_with_windows") ~= false
local POLL_MS = noctalia.getConfig("poll_ms") or 500

-- Counts windows on niri's focused workspace. Needs niri + jq; when either is
-- missing the previous state is kept so nothing changes unexpectedly.
local WIN_CMD =
  "sh -c 'ws=$(niri msg --json workspaces | jq -r \".[]|select(.is_focused==true).id\"); "
  .. "niri msg --json windows | jq --argjson ws \"$ws\" \"[.[]|select(.workspace_id==$ws)]|length\"'"

local knownWindows = nil
local busy = false

local function setWidgetsHidden(hidden)
  noctalia.log("desktop widgets " .. (hidden and "hidden" or "shown")
    .. " (focused workspace " .. (hidden and "has" or "has no") .. " windows)")
  noctalia.runAsync({ "noctalia", "msg", hidden and "desktop-widgets-hide" or "desktop-widgets-show" },
    function(res)
      if res ~= nil and res.exitCode ~= 0 then
        noctalia.log("desktop-widgets IPC failed (" .. tostring(res.exitCode) .. "): " .. tostring(res.stderr))
      end
    end, 5000)
end

local function poll()
  if not HIDE or busy then
    return
  end
  busy = true
  local started = noctalia.runAsync(WIN_CMD, function(res)
    busy = false
    if res == nil or res.exitCode ~= 0 then
      return
    end
    local n = tonumber(res.stdout)
    if n == nil then
      return
    end
    local hasWindows = n > 0
    if knownWindows == nil or hasWindows ~= knownWindows then
      local apply = hasWindows
      knownWindows = hasWindows
      setWidgetsHidden(apply)
    end
  end, 2000)
  if not started then
    busy = false
  end
end

noctalia.setUpdateInterval(POLL_MS)

function update()
  poll()
end

function onConfigChanged()
  HIDE = noctalia.getConfig("hide_with_windows") ~= false
  POLL_MS = noctalia.getConfig("poll_ms") or 500
  noctalia.setUpdateInterval(POLL_MS)
  if not HIDE and knownWindows == true then
    knownWindows = false
    setWidgetsHidden(false)
  end
  poll()
end

function onExit(_signal, reason)
  -- Never leave the shell stuck with every desktop widget hidden.
  if reason == "disable" or reason == "uninstall" then
    noctalia.runAsync({ "noctalia", "msg", "desktop-widgets-show" })
  end
end
