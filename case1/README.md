# 設問1

## Nimのインストールについて

https://nim-lang.org/install.html
or
https://github.com/dom96/choosenim

## 概要

プログラムを実行したディレクトリに存在する ```log``` という名前のログファイルを読み込み故障期間を出力する.

```
echo "20201019133324,10.20.30.1/16,-" > log
nimble build
./case1
```

## テスト

```
nimble test
```

[Code](https://github.com/fox0430/fixpoint-exam/blob/main/case1/tests/tcase1.nim)
