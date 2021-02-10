import strutils, strformat, os
import inspectlog

proc initCount(): int =
  let param = paramStr(1)
  try:
    return param.parseInt
  except ValueError:
    raiseAssert(fmt "引数の値が不正です: {param}")

proc initHeavilyLoadTimeSetting(): HeavilyLoadTimeSetting =
  block:
    let param = paramStr(2)
    try:
      result.Count = param.parseInt
    except ValueError:
      raiseAssert(fmt "引数の値が不正です: {param}")

  block:
    let param = paramStr(3)
    try:
      result.Time = param.parseInt
    except ValueError:
      raiseAssert(fmt "引数の値が不正です: {param}")

when isMainModule:
  if paramCount() != 3:
    raiseAssert(fmt "引数の値が不正です")

  if not fileExists("./log"):
    raiseAssert(fmt "ログファイルが見つかりません")

  let
    logData = readFile("./log").splitLines
    count = initCount()
    setting = initHeavilyLoadTimeSetting()

  outPutDownTimes(logData, count)
  outPutHeavilyLoadTime(logData, setting)
