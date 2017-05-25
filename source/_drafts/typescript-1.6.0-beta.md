---
title: TypeScript 1.6.0-beta 変更点
date: 2015-09-04 04:01:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/072fa78f9fe496edd1f0)ものと同じ内容です。

---

TypeScript 1.6.0-betaが出ました！
今回のアップデートはかなり多くの更新を含む、大規模なアップデートであると言えます。
↑ここまで[前回](http://qiita.com/vvakame/items/9b9fde6c71aae6a824c0)のコピペ

だからlatestタグで `-beta` を出すんじゃねぇって言ってんだろ(#ﾟДﾟ)ｺﾞﾙｧ!!
と思わなくもないですが、出たら出たで嬉しいものです。

**追記**
<blockquote class="twitter-tweet" data-cards="hidden" lang="ja"><p lang="ja" dir="ltr"><a href="https://twitter.com/vvakame">@vvakame</a> npm@2.11.2で、pre-release version(= tag付きのversion)をmatchさせるのを止めたようです。docsには元よりそう書いてあったっぽく、patchという認識。 <a href="https://t.co/rygKxlYRE7">https://t.co/rygKxlYRE7</a></p>&mdash; Daijiro Wachi ☕ (@watilde) <a href="https://twitter.com/watilde/status/640152117370425344">2015, 9月 5</a></blockquote>

なので、`npm install typescript` だと1.5.3が入って、`npm install typescript@latest` だと1.6.0-betaが入るらしいです。
なるほど…。

**追記終わり**

1.5.3リリースからたった1ヶ月強で出たので驚きですね。
その割には盛りだくさんなアップデートとなっていて、どんだけ1.5.3の準備できた後にリリースせずに貯めてたんだ(#ﾟДﾟ)ｺﾞﾙｧ!!

変更点は[公式Blog](http://blogs.msdn.com/b/typescript/archive/2015/09/02/announcing-typescript-1-6-beta-react-jsx-better-error-checking-and-more.aspx)や[Roadmap](https://github.com/Microsoft/TypeScript/wiki/Roadmap#16)にも書かれているが、ざっくりイカの通り。

* [ES6 Generatorsのサポート](https://github.com/Microsoft/TypeScript/issues/2873)
* [ローカル型のサポート](https://github.com/Microsoft/TypeScript/pull/3266)
	* ローカルスコープの扱いはlet, constと同じブロックスコープ
	* 関数内部でenum, class, interface, type aliasなどを定義できる
* [Generic type aliasのサポート](https://github.com/Microsoft/TypeScript/issues/1616)
	* type aliasにGenericsが使えるようになった
* [Classのextends対象に式が使えるように](https://github.com/Microsoft/TypeScript/pull/3516)
	* めっちゃキモいけどまぁJS的にはできてもいいよね… という感じ
* [Class定義式のサポート](https://github.com/Microsoft/TypeScript/issues/497)
	* 今まではstatementだったはず…
* [`--init` オプションの追加](https://github.com/Microsoft/TypeScript/issues/3079)
	* tsconfig.jsonの生成ができるようになった
* [tsconfig.jsonにexcludeプロパティ追加](https://github.com/Microsoft/TypeScript/pull/3188)
	* filesGlobみたいなのが不要になった
* [ユーザ定義のtype guard](https://github.com/Microsoft/TypeScript/issues/1007)
	* boolean返すついでに引数になった値の型を教えてやることができるようになった
* [外部モジュールの解決方法の改善](https://github.com/Microsoft/TypeScript/issues/2338)
	* ついでにnpmパッケージのrootのindex.d.tsが自動で参照されるようになった
* [JSX サポート](https://github.com/Microsoft/TypeScript/pull/3564)
	* WebComponents推進派のわかめさん的にはマジでいらねぇ
	* なんでか、 `as` による後置キャストもここで追加された
* [Intersection typeのサポート](https://github.com/Microsoft/TypeScript/pull/3622)
	* 型Aと型Bを合成した型が欲しい…！という要望に応えられるようになりました
* [abstract classのサポート](https://github.com/Microsoft/TypeScript/issues/3578)
	* わぉ！protectedとかprivateはいらないよ派だけどabstractはあってもいい！
* [より厳密な即値オブジェクトリテラルのチェック](https://github.com/Microsoft/TypeScript/pull/3823)
	* 厳密さという意味ではすごい便利になってるんだけどマジでstrictなので辛そう
* [定義の統合をクラス・インタフェースに提供](https://github.com/Microsoft/TypeScript/pull/3333)
	* [Class Decomposition](http://www.typescriptlang.org/Handbook#writing-dts-files)はいらなくなったかもしれない

うーん、まじかよ！盛りだくさんですね。
順番に見て行きましょう。

## ES6 Generatorsのサポート

まぁ普通にES6の解説とか探してみてください！で十分だと思うのでばっさり省略。
型周りでなにか疑問があればコメントに書いてもらえれば調べて書きます。

downpileの機能は(今のところ)ないので、`--target es6` 限定です。

## ローカル型のサポート

ローカルスコープの扱いはlet, constと同じブロックスコープ。
関数内部でenum, class, interface, type aliasなどを定義できます。

```localTypes.ts
{
	class Test {
		hi() { return "Hi!"; }
	}

	console.log(new Test().hi());
}
{
	class Test {
		hello() { return "Hello!"; }
	}

	console.log(new Test().hello());
}
// error TS2304: Cannot find name 'Test'.
// new Test();
```

なるほど。

```localClass.ts
function returnTestClass() {
	return class Test {};
}

let TestA = returnTestClass();
let TestB = returnTestClass();

// false と表示される
console.log(TestA === TestB);

let objA = new TestA();
// true と表示される
console.log(objA instanceof TestA);
// false と表示される
console.log(objA instanceof TestB);
```

評価するたび新しいclassを返すので、字面的には同一のものっぽく見えるが毎回新しいclassが帰ってくる。
そりゃそうですね。

特別な理由が思いつかない限り、今まで通り、トップレベルでの定義を使っていったほうが良いでしょう。

## Generic type aliasのサポート

昔mizchi君が欲しがってたやつ。
type aliasにGenericsサポートが入りました。

```genericsAlias.ts
// --target es6でコンパイルするか、適当にPromiseを解決する
// DefinitelyTypedからes6-promise持ってくるか、TypeScript同梱のlib.es6.d.tsを参照する

type PromiseValue<T> = Promise<T> | T;

function addOne(num: PromiseValue<number>) {
	return Promise.resolve(num).then(num => num + 1);
}

addOne(1).then(v => console.log(v));
addOne(addOne(1)).then(v => console.log(v));
// 2 と 3 が表示される

// 以下はちゃんとコンパイルエラーになる
// addOne("test").then(v => console.log(v));
// addOne(Promise.resolve("test")).then(v => console.log(v));
```

## Classのextends対象に式が使えるように

ちょっと何を言っているかわからない気がするが、以下のコードを見て欲しい。

```classExtendsWithExpression.ts
interface TestConstructor {
	new (): Test;
}
interface Test {
	str: string;
}
declare let Test: TestConstructor;

class Sample extends Test {
	num: number;
}

let obj = new Sample();
obj.str;  // OK
obj.num;  // OK
obj.bool; // Property 'bool' does not exist on type 'Sample'.
```

これが許されるようになりました。
今まで、extendsの右辺値に来るのはclassだけでした。
そのため、拡張性のために[Class decomposition](http://www.typescriptlang.org/Handbook#writing-dts-files)で定義されていたclass"のような"ものは継承できなかったのです。
Class decompositionというのは、先の例のようにclassのstatic部分を表現するinterfaceとinstance部分を表現するinterfaceをワンセットにして表現する方法です。
TypeScript組み込みの、ArrayやらRegExpやらも全てClass decompositionで定義されていたために今までは容易には拡張できませんでした。
それが大幅に改善された！素晴らしい！

一応、extendsの右辺値には、コンストラクタシグニチャを持ち、コンストラクタシグニチャの返り値の型がclassかinterfaceなものじゃないとならないようです(なのでtype aliasとかはダメ)。

```extendsWithImmediateFunction.ts
// https://github.com/Microsoft/TypeScript/pull/3516 より翻案
class ThingA {
	getGreeting() { return "Hello from A"; }
}

class ThingB {
	getGreeting() { return "Hello from B"; }
}

class Test extends (() => Math.random() > 0.5 ? ThingA : ThingB)() {
	sayHello() {
		console.log(this.getGreeting());
	}
}

// Hello from A ✕ 3 または Hello from B ✕ 3 が表示される
new Test().sayHello();
new Test().sayHello();
new Test().sayHello();
```

こういうのも書けるけど流石にこんなものは欲しくはない…。

誤解のように断っておきますが、こんな変態風コードが書けるのはES6が変態なのであってTypeScriptちゃんは無理やりやらされてるだけです。

## `--init` オプションの追加

tsconfig.jsonという、TypeScriptなプロジェクトについてどうコンパイルするべきかを設定するファイルがあります。
これは、より良いエディタのサポートやコンパイル方法の共有に便利です。

今までは、どこかからコピペしてくるかatom-typescriptに作らせるか、grunt-tsconfig-updateやgulp-tsconfig-updateを利用して初期設定を生成する必要がありました。
1.6.0-beta以降では `tsc --init` を実行することでtsconfig.jsonが生成されるようになりました。

```tsconfig.json
{
    "compilerOptions": {
        "module": "commonjs",
        "target": "es3",
        "noImplicitAny": false,
        "outDir": "built",
        "rootDir": ".",
        "sourceMap": false
    },
    "exclude": [
        "node_modules"
    ]
}
```

うーん、デフォルトの設定としては本当に最低限ですね。
tscに渡せるコマンドライン引数はtsconfig.jsonに記述することが可能です。
詳しくは[本家wiki](https://github.com/Microsoft/TypeScript/wiki/tsconfig.json)を参照してください。
わかめ的には、`noImplicitAny`はtrueをデフォルトにしておいてほしかったですね…。

## tsconfig.jsonにexcludeプロパティ追加

TL;DR
filesGlobとかtsconfig-updateはポイしてexcludeプロパティに除外したいルールを書いておこう！

TypeScript 1.5.3までは、コンパイル対象のファイルをfilesプロパティに1ファイルずつ手作業で記述しなければならず、幾人ものTypeScript利用者を発狂に追いやってきました。
[atom-typescriptではfilesGlob](https://github.com/TypeStrong/atom-typescript/blob/master/docs/tsconfig.md#filesglob)という方法を用意したり、[lacoにtsconfig-updateパッケージを作ってもらった](http://qiita.com/laco0416/items/a51b7534ddc4aec63875)りしていたのですが、`exclude`プロパティが本家に導入され、利用したくない、除外したいファイルだけを書いておくと、それ以外のファイルが自動的に対象になるようになりました。

この辺りの話については近日中にどっかにまとめます。

## ユーザ定義のtype guard

ユーザ定義のtype guardを書けるようになりました。
ユーザ定義以外のtype guardについては[こちら](http://typescript.ninja/typescript-in-definitelyland/types-advanced.html#h4-5)を参照してください。

```userDefinedTypeGuard.ts
interface TextNode {
	text: string;
}

interface NumberNode {
	num: number;
}

function isTextNode(node: any): node is TextNode {
	return node && typeof node.text !== "undefined";
}

let node: TextNode | NumberNode;

node = { text: "test" };
if (isTextNode(node)) {
	// TextNode に絞りこまれている！
	console.log(node.text);
}

node = { num: 1 };
if (isTextNode(node)) {
	// false なのでここに到達しない
	console.log(node.text);
}
```

便利ですね。
必要な局面は少ないと思いますが、あると確実に便利です。

## 外部モジュールの解決方法の改善

今まで、TypeScriptはNode.js(CommonJS)に於ける名前解決の方法があまり"らしく"なくて、本当であれば `require("./lib")` と書けるところを `require("./lib/index")` とか書かなければいけなかったりしました。
これが改善され、Node.jsでのロードの規則に沿うようになったようです。
[Issueの擬似コード](https://github.com/Microsoft/TypeScript/issues/2338#issue-60991541)がわかりやすかったので読めばいいと思います！

特記すべき特徴として、package.jsonに `typings` というフィールドがあった場合、そこに書かれている型定義ファイルをそのモジュールの型定義として参照してくれるようです。
もしくは、パッケージのrootディレクトリに `index.d.ts` を置いておいても解決されそうに見えます。
お好みのほうを使うと良いのではないでしょうか。

1ライブラリ=1型定義ファイルの制約が崩れたことになるので、かなり嬉しいですね！
あれがナシでよくなるとdts-bundleが不要になるかも…！
実験してみないとわかりませんが、だいぶ自然な運用ができるようになりそうです。

**追記**

実際に[commandpost](https://www.npmjs.com/package/commandpost)と、その利用ライブラリで試してみました。
まず、`--module commonjs`が必須です。`umd`とかを指定すると旧来のmodule lookupが使われてしまい意図通りに動きません。
また、`foo.d.ts`より`foo.ts`が優先的に発見されてしまうため、他ライブラリのtsファイルをコンパイルしようとします。
これはちょっといただけませんね…。
他ライブラリ内のreference pathもきっちり参照されてしまうので読み込まれる型定義ファイルのコントロールが難しい…。

## JSX サポート

JSXサポートが入りました。
拡張子は`.tsx`です。
サーバ側をNode.jsで書きたいとは思わないしReactがよりよいコンポーネント化の促進とエコシステム内における再利用性の向上とか全然達成してくれないと思うしわかめさんはWebComponentsに流行ってほしいと思うのでJSXサポートとかマジでいらないと思います。

また、なんでか後置キャストとして `as` がサポートされるようになりました。

```asOperator.ts
// 以下2つは等価
let obj1 = <any>{};
let obj2 = {} as any;
```

## Intersection typeのサポート

Twitterで教えてもらった所によると、交差型と日本語では呼ばれているそうです。
`{ str: string; }` と `{ num: number; }` を悪魔合体すると `{ str: string; num: number; }` なんじゃよ！みたいな。

```intersectionType.ts
interface A {
	str: string;
}
interface B {
	num: number;
}
type C = A & B; // intersection!!

// Bと互換性がない。numがない。
// let objA: C = { str: "A" };
// Aと互換性がない。strがない。
// let objB: C = { num: 2 };
// OK
let objC: C = { str: "A", num: 2 };
```

一見、なんの役に立つかわからないと思いますが、JavaScriptの場合"勝手にメソッドを生やして返してくる関数"というのが案外います。
以下に、ウロオボエのAngularJSの$resourceっぽいコードで便利さを示します。

```usefulIntersectionType.ts
// 今までの書き方
declare namespace angular.resource1 {
	interface ResourceProvider {
		create<T extends Resource<any>>(): T;
	}

	interface Resource<T> {
		$insert(): T;
	}
	var $resource: ResourceProvider;
}
// 上の定義を使ってみる
namespace sample1 {
	interface Sample {
		str: string;
	}
	// SampleResource の作り方をよく知っていないといけない…！どういうトリックかわかるだろうか？
	interface SampleResource extends Sample, angular.resource1.Resource<Sample> {}

	let $obj = angular.resource1.$resource.create<SampleResource>();
	$obj.str = "test";
	let obj = $obj.$insert();
	console.log(obj.str);
}

// これからの書き方
declare namespace angular.resource2 {
	interface ResourceProvider {
		create<T>(): T & Resource<T>;
	}

	interface Resource<T> {
		$insert(): T;
	}
	var $resource: ResourceProvider;
}
// 上の定義を使ってみる
namespace sample2 {
	interface Sample {
		str: string;
	}

	// 超簡単…！！
	let $obj = angular.resource2.$resource.create<Sample>();
	$obj.str = "test";
	let obj = $obj.$insert();
	console.log(obj.str);
}
```

## abstract classのサポート

サポートされました。
protectedとかprivateとかは使ってませんでしたが、これは使う機会があるかもしれないですね。
やはり子に実装を強制できるのは良い…！

```abstractClass.ts
abstract class AbstractTest {
}
// Cannot create an instance of the abstract class 'AbstractTest'.
// let obj = new AbstractTest();
// OK!
let obj = new class extends AbstractTest {} ();

// メソッドもabstractにできる
abstract class Test {
	abstract hi(): string;
	sayHi() {
		console.log(this.hi());
	}
}

new (class extends Test {
	hi(){
		return "Hi!";
	}
})().sayHi();
```

(なんかclass expressionの挙動おかしい気がするので[Issue投げた](https://github.com/Microsoft/TypeScript/issues/4630))

## より厳密な即値オブジェクトリテラルのチェック

TL;DR
あるパターンで型定義ファイルにないプロパティ書いとくとめっちゃ怒られるようになった。

割と辛い変更なんですが、堅牢さは確実に向上します。僕の感想としては、結構な荒療治です。
また、型定義ファイルが未完成だと困るパターンが増えましたので、みんなでモリモリ改善していきましょう！
[DefinitelyTyped](https://github.com/borisyankov/DefinitelyTyped)へのpull requestお待ちしています！！

```objectLiteralAssignment.ts
// 足りてない！ (今までもダメだった)
let objA: {str: string;} = {};

// 多すぎる！ (1.6.0-betaからダメ) オブジェクトリテラルは既知のプロパティのみ可だよ！
// Object literal may only specify known properties, and 'num' does not exist in type '{ str: string; }'.
let objB: {str: string;} = { str: "", num: 1 };

// 一旦別の変数に入れてからなら、プロパティが多すぎても怒られない。
let objC: {str: string;};
let objD = { str: "", num: 1 };
objC = objD;
```

これが役に立つ例を見て行きましょう。

```objectLiteralAssignmentWithRealWorld.ts
interface FooOptions {
	fileName?: string;
	checkBar?: boolean;
}

declare function foo(opts: FooOptions): void;

// fileName の大文字小文字を間違えている！
// Object literal may only specify known properties, and 'filename' does not exist in type 'FooOptions'.
foo({
	filename: "vvakame.txt",
	checkBar: true
});
```

ありがちなミスですね。
これはTypeScript 1.5.3までは検出できないミスでした。信頼性の向上！
しかし、型定義ファイル側は今まで以上に網羅性や、intersection typeやtype aliasなどのTypeScriptの知識を活用した正しい定義作りが求められるようになってしまいました。
とりあえず、型定義ファイルのテストのためのコードをもりもり書き、公式のexampleはコンパイルが通る状態になっていると素晴らしい！状態といえるでしょう。

## 定義の統合をクラス・インタフェースに提供

これも待ち望まれていた機能を言えるでしょう。

```mergeClassDeclarations.ts
// ambient class だけ！
declare class Test {
	str: string;
}

interface Test {
	num: string;
}

let obj = new Test();
obj.str;
obj.num;
```

やったぜ！classの定義を後から拡張できました。
これまで、型定義ファイルで素直にclassを使うかinterface(class decomposition)を使うかは拡張できない or 継承できないのトレードオフですが、両者の垣根がなくなり、便利になりました。
classで定義した場合、static methodを後から増やす方法が今のところなさそうなので、今後はclass decompositonを使うのが主流になるかもしれません。

## 番外編 その1

`default`でexportした時の出力結果がbabelフレンドリーになりました。
僕が実装しました。
えへん。俺babel使わないけど…。

```exportDefault.ts
export default 1;
```

```exportDefault.js
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = 1;
```

## 番外編 その2

[DefinitelyTypedの1.6.0-beta対応](https://github.com/borisyankov/DefinitelyTyped/pull/5590)もう終わってます！ほめてほめて
中の人である @DanielRosenwasser がだいぶ計画的に前々から "より厳密な即値オブジェクトリテラルのチェック" 対応のpull requestをくれていたので割りとeasyモードでした。
大感謝！

## 終わりに

今回公式サイトとRoadmapと自分の記憶を頼りに項目を拾い上げたので、抜け漏れあったら誰か教えてください。
とりあえず眠いので寝る！朝4時だよ今。
