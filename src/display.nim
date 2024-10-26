import std/[os], strutils, math
import illwill
proc exitProc*() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

illwillInit(fullscreen=true)
setControlCHook(exitProc)

var tb* = newTerminalBuffer(terminalWidth(), terminalHeight())

let leftPanelSize = 0.20
let rightPanelSize = 0.5
let leftWidth = int floor float(terminalWidth())*leftPanelSize
let midWidth = int floor float(terminalWidth())*((1-rightPanelSize)*(1-leftPanelSize))
let rightWidth = int floor float(terminalWidth())*(rightPanelSize*(1-leftPanelSize))

proc drawBoxes*() =  
  tb.drawRect(0, 1, leftWidth, terminalHeight()-2)
  tb.drawRect(leftWidth+1, 1, leftWidth+midWidth, terminalHeight()-2)
  tb.drawRect(leftWidth+midWidth+1, 1, leftWidth+midWidth+rightWidth, terminalHeight()-2)

var lastDir: string = ""
proc drawWorkingDir*(dir: string) =
    if dir != lastDir:
      tb.write(1, 0, fgNone, repeat(" ", terminalWidth()))
      tb.write(1, 0, fgMagenta, dir)
      lastDir = dir

var lastLeftDir: string = ""
proc drawFilesLeft*(files: seq[tuple[kind: PathComponent, path: string]], workingDir: string) =
  if workingDir != lastLeftDir:
    var i = 0
    tb.setForegroundColor(fgNone)
    tb.setBackgroundColor(bgNone)
    tb.fill(1,2, leftWidth-1, terminalHeight()-3, " ")
    for file in files:
      if file.kind == pcFile:
        tb.write(1, i+2, resetStyle, fgWhite, extractFilename(file.path))
      elif file.kind == pcDir:
        tb.write(1, i+2, resetStyle, fgWhite, extractFilename(file.path) & "/")
      i+=1
      if i >= terminalHeight()-4:
        break
    lastLeftDir = workingDir

var lastMidDir: string = ""
var lastY: int = -1
proc drawFilesMid*(files: seq[tuple[kind: PathComponent, path: string]], workingDir: string, cursorY: int) =
  if workingDir != lastMidDir or cursorY != lastY:
    var i = 0
    tb.setForegroundColor(fgNone)
    tb.setBackgroundColor(bgNone)
    tb.fill(leftWidth+2,2, leftWidth+midWidth-1, terminalHeight()-3, " ")
    for file in files:
      let fg = if i == cursorY: fgCyan else: fgWhite
      let bg = if i == cursorY: bgWhite else: bgNone
      if file.kind == pcFile:
        tb.write(leftWidth+2, i+2, resetStyle, fg, bg, extractFilename(file.path))
      elif file.kind == pcDir:
        tb.write(leftWidth+2, i+2, resetStyle, fg, bg, extractFilename(file.path) & "/")
      i+=1
      if i >= terminalHeight()-4:
        break
    lastMidDir = workingDir
    lastY = cursorY
