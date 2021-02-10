# 設問2

## Nimのインストールについて

https://nim-lang.org/install.html
or
https://github.com/dom96/choosenim

## 概要

プログラムを実行したディレクトリに存在する ```log``` という名前のログファイルを読み込み故障期間, 及び過負荷期間を出力する.
プログラムには3つ数値の引数を与える必要がある.

1つ目の引数をNとするとN回以上連続してタイムアウトした場合にのみ故障とみなす

2つめの引数をm, 3つ目の引数をtとすると, 直近m回の平均応答時間がtミリ秒を超えた場合を過負荷状態とみなす


```
echo "20201019133324,10.20.30.1/16,-" > log
nimble build
./case2 1 1 1
```

## テスト

```
nimble test
```

[Code](https://github.com/fox0430/fixpoint-exam/blob/main/case3/tests/tcase3.nim)
