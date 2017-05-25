---
title: TypeScript 2.0 Beta 変更点
date: 2016-07-13 23:45:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/ae239f3d6f6f08f7c719)ものと同じ内容です。

---

追記4：Quramyパイセン記事へのリンク追加
追記3：`--skipLibCheck`の解説が間違ってたのを修正
追記2：モジュール名のワイルドカードについて が漏れてたので追加
追記1：DefinitelyTypedについて を少し更新

TypeScript 2.0 Betaが出ました！
今回のアップデートはかなり多くの更新を含む、大規模なアップデートであるといえます。
なんせ、2.0ですからね。

2.0 Betaを試したい時は `npm install -g typescript@beta` しましょう。

[公式ブログ](https://blogs.msdn.microsoft.com/typescript/2016/07/11/announcing-typescript-2-0-beta/)と[What's new](https://github.com/Microsoft/TypeScript/wiki/What%27s-new-in-TypeScript#typescript-20)と
[Roadmap](https://github.com/Microsoft/TypeScript/wiki/Roadmap#20)からまとめていきます。

さすが、major versionが上がっただけあって心の強い変更が多いです。
最高に堅牢な設定を維持し、ついていくのは大変ですが頑張りたいところです。
正味な話、利便性が高まる代わりにコンパイルエラーの発生を事前に脳内でエミュレートするのが難しくなってきています。
TypeScriptの複雑な機能はJavaScriptとの互換性を取るため泣きながら使うもので、自分のコードの中ではシンプルな型を保つ事が継続しやすいプロジェクトになると考え頑張りましょう。

なお、async/await のES3/ES5へのdownpileは2.1へ持ち越されました。
残念ですね…。

## 変更点まとめ

* nullを許容しない型（[Non-nullable types](https://github.com/Microsoft/TypeScript/pull/7140)）
  * `--strictNullChecks` オプションが追加され、デフォルトではnullが非許容にできるようになった。
* 条件分岐による型の絞込み（[Control flow based type analysis](https://github.com/Microsoft/TypeScript/pull/8010)）
  * if文などによる条件分岐によって型の絞込みが行われるようになった。
* union types限定の条件分岐による型の絞込（[Discriminated union types](https://github.com/Microsoft/TypeScript/pull/9163)）
  * union typesについて、プロパティによる型の絞込やswitch文の利用がサポートされた。
* 関数のthisの型を指定可能に（[Specifying this types for functions](https://github.com/Microsoft/TypeScript/issues/3694)）
  * 第一引数の仮引数名を `this` にした場合、偽パラメータとして型付けできる。
  * 文法クッソ微妙じゃない…？？？
* プロパティアクセスについてtype guardsを行う（[Type guards on property access](https://github.com/Microsoft/TypeScript/issues/186)）
  * プロパティアクセスでの型の絞込ができる。
* readonly修飾子の追加（[Readonly properties and index signatures](https://github.com/Microsoft/TypeScript/pull/6532)）
  * readonlyである事を明示できる。constと違いmutableなので変更の可能性が示唆される。
* モジュールの解決のためのパスのマッピング（[Use path mappings in module resolution](https://github.com/Microsoft/TypeScript/issues/5039)）
  * tsconfig.json にrootDirsやpathsなどの項目が増えた。
* 雑な型定義の作成法の追加（[Shorthand ambient module declarations and wildcard matching in module names](https://github.com/Microsoft/TypeScript/issues/6615)）
  * とりあえずコンパイル通す用。初心者に優しい。
* 暗黙的なインデックスシグニチャ（[Implicit index signatures](https://github.com/Microsoft/TypeScript/pull/7029)）
  * 全てのプロパティが要求されるインデックスシグニチャにマッチする場合コンパイルが通るようになった。
* コンストラクタにprivateとprotectedが使えるように（[Support private and protected constructors](https://github.com/Microsoft/TypeScript/pull/6885)）
  * シングルトンパターンの実装が容易に的な。
* abstract修飾子がプロパティに対しても利用可能に（[Support abstract properties](https://github.com/Microsoft/TypeScript/issues/4669)）
  * 子クラスでアクセス可能になることが強制できる。地味に欲しかったやつ。
* クラスのプロパティが省略可能かどうか指定の追加（[Optional properties in classes](https://github.com/Microsoft/TypeScript/pull/8625)）
  * 今までは `--strictNullChecks` がなかったので指定できなくても困らなかった。
* "ありえない"型の追加（[The never type](https://github.com/Microsoft/TypeScript/pull/8652)）
  * ありえないなんてことはありえないことが型として追加されてしまった。
* 型定義ファイルの整合性チェックのスキップオプション `--skipLibCheck`（[--skipLibCheck compiler option](https://github.com/Microsoft/TypeScript/pull/8735)）
  * grunt-typescript に前からあったやつ。
* 型定義ファイルの生成先の変更オプション `--declarationDir`（[Support for declaration output folder using --declarationDir](https://github.com/Microsoft/TypeScript/issues/6723)）
  * `.ts`から`.d.ts`を出すやつの出力先が変更可能になった。
* コンパイル対象のワイルドカード指定が可能に（[Glob support in tsconfig.json](https://github.com/Microsoft/TypeScript/issues/1927)）
  * `!` は存在しないのでincludeとexcludeを組み合わせて頑張る
* lib.d.tsの細分化と`--lib`プロパティによる個別指定（[Improve lib.d.ts modularity and new --lib support](https://github.com/Microsoft/TypeScript/issues/494) [他](https://github.com/Microsoft/TypeScript/issues/6974)）
  * やっとコンパイル先形式と使えるfeatureの指定が分割可能にされた。
* UMD形式の型定義ファイル作成時に便利な記法の追加（[Support for UMD module definitions](https://github.com/Microsoft/TypeScript/issues/7125)）
  * 外部モジュールとしてもグローバルの拡張としても読み込み方法によって分割可能になった。
* 関数の実引数の末尾の余計なカンマの許容（[Trailing Commas in Function Param Lists](https://github.com/Microsoft/TypeScript/issues/7279)）
  * 複数行に分割して実引数書く時に便利なやつ。
* @typedef タグの利用がJSファイルについて可能に（[Support for jsdoc @typedef for JS files](https://github.com/Microsoft/TypeScript/pull/8103)）
  * Salsa的な話題のやつ。
* 入力補完候補にstring literalsが入ってくるようになった（[Completion lists for string literals](https://github.com/Microsoft/TypeScript/issues/606)）
  * 地味にすごく良い奴。イベント名とかが入力補完できる感じ。
* 拡張子ありのモジュール名について`.js`を考慮するようにした（[Module name in imports allow .js extension](https://github.com/Microsoft/TypeScript/issues/4595)）
  * `import a = require("./foo.ts")` とか書いても意図通り動くようになった。
* ES5にdownpileしつつモジュール周りはES6にできるように（[Support 'target:es5' with 'module:es6'](https://github.com/Microsoft/TypeScript/issues/6319)）
  * rollup.jsに優しそう
* `--noUnusedLocals` と `--noUnusedParameters` が追加（[Flag unused declarations with --noUnusedLocals and --noUnusedParameters](https://github.com/Microsoft/TypeScript/pull/9200)）
  * golangかな？？

## DefinitelyTypedについて

[lacoが目ざとく見つけた](http://qiita.com/laco0416/items/ed1aadf335f12cd3618d)とおり、現在[@types](https://www.npmjs.com/~types)への移行が進んでいます。
これにより、tsdやtypingsを使わずにnpmだけで完結するエコシステムになるはずです。

DefinitelyTypedのメンバーに、TypeScriptチームのメンバーがどんどん入ってきてくれて、彼らの仕事時間という強いリソースをもってガンガン処理されています。
[types-2.0](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/types-2.0)ブランチにてTypeScript 2.0対応な型定義ファイルの管理が進められています。
もし、@typesに送りたい型定義がある場合、そちらのブランチにpull requestを送ってもらえればよいです。

現在彼らの手によって様々な自動化が行われていて2.0リリースまでには何らかのアナウンスがあると思います。
細かい事が知りたい人は何かの機会に直接僕に聞いてください。

参考

* [types-publisher](https://github.com/Microsoft/types-publisher)
* [TypeSearch](https://microsoft.github.io/TypeSearch/) [repo](https://github.com/Microsoft/TypeSearch)

## 各機能詳細

### nullを許容しない型（[Non-nullable types](https://github.com/Microsoft/TypeScript/pull/7140)）

`--strictNullChecks` オプションが追加され、デフォルトではnullが非許容にできるようになりました。
これに伴い、 `null` と `undefined` も型として利用可能になっています。
自然とnullやundefinedが除外されるようなコードを書くといい感じに変数の型候補からnullやundefinedが除外されていきます。
`!` を使った、人力でnull無視などができるが危険なのであまり行わないほうがよいです。

```ts:basic.ts
/* シンプルなパターン */
// OK
let strA: string = "str";
let strB: string | null = "str";

// NG error TS2322: Type 'null' is not assignable to type 'string'.
let strC: string = null;

/* --strictNullChecks無しとの比較 */
// 無しの場合に等しい表現は…
let objA: Object;
// コレです
let objB: Object | null | undefined;

/* 後から初期化パターン */
let arrayA: string[];
// NG error TS2454: Variable 'array' is used before being assigned.
arrayA.forEach(v => console.log(v));

// 初期化したら大丈夫！
arrayA = [];
arrayA.forEach(v => console.log(v));

/* Kotlinでいうエルヴィス的な奴 */
let numA: number | null = null;

// 人間がヒント与えてコンパイル通す奴（なるべく使わない）
numA!.toString();

// ちゃんとnullチェックして通す奴
if (numA != null) {
    // ここでは絞込により number と確定している
    numA.toString();
}

/* なお、undefinedもある模様 */
let boolA: boolean | undefined;
// NG error TS2532: Object is possibly 'undefined'.
boolA.toString();
```

```ts:optional.ts
function hiA(word?: string) {
    // 省略可能引数は undefined の可能性がある！
    // error TS2532: Object is possibly 'undefined'.
    console.log(`Hi! ${word.toUpperCase()}`);
}

function hiB(word?: string) {
    if (!word) {
        // undefined の場合の対処を入れた場合…
        word = "JohnDoe";
    }
    // コンパイルが通る。賢い。
    console.log(`Hi! ${word.toUpperCase()}`);
}

function hiC(word = "JohnDoe") {
    // まぁ、これが一番ラクですね。
    console.log(`Hi! ${word.toUpperCase()}`);
}

// なお、これは string | undefined に当てはまらないのでコンパイルエラーになる！最高！
// error TS2345: Argument of type 'null' is not assignable to parameter of type 'string | undefined'.
hiC(null);
// これはOK
hiC(undefined);

function hiD(word: string | undefined) {
    word = word || "JohnDoe";
    console.log(`Hi! ${word.toUpperCase()}`);
}

// string | undefined だからといってoptionalになるわけではない
// error TS2346: Supplied parameters do not match any signature of call target.
hiD();
```

良いですね。
問題は、未だ多くの型定義ファイルが `--strictNullChecks` 未考慮であることです。
未考慮であると、本来はundefinedになる可能性があるのにnullではない型、とされてしまう場合があるでしょう。
だんだん対応が広がっていくとは思いますが、まずは自分のコード内の健全さを育てる事に注力したほうがいいかもしません。

### 条件分岐による型の絞込み（[Control flow based type analysis](https://github.com/Microsoft/TypeScript/pull/8010)）

if文などによる条件分岐によって型の絞込みが行われるようになりました。

公式のWhat's newの例が大変わかりやすいためそのまま引用してきます。

```ts:basic.ts
function foo(x: string | number | boolean) {
    if (typeof x === "string") {
        x; // ここではstringに絞りこまれてる
        x = 1;
        x; // numberに変わった！
    }
    x; // number | boolean に絞りこまれている！
}

function bar(x: string | number) {
    if (typeof x === "number") {
        return;
    }
    x; // 残るは string だけ
}
```

良いですね。大変賢いです。
特に、新しい値を代入した場合に代入した値の型で絞込が行われるのが大変よいです。
次のようなコードを書けるのがよいですね。
今までのTypeScriptだと一時変数を1つ増やさねばなりませんでした。

```ts:split.ts
function hiAll(words: string | string[]) {
    if (typeof words === "string") {
        // string の世界線はここで string[] に置き換えられる！
        words = words.split("|");
    }
    // words は string[] であると確定しているッ！
    console.log(`Hi, ${words.join(", ")}`);
}

hiAll("TypeScript");
hiAll("TypeScript|JavaScript");
hiAll(["TypeScript", "JavaScript"]);
```

`--strictNullChecks` でnullやundefinedを自然に制御できるようにしたらコレもできるようになった、という感じに見えます。

### union types限定の条件分岐による型の絞込（[Discriminated union types](https://github.com/Microsoft/TypeScript/pull/9163)）

union typesについて、プロパティによる型の絞込やswitch文の利用がサポートされました。
多くの人はあまり使わない気もしますが、ASTの取扱などで大変便利な機能です。

```ts:basic.ts
interface Node {
    left: Tree;
    right: Tree;
}

interface Add extends Node {
    type: "add";
}

interface Sub extends Node {
    type: "sub";
}

interface Leaf {
    type: "leaf";
    value: number;
}

type Tree = Add | Sub | Leaf;

// (10 - 3) + 5 を表現する
let node: Tree = {
    type: "add",
    left: {
        type: "sub",
        left: {
            type: "leaf",
            value: 10
        },
        right: {
            type: "leaf",
            value: 3
        },
    },
    right: {
        type: "leaf",
        value: 5
    },
};

// 12 と表示される
console.log(calc(node));

function calc(root: Tree): number {
    // プロパティの値で型の絞込ができる！
    switch (root.type) {
        case "leaf":
            // 型は Leaf で決定！
            return root.value;
        case "add":
            // 型は Add で決定！
            return calc(root.left) + calc(root.right);
        case "sub":
            // 型は Sub で決定！
            return calc(root.left) - calc(root.right);
    }
    throw new Error("unknown node");
}

export { }
```

よいですね。

### 関数のthisの型を指定可能に（[Specifying this types for functions](https://github.com/Microsoft/TypeScript/issues/3694)）

第一引数の仮引数名を `this` にした場合、偽パラメータとして型付けできるようになりました。
偽パラメータなので、実際の引数として存在しているわけではありません。
文法クッソ微妙じゃない…？？だいじょうぶ？？？

```ts:basic.ts
function test(this:string) {
  console.log(this.toUpperCase());
}

// TYPESCRIPT と表示される
test.bind("typescript")();

// ちゃんとthisの型が想定と違うよ！と怒ってくれる… すごい！
// error TS2684: The 'this' context of type 'void' is not assignable to method's 'this' of type 'string'.
test();

// 何故かこれはコンパイルが通る this が void かどうかしか見てないのかな？
let obj = new class{
  exec() {
    test.bind(this)();
  }
};
obj.exec();
```

なるほど。
jQueryなどのthisの差し替えを行う古いAPIはこの恩恵にあずかる機会があるかもしれません。

`--noImplicitThis` オプションを使うと、thisの型が明示されていない場合エラーにできるようですが、流石にわかめさんもこのオプションの常用には音を上げる可能性が高い気がします。
そもそも`.bind`とか`.apply`とか使わなければあまり必要にならないし…(震え

### プロパティアクセスについてtype guardsを行う（[Type guards on property access](https://github.com/Microsoft/TypeScript/issues/186)）

プロパティアクセスでの型の絞込ができる。

```ts:basic.ts
interface Foo {
    value: number | string;
}

let foo: Foo = {
    value: "TypeScript",
};

// number | string では toUpperCase があるか確定できない
// error TS2339: Property 'toUpperCase' does not exist on type 'number | string'.
foo.value.toUpperCase();

if (typeof foo.value === "string") {
    // ここでは foo.value は string に絞りこまれている！一時変数いらない！
    foo.value.toUpperCase();
}
```

強い(確信

### readonly修飾子の追加（[Readonly properties and index signatures](https://github.com/Microsoft/TypeScript/pull/6532)）

readonlyである事を明示できる修飾子が導入されました。
constと違いmutableなので別の箇所から変更される可能性があります。

```ts:basic.ts
interface Foo {
    readonly str: string;
}

let objA: Foo = {
    str: "TypeScriot",
};
// 上書きはできない！
// error TS2450: Left-hand side of assignment expression cannot be a constant or a read-only property.
objA.str = "JavaScript";

// 別にconstではないので…
let objB = {
    str: "Mutable",
};
let objA = objB;
// readonly じゃない箇所経由で変えられる可能性がある
objB.str = "Modified!";
// Modified! と表示される
console.log(objA.str);

export { }
```

なお、classのプロパティに対して使った時はコンストラクタでだけ書き換え可能です。
Javaのfinalみたいな感じですね。

```ts:class.ts
class Foo {
    readonly str: string;

    constructor() {
        this.str = "TypeScript";
    }

    modify() {
        // readonly が変更できるのはconstructorだけ！
        // error TS2450: Left-hand side of assignment expression cannot be a constant or a read-only property.
        this.str = "JavaScript";
    }
}
```


### モジュールの解決のためのパスのマッピング（[Use path mappings in module resolution](https://github.com/Microsoft/TypeScript/issues/5039)）

tsconfig.jsonにrootDirsやpathsなどの項目が増えました。
RequireJSやSystemJS向けの機能のようですね。

僕はあまり興味がないので[このあたり](https://github.com/Microsoft/TypeScript/wiki/What%27s-new-in-TypeScript#module-resolution-enhancements-baseurl-path-mapping-rootdirs-and-tracing)を見て頑張ってみてください。

と思ったら @Quramy ﾊﾟｲｾﾝが[記事](http://qiita.com/Quramy/items/44ab1a046d58449cd783)を書いたようなのでそちらを見るとかすると高まると思います。

`--traceResolution`オプションを使うとファイル探索がどのように行われていくのかが確認できます。
これは`@types`など、新機能を使う時に何故かうまく型定義ファイルが見つからない場合などにも活用できそうなので詰まった時は試してみるとよいでしょう。

### 雑な型定義の作成法の追加とワイルドカード（[Shorthand ambient module declarations and wildcard matching in module names](https://github.com/Microsoft/TypeScript/issues/6615)）

とりあえずコンパイル通す用。初心者に優しい。

```ts:lodash.d.ts
declare module "lodash";
```

こんな感じです。
こう書けば、とりあえずanyが盛りだくさんな状況にはなりますが、既存ライブラリが使えるようになります。

さらに、モジュール名にワイルドカードを使う事ができます。
例えば次のような型定義ファイルを用意してみます。

```ts:def.d.ts
// AMPとかSystemJSであるやつらしい
declare module "*!text" {
    const _: string;
    export = _;
}
// とりあえず全部anyで
declare module "json!*";
// 特定のパッケージ配下をとりあえず全部anyで
declare module "sample/*";
```

すると、こういうコードのコンパイルが通るようになります。

```ts:basic.ts
import * as text from "./foo.txt!text";
import * as data from "json!./bar.json";

import {fizzbuzz} from "sample/foo/bar";

// text は string です
text.toUpperCase();
// data は any です
data.piyo;
// fizzbuzz も any です
fizzbuzz();

```

一部ツールとの組み合わせがより便利になりましたね。
わかめ的にはJSコードじゃないものをモジュール用の構文で読み込むのはどーなんだそれは、と思いますが。

これらのやり方を多様して最初に楽をしていると`--noImplicitAny`を有効にするのがドンドンキツくなっていくのであまりおすすめはしません。
まずは、これらの方法を使って使い捨てのプロジェクトでTypeScriptの徳を積んだ後に、一旦全て捨てて本ちゃんのプロジェクトに取り組むのがよいのではないでしょうか。
Topgate社はTypeScriptを使ったプロジェクトの開発コンサルなども受け付けております(ｷﾘ(受注できる人的キャパがあるとは限らないですが

### 暗黙的なインデックスシグニチャ（[Implicit index signatures](https://github.com/Microsoft/TypeScript/pull/7029)）

全てのプロパティが要求されるインデックスシグニチャにマッチする場合コンパイルが通るようになった。
これも公式から例を引用します。

```ts:basic.ts
function httpService(path: string, headers: { [x: string]: string }) { }

const headers = {
    "Content-Type": "application/x-www-form-urlencoded",
};

// 前からOK
httpService("/", { "Content-Type": "application/x-www-form-urlencoded" });

// これがOKになった！
// 前は以下のように怒られてた
// error TS2345: Argument of type '{ "Content-Type": string; }' is not assignable to parameter of type '{ [x: string]: string; }'.
//   Index signature is missing in type '{ "Content-Type": string; }'.
httpService("/", headers);
```

### コンストラクタにprivateとprotectedが使えるように（[Support private and protected constructors](https://github.com/Microsoft/TypeScript/pull/6885)）

シングルトンパターンの実装が容易に的なやつです。

```ts:basic.ts
class Foo {
    static newInstance() {
        return new Foo();
    }

    private constructor() {
        console.log("Foo");
    }
}
// private だからダメ！
// error TS2673: Constructor of class 'Foo' is private and only accessible within the class declaration.
new Foo();
// これはOK
Foo.newInstance();

class Bar {
    protected constructor() {
        console.log("Bar");
    }
}
// protected だからダメ！
// error TS2674: Constructor of class 'Bar' is protected and only accessible within the class declaration.
new Bar();
// 子クラスからは参照可能
new class extends Bar {
    constructor() {
        super();
    }
};
```

やっとprivate修飾子に存在価値が出てきた感じがあります。

### abstract修飾子がプロパティに対しても利用可能に（[Support abstract properties](https://github.com/Microsoft/TypeScript/issues/4669)）

子クラスでアクセス可能になることが強制できるようになりました。
地味に欲しかったやつです。

```ts:basic.ts
abstract class Foo {
    abstract str: string;
}

class FooA extends Foo {
    str: "TypeScript";
}

// str が実装されていないのでダメ！
// error TS2515: Non-abstract class 'FooB' does not implement inherited abstract member 'str' from class 'Foo'.
class FooB extends Foo {
}
```

よいですね。

### クラスのプロパティが省略可能かどうか指定の追加（[Optional properties in classes](https://github.com/Microsoft/TypeScript/pull/8625)）

今までは `--strictNullChecks` がなかったので指定できなくても困らなかったですがこれからはそうもいきません。
クラスのプロパティがちゃんとした値か、undefinedなのかというのは重要な事です。
そこで、今までのTypeScriptのやり方に反しないやり方が追加されました。

```ts:basic.ts
class Foo {
    str: string;
    num?: number; // あまりに自然すぎて今までもこの書き方できた気がするレベル

    constructor() {
        // 残念ながら初期化の強制はまだ無さそう
        this.str.toUpperCase();
        // undefinedのチェックが必要
        if (this.num != null) {
            this.num.toFixed();
        }
    }
}

new Foo();
```

### "ありえない"型の追加（[The never type](https://github.com/Microsoft/TypeScript/pull/8652)）

ありえないなんてことはありえないことが型として追加されてしまった。
到達不可能なコードは`never`型となる。

```ts:basic.ts
let str = "TypeScript";
if (typeof str === "number") {
    // string型な変数の値がnumberだったら… ありえん！never！
    // error TS2339: Property 'toUpperCase' does not exist on type 'never'.
    str.toUpperCase();
}

function test(): never {
    // returnないし関数のおしりに到達できないので返り値の型はneverになる
    throw new Error();
}
```

### 型定義ファイルの整合性チェックのスキップオプション `--skipLibCheck`（[--skipLibCheck compiler option](https://github.com/Microsoft/TypeScript/pull/8735)）

~~grunt-typescriptに前からあったやつですね。
手元で試した感じ、普通に1秒以上コンパイルにかかる時間が減ったのでデフォルトで使う方向で良いかもしれません。~~

標準の型定義ファイルだけではなく、全ての型定義ファイル（`.d.ts`）の整合性チェックを行わないようにするオプションです。
3rd partyの型定義ファイルはバグってたり、想定するTypeScriptのバージョンが一致しない可能性などがあるため無条件に常用するのは少し怖いところです。

### 型定義ファイルの生成先の変更オプション `--declarationDir`（[Support for declaration output folder using --declarationDir](https://github.com/Microsoft/TypeScript/issues/6723)）

`.ts`から`.d.ts`を出すやつの出力先が変更可能になりました。
`--declaration`と組み合わせて使うやつです。
どっちかというと、生成される型定義ファイルを1つにconcatしてくれる機能のほうを待ってます！

### コンパイル対象のワイルドカード指定が可能に（[Glob support in tsconfig.json](https://github.com/Microsoft/TypeScript/issues/1927)）

今まで、tsconfig.jsonには雑にexcludeで除外フォルダを指定するか、filesにコンパイル対象を列挙しなければなりませんでした。
そのためのツールとして[tsconfig-cli](https://www.npmjs.com/package/tsconfig-cli)があったのですが、いらなくなりそうですね。

```tsconfig.json
{
    "compilerOptions": {
        "module": "commonjs",
        "target": "es5"
    },
    "include": [
        "./lib/**/*.ts"
    ],
    "exclude": [
        "node_modules",
        "./lib/**/*-invalid.ts"
    ]
}
```

`!` は存在しないのでincludeとexcludeを組み合わせて頑張りましょう。

### lib.d.tsの細分化と`--lib`プロパティによる個別指定（[Improve lib.d.ts modularity and new --lib support](https://github.com/Microsoft/TypeScript/issues/494) [他](https://github.com/Microsoft/TypeScript/issues/6974)）

やっとコンパイル先形式と使えるfeatureの指定が分割可能にされた感じですね。
公式から抜粋すると以下の通りです。

* dom
* webworker
* es5
* es6 / es2015
* es2015.core
* es2015.collection
* es2015.iterable
* es2015.promise
* es2015.proxy
* es2015.reflect
* es2015.generator
* es2015.symbol
* es2015.symbol.wellknown
* es2016
* es2016.array.include
* es2017
* es2017.object
* es2017.sharedmemory
* scripthost

targetはes5なんだけどPromiseは使いたい…というパターンは多かったので自然に使えるように改善されたといえます。

### UMD形式の型定義ファイル作成時に便利な記法の追加（[Support for UMD module definitions](https://github.com/Microsoft/TypeScript/issues/7125)）

外部モジュールとしてもグローバルの拡張としても読み込み方法によって分割可能になりました。

DefinitelyTypedにUMDの定義として置く、みたいな使い方ができないっぽいです。
よって、イマイチ使いドコロが謎。興味がある人は研究してみてください。よいテクを発掘したら教えてください。

### 関数の実引数の末尾の余計なカンマの許容（[Trailing Commas in Function Param Lists](https://github.com/Microsoft/TypeScript/issues/7279)）

複数行に分割して実引数書く時に便利なやつ。
要するに[コレ](https://jeffmo.github.io/es-trailing-function-commas/)です。

### @typedef タグの利用がJSファイルについて可能に（[Support for jsdoc @typedef for JS files](https://github.com/Microsoft/TypeScript/pull/8103)）

Salsa的な話題のやつです。
tscにjsを食わせる事があまりないのでパスします。

### 入力補完候補にstring literalsが入ってくるようになった（[Completion lists for string literals](https://github.com/Microsoft/TypeScript/issues/606)）

地味にすごく良い奴。イベント名とかが入力補完できる感じ。

![complete-string-literal.png](https://qiita-image-store.s3.amazonaws.com/0/13283/a723eca2-fc8b-6886-62c7-0673777bb63b.png "complete-string-literal.png")


### 拡張子ありのモジュール名について`.js`を考慮するようにした（[Module name in imports allow .js extension](https://github.com/Microsoft/TypeScript/issues/4595)）

`import a = require("./foo.ts");` とか書いても意図通り動くようになった。
拡張子を書きたがるパターン少ないと思うので使う場面は少なさそう。

```ts:basic.ts
// 今までは .js を指定した時に .ts を見てくれなかった
// error TS2307: Cannot find module './foo.js'.
import { hi } from "./foo.js";
hi();
```

### ES5にdownpileしつつモジュール周りはES6にできるように（[Support 'target:es5' with 'module:es6'](https://github.com/Microsoft/TypeScript/issues/6319)）

`--target es5 --module es6` 的な感じですね。
rollup.jsとの相性がよくなったといえます。
今まではTypeScriptとrollup.jsを組み合わせようとすると、downpileの工程が別途必要になる（=babelが必要になる）ため、敬遠していましたが今後はTypeScript+rollup.jsの組み合わせもよく見かけるようになるかもしれません。

### `--noUnusedLocals` と `--noUnusedParameters` が追加（[Flag unused declarations with --noUnusedLocals and --noUnusedParameters](https://github.com/Microsoft/TypeScript/pull/9200)）

golangかな？？
`--noUnusedLocals` と `--noUnusedParameters` を使うことにより、使ってない変数や使ってない関数の仮引数を教えてくれるようになります。
未使用変数を削除していくと、最終的にモジュールのimport自体を削れた…！というパターンも多いため、常用してしまってよいでしょう。
Angular2のプロジェクトだと特に役に立ちそうです。

仮引数の名前のprefixを`_`にしておくと怒られなくなるようなので、将来のためにパラメータだけは残しておきたい場合は活用するとよいでしょう。

```ts:basic.ts
// 使ってない変数！
// error TS6133: 'sub' is declared but never used.
import sub, { hi } from "./sub";

// 使ってない変数！
// error TS6133: 'a' is declared but never used.
let a: string;

hi();

// 使ってない関数！使ってないパラメータ！
// error TS6133: 'foo' is declared but never used.
// error TS6133: 'b' is declared but never used.
function foo(a: string, b: number, _c: boolean) {
    console.log(a);
}
```

## まとめ

この記事書くのにかなり時間かかったので5万円くらいほしい
