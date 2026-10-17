--!nonstrict
-- Cava Visualizer — desktop widget: rounded bars pinned to the bottom edge.
--
-- Streams `cava` stdout in raw ascii mode via noctalia.runStream, smooths the
-- values, and renders a bottom-aligned row of rounded ui.box bars.
--
-- Two layout details matter:
--   * The row gets an explicit `height` (row_height == the widget box_height).
--     Without it the row hugs the tallest bar, the host centres that block in
--     the box, and the baseline drifts with the music ("grows from the middle").
--   * The box is placed so it extends a few px past the bottom of the screen;
--     the bars' bottom rounding is then clipped off-screen and the base reads
--     flat instead of tapering like a pill.

local BARS = math.floor(noctalia.getConfig("bands") or 48)
local BOX_H = noctalia.getConfig("bar_max_height") or 100.0
local ROW_H = noctalia.getConfig("row_height") or 150.0
local SPACING = noctalia.getConfig("spacing") or 3.0
local RADIUS = noctalia.getConfig("radius") or 0.0 -- 0 = pill (half bar width)
local COLOR = noctalia.getConfig("bar_color") or "#ffffff"
local OPACITY = noctalia.getConfig("bar_opacity") or 1.0
local HIDE_IDLE = noctalia.getConfig("hide_when_idle") ~= false
local HIDE_WINDOWS = noctalia.getConfig("hide_with_windows") ~= false
local BOX_W = noctalia.getConfig("box_width") or 1920.0

local ASCII_MAX = 100
-- Tuned for a 60Hz display: cava samples at 60fps and render matches it. SMOOTH
-- is the per-frame lerp; 0.175 at 60fps settles in the same ~0.26s that 0.32 did
-- at 30fps (1-(1-0.32)^(30/60)). EPSILON is halved for the same reason: a given
-- audio change is split across twice as many frames.
local SMOOTH = 0.175
local IDLE_FRAMES = 15
local RENDER_MS = 16
local WIN_POLL_MS = 500
local EPSILON = 0.002

local target = {}
local current = {}
local idleFrames = 0
local cavaStarted = false
local cavaWarned = false
local hasWindows = false
local winBusy = false

for i = 1, BARS do
  target[i] = 0
  current[i] = 0
end

local BAR_W = (BOX_W - SPACING * (BARS - 1)) / BARS
local BAR_RADIUS = RADIUS > 0 and RADIUS or math.min(BAR_W / 2, BOX_H / 2)

-- Counts windows on niri's focused workspace. Needs niri + jq; silently keeps
-- the previous state when either is missing so the widget never sticks hidden.
local WIN_CMD =
  "sh -c 'ws=$(niri msg --json workspaces | jq -r \".[]|select(.is_focused==true).id\"); "
  .. "niri msg --json windows | jq --argjson ws \"$ws\" \"[.[]|select(.workspace_id==$ws)]|length\"'"

local render

local function writeCavaConfig()
  local path = noctalia.pluginDataDir() .. "/cava.conf"
  local conf = string.format(
    table.concat({
      "[general]",
      "framerate = 60",
      "autosens = 1",
      "sleep_timer = 0",
      "bars = %d",
      "",
      "[input]",
      'method = "pulse"',
      'source = "auto"',
      "",
      "[smoothing]",
      "monstercat = 1",
      "waves = 0",
      "gravity = 120",
      "noise_reduction = 80",
      "",
      "[output]",
      'method = "raw"',
      'raw_target = "/dev/stdout"',
      'data_format = "ascii"',
      "ascii_max_range = %d",
      "bar_delimiter = 59",
      "frame_delimiter = 10",
      "",
    }, "\n"),
    BARS,
    ASCII_MAX
  )
  noctalia.writeFile(path, conf)
  return path
end

local function onCavaLine(line)
  if line == nil or line == "" then
    return
  end
  local i = 1
  for num in line:gmatch("([^;]+)") do
    if i > BARS then
      break
    end
    local v = tonumber(num)
    if v ~= nil then
      target[i] = math.clamp(v / ASCII_MAX, 0, 1)
    end
    i = i + 1
  end
  while i <= BARS do
    target[i] = 0
    i = i + 1
  end
  idleFrames = 0
end

local function startCava()
  if cavaStarted then
    return
  end
  if not noctalia.commandExists("cava") then
    if not cavaWarned then
      cavaWarned = true
      noctalia.notifyError("Cava Visualizer", "cava is not installed (pacman -S cava).")
    end
    return
  end
  local conf = writeCavaConfig()
  if noctalia.runStream("cava -p '" .. conf .. "'", onCavaLine) then
    cavaStarted = true
  else
    noctalia.notifyError("Cava Visualizer", "Failed to launch cava.")
  end
end

-- Advances the smoothed values (cheap, no UI objects) and reports whether any
-- bar moved more than EPSILON, so the caller can skip an identical render.
local function advanceBars()
  local sum = 0
  local moved = false
  for i = 1, BARS do
    local t = target[i] or 0
    local prev = current[i] or 0
    local c = prev + (t - prev) * SMOOTH
    if c < 0.015 then
      c = 0
    end
    current[i] = c
    if math.abs(c - prev) > EPSILON then
      moved = true
    end
    sum = sum + c
  end
  return sum, moved
end

-- Building 70 ui.box nodes is the expensive half, so it only runs when we are
-- actually about to hand a new tree to the host.
local function buildBoxes()
  local boxes = {}
  for i = 1, BARS do
    boxes[i] = ui.box({
      key = "bar" .. i,
      width = BAR_W,
      height = (current[i] or 0) * BOX_H,
      radius = BAR_RADIUS,
      fill = COLOR,
      opacity = OPACITY,
    })
  end
  return boxes
end

-- height pins the row to the full box height; align = "end" then puts every
-- bar's baseline on the row's bottom edge, whatever the tallest bar is.
local ROW = { gap = SPACING, align = "end", height = ROW_H, flexGrow = 1 }

local lastHidden = nil

render = function()
  local hidden = HIDE_WINDOWS and hasWindows
  local moved = false

  if not hidden then
    local sum
    sum, moved = advanceBars()
    if HIDE_IDLE and sum < 0.05 then
      idleFrames = idleFrames + 1
      if idleFrames > IDLE_FRAMES then
        hidden = true
      end
    else
      idleFrames = 0
    end
  end

  -- Only touch the tree when the visible state actually changes.
  if hidden then
    if lastHidden ~= true then
      lastHidden = true
      desktopWidget.render(ui.row(ROW, {}))
    end
    return
  end
  if lastHidden == true then
    lastHidden = false
    moved = true
  end
  if not moved then
    return
  end
  desktopWidget.render(ui.row(ROW, buildBoxes()))
end

local function pollWindows()
  if not HIDE_WINDOWS or winBusy then
    return
  end
  winBusy = true
  local started = noctalia.runAsync(WIN_CMD, function(res)
    winBusy = false
    if res == nil or res.exitCode ~= 0 then
      return
    end
    local n = tonumber(res.stdout)
    if n == nil then
      return
    end
    local v = n > 0
    if v ~= hasWindows then
      hasWindows = v
      render()
    end
  end, 2000)
  if not started then
    winBusy = false
  end
end

startCava()
desktopWidget.setNeedsFrameTick(true)
render()
pollWindows()

local pollAcc = 0
local renderAcc = 0
function onFrameTick(deltaMs)
  local dt = deltaMs or 0
  if HIDE_WINDOWS then
    pollAcc = pollAcc + dt
    if pollAcc >= WIN_POLL_MS then
      pollAcc = 0
      pollWindows()
    end
  end
  renderAcc = renderAcc + dt
  if renderAcc >= RENDER_MS then
    renderAcc = 0
    render()
  end
end

function onExit(_signal, _reason)
  -- runStream is terminated automatically when the entry stops/reloads.
end
