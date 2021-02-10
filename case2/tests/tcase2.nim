import unittest, strutils, times, options
include src/inspectlog

const log = """
20201019133124,10.20.30.1/16,2
20201019133125,10.20.30.2/16,1
20201019133134,192.168.1.1/24,10
20201019133135,192.168.1.2/24,5
20201019133224,10.20.30.1/16,522
20201019133225,10.20.30.2/16,-
20201019133234,192.168.1.1/24,-
20201019133235,192.168.1.2/24,-
20201019133324,10.20.30.1/16,-
20201019133325,10.20.30.2/16,2
"""

suite "設問 2":
  test "2回以上連続で応答が無かった場合に故障とみなす":
    let
      logList = initLogInfoList(log.splitLines)
      downTimes = getDownTimes(logList, 2)

    check downTimes.len == 1

  test "5回以上連続で応答が無かった場合に故障とみなす":
    let
      logList = initLogInfoList(log.splitLines)
      downTimes = getDownTimes(logList, 5)

    check downTimes.len == 0
