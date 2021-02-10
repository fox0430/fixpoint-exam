import strutils, options, times, strformat

type LogInfo = object
  # 確認時間
  SendTime: DateTime
  # IP アドレス
  IpAddress: string
  # 応答時間
  ResponceTime: Option[int]

# 故障期間
type DownTime = tuple
  Start: Option[DateTime]
  End: Option[DateTime]

proc parseResponceTime(str: string): Option[int] =
  if str == "-":
    # 応答が無い場合
    return none(int)
  else:
    try:
      return some(parseInt(str))
    except ValueError:
      raiseAssert(fmt "応答時間の文字列が不正です: {str}")

proc parseDate(str: string): DateTime =
  const format = "yyyymmddhhmmss"
  try:
    return parse(str, format)
  except TimeParseError:
    raiseAssert(fmt "確認日時のフォーマットが不正です: {str}")

# ログのデータから seq[LogInfo] を作成
proc initLogInfoList(log: seq[string]): seq[LogInfo] =
  for line in log:
    let lineSplit = line.split(",")
    if lineSplit.len == 3:
      let
        sendTime = parseDate(lineSplit[0])
        ipAddress = lineSplit[1]
        reponceTime = parseResponceTime(lineSplit[2])

        # LogInfo object を作成
        logInfo = LogInfo(SendTime: sendTime,
                          IpAddress: ipAddress,
                          ResponceTime: reponceTime)

      # Nimでは返り値がある場合, 暗黙的にresult変数が使用可能
      result.add(logInfo)

# ログのデータから故障している期間を全て取得
proc getDownTimes(logList: seq[LogInfo]): seq[DownTime] =
  var isBroken = false
  for index, log in logList:
    if isNone(log.ResponceTime) and not isBroken:
      # 故障開始時間をセット
      isBroken = true
      let f: DownTime = (Start: some(log.SendTime), End: none(DateTime))
      result.add(f)
    elif isBroken and isSome(log.ResponceTime):
      # 復旧時間をセット
      # ^1 == result.high == result.len - 1
      result[^1].End = some(log.SendTime)
      isBroken = false

  if isBroken:
    result[^1].End = result[^1].Start

# 故障している期間を全て出力
proc outPutDownTimes*(log: seq[string]) =
  let
    logList = initLogInfoList(log)
    downTimes = getDownTimes(logList)

  echo "-- 故障期間 --"
  for index, time in downTimes:
    let
      startTime = time.Start.get
      endTime = time.End.get
    echo fmt "{index + 1}: {startTime} ~ {endTime} " & "\n"
