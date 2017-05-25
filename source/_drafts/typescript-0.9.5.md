---
title: TypeScript 0.9.5 breaking change!
date: 2013-12-10 01:31:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/d308b5d69d7b71dca470)ものと同じ内容です。

---

TypeScript 0.9.5 が先日リリースされまして。
そんでまぁ、breaking change(非互換な変更)があるわけですよ。
しょうがないね、1.0 にまだなってないもんね。

[こちら](https://typescript.codeplex.com/wikipage?title=Known%20breaking%20changes%20between%200.8%20and%200.9&referringTitle=Documentation)が 0.9.1 から 0.9.5 への非互換な変更点でございます。
この記事では、この非互換な変更点を解説し、0.9.1.1向けに書いているプロダクトの移行支援がしたいなぁ、という次第です。
また、今後TypeScriptを使っていく上でのアドバイスとして、 —noImplicitAny オプションは必ず使うようにしましょう、ということです。
これを使って開発していれば、今回の非互換な変更も引っかからずにスルーできるものが少しあります。今後、制約は増え、より堅牢なコードを自然と書けるような仕様になっていくと思いますが、その時のための転ばぬ先の杖としても役に立つと断言できます。

で、TypeScriptでコードを書くには、やはりJavaScriptのライブラリもバリバリ使うので、型定義ファイル(.d.ts)が必要になります。
この型定義ファイルを集積しているサイトで、もっともよく使われているのが[DefinitelyTyped](https://github.com/borisyankov/DefinitelyTyped)というリポジトリになります。
[TypeScript 0.9.5リリースの公式ブログ](http://blogs.msdn.com/b/typescript/archive/2013/12/05/announcing-typescript-0-9-5.aspx)でも言及されています。

12月24日によーやっとmasterが0.9.5になりました。
Igorbekさんの活躍によるところが大です。ありがとうございました！
<del>
んですが、ちょっと問題があって、0.9.5対応が[なかなか進んでいない](https://github.com/borisyankov/DefinitelyTyped/pull/1385)んです。
現在のmasterブランチはTravis-CI上で 0.9.1.1 でテストされています。0.9.5対応は switch-0.9.5 ブランチで行われていて、Travis-CIも0.9.5で動いています。
全てのテストが通ったら文句なくmasterにマージ！と相成るわけですので、こちらのブランチにpull requestが欲しいわけです。
</del>
<del>
要約：0.9.5の対応方法教えてやっから DefinitelyTyped の switch-0.9.5 ブランチにpull requestくれよ！Travis-CI全部通るようにしてくれよー！
</del>

ちなみに、筆者(わかめ)はTravis-CIのためのテストランナー周りを書きなおしてしつこくpull requestを送っていたら見るのに飽きたのか、最近コミッタにしてもらいました。
なので、GitHub上で議論にならない限りは、Twitterで日本語でサポートもできるのでお気軽にお問い合わせください。GitHub上で議論になったら頑張って英語で戦ってください(辛

もし、筆者の理解に誤りがあった場合は早めに教えていただけると大変喜びます。:;(∩´﹏`∩);:

## Genericsとかの型引数のデフォが any から {} になった

### 今まで

型引数がうまく推論できない場合、any が推論されていた。

### これから

型引数がうまく推論できない場合、{} が推論される。
{} は var a = {}; とした時の typeof a と同じもので、要するに何もプロパティを持たないので自由度がアホみたいに低い型を指します。

コレについて0.9.1.1と0.9.5でどういう差があるかわかるコードを作ってみようとしたのですが、案外0.9.1.1でもちゃんと弾いてくれちゃって思うようにいかないというね…。

## オブジェクトに対する明示的なインデクサアクセスを許さないようにした

### 今まで

Object(ここではEnum)に対してインデクサを使ってデータにアクセスできていました。
この場合だと、Colorsの定義に`test`は含まれないため`undefined`が得られます。

```typescript:enum.ts
function useEnum(e: { [idx: string]: any}) {
    return e["test"];
}

enum Colors { Blue, Green, Orange }

useEnum(Colors);  //errors in 0.9.5, but has no error in 0.9.1.1
```

### これから

コード内の型カバレッジを強化するために使えなくなりました。型カバレッジって表現すげーな。

ちなみに、以下のようにすれば一応回避することができます。

```typescript:enum.ts
function useEnum(e: { [idx: string]: any}) {
    return e["test"];
}

enum Colors { Blue, Green, Orange }

useEnum(<any>Colors);  // まぁ any にしてしまえば…
```

こういう方法もあります。e を Colors そのものにしてしまうわけですね。
e: Colors にすると、Colors全体ではなくColorsの1要素しか受け取れません。

```typescript:enum.ts
function useEnum(e: typeof Colors) {
    return e["test"];
}

enum Colors { Blue, Green, Orange }

useEnum(Colors);  // まぁ any にしてしまえば…
```

TypeScriptの型推論さんはかなり頑張ってくれるので、`”test”`の部分を`”Blue”`とか、ホントに含まれている値にすると、正しくNumberと推論してくれます。`”test”`だとColorsに存在しないので any (undefined) になります。

## any が {} のサブタイプではないようにした

### 今まで

any は {} のサブタイプになることができたようです。
any はTypeScriptの仕様上、全ての型のスーパークラスとされているはずなのですが、any は {} のサブタイプであり、スーパークラスでもある、って、微妙に倒錯してませんかね…。

ともあれ、以下のようなコードが許されていました。

```typescript:sample.ts
interface MyOptionals {
    optional1?: number;
    optional2?: boolean;
}

interface MyInterface {
    call(): MyOptionals;
} 

class MyClass implements MyInterface { 
    call(): any {
        return null;
    }
}
```

MyClassはMyInterfaceを実装していることになっています。

### これから

これからはダメです！

```typescript:sample.ts
interface MyOptionals {
    optional1?: number;
    optional2?: boolean;
}

interface MyInterface {
    call(): MyOptionals;
} 

// MyClass does not implement MyInterface 
class MyClass implements MyInterface { 
    call(): any {
        return null;
    }
}
```

ちなみにこうするとコンパイル通ります(通るけど実用的ではない…

```typescript:empty.ts
class MyClass implements MyInterface { 
    call(): {} {
        return null;
    }
}
```

具体的な事例として以下のようなパターンがある。

```typescript:lib.d.ts
interface DOMStringMap {
}

interface HTMLElement {
    dataset: DOMStringMap;
}
```

```typescript:swipeview.d.ts
interface PageHTMLElement extends HTMLElement {
    dataset: any;
}
```

えぇい、lib.d.ts は組み込みだからいじくれないし、どうせいっちゅーんじゃ…！！

## オーバーロードの解決規則が変わった

### 今まで

超頑張って一番一致するの探してた(っぽい

### これから

純粋に字句的に上にあるものから順にマッチするか試していって、最初に見つかったやつにマッチしたことにする。
そのため、specialized signatureが既存のままだと動かなかったりする。

```typescript
class HTMLElement {}
class HTMLSpanElement extends HTMLElement {
    iAmSpan():void{}
}

declare class Document {
    // “span” が string の下にあると、先にstringにマッチしちゃうので “span” の定義のほうが必ず上にこないといけない
    createElement(tag: "span"):HTMLSpanElement;
    createElement(tag: string):HTMLElement;
}
```

で、シンプルでわかりやすくて良いんだけど、Igorbekさんが[言及している](https://typescript.codeplex.com/discussions/472172)通り、複数の型定義ファイルから1つのinterfaceをいじくった場合に、どう頑張っても有効にできないシグニチャが出てきて困る… みたいな事例があるので、これはちょっと直して欲しい感じあります。

追記：議論のかいあり、1.0 では後からmergeしたインタフェースの定義のほうが優先度が高く扱われるように仕様が修正されることになり、問題は解決されそうです( https://typescript.codeplex.com/wikipage?title=Known%20breaking%20changes%20between%200.8%20and%200.9 )。

## rest argument(可変長引数)を使った定義の上書き規則が変わった

### 今まで

こういうコードが許されていた。元の定義は全て可変長引数なので、1番目の引数も2番目の引数も、渡されない(undefinedになる)可能性がありました。

```typescript:rest.ts
function myFunction(f: (...args: string[]) => void) { }

myFunction((x, y) => { }); //0.9.1.1
```

### これから

1番目の引数と2番目の引数が省略されうる(undefinedになる)可能性を省略せずコード上に表明しないといけないようになりました。

```typescript:rest.ts
function myFunction(f: (...args: string[]) => void) { }

myFunction((x?, y?) => { }); //0.9.5
```

追記。
basaratの[提案](https://github.com/borisyankov/DefinitelyTyped/pull/1435) では、今後こういう時は単に `f: Function` としたほうがいいだろう。という意見。なるほど確かに。

## Arrow Functionの即値評価の仕様をES6にあわせた

TypeScriptはECMAScript 262 5.1 をベースにした言語ですが、一部ES6の仕様も取り込んでいます。
そのため、あちらさんの変更に追従したようです。
アロー関数式を使った時に即値評価(即実行)する時の仕様ですね。
JavaScriptでは`(function(){ return 5; })()`と書くことが必須だったので、まぁ今まで通りで混乱がなくていいかな、という印象です。

```typescript:arrow.ts
var f1 = () => { return 5 }();  // Error now, used to be OK in 0.9.1.1
var f2 = (() => { return 5 })(); // OK in 0.9.1.1 and 0.9.5
```

## --noResolveと外部モジュールのインポートが同時にできなくなった

外部モジュールっていうのは `declare module “hoge” {` みたいな定義の仕方してたやつですね多分。
—noResolveオプションと組み合わせた時に正しいコード生成を行えるようにするためにこの制約が追加されたようです。
—noResolve 使ったことない…。

## 終わり

以上です！ね？簡単でしょう？
みんなも頑張って .d.ts のアップデートしてくださいなんです＞＜
