import std/[os, distros, algorithm], sequtils, strutils
import global

var workingDir*: string
var files*: Files = @[]
var parentWorkingDir*: string
var parentFiles*: Files = @[]
proc execute*(text: string): bool =
  if text.startsWith("cd "):
    var dir = text[3..text.len-1]
    if dir == "..":
      dir = workingDir.splitPath().head
    elif dir == "~":
      dir = getHomeDir()
    elif dir.startsWith("."):
      dir = workingDir/dir
    else:
      if detectOs(Windows) and dir.contains("\\"):
        dir = dir.replace("\\", "/")
      for file in files:
        if file.path == workingDir/dir:
          dir = workingDir/dir
          break

    dir = dir.normalizedPath().absolutePath()
    if dirExists dir:
      workingDir = dir
      files = toSeq(walkDir(workingDir))
      files = files.sortedByIt(it.kind == pcFile)
      if isRootDir(workingDir):
        if detectOs(Windows):
          parentWorkingDir = "ThisPC"
        else:
          parentWorkingDir = ""
        parentFiles = @[]
      else:
        parentWorkingDir = workingDir.parentDir()
        parentFiles = toSeq(walkDir(workingDir.parentDir()))
        parentFiles = parentFiles.sortedByIt(it.kind == pcFile)
      return true
    else:
      return false
  elif text == "q":
    exitProc()
  else:
    return false
