import strutils, strformat, os
import inspectlog

when isMainModule:
  if not fileExists("./log"):
    raiseAssert(fmt "ログファイルが見つかりません")
  let logData = readFile("./log").splitLines

  if paramCount() != 2:
    raiseAssert(fmt "引数の値が不正です")

  var timeoutCount = 0
  block:
    let param = paramStr(1)
    try:
      timeoutCount = param.parseInt
    except ValueError:
      echo fmt "引数の値が不正です: {param}"

  var subnetCount = 0
  block:
    let param = paramStr(2)
    try:
      subnetCount = param.parseInt
    except ValueError:
      echo fmt "引数の値が不正です: {param}"

  outPutDownTimes(logData, timeoutCount)
  outPutBrokenSubnet(logData, subnetCount)
