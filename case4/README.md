# 設問2

## Nimのインストールについて

https://nim-lang.org/install.html
or
https://github.com/dom96/choosenim

## 概要

プログラムを実行したディレクトリに存在する ```log``` という名前のログファイルを読み込みサーバーの故障期間, 及びサブネットの故障期間を出力する.
プログラムには2つ数値の引数を与える必要がある.

1つ目の引数をNとするとN回以上連続してタイムアウトした場合にのみ故障とみなす

2つめの引数をMとするとM回以上連続であるサブネットで応答が無かった場合サブネットの故障とみなす

```
echo "20201019133324,10.20.30.1/16,-" > log
nimble build
./case2 1 1
```

## テスト

```
nimble test
```

[Code](https://github.com/fox0430/fixpoint-exam/blob/main/case4/tests/tcase4.nim)
