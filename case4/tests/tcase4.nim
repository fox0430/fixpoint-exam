import unittest, strutils, times, options
include src/inspectlog

const log = """
20201019133122,192.168.1.1/24,10
20201019133123,10.20.30.1/16,10
20201019133124,10.20.30.1/16,-
20201019133125,10.20.30.2/16,-
20201019133224,10.20.30.3/16,-
20201019133225,10.20.30.4/16,-
20201019133134,192.168.1.1/24,10
20201019133135,192.168.1.2/24,-
20201019133325,10.20.30.2/16,2
"""

suite "設問 4":
  test "同一サブネットから応答が3回以上無かった場合故障とみなす":
    let
      logList = initLogInfoList(log.splitLines)
      brokenSubnet = getBrokenSubnet(logList, 3)

    check brokenSubnet.len == 1
    check brokenSubnet[0].LogList.len == 4

    for log in brokenSubnet[0].LogList:
      check isNone(log.ResponceTime)
