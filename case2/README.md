# 設問2

## Nimのインストールについて

https://nim-lang.org/install.html
or
https://github.com/dom96/choosenim

## 概要

プログラムを実行したディレクトリに存在する ```log``` という名前のログファイルを読み込み故障期間を出力する.
プログラムには1つ数値の引数を与えることができこの引数N回以上連続してタイムアウトした場合にのみ故障とみなす.
引数を与えなかった場合, 値は1となる.

```
echo "20201019133324,10.20.30.1/16,-" > log
nimble build
./case2 1
```

## テスト

```
nimble test
```

[Code](https://github.com/fox0430/fixpoint-exam/blob/main/case2/tests/tcase2.nim)
