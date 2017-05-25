---
title: TypeScript 2.1.1 変更点
date: 2016-11-11 02:41:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/305749d3d6dc6bf877c6)ものと同じ内容です。

---

こんばんは[@vvakame](https://twitter.com/vvakame)です。

[TypeScript 2.1(RC)](https://blogs.msdn.microsoft.com/typescript/2016/11/08/typescript-2-1-rc-better-inference-async-functions-and-more/)がアナウンスされましたね。

2.0系の正式リリースである2.0.3が9/22のリリースなので、1月半でminor versionが上がりました。

## 変更点まとめ

[公式ブログ記事](https://blogs.msdn.microsoft.com/typescript/2016/11/08/typescript-2-1-rc-better-inference-async-functions-and-more/)では小さい更新かと思いきや、[Roadmap](https://github.com/Microsoft/TypeScript/wiki/Roadmap)を見ると結構たくさんの更新があります。

* トランスフォームベースのJSコード生成 ([Switch to a transformation-based emitter](https://github.com/Microsoft/TypeScript/issues/5595))
	* generatorのdownpileとかに必要だった認識(今回はgeneratorのdownpileはなしっぽい
* async/awaitのes3 or es5 downpileのサポート ([async/await support for ES5/ES3](https://github.com/Microsoft/TypeScript/pull/9175))
	* Promiseの糖衣構文的なアレがES5とかでも使えるようになった
* ヘルパライブラリを外部に持てるように ([Support for external helpers library](https://github.com/Microsoft/TypeScript/issues/3364))
	* downpile時にクラスのextends用補助関数をファイル毎に出力してたのをやめれるようにした
* リテラル型とより良い型推論 ([Better inference for literal types](https://github.com/Microsoft/TypeScript/pull/10676))
	* リテラル型が推論で導出される箇所が増えた
* 型注釈無しの変数に対する型導出のサポート ([Control flow analysis for implicit any variables](https://github.com/Microsoft/TypeScript/pull/11263))
	* 前よりも生のJS的な書き方をしても適切な型が推論されるようになった
* 型注釈無しの配列に対する型導出のサポート ([Control flow analysis for array construction](https://github.com/Microsoft/TypeScript/pull/11432)
	* 同上
* 条件式によるnumber or stringからリテラル型への変換 ([Narrow string and number types in literal equality checks](https://github.com/Microsoft/TypeScript/pull/11587))
	* 同上
* 部分的型注釈からの型推論 ([Contextual typing of partially annotated signatures](https://github.com/Microsoft/TypeScript/pull/11673))
	* 一部しか型推論が与えられていなくても型パラメータなどから類推できる場合頑張るようになった
* 直和型と交差型を組み合わせのノーマライズ ([Normalize union/intersection type combinations](https://github.com/Microsoft/TypeScript/pull/11717)
	* 論理演算的にイコールのパターンでも互換性無しと判定されてたパターンを頑張って潰した
* tsconfig.jsonでextendsが使えるようになった ([Configuration inheritance](https://github.com/Microsoft/TypeScript/issues/9876))
	* そのまんま Angularの中の人たちが欲しがったらしい
* "定義にジャンプする" をLanguageServiceに追加 ([Go to implementation support](https://github.com/Microsoft/TypeScript/pull/10482))
	* 3rd partyのエディタとかがリッチになるやつです
* reference commentとかimport文での入力補完をLanguageServiceに追加 ([Completions in imports and triple-slash reference paths](https://github.com/Microsoft/TypeScript/issues/188))
	* 同上
* 無条件にstrict modeにするオプションの追加 ([New --alwaysStrict](https://github.com/Microsoft/TypeScript/issues/10758))
	* 全てのtsファイルで全自動で `"use strict";` なモードで動くようになる
* es2016, 2017 をターゲットに追加 ([Support for --target ES2016 and --target ES2017](https://github.com/Microsoft/TypeScript/pull/11407))
	* そのまんま
* Quick fixes をLanguageServiceに追加 ([Quick fixes support in language service API](https://github.com/Microsoft/TypeScript/issues/6943))
	* たぶん実装は[コレ](https://github.com/Microsoft/TypeScript/pull/10185)

### 2.1.3の予定

すでに[Milestone](https://github.com/Microsoft/TypeScript/milestone/31)は切られてて結構進んでるっぽいです。
いくつかのマジでそれ実装してShippingしちゃうんすか…？みたいな変更があるので楽しみです。

* [Static types for dynamically named properties](https://github.com/Microsoft/TypeScript/pull/11929)
* [Mapped Types](https://github.com/Microsoft/TypeScript/pull/12114)
* [Support ES8 object property spread and rest](https://github.com/Microsoft/TypeScript/issues/2103)

<!--
これはRoadmapに書いてあるけど2.1.3でも入らない予感がする
* [Investigate Language Service extensibility](https://github.com/Microsoft/TypeScript/issues/6508)
-->

## トランスフォームベースのJSコード生成

async/awaitをdownpileする時などに従来のワンパス変換だとめっちゃ辛いのでトランスフォーム(変換)ベースになったという理解です。
[このへん](https://github.com/Microsoft/TypeScript/blob/28cc9385035a65f5dcd74a4f9b47e7022678302f/src/compiler/transformer.ts#L107-L141)見ると分かりやすいんですが、複数パスの変換で徐々に目的のレベルまで変換していくという感じっぽいです。
generatorの変換とかも入った…！ように見えるんですが今のところ `--target es5` ではgeneratorは使えないようです。

## async/awaitのes3 or es5 downpileのサポート

されました。

```async.ts
function doubleAsync(v: number) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve(v * 2);
        }, 10);
    });
}

function exec1() {
    const p = doubleAsync(1);
    return p.then(v => console.log(v));
}

async function exec2() {
    const v = await doubleAsync(4);
    console.log(v);
}

// 両方 Promise<void>
const v1 = exec1();
const v2 = exec2();

Promise.all([v1, v2]).then(() => {
    console.log("end");
});
```

これが `--target es2015` の時こうなる。

```async.es2015.js
"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments)).next());
    });
};
function doubleAsync(v) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve(v * 2);
        }, 10);
    });
}
function exec1() {
    const p = doubleAsync(1);
    return p.then(v => console.log(v));
}
function exec2() {
    return __awaiter(this, void 0, void 0, function* () {
        const v = yield doubleAsync(4);
        console.log(v);
    });
}
// 両方 Promise<void>
const v1 = exec1();
const v2 = exec2();
Promise.all([v1, v2]).then(() => {
    console.log("end");
});
```

これが `--target es5` の時こうなる。

```async.es5.js
"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments)).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t;
    return { next: verb(0), "throw": verb(1), "return": verb(2) };
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = y[op[0] & 2 ? "return" : op[0] ? "throw" : "next"]) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [0, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
function doubleAsync(v) {
    return new Promise(function (resolve, reject) {
        setTimeout(function () {
            resolve(v * 2);
        }, 10);
    });
}
function exec1() {
    var p = doubleAsync(1);
    return p.then(function (v) { return console.log(v); });
}
function exec2() {
    return __awaiter(this, void 0, void 0, function () {
        var v;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, doubleAsync(4)];
                case 1:
                    v = _a.sent();
                    console.log(v);
                    return [2 /*return*/];
            }
        });
    });
}
// 両方 Promise<void>
var v1 = exec1();
var v2 = exec2();
Promise.all([v1, v2]).then(function () {
    console.log("end");
});
```

次に紹介するヘルパライブラリの外部化を併用したい。

## ヘルパライブラリを外部に持てるように

まとめ： `npm install --save tslib` して `--noEmitHelpers` と `--importHelpers` を併用し、どこかで `import "tslib";` しよう。async/awaitを使いたい場合旧来の方法のほうがよい。

TypeScriptで `--target es5` とした場合、ヘルパ関数が自動的に出力される。

```class.ts
class A {}
class B extends A {}
```

をコンパイルすると

```class.js
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
};
var A = (function () {
    function A() {
    }
    return A;
}());
var B = (function (_super) {
    __extends(B, _super);
    function B() {
        return _super.apply(this, arguments) || this;
    }
    return B;
}(A));
```

こうである。
このヘルパ関数は1つのtsファイルについてそれぞれ作成されるので、大量の重複コードが生成されブラウザ用JSでは結構なサイズ負担になっていたそうな。

前から `--noEmitHelpers` というのがあって、この場合[ts-helpers](https://www.npmjs.com/package/ts-helpers)を使って同名のヘルパ関数をglobalに生やすというアプローチだったようだ。

これが改められ、 `--importHelpers` が追加され、これはMS謹製の[tslib](https://www.npmjs.com/package/tslib)を使う。
ざっくり以下のように書く。

```class.ts
import * as tslib from "tslib";

class A {}
class B extends A {}
```

import句はなくてもglobalにも生えるためソース中のどこか一箇所でimportしておくだけでもよい。
このオプションを使っている場合、tslibの存在チェックと必要な関数があるかどうかのチェックをしてくれる。
併せて、`--noEmitHelpers` を併用したほうがミスが防げてよい。

なぜか、 `tslib@1.0.0` には `__generator` が含まれていないため、async/awaitなどこれを要求するとコンパイルエラーになる。
その場合、 `--importHelpers` はまだ使わないほうがよさそうだ。
tslibの新しいの早くリリースしてください。

## リテラル型とより良い型推論

まとめ：型推論が今までより頭がよくなるという話なので特に気にしなくてよい。

詳しいことは[御大の書いた仕様](https://github.com/Microsoft/TypeScript/pull/10676#issue-174651709)を見てほしい感じ…。

例えば、`let str: "Hello";` の、`"Hello"` のような型をリテラル型と呼ぶ。

例えば次のような例について。

```
const a1 = "a";
const a2: "a" = "a";
```

TypeScript 2.1以前はa1の型は `string` だったが、今後は `"a"` に推論されるようになる。
これはconstやreadonly特有のもので、letやvarなどの場合は今まで通りstringに推論される。

正直どいうモチベーションでこの機能がいるのか分かりにくいが、[このIssue](https://github.com/Microsoft/TypeScript/issues/10898#issue-176715115)のようなユースケースの時に嬉しいらしい。

## 型注釈無しの変数に対する型導出のサポート

まとめ：型推論が今までより頭がよくなるという話なので特に気にしなくてよい。変数の型注釈外してみてもいいかも。

ざっくりこういう感じになった。

```ts
let a; // a は implicit any (ただし--noImplicitAnyでもエラーにならない)

a = () => console.log("Test");
// a は () => void
a();

a = "Test";
// a は string
a.toUpperCase();

if (Math.random() < 0.5) {
    a = 1;
} else {
    a = true;
}
// a はnumber | boolean
a;
```

わりと良さそう。
実用上、初期化子無しのconstとか、関数やメソッドの仮引数以外で `--noImplicitAny` に引っかかるようなコードを書けなくなったのでは…？
もし反例があったらコメントかなにかで教えてください。

## 型注釈無しの配列に対する型導出のサポート

まとめ：型推論が今までより頭がよくなるという話なので特に気にしなくてよい。変数の型注釈外してみてもいいかも。

```
let array = [];

// 以下のようなコードを書くと --noImplicitAny に引っかかってエラーになる
//   error TS7005: Variable 'array' implicitly has an 'any[]' type.
// let a1 = array[0];

array.push("Hi");
// arrayは string[]
array.forEach(v => v.toUpperCase());

array.push(/test/);
// arrayは (string | RegExp)[] なので toUpperCase は必ずしも存在しないのでエラーになる
array.forEach(v => v.toUpperCase());
```

ここに

```
let a;
array.push(a);
```

とかやった時の挙動は `--strictNullChecks` が有効かどうかで変わるので面白い。

## 条件式によるnumber or stringからリテラル型への変換

まとめ：型推論が今までより頭がよくなるという話なので特に気にしなくてよい。

```ts
function suite(v: "spades" | "diamonds" | "hearts" | "clubs") {
}

let a: string = "";
switch (a) {
    case "spades":
    case "diamonds":
    case "hearts":
    case "clubs":
        // a は "spades" | "diamonds" | "hearts" | "clubs"
        // 前は a は string のままだったのでコンパイルエラーだった
        suite(a);
}
```

よさそう。

## 部分的型注釈からの型推論

まとめ：テキトーに型注釈をサボっても怒られなくなった。

かなりよさそうです。

```ts
function random() {
    // resolveの型注釈書いたらrejectの型注釈も書かなきゃいけなかったけどサボれるようになった
    return new Promise((resolve: (v: number) => void, reject) => {
        resolve(Math.random());
    });
}
```

こういうコードが `--noImplicitAny` 下でもvalidになった。
いくつかの仮引数から残りの仮引数の型が確定できるなら省略してもちゃんと推論されるようになった。
という挙動のようです。
型パラメータが絡んだ時にわかりきってるけど省略できなかった型注釈を省けるようになるのは嬉しいところ。

## 直和型と交差型を組み合わせのノーマライズ

PRのdesctiption曰く、以下のようなコードのコンパイルが通るようになったらしい。

```ts
interface A { a: string }
interface B { b: string }
interface C { c: string }
interface D { d: string }

// Identical ways of writing the same type
type X1 = (A | B) & (C | D);
type X2 = A & (C | D) | B & (C | D);
type X3 = A & C | A & D | B & C | B & D;
```

交換法則とかそういう推移律を満たすようになったとかいう事だと思うんだけどだからなんだという感じだ…(こんな分かりにくいコードを書くな的な気持ち

## tsconfig.jsonでextendsが使えるようになった

まとめ：tsconfig.jsonで他のtsconfig.jsonを継承できるようになった

```tsconfig.json
{
    "extends": "./tsconfig.test",
    "compilerOptions": {
        "listFiles": true
    }
}
```

`"typescript/strict"` とか書けるようにしたいなーみたいなのもちょろっと書いてあって、`"definitelytyped/recommended"` とか出来ると楽そうだなーと思った。
今のところはは相対パスか絶対パスしかダメ。

## LanguageServiceの改善系

* 定義にジャンプする
* reference commentとかimport文での入力補完
* Quick fixes

エディタ作者以外はあまり関係がなさそう。
プロジェクト上のQuick fix候補を全て修正して回るコマンドラインツールとか作ったらウケそうな気がするな〜〜(放流

## 無条件にstrict modeにするオプションの追加

まとめ： `--alwaysStrict` は常用しよう

今まで、strict modeが自動的に適用されるようなコード(es2015 module syntaxな時とか)は自動的に `"use strict";` が出力されていましたが、そうではない時でも常にstrict modeとして検査し、 `"use strict";` も自動的に出力してくれるようにするオプションです。

想定していないパターンなどでうっかりstrict modeではなくなってしまうのを防ぐためにも、 `--alwaysStrict` は常に有効で作業してしまってよいでしょう。

## es2016, 2017 をターゲットに追加

まとめ：IE11とかは早く死んでほしい

`--target es2016` と `--target es2017` が使えるようになったという話。
es2017にするとasync/awaitがdownpile無しで出力される。
