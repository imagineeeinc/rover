import std/[os], strutils, math
import illwill
import config, global

illwillInit(fullscreen=true)
setControlCHook(exitProc)

var tb* = newTerminalBuffer(terminalWidth(), terminalHeight())

let leftPanelSize = 0.20
let rightPanelSize = 0.5
let leftWidth = int floor float(terminalWidth())*leftPanelSize
let midWidth = int floor float(terminalWidth())*((1-rightPanelSize)*(1-leftPanelSize))
let rightWidth = int floor float(terminalWidth())*(rightPanelSize*(1-leftPanelSize))

let offset: int = if globalConfig.layout.cursor == "center": int floor (terminalHeight()-4)/2 elif globalConfig.layout.cursor == "top-padded": 3 else: 2
proc drawBoxes*() =  
  tb.drawRect(0, 1, leftWidth, terminalHeight()-2)
  tb.drawRect(leftWidth+1, 1, leftWidth+midWidth, terminalHeight()-2)
  tb.drawRect(leftWidth+midWidth+1, 1, leftWidth+midWidth+rightWidth, terminalHeight()-2)

var lastDir: string = ""
proc drawWorkingDir*(dir: string) =
    if dir != lastDir:
      tb.write(1, 0, resetStyle, fgNone, repeat(" ", terminalWidth()))
      tb.write(1, 0, fgMagenta, dir)
      lastDir = dir

var lastLeftDir: string = ""
proc drawFilesLeft*(files: seq[tuple[kind: PathComponent, path: string]], workingDir: string) =
  if workingDir != lastLeftDir:
    if workingDir != "ThisPc" and workingDir != "":
      var i = 0
      tb.setForegroundColor(fgNone)
      tb.setBackgroundColor(bgNone)
      tb.fill(1,2, leftWidth-1, terminalHeight()-3, " ")
      for file in files:
        var text = if file.kind == pcFile: extractFilename(file.path) else: extractFilename(file.path) & "/"
        text = if text.len > leftWidth-2: text[0..leftWidth-5] & "..." else: text
        tb.write(1, i+2, resetStyle, fgNone, text)
        i+=1
        if i >= terminalHeight()-4:
          break
      lastLeftDir = workingDir
    else:
      discard
var lastMidDir: string = ""
var lastY: int = -1
proc drawFilesMid*(files: seq[tuple[kind: PathComponent, path: string]], workingDir: string, cursorY: int) =
  if workingDir != lastMidDir or cursorY != lastY:
    var i = 0
    tb.setForegroundColor(fgNone)
    tb.setBackgroundColor(bgNone)
    tb.fill(leftWidth+2,2, leftWidth+midWidth-1, terminalHeight()-3, " ")
    for file in files:
      if i+offset-cursorY < 2:
        i+=1
        continue
      var color: string = ""
      if file.kind == pcDir:
        color = globalConfig.colors.colorType.folder
      elif file.path.endsWith(".exe") or file.path.endsWith(".bat") or file.path.endsWith(".cmd") or file.path.endsWith(".sh"):
        color = globalConfig.colors.colorType.executable
      # TODO: Remove hardcoded file types
      elif file.path.endsWith(".jpg") or file.path.endsWith(".png") or file.path.endsWith(".gif"):
        color = globalConfig.colors.colorType.images
      else:
        color = "white"
      var fg: ForegroundColor = if i == cursorY: fgBlack else: matchColorFg(color)

      let bg: BackgroundColor = if i == cursorY: matchColorBg(color) else: bgNone
      var text = if file.kind == pcFile: extractFilename(file.path) else: extractFilename(file.path) & "/"
      text = if text.len > midWidth-2: text[0..midWidth-5] & "..." else: text
      tb.write(
        leftWidth+2,
        i+offset-cursorY,
        resetStyle,
        fg, bg,
        text
      )
      i+=1
      if i-cursorY >= terminalHeight()-2-offset:
        break
      
    lastMidDir = workingDir
    lastY = cursorY
proc drawRightPanel*(file: global.File) =
  if file.path.endsWith(".jpg") or file.path.endsWith(".png"):
    discard
