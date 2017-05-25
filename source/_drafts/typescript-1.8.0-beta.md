---
title: TypeScript 1.8.0-beta 変更点
date: 2016-02-01 12:00:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/31f5c45ff49de67d5634)ものと同じ内容です。

---

TypeScript 1.8.0-betaが出ました！
今回のアップデートはかなり多くの更新を含む、大規模なアップデートであると言えます。
いやマジで。

latestタグではなく、betaタグでリリースされたため、`npm install -g typescript` では未だに1.7.5が入ります。やったね！
1.8.0-betaを試したい時は `npm install -g typescript@beta` しましょう。

[公式ブログ](http://blogs.msdn.com/b/typescript/archive/2016/01/28/announcing-typescript-1-8-beta.aspx)と[What's new](https://github.com/Microsoft/TypeScript/wiki/What%27s-new-in-TypeScript#typescript-18)、[Roadmap](https://github.com/Microsoft/TypeScript/wiki/Roadmap#18)から変更点をさらっていきます。
量が多すぎてやばいです。

* `--allowJs` の導入
	* JavaScriptなコードをTypeScriptコードと混在させて利用可
* JSX系の何か
	* Reactは興味ないので割愛したい…したくない？React以外に有用なJSX使ったツールって何かあるのかしら
	* statelessなコンポーネントをより簡単につくれるようになった
	* `--reactNamespace` とか追加した
	* VS 2015 でシンタックスハイライトとか
* TypeScript NuGet Packges
	* NuGet使ってないし使う予定もないのでなんとも…
* Chakra Core + TypeScript
	* とりあえずNode.jsより早いらしいです
* F-Bounded Polymorphismの復活
	* コンパイルにかかる時間短縮のために闇に葬られたアレが復活しました
* Control flow analysis errors
	* 到達不能コードとかswitch文での意図してなさそうなfall-throughの検出などがサポートされた
* moduleの拡張とglobalの拡張が可能に
	* 型定義ファイル的には色々なつらみが解消される神アプデかと思ったらそこまででもなかった
* String literal types
	* 役に立たないenumよりよっぽど使いやすそうな文字列リテラルに対する型だ！やった！
* union/intersection typeの型推論がより賢く
	* 今までtype guardによる絞込みはシンプル側に倒されていたが少し頑張るようになったぽい
* AMDとSystemJSをモジュールに利用した時、`--outFile` でconcatできるようになった
* SystemJSにおける `default` の互換性の向上
* let / const でループの変数のキャプチャが可能になった
* for .. in 句での型推論が改善
	* 今まで `any` になってたのが改善された… for .. in 誰か使ってる？？
* モジュール利用時、自動的に `"use strict";` が出力されるようになった
	* よりes6 specでの振る舞いに近づいた。要するに神。
* thisベースのtype guards
	* 1.7で入ったような気がしてたけど1.8からだった…
	* [1.6で入った奴](https://github.com/Microsoft/TypeScript/issues/1007)がthisに対しても使えるようになった
* エラーメッセージを今までよりわかりやすく表示できるようになった
	* `--pretty`
* `--project` の引数にディレクトリ以外もとれるようになった
	* 今までは `-p ./` とすると、暗黙的にtsconfig.jsonが読まれていた
	* 今後はtsconfig.jsonとコンパチなファイルを指定すればそれで動くようになった
* tsconfig.json中にコメントが書けるようになった
	* 別npm packageとかに切り出されたりしてないし拡張子変わってないし罠の予感しかしない…
* --outFileの対象に /dev/stgout とかを指定できるようになった
* computed propertyの利用可能範囲が広がった

## `--allowJs` の導入

[Issue1](https://github.com/Microsoft/TypeScript/issues/4792) [Issue2](https://github.com/Microsoft/TypeScript/pull/5876)

TypeScriptコンパイラがJavaScriptコードを直接食べれるようになりました。
`--allowJs` を使います。

今まで、既存のJavaScriptコードをTypeScriptに変換するには、とりあえず拡張子を `.ts` に変更して、泣きながらコンパイルエラーを潰す作業が必要でした。
これは一括で変換しないといけないし、自分のペースで少しづつやる、ということに向いていませんでした。
1.8からは、巨大なプロジェクトでも少しづつ、自分のペースでTypeScriptコードに変換していくことができます。
最終的には `--allowJs` 無しでコンパイルできるようになる事を目指すとよいでしょう。

更に、3rd partyライブラリもより簡単に利用しはじめることができるようになります。
今までは、型定義ファイル(.d.ts)が必須でしたがそれなしで使いはじめることができます。
それに、browserifyやwebpackなどの外部のbundle用ツールを使わずとも、tscにそれをやらせることができるようになったと言えます。

また、TypeScriptコンパイラをes6のjsコードからes5へのdownpile用ツールとして使えるということでもあります。

### 実際に試してみた

まず、公式のブログに従ってVisualStudioCodeで使うtscを1.8.0にします。
そうするとIDE上でどの変数や関数がどういう型として認識されているか見やすくなるので便利です。

```.vscode/settings.json
{
    "typescript.tsdk": "./node_modules/typescript/lib"
}
```

* JSコードの型付けはどう解釈されるのか？
	* 割りと賢く解析してくれる
	* `--noImplicitAny` をオフにしたTypeScriptコードとだいたい同じっぽい
	* 試しにasm.jsっぽい書き方をしてみたけど特に影響無し
	* argumentsとかを使っていてもそれを考慮してはくれない (仮引数の記述通りになる)
* JSコードを変換する時もともとのコードが上書きされちゃう？
	* `error TS5055: Cannot write file 'sub.js' because it would overwrite input file.`
	* 逆に言うと、 `--out` もしくは `--outFile` との併用が必須になる
* どんな形式のJSコードでもいけるか
	* UMDで書いたコード→ダメそう
	* CommonJSで書いたコード→いけた
	* 古い、prototypeを使ったOOP→いけた！
		* prototypeチェーンに対応してるかは見てない…！書き方忘れたし
	* es6 moduleで書いたコード→いけた
* --declaration指定でJSコードの型定義ファイルを生成してくれるか
	* してくれなかった(´・ω・) `error TS5053: Option 'allowJs' cannot be specified with option 'declaration'.`
* node_modules配下を見てくれるか→見てくれないっぽい

### 結論

`--allowJs` は一時的に利便性を得るものであり、恒常的に使うべきものではなさそうです。
というのも、TypeScriptの型推論は関数・メソッドの返り値の型については処理内容からそれなりに頑張ってそれっぽい型を推論してくれます。
ところが、仮引数の型についてはそうはいかず、基本的に手で指定してやらなければなりません。
JavaScriptコードの場合、仮引数の型注釈がないため、基本的には `any` と推論されてしまいます。
ガバガバやな！ノーガード戦法で問題ないんだったらTypeScriptじゃなくてbabel使っておけばいいと思います。
また、上記性質により、型定義ファイルが完全に不要になることもないといえます。

とはいえ、--allowJs は歓迎すべきものだと考えられます。
今までは ES3/5なコード→ES6なコード(with babel)→徐々にTypeScriptコードに切り替え という流れでした。
それが、ES3/5なコード→TypeScriptコンパイラで処理できる構成に整える→徐々にES6化→型注釈を補う→--allowJsを外す という流れにできます。
TypeScriptコンパイラによる整合性チェックがより早くから得られるのは大きな利点であるといえます。

## JSX系の何か

[Issue1](https://github.com/Microsoft/TypeScript/issues/5478) [Issue2](https://github.com/Microsoft/TypeScript/pull/6146) [Issue3](https://github.com/Microsoft/TypeScript/issues/4835)

あまり興味がないので割愛したい…したくない？
Angular2とJSX組み合わせる方法が編み出されたら教えてください。
[公式ブログ](http://blogs.msdn.com/b/typescript/archive/2016/01/28/announcing-typescript-1-8-beta.aspx)にサンプルコード載ってるしなんとなく眺めるとざっくりわかるんじゃないかと思います。

## TypeScript NuGet Packges

[Issue](https://github.com/Microsoft/TypeScript/issues/3940)

これも使ってないので…
Macで開発してるので…

## Chakra Core + TypeScript

[ChakraがOSSになった](https://blogs.windows.com/msedgedev/2016/01/13/chakracore-now-open/)とかそういう話。
Node.jsよりコンパイル速度が早い！とのことなので、もっと使いやすくなってきたら試すのもありかも。

## F-Bounded Polymorphismの復活

[Issue](https://github.com/Microsoft/TypeScript/pull/5949)

[TypeScript 0.9.7でダメになった](https://typescript.codeplex.com/wikipage?title=Known%20breaking%20changes%20between%200.8%20and%200.9&referringTitle=Documentation)、Genericsで型パラメータが別の型パラメータが参照できなくなる制限が緩和され再び使えるようになりました。

```error-in-tsc0.9.7.ts
interface Service<T> {
    service(t: T): T;
}

//Error: Service<T> references T, which is a type parameter in the same list
function f<T extends Service<T>>(x: T) { }

//Likewise. Error: Service<U> references U, which is a type parameter in the same list
function g<U, T extends Service<U>>(x: T) { }
```

0.9.7のBreaking Changeに書かれている上記のコードはTypeScript 1.8.0から再びOKになりました。
やったね…！！
これないと地味に型定義ファイル書きづらくて困る事があったので嬉しいです。

## Control flow analysis errors

[Issue](https://github.com/Microsoft/TypeScript/pull/4788)

[公式ブログ](https://github.com/Microsoft/TypeScript/wiki/What%27s-new-in-TypeScript#control-flow-analysis-errors)のGIFアニメがとりあえずわかりやすいので一回見てみるとよいでしょう。

### Unreachable code

到達不能な(つまり不要な)コードの存在を検出してエラーにする。
`--allowUnreachableCode` を指定するとオフにできる。
TypeScript 1.7.5までの動作と同じなのはオフの時である。

```
$ cat unreachableCode.ts
function hi(word: string) {
    return `Hi, ${word}`;

    word += "!";
}
$ ./node_modules/.bin/tsc --pretty unreachableCode.ts

4     word += "!";
      ~~~~

unreachableCode.ts(4,5): error TS7027: Unreachable code detected.
```

関数のhoistingなどは問題ないです。

一般的に、意図してUnreachable codeを書く事はないはずなので、デフォルトの挙動に従い、怒られたらコードをリファクタリングするのがよいでしょう。

### Unused labels

使ってないラベルをエラーにしてくれます。
`--allowUnusedLabels` を指定するとオフにできる。

```
$ cat unusedLabel.ts
function contains<T>(arrayA: T[], arrayB: T[]): boolean {
    outer: for (let i = 0; i < arrayA.length; i++) {
        let v = arrayA[i];
        if (arrayB.filter(vB => v === vB).length !== 0) {
            return true;
        }
    }
    return false;
}

contains([1, 2, 3, 4], [3, 6]);

$ ./node_modules/.bin/tsc --pretty unusedLabel.ts

2     outer: for (let i = 0; i < arrayA.length; i++) {
      ~~~~~

unusedLabel.ts(2,5): error TS7028: Unused label.
```

JavaScriptだとArrayのメソッドが使いやすいのでまぁ単純にforとかwhileを使う場合ってほとんどないと思うのですがまぁ便利ですね。

これもデフォルトの挙動に従っておけばよいでしょう。

### Implicit returns

暗黙的な(undefinedを返す)returnを禁止します。
これは明示的に `--noImplicitReturns` を指定して利用します。

```
$ cat implicitReturns.ts
function f(x: any): boolean {
    if (x) {
        return false;
    }

    // implicitly returns `undefined`
}

$ ./node_modules/.bin/tsc --pretty --noImplicitReturns implicitReturns.ts

1 function f(x: any): boolean {
                      ~~~~~~~

implicitReturns.ts(1,21): error TS7030: Not all code paths return a value.
```

良いですね。これって今までもやると怒られてた気がするんだけど違ったっけ…？
tslintのルールとかにあるかなーと思って見たらなさそう…？？

ともあれ、undefinedを返したいなら明示的に返すのが正しいので、このオプションは常に利用したほうがよいでしょう。

### Case clause fall-throughs

switch文でcase句にbreakがなかったらエラーにする。
ただし、case句にぶら下がるstatementが何もなかったらfall-throughを許す。
`--noFallthroughCasesInSwitch` を明示的に利用する。

```
$ cat caseClauseFallthroughs.ts
let ss = ["a", "b", "c", "d"];
let s = ss[Date.now() % ss.length];

switch (s) {
    case "a":
        console.log("This is A!");
        // break 忘れてます！エラーにするのが安全だ！
    case "b":
        console.log("This is B!");
        break;
    case "c":
        // empty statement は許される…！
    case "d":
        console.log("This is C or D!");
        break;
}

$ ./node_modules/.bin/tsc --pretty --noFallthroughCasesInSwitch caseClauseFallthroughs.ts

5     case "a":
      ~~~~

caseClauseFallthroughs.ts(5,5): error TS7029: Fallthrough case in switch.
```

意図してfallthroughしたい箇所で一時的にオフにする方法がないのは辛いですね。
基本的にはこのオプションを利用し、明確に理由が説明できる事情が説明できるプロジェクトでだけオフにするのがよいでしょう。

## moduleの拡張とglobalの拡張が可能に

[Issue](https://github.com/Microsoft/TypeScript/issues/4166)

神アプデかと思ってしっかり見たら狛犬アプデくらいだったでござる。

~~今までのTypeScriptでは、既存モジュールに対して型定義ファイルを当てるというのはなかなか難儀な作業でした。
というのも、外部モジュールとして一度宣言すると、それをグローバルスコープに対して公開する方法がなかったのです。
そのため、グローバルスコープに変数やらインタフェースやらクラスやら、諸々全てを定義しておいて、外部モジュールから参照する、逆はできない…！という状況にありました。
しかし、本アップデートでその状況が改善されます！やったーー！！~~

と思ったら、`Neither module augmentations nor global augmentations can add new items to the top level scope - they can only "patch" existing declarations.` と書いてあって、俺の期待は塵になった。合掌。

要するに、このアップデートは既存のクラスに新しいメソッドを生やす事ができるようになった、というアップデートです。

`declare module "./observable"` 的な、外部モジュールの型定義の再オープンができるようになったのと、`declare global {` みたいな感じでグローバルスコープのインタフェースなどに好きに追加ができるようになりました。

[What's new](https://github.com/Microsoft/TypeScript/wiki/What%27s-new-in-TypeScript#augmenting-globalmodule-scope-from-modules)のサンプルを見ると一発でわかると思うのでそちらをどうぞ。

## String literal types

[Issue](https://github.com/Microsoft/TypeScript/pull/5185)

特定の文字列であることを型として強制できるようになりました。

```
$ cat main.ts
type Season = "winter" | "spring" | "summer" | "autumn";

function seasonToJapaneseString(s: Season): string {
    switch (s) {
        case "winter":
            return "冬";
        case "spring":
            return "春";
        case "summer":
            return "夏";
        case "autumn":
            return "秋";
    }

    return "???";
}

seasonToJapaneseString("winter");
seasonToJapaneseString("winert");

$  ./node_modules/.bin/tsc --pretty main.ts

19 seasonToJapaneseString("winert");
                          ~~~~~~~~

main.ts(19,24): error TS2345: Argument of type '"winert"' is not assignable to parameter of type '"winter" | "spring" | "summer" | "autumn"'.
  Type '"winert"' is not assignable to type '"autumn"'.
```

うーん、いいですね！！
これを使うことで改善できる型定義ファイルは山程あるでしょう。

## union/intersection typeの型推論がより賢く

[Issue](https://github.com/Microsoft/TypeScript/pull/5738)

ざっくり、type guardした時の型の候補の削減がより正確になった感じです。

```
$ cat main.ts
type Maybe<T> = T | void;

function isDefined<T>(x: Maybe<T>): x is T {
    return x !== undefined && x !== null;
}

let v: Maybe<string>;
if (isDefined(v)) {
    // v is string!
    v.charAt(0);
} else {
    // v is void.
    v.charAt(0);
}

$ tsc -v
message TS6029: Version 1.7.5
$ tsc main.ts
main.ts(10,7): error TS2339: Property 'charAt' does not exist on type 'string | void'.
main.ts(13,7): error TS2339: Property 'charAt' does not exist on type '{}'.

$ ./node_modules/.bin/tsc -v
Version 1.8.0
$ ./node_modules/.bin/tsc main.ts
main.ts(13,7): error TS2339: Property 'charAt' does not exist on type 'void'.
```

primitive typeを対象にした時の刈り込みと似た挙動に。すばらしい！わかりやすい！

## AMDとSystemJSをモジュールに利用した時、`--outFile` でconcatできるようになった

[Issue](https://github.com/Microsoft/TypeScript/pull/5090)

表題の通りです。
CommonJS, UMD, ES6 moduleでは不可。
まぁそういう機構がモジュールの仕様に入ってないからね。仕方ないね。

## SystemJSにおける `default` の互換性の向上

[Issue](https://github.com/Microsoft/TypeScript/issues/5285)

`--allowSyntheticDefaultImports` として導入された。
SystemJS興味ないから気にしてないけど、ざっくり昔のbabelみたく `module.exports = ...` として作られたライブラリとes6 moduleの親和性を向上させる系の奴だと思う。たぶん。

## let / const でループの変数のキャプチャが可能になった

[Issue](https://github.com/Microsoft/TypeScript/issues/3915)

letとループ組み合わせた挙動ってこんなだったんだ…(TypeScriptで書けないes6仕様は知らないマン並の感想

```
$ cat main.ts
let array = [1, 2, 3, 4];
let fs: (() => void)[] = [];
for (let i = 0; i < array.length; i++) {
    let f = () => {
        console.log(i);
    };
    fs.push(f);
}
// 0 1 2 3 が表示される
fs.forEach(f => f());

$ ./node_modules/.bin/tsc main.ts

$ node main.js
0
1
2
3
$ cat main.js
var array = [1, 2, 3, 4];
var fs = [];
var _loop_1 = function(i) {
    var f = function () {
        console.log(i);
    };
    fs.push(f);
};
for (var i = 0; i < array.length; i++) {
    _loop_1(i);
}
// 0 1 2 3 が表示される
fs.forEach(function (f) { return f(); });
```

## for .. in 句での型推論が改善

[Issue](https://github.com/Microsoft/TypeScript/pull/6379)

for .. in で繰り返しした時の変数の型がanyからstringになったという話(だと思う
for .. in て使ってる人いるんすかね？？
TypeScript上の仕様見てもなんかわかりにくいしやっぱいらない子だった。

## モジュール利用時、自動的に `"use strict";` が出力されるようになった

es6 moduleなコードを書いた時、1.7.5までは自分で "use strict"; を書かなければいけなかったが、1.8からは自動で出力されるようになったという話。
もともと、es6の仕様上es6 moduleとして解釈されるJSコードはstrict modeが強制される仕様なので、よりes6に対する準拠度があがった形だ。
将来爆発する地雷がまた少し減ったぞ！やったね！

## thisベースのtype guards

[Issue](https://github.com/Microsoft/TypeScript/pull/5906)

TypeScript 1.6で導入された、`is` によるType guardについて、左辺にthisが使えるようになりました。
以下のようなコードがかけます。

```
abstract class Node {
    constructor(v: any) { }
    isStringNode(): this is StringNode {
        return this instanceof StringNode;
    }
    isNumberNode(): this is NumberNode {
        return this instanceof NumberNode;
    }
}

class StringNode extends Node {
    constructor(public text: string) {
        super(text);
    }
}

class NumberNode extends Node {
    constructor(public value: number) {
        super(value);
    }
}

let nodes: Node[] = [new StringNode("TypeScript"), new NumberNode(1.8)];
// TypeScript と 1.8 と表示される
nodes.forEach(n => {
    if (n.isStringNode()) {
        // n is StringNode!
        console.log(n.text);
    } else if (n.isNumberNode()) {
        // n is NumberNode!
        console.log(n.value);
    }
});

export {};
```

## エラーメッセージを今までよりわかりやすく表示できるようになった

[Issue](https://github.com/Microsoft/TypeScript/pull/5140)

この記事中でも使ってましたが、`--pretty` をつけることでエラーメッセージが微妙に読みやすくなります。
まぁIDE使ってればあまり必要ではないでしょう。
TypeScript 2.0あたりでこちらの挙動をデフォルトにしてほしいですね。

## --project の引数にディレクトリ以外もとれるようになった

[Issue](https://github.com/Microsoft/TypeScript/issues/2869)

今まで、`--project` ないし `-p` では、ディレクトリの指定しかできず、設定ファイル名はtsconfig.json固定でした。
TypeScript 1.8からはtsconfig.json以外の名前でも、ファイル名まで指定することでイケるようになりました。
tsconfig.json1つで全ての.tsファイルを賄う事(= 今までと同じ範囲での運用)をお勧めしますが、protractorなど完全に本体コードから切り離されたTypeScriptコードがある場合、もしかしたら役に立つかもしれません。

## tsconfig.json中にコメントが書けるようになった

[Issue](https://github.com/Microsoft/TypeScript/issues/4987)

表題の通りです！

つらい。必要なのはわかるが…。
コメント付きjsonのparse部分をtypescript packageから切り分けてないと思うのでちょっとつらい。
一般的なツールで処理する方法をなんかしら提供してほしいところだ。

## --outFileの対象に /dev/stgout とかを指定できるようになった

[Issue](https://github.com/Microsoft/TypeScript/issues/4841)

簡単に修正できるのでしました！感を感じる…！
標準出力に出せばpipeで別のツールに生成したJSコードを渡せるので場合によっては便利とかそういう。

## computed propertyの利用可能範囲が広がった

[Issue](https://github.com/Microsoft/TypeScript/issues/4653)

destructuringが絡んだ時の挙動が改善されたっぽい。
ぼくにはユースケースも読み方も理解できない(^q^)
