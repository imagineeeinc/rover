import parsetoml

type Color = ref object
  important*: string
  normal*: string
  executable: string
type Preview = ref object
  text: string
  image: string
  audio: string
  video: string
type Config = ref object
  colors: Color
  preview: Preview
proc importConfig*(path: string): bool =
  let config = parsetoml.parseFile(path)
  result = true
