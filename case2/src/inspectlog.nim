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
proc getDownTimes(logList: seq[LogInfo], interval: int): seq[DownTime] =
  var
    downTime: DownTime
    # true で故障状態
    isBroken = false
    # この値がinterval以上ならば故障とみなす
    intervalCount = 0

  for index, log in logList:
    if isBroken and isNone(log.ResponceTime):
      intervalCount.inc
    elif isNone(log.ResponceTime) and not isBroken:
      # 故障開始時間をセット
      isBroken = true
      intervalCount.inc

      downTime.Start = some(log.SendTime)
    elif isBroken and isSome(log.ResponceTime):
      if intervalCount >= interval:
        isBroken = false

        # 復旧時間をセット
        downTime.End = some(log.SendTime)
        result.add(downTime)
      else:
        # intervalCount < interval の場合故障とみなされない
        # 変数をリセット
        intervalCount = 0
        downTime = (Start: none(DateTime), End: none(DateTime))

  if isBroken and intervalCount >= interval:
    downTime.End = some(downTime.Start.get)
    result.add(downTime)

# 故障している期間を全て出力.
proc outPutDownTimes*(log: seq[string], interval: int) =
  let
    logList = initLogInfoList(log)
    downTimes = getDownTimes(logList, interval)

  echo "-- 故障期間 --"
  for index, time in downTimes:
    let
      startTime = time.Start.get
      endTime = time.End.get
    echo fmt "{index + 1}: {startTime} ~ {endTime} " & "\n"
