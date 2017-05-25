---
title: TypeScript 2.2.1 変更点
date: 2017-02-23 18:39:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/eb6c054360868b88f9b1)ものと同じ内容です。

---

機能的にはもうかなり充実してきたので「もう次の出たの」みたいな感想になってきました。
こんばんは[@vvakame](https://twitter.com/vvakame)です。

[TypeScript 2.2](https://blogs.msdn.microsoft.com/typescript/2017/02/22/announcing-typescript-2-2/)がアナウンスされましたね。
[What's new in TypeScriptも更新](https://github.com/Microsoft/TypeScript/wiki/What's-new-in-TypeScript#typescript-22)されているようです。

## 変更点まとめ
* クラスのMixinパターンのサポート[Mixin classes](https://github.com/Microsoft/TypeScript/pull/13743)
	* 特定のコンストラクタパターンを持つクラスについて[Mixinパターン](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes#Mix-ins)のbaseに指定できるようになった
	* TypeScript的に自然な型の導出が行われるのが良いという話
* インタフェースが object-like typeならなんでも拡張できるようになった [Allow deriving from object and intersection types](https://github.com/Microsoft/TypeScript/pull/13604)
	* type aliasと組み合わせできなかったのができるようになった
	* intersection typesはOKだけどunion typesはだめ
	* intersection typesでの `this` 型はそれ自身を指すにようなった
* `new.target`がサポートされた [Support for new.target](https://github.com/Microsoft/TypeScript/issues/2551)
	* ES2015で追加されたやつ
* nullableな値に対する演算子の適用でよいよいチェックを提供[Improved checking of nullable operands in expressions](https://github.com/Microsoft/TypeScript/pull/13483)
	* `undefined + 1` とかになりうるコードを書くと教えてもらえる
* クラスの継承にObject.setPrototypeOfを使うようになった [Update __extends to use Object.setPrototypeOf](https://github.com/Microsoft/TypeScript/pull/12488)
	* Babel製クラスのフィールドが意図通り継承できない問題を解決
* stringインデックスシグニチャに対する `.` アクセスの挙動を改善[Allow property (dotted) access for types with string index signatures](https://github.com/Microsoft/TypeScript/issues/12596)
	* 今までは `hoge["fuga"]` と `hoge.fuga` でコンパイル時のチェックされかたに差があった
* JSXで子要素のspread記法がサポートされた[Support for JSX spread children](https://github.com/Microsoft/TypeScript/issues/9495)
	* `<TodoList {...x} />` こんなんとからしい
* JSX記法のターゲットにReact Nativeが追加された[New --jsx react-native](https://github.com/Microsoft/TypeScript/issues/11158)
	* preserveとreactの合体みたいな感じっぽい？
* `object`型のサポート [Support for the object type](https://github.com/Microsoft/TypeScript/issues/1809)
	* 新プリミティブ型
	* `Object.create('string')` とかをちゃんとエラーにしたかった
	* 要するにObjectかその他のプリミティブかを区別したかった
* Language Service経由で使えるQuick fixesの種類が増えた。More Quick fixes!
	* 使ってるシンボルがスコープになかったら適切なimport句を補ってくれる [Add missing imports](https://github.com/Microsoft/TypeScript/pull/11768)
	* インタフェースや抽象クラスの足りないメンバを補ってくれる [Implement interface/abstract class members](https://github.com/Microsoft/TypeScript/pull/11547)
	* 使ってないシンボルを削除してくれる [Remove unused declarations](https://github.com/Microsoft/TypeScript/pull/11546)
	* `this.`が足りない時に補ってくれる [Add missing this.](https://github.com/Microsoft/TypeScript/pull/13759)
	* アクセスしてるのに存在してないプロパティを補ってくれる [Add missing property declaration](https://github.com/Microsoft/TypeScript/pull/14097)

## クラスのMixinパターンのサポート

すごい端的に言うと `{ new (...args: any[]): A } & { new (s: string): B }` は `{ new(s: string): A & B }` に簡約してもいいというルールが追加されたという話。

[Playground](https://goo.gl/Xm8J4h)

```ts
type Constructor<T> = new (...args: any[]) => T;

function Tagged<T extends Constructor<object>>(Base: T) {
    return class extends Base {
        tag = "";
        constructor(...args: any[]) {
            super(...args);
        }
    };
}

class Score {
    constructor(public point: number) { }
}

// mixinできる
const TaggedScore = Tagged(Score);

// これはちゃんと怒られる
// error TS2345: Argument of type '"s"' is not assignable to parameter of type 'number'.
// new TaggedScore("s");

const ts = new TaggedScore(1);
ts.tag = "vv";
console.log(ts.tag, ts.point);

// mixinしたクラスを継承もできる
class RankingScore extends TaggedScore {
    constructor(public rank: number, tag: string, point: number) {
        super(point);
        this.tag = tag;
    }
}

const rs = new RankingScore(1, "vv", 100);
console.log(rs.rank, rs.tag, rs.point);
```

Mixin用の関数は先頭大文字にするんですかね…？

## インタフェースが object-like typeならなんでも拡張できるようになった

すごい端的に言うと、インタフェースはインタフェースを拡張できる（前から）。インタフェースと見做される範囲が拡張された。

```ts
type T1 = { a: number };
type T2 = T1 & { b: string };
type T3 = () => void;
type T4 = [string, number];

interface I1 extends T1 { x: string } // オブジェクトリテラルの拡張
interface I2 extends T2 { x: string } // intersection typesの拡張
interface I3 extends T3 { x: string } // 関数の拡張
interface I4 extends T4 { x: string } // タプル型の拡張

let obj1: object = null as any as T1;
let obj2: object = null as any as T2;
let obj3: object = null as any as T3;
let obj4: object = null as any as T4;

type T5 = string;
type T6 = T1 | { b: string };

interface I5 extends T5 { x: string } // primitive型は拡張できない
interface I6 extends T6 { x: string } // union typesは拡張できない

let obj5: object = null as any as T5;
let obj6: object = null as any as T6; // objectと互換性があるかという基準ではないらしい
```

intersection typesを含む型パラメータ付きのtype aliasも継承できるようになった。

```ts
type Named<T> = T & { name: string };

interface N1 extends Named<T1> { x: string } // { a: number, name: string, x: string }
interface N2 extends Named<T2> { x: string } // { a: number, b: string, name: string, x: string }

// 標準で入ってるPartialを使った型も継承できるようになった
interface P1 extends Partial<T1> { x: string } // { a?: number | undefined, x: string }
```

つよい。

また、 `this` が表す型がintersection typesの場合、定義されている型だけじゃなくて本当にintersection types自身を指すようになった。

```ts
interface Thing1 {
    a: number;
    self(): this;
}

interface Thing2 {
    b: number;
    me(): this;
}

function f1(t: Thing1 & Thing2) {
    // Thing1 & Thing2 が返ってくる
    // 以前は Thing1 だった…(のでコンパイルエラー
    t = t.self();
    // 同上
    t = t.me().self().me();
}
```

先のMixinのルールと組み合わせて以下のようなコードがコンパイルが通るようになった。

```
type Constructor<T> = new (...args: any[]) => T;
class Base extends (1 as any as Constructor<object>) {
}
// 当たり前だけど実行時エラー anyにキャストした報いを受けよ！
// Uncaught TypeError: Object prototype may only be an Object or null: 1
new Base();
```

このコードだけだと間違った例なのでアレなんだけど、3rd partyライブラリを使っている時にこういう操作を稀にしたい時があったのでこれが受け入れられるようになったのは喜ばしい…！

## new.targetがサポートされた

[コレ](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Operators/new.target)です。
されました(終わり

```ts
class A {
    constructor() {
        console.log(new.target.name);
    }
}
// A と出力される
new A();
```

Custom ElementsなどHTMLElementを扱う時、どうしても `new.target` が使えないと困る場合というのが極稀に人生で2回くらいあるそうなのでよかったですね。

## nullableな値に対する演算子の適用でよいよいチェックを提供

`undefined + 1` とかが怒られるようになってよかったねみたいな話。

```ts
// だめ
null + 1;
1 + null;
// OK (anyとstringのみ)
null + (1 as any);
null + "";
"" + null;

// --strictNullChecks有りだとこの後全部だめ

let n: number | null = null as any;

n - 1;
1 - n;
n * 1;
n ** 1;
n / 1;
n % 1;
n << 1;
n >> 1;
n >>> 1;
n & 1;
n | 1;
n ^ 1;

n < 1;
n > 1;
n <= 1;
n >= 1;

let obj: {} | null = null as any;
"v" in obj;

let D: typeof Date | undefined = null as any;
let v = obj instanceof D;

+n;
-n;
~n;
++n;
--n;
```

## クラスの継承にObject.setPrototypeOfを使うようになった

すごい端的に言うと、Babel製クラスのスタティックメソッドがTypeScriptから継承できなくて困ったので直しましたという話。

ES2015的にクラスのメンバ（メソッドとか）は `enumerable: false` なんだけどTypeScriptは `enumerable: true` なコードを生成してしまう。
TypeScriptで書いたクラスをTypeScriptで継承するクラスを書くのは特に齟齬が発生しない。
しかし、Babelは仕様どおり `enumerable: false` なコードを吐くので、Babel製クラスのスタティックメンバをTypeScriptで継承しようとすると `enumerable: true` である前提のコードが吐かれて困ってしまっていた。

これは[SkateJS](http://skatejs.github.io/)で[問題になった](https://github.com/skatejs/skatejs/issues/936)りして困った。
困ったので僕が直しました。褒めてほしい。
この辺の苦労話は[C91で書いた](https://booth.pm/ja/items/392258)ので買って欲しい(宣伝

## stringインデックスシグニチャに対する `.` アクセスの挙動を改善

謎の制約が解除されてよかったねって感じ。

```ts
interface A {
    exists: boolean;
    [other: string]: number | boolean;
}

let obj: A = { exists: true };

// これはOK
obj["exists"] = false;
obj["unknown"] = 1;

obj.exists = false;
// これは何故かTypeScript 2.1.xまでダメだった
// error TS2339: Property 'unknown' does not exist on type 'A'.
obj.unknown = 1;
```

JavaScript的に自然に書けなくて微妙だったのが改善された。
てっきりindex signatureなんか使うなよ気持ち悪い構文強制させて反省を促すぞ！みたいな話だと思ってた。(半分くらい本気

## JSXで子要素のspread記法がサポートされた

わかめさんもSkateJSをちょいちょい書くようになったので多少はJSX(TSX)に興味が出てきたんですがふーんって感じです。
ArrayなものはちゃんとArrayに見えるように記述できると構文解析的にチェックが正しく行いやすくなって嬉しいみたいな話かしら。
自分で[Issue](https://github.com/Microsoft/TypeScript/issues/9495)読んで下さい。

## JSX記法のターゲットにReact Nativeが追加された

なんか特別な何かなのかと思ったけど[Issue](https://github.com/Microsoft/TypeScript/issues/11158)見ると拡張子の出力の仕方がReact Nativeと親和性よくなるみたいな話で謎の魔術が追加導入されたということではなさそうだった。
`--jsx react-native` オプション。

## object型のサポート

`string` `boolean` `number` の他に `object` を増やして解決できる問題を増やそう！という話。

例えば `Object.create("str")` とかすると `Uncaught TypeError: Object prototype may only be an Object or null: str` とか言って怒られる。
これは既存のTypeScriptの型チェックだと検出できなかった。
ここに、新たに `object` primitiveを加える事により、`object` じゃないもの という概念が発生してこれを上手く弾く事ができるようになるという話。

```ts
Object.create("test");
Object.setPrototypeOf({}, "test");
```

など(少ない

keyofとかも多分そうなんですが、言語に多少の複雑さを持ち込んででも現実的JavaScriptの問題を手軽かつ静的に解決する事にマジで心血を注いでいる形なので偉いと思います(こなみ

## Language Service経由で使えるQuick fixesの種類が増えた

Language Service組込です。

* 使ってるシンボルがスコープになかったら適切なimport句を補ってくれる
* インタフェースや抽象クラスの足りないメンバを補ってくれる
* 使ってないシンボルを削除してくれる
* this.が足りない時に補ってくれる
* アクセスしてるのに存在してないプロパティを補ってくれる

http://code.visualstudio.com/
VisualStudioCodeのInsiders版を使うと試す事ができます。
Macだと `⌘+.` でQuick Fixが使えました。
[公式の紹介](https://blogs.msdn.microsoft.com/typescript/2017/02/22/announcing-typescript-2-2/)の動画もわかりやすいですね。

らこらこにこんなんできるようになったよ！！って見せたら「やぁっとWebStormに追いついてきましたか…」 って言われた。
