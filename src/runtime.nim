import std/[os, distros], sequtils, strutils
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
      parentWorkingDir = workingDir.parentDir()
      parentFiles = toSeq(walkDir(workingDir.parentDir()))
      return true
    else:
      return false
  elif text == "q":
    exitProc()
  else:
    return false
