import std/[os]
import illwill

proc exitProc*() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

type File* = tuple[kind: PathComponent, path: string]
type Files* = seq[File]

