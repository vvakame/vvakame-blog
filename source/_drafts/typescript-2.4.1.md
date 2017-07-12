---
title: TypeScript 2.4.1 変更点
date: 2017-06-28 11:20:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/289555dcc9aa888ce588)ものと同じ内容です。

---

こんばんは[@vvakame](https://twitter.com/vvakame)です。

[TypeScript 2.4.1](https://blogs.msdn.microsoft.com/typescript/2017/06/27/announcing-typescript-2-4/)がアナウンスされましたね。

[What's new in TypeScriptも更新](https://github.com/Microsoft/TypeScript/wiki/What's-new-in-TypeScript#typescript-24)されているようです。

## 変更点まとめ

* 関数の返り値の型をGenericsの型パラメータの推測に利用する [Infer from generic function return types](https://github.com/Microsoft/TypeScript/pull/16072)
	* `const array: string[] = (<T>(): T[] => [])();` のコンパイルが通るようになった
	* ざっくりコンパイル通すために具体的に型を指定していた箇所を省略可能に
* Generics有りの関数の型パラメータが推論されるようになった [Contextual generic function types](https://github.com/Microsoft/TypeScript/pull/16305)
	* これも上のと同様のメリット
* Genericsの型の互換性チェックがより厳密になった [Stricter generic signature checks](https://github.com/Microsoft/TypeScript/pull/16368)
	* `--noStrictGenericChecks` で無効化できる
* Genericsについて共変性のチェックが行われるようになった [Covariant checking for callback parameters](https://github.com/Microsoft/TypeScript/pull/15104)
	* 雑にAnimalをDogに突っ込む的な広い型から狭い型への代入ができてたのが禁止された
* enumの値にstringが使えるようになった [String valued members in enums](https://github.com/Microsoft/TypeScript/pull/15486)
	* わーい
	* numberの時にできたnumberから変数名を取る的なコードは書けないので注意
* プロパティが全てoptionalな型について特別なサポートを与えるようにした [Weak type detection](https://github.com/Microsoft/TypeScript/pull/16047)
	* 間違ったオブジェクトを渡すのをより積極的に検出するようにした
* dynamic importがstage 3になったので入った [ES dynamic import() expressions](https://github.com/Microsoft/TypeScript/pull/14774)
	* CommonJSのrequireっぽいやつ(ただし非同期に動作
	* ファイル名べた書きと動的な文字列を渡すのとで挙動が違う
* リファクタリングの機能をLanguage Service APIに追加 [Refactoring support in Language Service API](https://github.com/Microsoft/TypeScript/pull/15569)
	* jsファイル中のes5のclass likeな関数をes2015のclassにリファクタリングする [Refactor ES5 function to ES6 class in .js files](https://github.com/Microsoft/TypeScript/pull/15569)
* tsconfig.jsonについてのエラー表示がより良くなった [Better error reporting for errors in tsconfig.json](https://github.com/Microsoft/TypeScript/pull/12336)

全体的に、罠とか不便な箇所を避ける書き方が無意識的に身についてしまっているので "え、それできなかったっけ？" みたいな修正が多いですね。
TypeScriptは素直な言語だよ！と思ってたけど案外… 素直になりました！！

## 関数の返り値の型をGenericsの型パラメータの推測に利用する

説明するのが難しい変更 Part1

```ts
const emptyArray = <T>(): T[] => [];

// 今までは型パラメータの値を明示的に指定するやり方がよかった
let before = emptyArray<string>();
// 最終的な型を明示的に書けば解決できるようになった
let after: string[] = emptyArray();
```

今までは関数の返り値となる型からの型推論ができなかったため、 `T` は `{}` であると推論されていましたが、正しく`string` になるようになりました。

どちらがよいかと言われると、好みの問題感がありますね。
筆者は型パラメータを明示的に指定するほうが好きですが、結局変数の型をマウスホバーで確認することも多いのでどちらでも良いのでしょう。

## Generics有りの関数の型パラメータが推論されるようになった

説明するのが難しい変更 Part2

```ts
const map = <T, U>(f: (v: T) => U) => (a: T[]) => a.map(f);

// 今までは v の型推論ができず {} になっていたが正しく { length: number } になるようになった
const toLength1: (a: { length: number }[]) => number[] = map(v => v.length);

// 今まで通り普通にこう書いたほうがわかりやすい…
const toLength2 = map((v: { length: number }) => v.length);
```

言っていることはわかるが現実的なユースケースとしてどういうパターンで嬉しいのかイマイチわからない…。
推論される範囲が拡大していくとどんどん型を書かなくても堅牢さは保たれる！ということでいいのかもしれない。

## Genericsの型の互換性チェックがより厳密になった

次のような怪しいコードが検出できるようになりました。
破壊的変更でもあるので `--noStrictGenericChecks` オプションが追加されています。

```ts
type A = <T, U>(x: T, y: U) => [T, U];
type B = <S>(x: S, y: S) => [S, S];

function f(a: A, b: B) {
    a = b;  // Error
    b = a;  // Ok
}
```

なお、RCにはこの変更が入っていませんでした。

## Genericsについて共変性のチェックが行われるようになった

正直これまであまり気にしてませんでした(小声

```ts
class Animal {
    constructor(public kind: string) { }
}

class Dog extends Animal {
    constructor() {
        super("dog");
    }

    berk() {
        return "bow wow!";
    }
}

interface Container<T> {
    consume(callback: (data: T) => void): void;
}

let dogContainer: Container<Dog> = {
    consume(callback: (data: Dog) => void) {
        callback(new Dog());
    }
};
let catContainer: Container<Animal> = {
    consume(callback: (data: Animal) => void) {
        callback(new Animal("cat"));
    }
};

// 不正な操作 今までは検出できなかった
dogContainer = catContainer;
dogContainer.consume(dog => {
    console.log(dog.berk());
});

// こういうのも今まで検出できていなかった
let p: Promise<Dog> = Promise.resolve(new Animal("cat"));
p.then(dog => console.log(dog.berk()));

// こういうのは今までも検出できていた
(async () => {
    let p: Dog = await Promise.resolve(new Animal("cat"));
})();
```

## enumの値にstringが使えるようになった

わーい。その名の通りです。
enumやconst enumでstringを値にできます。
木構造を作る場合などにnodeの種類を表示する際、const enumを使うのは良い考えでした。
しかし、実際の値が数値になってしまうためデータを人間が目で確認した時に値の性質がわかりにくいという欠点があり、今回はそれが改善されました。

```ts
enum Suit {
    Club = "club",
    Heart = "heart",
    Diamond = "diamond",
    Spade = "spade",
}
type CardNumber = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13;

function makeCard(suit: Suit, num: CardNumber) {
    return `${suit}${num}`;
}

// diamond と出力される！
console.log(Suit.Diamond);

makeCard(Suit.Club, 1);
// これは許してもらえない
makeCard("club", 1);
```

コンパイル後のjsは次の通りです。

```js
"use strict";
var Suit;
(function (Suit) {
    Suit["Club"] = "club";
    Suit["Heart"] = "heart";
    Suit["Diamond"] = "diamond";
    Suit["Spade"] = "spade";
})(Suit || (Suit = {}));
function makeCard(suit, num) {
    return "" + suit + num;
}
// diamond と出力される！
console.log(Suit.Diamond);
makeCard(Suit.Club, 1);
// これは許してもらえない
// makeCard("club", 1);
```

コンパイル結果を見てわかるとおり、次のコードのようなnumberのenumでできた要素の名前を取るテクは使えないので注意しましょう。

```ts
enum Suit {
    Club = 1,
    Heart,
    Diamond,
    Spade,
}

// Club が表示される
console.log(Suit[1]);
```

## プロパティが全てoptionalな型について特別なサポートを与えるようにした

1. 1つ以上プロパティを持っていて
2. 全てのプロパティがoptional(`?`)で
3. インデックスシグニチャを持たない

ものをWeak Typeとして、より厳密な型チェックを行うようになりました。
Weak Typeに値を割り当てる場合、いずれか1つのプロパティが存在していないとコンパイルエラーとなるようになりました。
これにより、全く関係のないオブジェクトを間違って渡していた時にコンパイルエラーでミスを検出できなかったのが改善されます。

```
interface WeakTypeA {
    foo?: string;
}

function reqA(v: WeakTypeA) {
    console.log(v.foo || "foo");
}

reqA({
});
let a = {
    foo: "foo",
};
// 要素がマッチしているのでOK
reqA(a);

let b = {
    bar: "bar",
};
// 要素が1個もマッチしない！
// index.ts(22,6): error TS2559: Type '{ bar: string; }' has no properties in common with type 'WeakTypeA'.
reqA(b);

// 明示的にキャストすればOK
reqA(b as WeakTypeA);

interface WeakTypeB {
    bar?: string;
    [propName: string]: string | undefined;
}
function reqB(v: WeakTypeB) {
    console.log(v.bar || "bar");
}
// インデックスシグニチャを持つのでマッチしていなくても許される
reqB(a);
```
[1.6で入った厳密な即値のチェック](http://qiita.com/vvakame/items/072fa78f9fe496edd1f0#%E3%82%88%E3%82%8A%E5%8E%B3%E5%AF%86%E3%81%AA%E5%8D%B3%E5%80%A4%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%83%AA%E3%83%86%E3%83%A9%E3%83%AB%E3%81%AE%E3%83%81%E3%82%A7%E3%83%83%E3%82%AF)をさらに強化した感じですね。

## dynamic importがstage 3になったので入った

そのまんまですね。
[結構前にstage3になってた](https://github.com/tc39/proposal-dynamic-import)ので入ったようです。

```index.ts
async function hello() {
    const sub = await import("./sub");
    sub.hello();
}

hello();
```

```sub.ts
export function hello() {
    console.log("Hello!");
}
```

というようなコードが書けます。
importに渡す文字列が即値の場合、importしたオブジェクト(この場合 `sub`)は適切に型付けが行われています。
動的な文字列を渡すこともできますが、`any` になってしまうため利用はなるべく避けたいものです。

## リファクタリングの機能をLanguage Service APIに追加

リファクタリングを行うための仕組みがLanguage Service APIに準備されていたところに、実際にes5のfunctionベースのOOPのコードをes2015のクラスに変換する機能が入ったようです。
VSCodeとかが対応してきたら試してみるとしましょう。

## tsconfig.jsonについてのエラー表示がより良くなった

何かがよくなったらしい(小並感
