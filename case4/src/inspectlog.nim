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

type SubnetInfo = object
  Subnet: string
  LogList: seq[LogInfo]

proc parseInt(c: char): int {.inline.} = parseInt($c)

proc toBin(str: string, positive: int): string {.inline.} =
  parseInt(str).toBin(positive)

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

proc getSubnet(str: string): string =
  let strSplit = str.split("/")
  if strSplit.len != 2:
    raiseAssert(fmt "IPアドレスのフォーマットが不正です: {str}")

  let address = strSplit[0].split(".")
  if address.len != 4:
    raiseAssert(fmt "IPアドレスのフォーマットが不正です: {str}")

  try: discard strSplit[1].parseInt
  except ValueError:
    raiseAssert(fmt "IPアドレスのフォーマットが不正です: {str}")
  let mask = strSplit[1]

  # アドレスを2進数の配列に変換
  var addressBin: array[4, array[8, int]]
  for i, s in address:
    let
      n = s.parseInt
      bin = n.toBin(8)
    for j, bit in bin:
      addressBin[i][j] = bit.parseInt

  var maskBin = ""
  for i in 0 ..< mask.parseInt: maskBin &= "1"

  var countMask = 0
  for octet in addressBin:
    for bit in octet:
      if maskBin.len == countMask: return
      else:
        result &= $(bit and maskBin[countMask].parseInt)
        countMask.inc

proc contains(subnetList: seq[SubnetInfo], subnet: string): bool {.inline.} =
  for s in subnetList:
    if s.Subnet == subnet: return true

proc isAlive(log: LogInfo): bool {.inline.} = isSome(log.ResponceTime)

# 存在しない場合-1を返す
proc search(subnetList: seq[SubnetInfo], subnet: string): int {.inline.} =
  result = -1
  for index, s in subnetList:
    if s.Subnet == subnet: return index

proc getBrokenSubnet(logList: seq[LogInfo], count: int): seq[SubnetInfo] =
  var subnetList: seq[SubnetInfo]

  for log in logList:
    if not log.isAlive:
      let subnet = getSubnet(log.IpAddress)
      if subnetList.contains(subnet):
        let index = subnetList.search(subnet)
        subnetList[index].LogList.add(log)
      else:
        let s = SubnetInfo(Subnet: subnet, LogList: @[log])
        subnetList.add(s)

  for s in subnetList:
    var countTimeout = 0
    for log in s.LogList:
      if not log.isAlive: countTimeout.inc
      else: countTimeout = 0

      if countTimeout >= count:
        result.add(s)
        break

# count回以上連続で応答が無い場合故障とみなす
proc outPutBrokenSubnet*(log: seq[string], count: int) =
  let
    logList = initLogInfoList(log)
    brokenSubnet = logList.getBrokenSubnet(count)

  echo "-- サブネットの故障期間 --"
  for s in brokenSubnet:
    let
      startTime = s.LogList[0].SendTime
      endTime = s.LogList[^1].SendTime
    echo fmt "{s.Subnet}: {startTime} ~ {endTime}"

# 故障している期間を全て出力.
proc outPutDownTimes*(log: seq[string], interval: int) =
  let
    logList = initLogInfoList(log)
    downTimes = getDownTimes(logList, interval)

  echo "-- サーバーの故障期間 --"
  for index, time in downTimes:
    let
      startTime = time.Start.get
      endTime = time.End.get
    echo fmt "{index + 1}: {startTime} ~ {endTime} " & "\n"
