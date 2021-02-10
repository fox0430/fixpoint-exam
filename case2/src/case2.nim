import strutils, strformat, os
import inspectlog

when isMainModule:
  if not fileExists("./log"):
    raiseAssert(fmt "ログファイルが見つかりません")
  let logData = readFile("./log")

  var count = 1
  # 引数を取得
  if paramCount() == 1:
    let arg = paramStr(1)
    try:
      count = arg.parseInt
    except ValueError:
      echo fmt "引数の値が不正です: {arg}"

  outPutDownTimes(logData.splitLines, count)
