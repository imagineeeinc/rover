import sequtils
import parsetoml
import illwill

type ColorType = ref object
  folder*: string
  executable*: string
  archives*: string
  images*: string
  audio*: string
  video*: string
  mappings*: seq[tuple[ext: string, color: string]]
type Color = ref object
  important*: string
  normal*: string
  colorType*: ColorType

type Preview = ref object
  text*: string
  image*: string
  audio*: string
  video*: string

type Layout = ref object
  leftPanel*: float
  rightPanel*: float
  cursor*: string

type Config = ref object
  colors*: Color
  preview*: Preview
  layout*: Layout
  mappings*: seq[tuple[name: string, files: seq[string]]]

let defaultConfig = Config(
  layout: Layout(
    leftPanel: 0.20,
    rightPanel: 0.5,
    cursor: "center"
  ),
  colors: Color(
    important: "green",
    normal: "white",
    colorType: ColorType(
      folder: "blue",
      executable: "green",
      archives: "red",
      images: "magenta",
      audio: "cyan",
      video: "magenta"
    )
  ),
  preview: Preview(
    text: "cat",
    image: "chafa",
    audio: "ffplay",
    video: "ffplay"
  ),
  mappings: @[
    (name: "images", files: @["*.png", "*.jpg", "*.jpeg", "*.webp"]),
    (name: "audio", files: @["*.mp3", "*.wav", "*.ogg", "*.flac"]),
    (name: "video", files: @["*.mp4", "*.mkv", "*.avi", "*.mov", "*.webm"]),
    (name: "archives", files: @["*.zip", "*.rar", "*.tar", "*.gz", "*.7z", "*.iso"]),
  ]
)
var globalConfig* = deepCopy(defaultConfig)

proc matchColorFg*(ext: string): ForegroundColor =
  if ext == "black": result = fgBlack
  elif ext == "red": result = fgRed
  elif ext == "green": result = fgGreen
  elif ext == "yellow": result = fgYellow
  elif ext == "blue": result = fgBlue
  elif ext == "magenta": result = fgMagenta
  elif ext == "cyan": result = fgCyan
  elif ext == "white": result = fgWhite
  else: result = fgNone

proc matchColorBg*(ext: string): BackgroundColor =
  if ext == "black": result = bgBlack
  elif ext == "red": result = bgRed
  elif ext == "green": result = bgGreen
  elif ext == "yellow": result = bgYellow
  elif ext == "blue": result = bgBlue
  elif ext == "magenta": result = bgMagenta
  elif ext == "cyan": result = bgCyan
  elif ext == "white": result = bgWhite
  else: result = bgNone

proc importConfig*(path: string): bool =
  let loadedConfig = parsetoml.parseFile(path)
  if loadedConfig.hasKey("colors"):
    globalConfig.colors.important = loadedConfig["colors"]["important"].getStr(defaultConfig.colors.important)
    globalConfig.colors.normal = loadedConfig["colors"]["normal"].getStr(defaultConfig.colors.normal)

    globalConfig.colors.colorType.folder = loadedConfig["colors"]["folder"].getStr(defaultConfig.colors.colorType.folder)
    globalConfig.colors.colorType.executable = loadedConfig["colors"]["executable"].getStr(defaultConfig.colors.colorType.executable)
    globalConfig.colors.colorType.archives = loadedConfig["colors"]["archives"].getStr(defaultConfig.colors.colorType.archives)
    globalConfig.colors.colorType.images = loadedConfig["colors"]["images"].getStr(defaultConfig.colors.colorType.images) 
    globalConfig.colors.colorType.audio = loadedConfig["colors"]["audio"].getStr(defaultConfig.colors.colorType.audio)
    globalConfig.colors.colorType.video = loadedConfig["colors"]["video"].getStr(defaultConfig.colors.colorType.video)
    if loadedConfig["colors"].hasKey("mappings"):
      for mapping in loadedConfig["colors"]["mappings"].getElems():
        globalConfig.colors.colorType.mappings.add((mapping["name"].getStr(), mapping["color"].getStr()))

  if loadedConfig.hasKey("preview"):
    globalConfig.preview.text = loadedConfig["preview"]["text"].getStr(defaultConfig.preview.text)
    globalConfig.preview.image = loadedConfig["preview"]["image"].getStr(defaultConfig.preview.image)
    globalConfig.preview.audio = loadedConfig["preview"]["audio"].getStr(defaultConfig.preview.audio)
    globalConfig.preview.video = loadedConfig["preview"]["video"].getStr(defaultConfig.preview.video)
  
  if loadedConfig.hasKey("layout"):
    globalConfig.layout.leftPanel = loadedConfig["layout"]["leftPanel"].getFloat(defaultConfig.layout.leftPanel)
    globalConfig.layout.rightPanel = loadedConfig["layout"]["rightPanel"].getFloat(defaultConfig.layout.rightPanel)
    globalConfig.layout.cursor = loadedConfig["layout"]["cursor"].getStr(defaultConfig.layout.cursor)

  # TODO: Fix file mappings implemnetation
  if loadedConfig.hasKey("mappings"):
    for mapping in loadedConfig["mappings"].getElems():
      globalConfig.mappings.add((name: mapping["name"].getStr(), files: mapping["files"].getElems().mapIt(it.getStr())))

  result = true
