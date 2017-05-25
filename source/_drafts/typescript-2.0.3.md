---
title: TypeScript 2.0.3 変更点
date: 2016-09-24 12:00:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/826bf193dd301862014f)ものと同じ内容です。

---

こんばんは[@vvakame](https://twitter.com/vvakame)です。

とかいいつつ、本当は[RC変更点](https://blogs.msdn.microsoft.com/typescript/2016/08/30/announcing-typescript-2-0-rc/)とかです。
ついに[2系正式版リリース](https://blogs.msdn.microsoft.com/typescript/2016/09/22/announcing-typescript-2-0/)の運びとなり、大変めでたいです。
[2.0 Beta変更点](http://qiita.com/vvakame/items/ae239f3d6f6f08f7c719)から実に2ヶ月半。長い。

## 変更点まとめ

* Literal Typesの拡大 [Number, enum, and boolean literal types](https://github.com/Microsoft/TypeScript/pull/9407)
	* 今まではstringだけだったものがnumberとbooleanにも拡大

薄味ですね。

次の2つはBetaからの要素でした。
タグ付きUnion型 [Discriminated union types](https://github.com/Microsoft/TypeScript/pull/9163)
tsconfig.jsonでのglobサポート [support globs in tsconfig.json files property (or just file/directory exclusions)](https://github.com/Microsoft/TypeScript/issues/1927)

## Literal Typesの拡大

[String Literal Types](http://qiita.com/vvakame/items/31f5c45ff49de67d5634#string-literal-types)の考え方がbooleanとnumber、Enumにも拡張されました。
これでJavaScriptのprimitiveっぽい型はLiteral Typesで書けるようになりました。

```ts
// 1桁の数字！
type Digit = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9;

function pinNumber(a: Digit, b: Digit, c: Digit, d: Digit) {
}

// 1桁の数字×4 → OK！
pinNumber(1, 2, 3, 4);
// 2桁の数字が混ざってるのでコンパイルエラー
pinNumber(8, 7, 9, 10);

// JavaScript的に false な値の集合なども表現できる
type Falsy = "" | 0 | false | null | undefined;
let f: Falsy = 0;

// EnumもLiteral Types扱い
enum Suit {
	Heart, Spade, Club, Diamond,
}
type RedSuit = Suit.Heart | Suit.Diamond;
type BlackSuit = Suit.Spade | Suit.Club;
```

[Playground](https://goo.gl/9Qi1CU)

これだけなので見どころがない…！
