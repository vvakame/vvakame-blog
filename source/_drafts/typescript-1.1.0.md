---
title: TypeScript 1.1.0 変更点
date: 2014-10-07 12:17:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/5e53c392867ebc604267)ものと同じ内容です。

---

TypeScriptリファレンスお買い上げありがとうございます！ [Amazon](http://www.amazon.co.jp/gp/product/484433588X?ie=UTF8&camp=1207&creative=8411&creativeASIN=484433588X&linkCode=shr&tag=damenako-22) [達人出版会](http://tatsu-zine.com/books/typescript-reference)

2014/10/07 TypeScript 1.1.0-1 がリリースされました。ぱちぱち。
コンパイラが書き直されて、大幅な高速化と、わかめが見た感じコードベースのスリム化が行われている気がしなくもない、という感じです。

公式の変更点は[Changes between 1.0 and 1.1](https://github.com/Microsoft/TypeScript/wiki/Breaking-Changes#changes-between-10-and-11)と[List of minor breaking changes from 1.0](https://github.com/Microsoft/TypeScript/issues/153)を見てください。

[Playground](http://www.typescriptlang.org/Playground/)も既に1.1.0-1ベースにアップデートされているようです。

なお、以下の解説はあまり確認せずIssueやサイトに記載の内容を鵜呑みにして記述しております。

## 言語仕様上の変更

TypeScript 1.0 系の間は、基本的には非互換な変更は導入されないことになっています。[Roadmap](https://github.com/Microsoft/TypeScript/wiki/Roadmap)

[非互換な変更 一覧](https://github.com/Microsoft/TypeScript/issues?q=is%3Aissue+label%3A%22Breaking+Change%22+)
[1.1.0で入った非互換な変更 一覧](https://github.com/Microsoft/TypeScript/issues?q=is%3Aissue+label%3A%22Breaking+Change%22+milestone%3A%22TypeScript+1.1%22+is%3Aclosed) (でもMilestoneに組み込まれてないものが結構ある)

とはいえ、旧来のコンパイラを書き直しあわせてバグが減った結果、既存のコードのコンパイルが通らなくなる場合が僅かながら存在します。
つまり、非互換な変更に引っかかってしまった場合、バグる恐れのあるコードが正常に検出されるようになった、と言えます(改善だー)。
とはいえ、基本的には無修正で1.1.0が利用可能でしょう。

* null や undefined との即値演算がエラーになるようになった。
* null や undefined を即値として使いメソッド呼び出ししようとするとエラーになるようになった。
* [クラスのメンバ初期化時のthisの扱い](https://github.com/Microsoft/TypeScript/issues/641)
* [自分を参照する変数初期化の型推論が賢く](https://github.com/Microsoft/TypeScript/issues/522)
* [オーバーロードの選択が間違われるバグの修正](https://github.com/Microsoft/TypeScript/issues/305)
* [外部モジュールが正しいエイリアスを生成しなかったバグの修正？](https://github.com/Microsoft/TypeScript/issues/152)
* [Enumの値がObject型に代入できるようになった？](https://github.com/Microsoft/TypeScript/issues/151) ほんとか？
* [Enumの値がマイナスの数値でも暗黙的に正しくカウントアップされるようになった](https://github.com/Microsoft/TypeScript/issues/150)
* [クラスのメンバの初期化時にsuperが利用不可になった](https://github.com/Microsoft/TypeScript/issues/149)
* [オブジェクト型リテラル中でセミコロンの自動挿入がサポートされた](https://github.com/Microsoft/TypeScript/issues/148)
* [組み込みのObjectやFunctionの拡張まわりのバグが修正された？](https://github.com/Microsoft/TypeScript/issues/48)

## コンパイラの改善

おっそいおっそい言われていたコンパイルにかかる時間が改善されました。
実測値でだいたい4倍くらい高速になったよ！ということらしいです([公式アナウンスより](http://blogs.msdn.com/b/typescript/archive/2014/10/06/announcing-typescript-1-1-ctp.aspx))。
発表当初は5倍と言っていて、僕の手元で3.8倍くらいだったので、まぁそんな感じかな？という変化ですね。
これでコンパイル時間を理由にScalaをやらないくせにTypeScriptやってるダブスタ野郎と誹られなくて済むぞ！

なお、emitされるコードの効率の改善が行われたようです。
静的解析で不要とわかっているものは出力しない感じになっている。

## 結論

TypeScriptは今日から使うべき言語。
