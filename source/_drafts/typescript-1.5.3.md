---
title: TypeScript 1.5.3 変更点
date: 2015-07-22 01:35:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/9b9fde6c71aae6a824c0)ものと同じ内容です。

---

TypeScript 1.5.3が出ました！
今回のアップデートはかなり多くの更新を含む、大規模なアップデートであると言えます。
↑ここまで[前回](http://qiita.com/vvakame/items/69efc1c6a3b91876330d)のコピペ

まさか、1.4.1から半年待つことになろうとは思いませんでしたね…。
alphaからbetaが1月なのに正式リリースが2ヶ月強ですよ。

```
'1.4.1':		'2015-01-16T17:55:29.237Z',
'1.5.0-alpha':	'2015-04-02T16:40:27.808Z',
'1.5.0-beta':	'2015-04-30T17:23:52.442Z',
'1.5.3':		'2015-07-20T14:47:42.460Z'
```

変更点は[公式Blog](http://blogs.msdn.com/b/typescript/archive/2015/07/20/announcing-typescript-1-5.aspx)にも書かれているが、ざっくりイカの通り。

* ES6サポート
	* [es6 modules](https://github.com/Microsoft/TypeScript/issues/2242)
	* [destructuring](https://github.com/Microsoft/TypeScript/pull/1346)
	* [spread](https://github.com/Microsoft/TypeScript/pull/1931)
	* [for...of](https://github.com/Microsoft/TypeScript/pull/2207)
	* [symbols](https://github.com/Microsoft/TypeScript/pull/1978)
	* [computed properties](https://github.com/Microsoft/TypeScript/issues/1082)
	* [let/const](https://github.com/Microsoft/TypeScript/pull/2161)
	* [tagged string templates](https://github.com/Microsoft/TypeScript/pull/1589)
* [namespaceキーワード](https://github.com/Microsoft/TypeScript/issues/2159)の導入
* 外部モジュールのコンパイルターゲットに[UMD](https://github.com/Microsoft/TypeScript/issues/2036)[*](https://github.com/umdjs/umd)と[SystemJS](https://github.com/Microsoft/TypeScript/issues/2616)[*](https://github.com/systemjs/systemjs)のサポートを追加
* [プロジェクト設定ファイル(tsconfig.json)](https://github.com/Microsoft/TypeScript/issues/1667)の導入
* [Decorators](https://github.com/Microsoft/TypeScript/issues/2249)の追加
	* AngularJS 2と仲良くするためにJavaでいうアノテーション様の機能
	* --experimentalDecorators が必要
	* [type metadata](https://github.com/Microsoft/TypeScript/issues/2577)
* [TSServer](https://github.com/Microsoft/TypeScript/pull/2041)の追加
	* JSONベースでやりとりできる、エディタ用バックグラウンドデーモン
* [--rootDir](https://github.com/Microsoft/TypeScript/pull/2772)オプションの追加
	* --outDirオプションなどと組み合わせた時のルートディレクトリを決定する
	* SourceMapあたりの処理がぐちょぐちょになりがちなのを解消してくれるんですかね？
* [単一モジュールをサクッとコンパイルAPI](https://github.com/Microsoft/TypeScript/issues/2499)の追加
* [--noEmitHelpers](https://github.com/Microsoft/TypeScript/pull/2901)オプションの追加
	* AMDなどで__extendなど、クラスを実装するための要素を外部から取り込む場合などがあるのでヘルパの生成を抑制する用途
* [--inlineSourceMap](https://github.com/Microsoft/TypeScript/pull/2484)オプションの追加
	* SourceMapの情報を.js.mapではなく、.jsにインラインに出力する
* [--inlineSources](https://github.com/Microsoft/TypeScript/pull/2484)オプションの追加
	* SourceMapのsourcesContentを出力するようにする(要するに元のtsコードを埋め込む)
	* --inlineSourceMap か --sourceMap との併用が必須
* [--newLine](https://github.com/Microsoft/TypeScript/pull/2921)オプションの追加
	* 改行コードをCRLFかLFで指定できる
* [--isolatedModules](https://github.com/Microsoft/TypeScript/issues/2499)オプションの追加
	* TODO
	* --module の指定か、 --raget es6 の指定との併用が必須

公式Wikiの[What's new in TypeScript](https://github.com/Microsoft/TypeScript/wiki/What's-new-in-TypeScript#typescript-15)も参考になる。

## ES6サポート

まぁ普通にES6の解説とか探してみてください！で十分だと思うのでばっさり省略。
型周りでなにか疑問があればコメントに書いてもらえれば調べて書きます。

### 既存の外部モジュール(or 型定義ファイル)をes6 module syntaxで扱う

の、前にes6でのmoduleの書き方をおさらいしておきます。

```typescript
// sub.ts
export function hi (word: string) {
	console.log(`hi ${word}`);
}
export default function (word: string) {
	console.log(`bye ${word}`);
}
```

```typescript
// main.ts
import {hi} from "./sub"; // {hi, default as sub} とか sub, {hi} だと1行で書ける
import sub from "./sub";

hi("TypeScript");  // hi TypeScript と表示される
sub("JavaScript"); // bye JavaScript と表示される
```

```typescript
// main.ts 別解
import * as sub from "./sub";

sub.hi("TypeScript");		  // hi TypeScript と表示される
sub.default("JavaScript"); // bye JavaScript と表示される
```

OKですね。
TypeScriptのes6 moduleの偉いところは、--target es5などの時でも、CommonJSやAMDなどの外部モジュール形式に変換してくれるところです。
なので、1.5.3以降ではes6 moduleで書き、コンパイル時にCommonJSなどにするのが良いでしょう。

さて、逆に考えるとCommonJS形式などのJavaScriptでも、適切にes6 moduleによる型定義を与えてやればes6 moduleの書き方で扱うことができます。
しかし、現在の[DefinitelyTyped](https://github.com/borisyankov/DefinitelyTyped)にはまだまだes6 moduleの書き方をしている型定義ファイルは多くありません。というか皆無です。

なので、とりあえず `* as foo` の形式でfooにモジュールを束縛して使うのが今までの使い方とあまり差がなく、わかりやすいでしょう。

```typescript
// test.d.ts
// 旧来の型定義ファイルの書き方！
declare module "test" {
	var str: (word: string) => void;
	export = str;
}
```

```typescript
/// <reference path="./test.d.ts" />
// 前は import test = require("test"); と書いてた
import * as test from "test";

test("TypeScript");
```

```javascript
/// <reference path="./test.d.ts" />
var test = require("test");
test("TypeScript");
```

なお、`export =` と等価なes6 moduleの書き方は存在していない(よね？)ため、しばらくはes6 moduleと旧来の書き方が混在した状態が続くでしょう。
(export defaultは `export =` とは微妙に異なる挙動です。)

## namespace キーワード

TypeScriptにも今まで外部モジュール（1ファイル=1モジュール）と内部モジュール（関数でモジュール様の構造を作る）と呼ばれるモジュールの仕組みが存在していました。
しかし、ES6でmoduleというものが定義されまして、これは、今までのTypeScriptでいうと外部モジュールに相当します。
つまり、今後JavaScript界で単に "モジュール" と言えば、es6 module（=外部モジュール）を指すようになることは火を見るよりも明らか！
余計な混乱を生まぬよう、内部モジュールは今後、namespaceという名前にしようね！という変更です。
今後は、内部モジュールではなくnamespaceを使うようにしましょう。

```typescript
// 今まで
module foobar {
	export function hi(word: string) {
		console.log(word);
	}
}
foobar.hi("TypeScript");

// これから
namespace buzz {
	export function hi(word: string) {
		console.log(word);
	}
}
buzz.hi("TypeScript");
```
[Playground](http://goo.gl/VOJaOt)

## UMDとSystemJS

[UMD](https://github.com/umdjs/umd)と[SystemJS](https://github.com/systemjs/systemjs)のサポートが追加されました。

### UMD

Universal Module Definitionの略。
仕様というよりかは、モジュールを外部にexportする時のデザパタと言ったほうがいいだろう。
TypeScriptの出力では、AMDとCommonJS両方に対応したJSを出力できます。

TypeScriptコードとコンパイル結果のJSを示す。

```typescript
import sub = require("./sub");
sub("");
```

```javascript
(function (deps, factory) {
    if (typeof module === 'object' && typeof module.exports === 'object') {
        var v = factory(require, exports); if (v !== undefined) module.exports = v;
    }
    else if (typeof define === 'function' && define.amd) {
        define(deps, factory);
    }
})(["require", "exports", "./sub"], function (require, exports) {
    var sub = require("./sub");
    sub("");
});
```

### SystemJS

[jspm](http://jspm.io/)が使ってるモジュールローダらしい。
トランスパイラはTypeScriptで間に合ってます…感が高い。

TypeScriptコードとコンパイル結果のJSを示す。

```typescript
import sub = require("./sub");
sub.hi("");
```

```javascript
System.register(["./sub"], function(exports_1) {
    var sub;
    return {
        setters:[
            function (_sub) {
                sub = _sub;
            }],
        execute: function() {
            sub.hi("");
        }
    }
});
```

やりたいことはわからんでもない。

## tsconfig.json

大昔からある仕様として、 `tsc @sample.tscparams` のように書くと、sample.tscparamsファイル内に書いてある内容がそのままtscのオプションとして利用される、という機能がありました。
tsconfig.jsonはそれに似た仕様です。

tsconfig.jsonは、TypeScriptコンパイラに与えるオプションの設定としてだけではなく、AtomやVisualStudioCodeなどのエディタとコンパイラへの設定を共有するのに便利です。
詳細は[公式のWiki](https://github.com/Microsoft/TypeScript/wiki/tsconfig.json)を参照してください。

ざっくり以下のような書式です。

```tsconfig.json
{
    "compilerOptions": {
        "module": "commonjs",
        "noImplicitAny": true
    },
    "files": [
        "foo.ts"
    ]
}
```

compilerOptions に書けるものは、tscコマンドに渡せるオプションと同一のようです。
また、filesにコンパイル対象のファイルを全て記述します。
これにより、`/// <reference path="./hoge.d.ts" />`というリファレンスコメントから逃れることができます。

tsconfig.jsonは基本的に1プロジェクト1ファイルですが、例えばlibとtestの2フォルダそれぞれに置くこともできます。
tscコマンドからtsconfig.jsonを読み込む時は、`--project` オプションでtsconfig.jsonのあるフォルダを指定します。

複数設定を書くのもめんどいですし、そのうちgruntやgulpからもtsconfig.jsonを参照するスタイルが流行るのではないでしょうか。

いちいちfilesを書くのはめんどくさい！という人は、[atom-typescript](https://atom.io/packages/atom-typescript)を使うと、filesGlobでパターンを指定するとエディタの保存時にfilesを更新してくれます。
また、TypeScript 1.6では[exclude](https://github.com/Microsoft/TypeScript/issues/3043)による除外指定が導入されます。

## Decorators

ざっくり言うとJavaのアノテーションのような構文で、処理を差し挟めるようになりました。
デコレータは以下の箇所に使うことができます。

* クラス定義
* インスタンスメソッド
* インスタンスプロパティ
* インスタンスのget/setアクセサ
* メソッドの引数
* クラスメソッド
* クラスプロパティ

コンパイルには `--experimentalDecorators` オプションが必要です。

```typescript
var constructorNames: string[] = [];

function collectConstructorName(sampleClazz: any) {
	constructorNames.push(sampleClazz.name);
	return null; // 値を返すとその値でクラスそのものを置き換えることもできる
}

@collectConstructorName
class Foo {
}

alert(JSON.stringify(constructorNames)); // ["Foo"] と表示される
```

変換結果は長いので、[Playgroundで確認](http://goo.gl/pIvVMq)してください。

デコレータの使い道は色々あって、想像力次第で色々と便利なことや邪悪なことができるでしょう。
筆者は、[本来継承できないオブジェクトを無理やり継承する](http://goo.gl/xT6cSX)などして有効活用しています。

なお、`--emitDecoratorMetadata` オプションを併用することで型情報を実行時に(ちょっぴり)参照できるようになるので、興味があれば検証してみるといいでしょう。
筆者は普通にTypeScriptのASTを読んで実行時情報として出力するツールを作ったほうがよくない？と思いました。

## これからのベストプラクティスまとめ

`import foo = require("foo");` 形式の外部モジュール使うな！es6 module syntax使え！
内部モジュール使うな！namespace使え！
なるべくtsconfig.json使おう！
よろしくお願いします ┏○
