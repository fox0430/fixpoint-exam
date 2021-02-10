import strutils
import inspectlog

when isMainModule:
  if not fileExists("./log"):
    raiseAssert(fmt "ログファイルが見つかりません")

  let logData = readFile("./log")
  outPutDownTimes(logData.splitLines)
