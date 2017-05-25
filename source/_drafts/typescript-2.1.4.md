---
title: TypeScript 2.1.4 変更点
date: 2016-12-09 12:00:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/fc7e37d0296c63f41f4f)ものと同じ内容です。

---

まさかこんなことになるなんて。

こんばんは[@vvakame](https://twitter.com/vvakame)です。

[TypeScript 2.1](https://blogs.msdn.microsoft.com/typescript/2016/12/07/announcing-typescript-2-1/)がアナウンスされましたね。
[What's new in TypeScriptも更新](https://github.com/Microsoft/TypeScript/wiki/What's-new-in-TypeScript#typescript-21)されているようです。

RC版である2.1.1から1ヶ月ほどで正式版が出てきました。
なかなか重たい変更がこの期に及んで！追加されているため解説していきます。
なお、[2.1.1変更点](http://qiita.com/vvakame/items/305749d3d6dc6bf877c6)で解説した内容は扱いません。

既に [TypeScript 2.1 で導入される `keyof` を使って `EventEmitter` を定義してみる](http://qiita.com/kimamula/items/ee468b1ed5b3f45dee0f) や [TypeScript 2.1のkeyofとかMapped typesがアツい](http://qiita.com/Quramy/items/e27a7756170d06bef22a) などの記事が書かれているので、本記事で物足りなかった人は色々と巡回してみるとよいでしょう。

## 変更点まとめ

* keyof と 型の切り出し [Static types for dynamically named properties (keyof T and T[K])](https://github.com/Microsoft/TypeScript/pull/11929)
  * typeof より直感的な型の計算？ができる
* ある型のフィールドの修飾子の変換(Map処理)が可能に [apped types (e.g. { [P in K]: T[P] })](https://github.com/Microsoft/TypeScript/pull/12114)
  * 全てのフィールドがoptionalな型とかが表現可能になった
* [Object Rest/Spread Properties for ECMAScript](https://github.com/sebmarkbage/ecmascript-rest-spread)がstage 3になったので入ったっぽい [ESNext object property spread and rest](https://github.com/Microsoft/TypeScript/issues/2103)
  * `Object.assign` 不要になる説
* superを呼び出しした時コンストラクタでreturnした値がthisとなるように変更 [Use returned values from super calls as 'this'](https://github.com/Microsoft/TypeScript/pull/10762)
  * ES2015からあった仕様らしい 知らんかった…
* `React.createElement` 以外のJSXファクトリが利用可能に [New --jsxFactory](https://github.com/Microsoft/TypeScript/pull/12135)
  * SkateJSユーザ大喜び
* `--target ESNext` がさらに追加された [Support for --target ES2016, --target ES2017 and --target ESNext](https://github.com/Microsoft/TypeScript/pull/11407)
  * stage 3な実装とかがdownpileされないためのtargetらしい
* 型付けなしの気軽なimport句 [Untyped (implicit-any) imports](https://github.com/Microsoft/TypeScript/pull/11889)
  * 書き捨て用スクリプトが楽にかけるように とかそういう

## keyof と 型の切り出し

`keyof` 演算子が導入されました。

```keyof-a.ts
interface Person {
    name: string;
    age: number;
    location: string;
}

let propName: keyof Person;
```

![keyofの動作の様子](https://qiita-image-store.s3.amazonaws.com/0/13283/a3e9f3a0-fc2e-b819-9202-dc08f1197424.png "keyof-a_ts_-_tsc-2_1_4.png")

こんな感じの動作です。

さらに、型の切り出しが可能になりました。
(Lookup Types を 型の切り出し と訳すのが妥当かどうか微妙なので広く知られた訳が既に存在していたらコメントかなにかで教えてください…)

```keyof-b.ts
interface Person {
    name: string;
    age: number;
    location: string;
}

let a: Person["age"];

// 以前からclassだったら頑張れば似たようなことができた
class Animal {
    kind: string;
    name: string;
}

let b: typeof Animal.prototype.kind;
```

![型の切り出しの様子](https://qiita-image-store.s3.amazonaws.com/0/13283/f05e07d4-5041-591b-4748-1f4cb0a763cd.png "keyof-b_ts_-_tsc-2_1_4.png")

便利といえば便利ですね。
`"age"`部分は入力補完も効きますし、typoすればコンパイルエラーにもなります。
リファクタリングかけた時に一緒に変更されたりはしないようなので多用すると修正がめんどくなる可能性はあります。

さらに、プロパティ名部分にunion typesが使えたり

```keyof-c.ts
interface Person {
    name: string;
    age: number;
    location: string;
}

// string | number 型
let nameOrAge: Person["name" | "age"];
```

Genericsと組み合わせた演算処理っぽいのもできるそうです。
ここまでやるかこの変態！(JavaScriptの実用上普通にこういう処理あるので必要といえば必要

```keyof-d.ts
function get<T, K extends keyof T>(obj: T, propertyName: K): T[K] {
    return obj[propertyName];
}

let x = { foo: 10, bar: "hello!" };

let foo = get(x, "foo"); // has type 'number'
let bar = get(x, "bar"); // has type 'string'

let oops = get(x, "wargarbl"); // error!
```

これを突き詰めていくと `Object.defineProperty` 的なものでも型チェックできそうです。

```keyof-e.ts
interface PropertyDescriptor<T> {
    configurable?: boolean;
    enumerable?: boolean;
    value?: T;
    writable?: boolean;
    get?(): T;
    set?(v: T): void;
}
function defineProperty<T, K extends keyof T>(o: T, p: K, attributes: PropertyDescriptor<T[K]>): any {
    return Object.defineProperty(o, p, attributes);
}

interface Foo {
    a?: string;
}

let foo: Foo = {};

// 正しい組み合わせ a に string
defineProperty(foo, "a", {
    enumerable: false,
    value: "a",
});
// ダメ a に number
defineProperty(foo, "a", {
    enumerable: false,
    value: 1,
});
// ダメ b は存在しない
defineProperty(foo, "b", {
    enumerable: false,
    value: "a",
});
```

すごい。
この機能はハード型定義クリエイター以外の人も普通にコードを書いていて使う必要に迫られる可能性があるのがヤバいです。
万人が使いこなせる気配が全くしないので、ある程度の `keyof` を使った処理のsnippetとかをみんなで育てたほうがよいのでは…。

## ある型のフィールドの修飾子の変換(Map処理)が可能に

2.1.4はヤバい機能盛りだくさんなの？？
型のMap処理ができるようになりました。
ちょっと理解が追いついてるのか完全に怪しい…。

基本操作は次の4種類だそうです。

```
{ [ P in K ] : T }
{ [ P in K ] ? : T }
{ readonly [ P in K ] : T }
{ readonly [ P in K ] ? : T }
```

英語話者だとｽｯと理解できるのかもしれないけど難しいですね。
`K` の中の `P` の値にあたる `T` と読めばいいのでしょうか。

TypeScriptの標準型定義の中にいくつかのパーツが同梱されているのでまずはその定義を見てみましょう。

```
// 各プロパティをoptional ? にする
type Partial<T> = {
    [P in keyof T]?: T[P];
};

// 各プロパティを読取専用にする (immutable化)
type Readonly<T> = {
    readonly [P in keyof T]: T[P];
};

// 一部のプロパティのみ集めた部分集合
type Pick<T, K extends keyof T> = {
    [P in K]: T[P];
}

// Genericsと組み合わせて写像を作る用ぽい
type Record<K extends string, T> = {
    [P in K]: T;
}
```

これをざっくりこう使うようです。

```mapped-types-a.ts
interface Person {
    name: string;
    age: number;
    location?: string;
}

let p1: Person = {
    name: "vvakame",
    age: 32,
    location: "Tokyo",
};

let p2: Partial<Person> = {
    name: "vvakame",
    // age, location が欠けていてもエラーにならない
};

let p3: Readonly<Person> = {
    name: "vvakame",
    age: 32,
};
p3.name = "TypeScript"; // readonly なのでエラーになる

let p4: Pick<Person, "name" | "location"> = {
    name: "vvakame",
    // age は K に含まれていないので不要
    location: "Tokyo", // 必須になる
};

let p5: Record<keyof Person, boolean> = {
    // 全てのプロパティの型はbooleanを要求される
    name: true,
    age: true,
    location: false, // 必須になる
};
```

難易度が高い。
上手く使えば次のような変換処理も動くそうな。

```
interface Foo {
    a: string;
    b: string;
}

function mapObject<K extends string, T, U>(obj: Record<K, T>, f: (x: T) => U): Record<K, U> {
    let newObj: any = Object.assign({}, obj);
    Object.keys(obj).forEach(key => newObj[key] = f(newObj[key]));
    return newObj;
}

// result は Record<"name", number>
let result = mapObject({name: "vvakame"}, v => v.length);
// { name: 7 } と表示される
console.log(result);
```

入力補完もちゃんと効くし型も正しく認識されている

![Mapped Typesの様子](https://qiita-image-store.s3.amazonaws.com/0/13283/2dc93a90-69d8-3e2f-f8b5-7e52af327f56.png "mapped-types-b_ts_-_tsc-2_1_4_and_es2015_ts_-_TypeScript.png")

ここでReactのpropsみたいな複雑な型も上手く扱えるのはか興味があるところです。

## Object Rest/Spread Properties for ECMAScript が入った

ArrayとかにあったやつがObjectにも来た的なやつです

```
let original = {
    1: 1, 2: 2, 3: 3, 4: 4, 5: 5,
    6: 6, 7: 7, 8: 8, 9: 9, 10: 10,
    11: 11, 12: 12, 13: 13, 14: 14, 15: 15,
};

// コピーとかできます
let copy = { ...original };

let fizz = { 3: "foo", 6: "foo", 9: "foo", 12: "foo", 15: "foo" };
let buzz = { 5: "buzz", 10: "buzz", 15: "buzz" };
let fizzbuzz = { 15: "fizzbuzz" };

// mergeとかできるで
let merged = { ...copy, ...fizz, ...buzz, ...fizzbuzz };
// { '1': 1,
//   '2': 2,
//   '3': 'foo',
//   '4': 4,
//   '5': 'buzz',
//   '6': 'foo',
//   '7': 7,
//   '8': 8,
//   '9': 'foo',
//   '10': 'buzz',
//   '11': 11,
//   '12': 'foo',
//   '13': 13,
//   '14': 14,
//   '15': 'fizzbuzz' }
console.log(merged);

let animals = {
    cat: "😺",
    dog: "🐶",
    rat: "🐭",
};
let { cat, ...others } = animals;
// 😺
console.log(cat);
// { dog: '🐶', rat: '🐭' }
console.log(others);
```

## superを呼び出しした時コンストラクタでreturnした値がthisとなるように変更

そういう仕様がECMAScriptにあったけど完全に知らなかった…
http://www.ecma-international.org/ecma-262/6.0/index.html#sec-super-keyword

コンストラクタ内部で任意の値をreturnするとその値が生成された事になります。
Chromeとかで `var obj = new class { constructor() { return new Date(); } }();` とかやるとobjは普通にDateになります。

この仕様は特にCustom Elements周りで必要らしいです。

```super-returns-this.ts
class Base {
}

class Inherit extends Base {
    x: string;
    constructor() {
        super();
        this.x = "Hi!";
    }
}
```

こういうコード書くと

```super-returns-this.js
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
};
var Base = (function () {
    function Base() {
    }
    return Base;
}());
var Inherit = (function (_super) {
    __extends(Inherit, _super);
    function Inherit() {
        var _this = _super.call(this) || this;
        _this.x = "Hi!";
        return _this;
    }
    return Inherit;
}(Base));
```

こういうコードが出てくる。

returnした値の型がインスタンスの値になるわけではないようなので、returnする値がクラスの制約を満たすように書いてやらねばならない点に注意が必要です。
instanceofの挙動も死にそうだし変に多用してはダメっぽそう。

## `React.createElement` 以外のJSXファクトリが利用可能に

TSX(JSX)書いた時に要素の組み立てに使うファクトリに `React.createElement` 以外を使うことができるようになりました。
例えば、[SkateJS](http://skate.js.org/)もJSXを採用しているので、このオプションを使う場面があります。
興味がある人は僕が作った[skatejs-todo](https://github.com/vvakame/skatejs-todo/)を参照してみてください。
また、TechBoosterがC91で出すWeb本でもこのあたりの話に触れているので興味がある人はどうぞ！(宣伝

## `--target ESNext` がさらに追加された

[このへん](https://github.com/Microsoft/TypeScript/commit/7b9a42f9958b072f057d42d506b7e082ebf19974) ぽい

Object Rest/Spread Properties はまだstage 3でES2017にも入ってないので、これらがdownpileされないためのtargetを追加したようだ。

## 型付けなしの気軽なimport句

今まで　：型定義ファイルが存在しないライブラリは利用できなかった
これから：とりあえず常にimportできて動きます

今まで、型定義ファイルのないライブラリはTypeScriptは信用せず、使い始めるのがめんどくさかったです。
そのため、"書き捨てのコードを書きたい"とか"とりあえず使い始めたい"という時にTypeScriptを使うのは億劫でした。
今回の更新で、"とりあえずnpm installされてるならanyとしてimportできるようにしよう"という方針に転換したようです。
これはなかなかいい話ですね。

なお、今まで通り厳密な運用をしたい！という人は `--noImplicitAny` を(既に使っているように)使えば従来通りの挙動になります。
ごあんしんです。

## 余談

[前回記事でtslib更新されてなくてアカンわ](http://qiita.com/vvakame/items/305749d3d6dc6bf877c6#%E3%83%98%E3%83%AB%E3%83%91%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%82%92%E5%A4%96%E9%83%A8%E3%81%AB%E6%8C%81%E3%81%A6%E3%82%8B%E3%82%88%E3%81%86%E3%81%AB)と書いたのですが、ユーザが触れる機会も増えたので高い頻度で更新されるようになりました。
最新のtslibでは __generator など必要なものが一式含まれているため、`--importHelpers` を使ってよい時期が来たと言えるでしょう。
