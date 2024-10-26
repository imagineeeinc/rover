import std/[os], strutils
import illwill
import config, display, runtime

discard importConfig("config.toml")
tb.setForegroundColor(fgBlack, true)

drawBoxes()
hideCursor()

var cursorX: int = 0
var cursorY: int = 0
var statusLine: bool = false
var status: string = ""

let pwd = getCurrentDir()
discard execute("cd " & pwd)

when isMainModule:
  while true:
    # Draw
    drawWorkingDir(workingDir)
    drawFilesLeft(parentFiles, parentWorkingDir)
    drawFilesMid(files, workingDir, cursorY)
    # Input
    var key = getKey()
    try:
      let inputed = char(key.ord)
      if key == Key.Up or key == Key.K:
        if cursorY > 0:
          cursorY -= 1
      elif key == Key.Down or key == Key.J:
        if cursorY < len(files)-1:
          cursorY += 1
      elif (key == Key.Left or key == Key.H) and statusLine == false:
        discard execute("cd ..")
        cursorY = 0
      elif (key == Key.Right or key == Key.L) and statusLine == false:
        if files[cursorY].kind == pcDir:
          discard execute("cd " & files[cursorY].path)
          cursorY = 0
      elif key == Key.Colon and statusLine == false:
        statusLine = true
        tb.write(cursorX, terminalHeight()-1, fgWhite,":")
        cursorX+=1
      elif (key == Key.Backspace or key == Key.CtrlH or key == Key.Delete) and statusLine == true:
        if cursorX-1 == 0:
          statusLine = false
        else:
          status = status[0..^2]
        cursorX-=1
        tb.write(cursorX, terminalHeight()-1, "  ")
      elif key == Key.Enter and statusLine == true:
        statusLine = false
        discard execute(status)
        cursorX = 0
        tb.write(0, terminalHeight()-1, fgNone, repeat(" ", len(status)+2))
        status = ""
      elif statusLine == true:
        tb.write(cursorX, terminalHeight()-1, fgWhite, $inputed)
        cursorX+=1
        status = status & $inputed
      if statusLine == true:
        tb.write(cursorX, terminalHeight()-1, fgWhite, "█")
    except:
      discard
    tb.setCursorPos(0, terminalHeight()-1)
    tb.display()
