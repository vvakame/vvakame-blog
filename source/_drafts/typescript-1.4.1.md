---
title: TypeScript 1.4.1 変更点
date: 2015-01-17 12:00:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/69efc1c6a3b91876330d)ものと同じ内容です。

---

TypeScriptリファレンスお買い上げありがとうございます！ [Amazon](http://www.amazon.co.jp/gp/product/484433588X?ie=UTF8&camp=1207&creative=8411&creativeASIN=484433588X&linkCode=shr&tag=damenako-22) [達人出版会](http://tatsu-zine.com/books/typescript-reference)
[TypeScript in Definitelyland](http://typescript.ninja/typescript-in-definitelyland/)もよろしくオナシャス！

TypeScript 1.4.1が出ました！
今回のアップデートはかなり多くの更新を含む、大規模なアップデートであると言えます。

[公式のBlog](http://blogs.msdn.com/b/typescript/archive/2015/01/16/announcing-typescript-1-4.aspx)にも書かれているのは以下の通り。

* 型システムの改善
  * Union Types
  * Type Aliases
  * Const Enums
  * [And more...](http://blogs.msdn.com/b/typescript/archive/2014/11/18/what-s-new-in-the-typescript-type-system.aspx) (Type GuardsとGenericsの改善)
* ES6構文のサポートの開始
  * --target es6 の追加
  * Let/Const
  * Template Strings
  * Looking Ahead (async/awaitやってるらしい)

[Roadmap](https://github.com/Microsoft/TypeScript/wiki/Roadmap)上ではExport Language Service public APIと書かれているんだけどアナウンスには含まれてないな…？

あとは、Node.jsが0.12系になってくれれば僕個人としてはわりとes6に移りやすいのですけどもいつになるやら？

## 型システムの改善

### 直和型(Union Types)

TypeScript in Definitelylandで[既に書いてる](http://typescript.ninja/typescript-in-definitelyland/types-advanced.html#h4-4)ので、詳しくはそちらを参照のこと。

最初に書くが **TypeScriptで新規にコードを書く時にUnion Typesを使ってはいけない**。
何故ならば、Union Typesを使ったからってTypeScriptコードの使い勝手がよくなったりするわけではないからだ。
Union Typesは、型定義ファイルを書く時に仕方なく使うのが正しい。
(もちろん、一部例外はある。構文木を書く時などはあると便利だろう。)

例えば、以下のようなJavaScriptコードを考える。

```js
function fizzbuzz(value) {
  if(value % 5 === 0) {
    return "Fizz";
  } else if(value % 3 === 0) {
    return "Buzz";
  } else {
    return value;
  }
}

// [ 1, 2, "Buzz", 4, "Fizz", "Buzz" ] と表示される
console.log([1, 2, 3, 4, 5, 6].map(v => fizzbuzz(v)));
```

何か普通のFizzBuzzと仕様が違う気がするけどまぁ良い。
これに対して型定義ファイルを書く。
TypeScript 1.3.0までは以下のように書いていた。

```ts
declare function fizzbuzz(value: number): any /* string | number */;
```

返り値の型が、`number`か`string`で、それを表現する手法がなかったので`any`となる。

今後は普通にこう書ける。

```ts
declare function fizzbuzz(value: number): string | number;
```

また、Union Typesの導入によって[BCT(Best Common Type)](http://typescript.ninja/typescript-in-definitelyland/types-advanced.html#h4-1)の仕様が消滅した。
そのため、以下のようなコードの挙動が変わる。

```ts
// arrayの型は (number | string)[] になる
var array = [1, "str"];
```

より安全だ！
実際に要素にアクセスして利用するには、型アサーションが必要になる。
[Playground](http://goo.gl/e2JWNr)

```ts
var array = [1, "str"];
// string か number かわからんので型アサーションが必要
(<string>array[1]).charAt(1);
// これはエラーになる
array[1].charAt(1);
```

これは流石にめんどくさいし、ヒューマンエラーが入り込む余地がある。
そこで、Union Typesと併せて導入されたのがType Guardsだ。

### 型のためのガード(Type Guards)

TypeScript in Definitelylandで[既に書いてる](http://typescript.ninja/typescript-in-definitelyland/types-advanced.html#h4-5)ので、詳しくはそちらを参照のこと。

既にしっかり書いたのに記事として新規に書くのめんどくさくなってきたぞ！端折ろう！

### 型の別名(Type Alias)

TypeScript in Definitelylandで[既に書いてる](http://typescript.ninja/typescript-in-definitelyland/types-advanced.html#h4-6)ので、詳しくはそちらを参照のこと。

**interfaceと比べると機能的に劣るので極力使うな！**

### Const Enums

常にインライン展開されることが保証されているenum。
enumの実体は生成されない。コンパイラ上でのみ存在する。
TypeScriptコンパイラ内部に存在するenumはほぼconst enumに置き換えられました。

[Playground](http://goo.gl/zp4JWi)

```ts
enum Fruit {
	Apple,
	Cherry,
	Banana,
}

const enum OS {
	Linux,
	OSX,
	FreeBSD
}

var a1 = Fruit.Apple;
var b1 = OS.Linux;

var a2 = Fruit[Fruit.Apple];
// エラーになる
var b2 = OS[OS.Linux];
```

これをコンパイルするとこうなる。

```js
var Fruit;
(function (Fruit) {
    Fruit[Fruit["Apple"] = 0] = "Apple";
    Fruit[Fruit["Cherry"] = 1] = "Cherry";
    Fruit[Fruit["Banana"] = 2] = "Banana";
})(Fruit || (Fruit = {}));
var a1 = 0 /* Apple */;
var b1 = 0 /* Linux */;
var a2 = Fruit[0 /* Apple */];
var b2 = OS[0 /* Linux */];
```

tscのコンパイルオプションに`--preserveConstEnums`とか追加されてる。

### Genericsの改善

[こういうコード](http://goo.gl/OCF5OY)がコンパイル通らなくなった。
利用例からの推論に矛盾が生じた場合、エラーになる。
`(string | number)`とかに推論したりはしない。

```ts
function equal<T>(lhs: T, rhs: T): boolean {
   return lhs === rhs;
}

// Previously: No error
// New behavior: Error, no best common type between 'string' and 'number'
var e = equal(42, 'hello');
```

## ES6構文のサポートの開始

### --target es6 の追加

es3(default), es5 についで、3つ目のtargetとして追加されました。
es6を指定すると一部の言語仕様が使えるようになります。

### let, const

ES6のやつだよ！
既に巷に説明が氾濫していると思うので、そっちを見て、どうぞ。
[let](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/let), [const](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/const)

### Template Strings

[この辺見て](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/template_strings)

#### tagged template stringsじゃないやつ

```ts
var name = "vvakame";
var like = "猫";

var str = `${name}は${like}が好き`;
console.log(str);
```

`--target es6`でコンパイルした場合

```js
var name = "vvakame";
var like = "猫";
var str = `${name}は${like}が好き`;
console.log(str);
```

`--target es5`でコンパイルした場合

```js
var name = "vvakame";
var like = "猫";
var str = "" + name + "は" + like + "が好き";
console.log(str);
```

Cool！

#### tagged template stringsなやつ

```ts
function agreed(strings: TemplateStringsArray, like: string): string {
  var ret = strings[0] + like + strings[1];
  if (like === "TypeScript") {
    ret += "(わかるわー)";
  }

  return ret;
}

// 私はTypeScriptが好き！(わかるわー) と表示される
console.log(agreed`私は${"TypeScript"}が好き！`);
```

`--target es6`でコンパイルした場合

```js
function agreed(strings, like) {
    var ret = strings[0] + like + strings[1];
    if (like === "TypeScript") {
        ret += "(わかるわー)";
    }
    return ret;
}
console.log(agreed `私は${"TypeScript"}が好き！`);
```

`--target es5`でコンパイルした場合

```
$ tsc --target es5 test.ts
test.ts(11,19): error TS1159: Tagged templates are only available when targeting ECMAScript 6 and higher.
```

流石にそこまで面倒見てはくれなかった…

### ES6用型定義ファイルの同梱

Promiseとか普通に使える。
--target es6した時だけ使われる型定義ファイルがあるので、全てのターゲットで使えるわけではない。

### numberの2進数表記

[この辺](https://github.com/Microsoft/TypeScript/pull/1254)

こう書ける。

```ts
var bin = 0b0101;

console.log(bin);
```

`--target es6`でコンパイルした場合

```js
var bin = 0b0101;
console.log(bin);
```

`--target es5`でコンパイルした場合

```js
var bin = 5;
console.log(bin);
```

なお、8進数はes3限定の模様。

### shorthand property

[この辺](https://github.com/Microsoft/TypeScript/pull/1127)と[この辺](https://github.com/Microsoft/TypeScript/pull/1184)

こう書ける。

```ts
var num = 1;
var str = "str";
var obj = {num, str};
```

`--target es6`でコンパイルした場合

```js
var num = 1;
var str = "str";
var obj = {num, str};
```

`--target es5`でコンパイルした場合

```js
var num = 1;
var str = "str";
var obj = { num: num, str: str };
```

## その他

* `--noEmitOnError`が追加された
  * 今までは型の整合性エラーがあってもソースコードが出力される場合があった
  * なるべく使ったほうが良さそう
* `--suppressImplicitAnyIndexErrors`が追加された
  * インデクスアクセス時に暗黙的にanyになった場合のエラーを抑制できるようになった
  * 基本的には使わないほうがいいと思う
* TypeScriptコンパイラ本体の型定義ファイルがnpmのモジュールに同梱されるようになった。
