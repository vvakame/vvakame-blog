---
title: TypeScript 2.3 RC 変更点
date: 2017-04-11 23:58:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/d926f0e1b02397dbd5df)ものと同じ内容です。

---

追記1: plugins周りに参考Issueや @Quramy パイセンの記事へのリンクを追加。

こんばんは[@vvakame](https://twitter.com/vvakame)です。

[TypeScript 2.3 RC](https://blogs.msdn.microsoft.com/typescript/2017/04/10/announcing-typescript-2-3-rc/)がアナウンスされましたね。
[What's new in TypeScriptも更新](https://github.com/Microsoft/TypeScript/wiki/What's-new-in-TypeScript#typescript-23)されているようです。

TypeScriptの[リリースサイクルの変更](https://blogs.msdn.microsoft.com/typescript/2017/03/27/typescripts-new-release-cadence/)がアナウンスされた後の初めてのリリース候補です。

## 変更点まとめ

* `--target es3` と `--target es5` でもジェネレータが使えるようになった [Generator support for ES3/ES5](https://github.com/Microsoft/TypeScript/issues/1564)
* 非同期イテレータのサポート [Asynchronous iterators](https://github.com/Microsoft/TypeScript/pull/12346)
	* async generatorsとasync iterationのサポート
	* for-await-of のサポート
	* `--downlevelIteration` オプションの追加
* Genericsの型パラメータにデフォルトの型を設定できるようになった [Generic defaults](https://github.com/Microsoft/TypeScript/pull/13487)
	* `interface X<A, B = number> {}` こんなん書ける
* thisの型のコントロールがより柔軟に行われるようになった [Controlling this in methods of object literals through contextual type](https://github.com/Microsoft/TypeScript/pull/14141)
	* `ThisType<T>` が導入された
	* オブジェクトリテラル中の `this` の型が改善された
		* 今まで `any` だった場合、オブジェクトリテラル自体の型を指すようになる
	* prototype経由でメソッドセットする時とかもわりといい感じにしてくれるぽい
	* この挙動は `--noImplicitThis` が有効なときのみ働く
* JSXのstateless componentsとなる関数がoverloadできなかったのが直された [JSX stateless components overload resolution](https://github.com/Microsoft/TypeScript/issues/9703)
* `--strict` オプションの追加 [New --strict master option](https://github.com/Microsoft/TypeScript/pull/14486)
	* `--strictNullChecks --noImplicitAny --noImplicitThis --alwaysStrict` と等価
	* `tsc --init` で生成されるtsconfig.jsonでデフォルト有効になってた
* `--checkJs` オプションでJSコードについて型の整合性やらをチェックするようになったらしい [Report errors in .js files with new --checkJs](https://github.com/Microsoft/TypeScript/pull/14496)
	* `/// @check` でファイル毎に有効にもできるそうな
* `tsc --init` の出力が整理されてコメントとかも付くように [Enhanced tsc --init output](https://github.com/Microsoft/TypeScript/pull/13982)
* `--plugins` オプションの追加 [Language Service Extensibility](https://github.com/Microsoft/TypeScript/pull/12231)
	* ただしtsconfig.json内部の記述に限る(っぽい
	* 入力補完とかツールチップの出力に介入できるっぽい
	* これはAngular勢がアップを初めてしまうのでは…？

## `--target es3` と `--target es5` でもジェネレータが使えるようになった

そのまんまです。
次のようなコードがdownpileできるようになりました。

```ts
function* f() {
    yield 1;
    yield* [2, 3];
}
```

babelとかと同じく生成されるコードが割りと太ります。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">本日をもってMSによるWindows VistaおよびIE9のサポートが終了。IE10もサポート終了済なので、明日からはPC WebでもIE11+な世界が始まります。参考: <a href="https://t.co/yZdHtNjE6C">https://t.co/yZdHtNjE6C</a></p>&mdash; Teppei Sato (@teppeis) <a href="https://twitter.com/teppeis/status/851354134326333440">2017年4月10日</a></blockquote>

…もう `--target es2015` にしてしまってはダメですかね…？

なお、async/awaitのES3/ES5 downpileは2.1.1で出来るようになっていました。

## 非同期イテレータのサポート

1つのpull requestに含まれている変更としてはめちゃめちゃ量が多いです。

* for-of のサポート
	* Mapとか `[Symbol.iterator](): Iterator` 的なものを持ってる奴はfor-ofに突っ込めるようになった
* AsyncIterators のサポート
	* `[Symbol.asyncIterator](): AsyncIterator`
* Generators のサポート
	* やっと来たか〜という感じ でも自分のコードで書く機会少ないよね…
* Async Generators のサポート
	* 無限stream作る時に便利そう
* for-await-of のサポート
* GeneratorsやIterationのdownpile
	* `--downlevelIteration` を使うとIterator周りの処理もdownpileできる
		* 生 `Symbol.iterator` かpolyfillが必要
		* spreadとかもできる(すごい

色々なfor-ofとかspreadとか。
es5で出すには `--downlevelIteration` が必要。

```ts
const array = [1, 2, 3];
for (const v of array) {
    console.log(v);
}

const map = new Map<string, string>();
map.set("a", "b");
for (const v of map) {
    console.log(v);
}

const obj = {
    [Symbol.iterator]() {
        return g();

        function* g() {
            yield 1;
            yield* [2, 3];
        }
    },
};
for (const v of obj) {
    console.log(v);
}
const [a1, a2, a3] = obj;
```

for-await-of の例(公式より抜粋
コンパイルには `--lib esnext` が必要。

```ts
// Node.js v7.8.0 だと Symbol.asyncIterator は存在してない…
(Symbol as any).asyncIterator = Symbol.asyncIterator || Symbol.for("Symbol.asyncIterator");

function sleep(milliseconds: number) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
}

async function* getItemsReallySlowly<T>(items: Iterable<T>) {
    for (const item of items) {
        await sleep(500);
        yield item;
    }
}

async function speakLikeSloth(items: string[]) {
    for await (const item of getItemsReallySlowly(items)) {
        console.log(item);
    }
}

speakLikeSloth("never gonna give you up never gonna let you down".split(" "))

```


## Genericsの型パラメータにデフォルトの型を設定できるようになった

ｽｯと便利そうなパターンが思いつかないっちゃ思いつかないけど、Genericsの型パラメータにデフォルトの型を設定できるようになりました。
こんな感じ。

```ts
class Container<T = string> {
    data?: T;
}

const objA = new Container();
// index.ts(54,1): error TS2322: Type '1' is not assignable to type 'string | undefined'.
objA.data = 1;

const objB = new Container<number>();
objB.data = 1;
```

今までは型パラメータが何か推論できない場合、`{}`と認識されていました。
今後はその場合のデフォルトが指定できるようになりました。

## thisの型のコントロールがより柔軟に行われるようになった

オブジェクトリテラル中でのthisの型が正しく認識されるようになりました。
`--noImplicitThis` が必要です。

```ts
const obj = {
    name: "maya",
    greeting() {
        return `Hello, ${this.name}`;
    },
    compileError() {
        // error TS2339: Property 'notExists' does not exist on
        //   type '{ name: string; greeting(): string; compileError(): any; }'.
        return `Hello, ${this.notExists}`;
    },
};
console.log(obj.greeting());
```

```ts
class Sample {
    name: string;
    hello() {
        console.log(`Hello, ${this.name || "world"}`);
    }
}

Sample.prototype.hello = function () {
    // error TS2339: Property 'notExists' does not exist on type 'Sample'.
    console.log(`Hi, ${this.notExists || "world"}`);
};
```

`ThisType<T>` という特殊な型が導入され、この型が付与されている値についてthisは `T` であると制御することができます。

```ts
interface A {
    name: string;
}
interface B {
    hello(): void;
}

// objの型はBであり、obj内でのthisの型はAと明示的に指定する
const obj: B & ThisType<A> = {
    hello() {
        console.log(`Hello, ${this.name}`);
        // error TS2339: Property 'notExists' does not exist on type 'A'.
        console.log(`Hello, ${this.notExists}`);
    },
};
obj.hello();
```

## JSXのstateless componentsとなる関数がoverloadできなかったのが直された

らしいです。
あまり興味がないのでご自分で[Issue](https://github.com/Microsoft/TypeScript/issues/9703)を確認してみてください。

## `--strict` オプションの追加

`--strictNullChecks --noImplicitAny --noImplicitThis --alwaysStrict` と等価なオプションです。
`tsc --init` で生成されるtsconfig.jsonでもデフォルトで使われるようになりました。

## `--checkJs` オプションでJSコードについて型の整合性やらをチェックするようになったらしい

なんかあるらしいです。

## `tsc --init` の出力が整理されてコメントとかも付くように

こういうのが出力されるようになりました。
デフォルトで有効なのは `--target es5 --module commonjs --strict` という感じです。
何も考えずに作業を始めるとstrictな制約の元に作業をさせるようになったのはなかなか感慨深いものがあります。
より強固で美しい世界を作ろう！

```tsconfig.json
{
  "compilerOptions": {
    /* Basic Options */                       
    "target": "es5",                          /* Specify ECMAScript target version: 'ES3' (default), 'ES5', 'ES2015', 'ES2016', 'ES2017', or 'ESNEXT'. */
    "module": "commonjs",                     /* Specify module code generation: 'commonjs', 'amd', 'system', 'umd' or 'es2015'. */
    // "lib": [],                             /* Specify library files to be included in the compilation:  */
    // "allowJs": true,                       /* Allow javascript files to be compiled. */
    // "checkJs": true,                       /* Report errors in .js files. */
    // "jsx": "preserve",                     /* Specify JSX code generation: 'preserve', 'react-native', or 'react'. */
    // "declaration": true,                   /* Generates corresponding '.d.ts' file. */
    // "sourceMap": true,                     /* Generates corresponding '.map' file. */
    // "outFile": "./",                       /* Concatenate and emit output to single file. */
    // "outDir": "./",                        /* Redirect output structure to the directory. */
    // "rootDir": "./",                       /* Specify the root directory of input files. Use to control the output directory structure with --outDir. */
    // "removeComments": true,                /* Do not emit comments to output. */
    // "noEmit": true,                        /* Do not emit outputs. */
    // "importHelpers": true,                 /* Import emit helpers from 'tslib'. */
    // "downlevelIteration": true,            /* Provide full support for iterables in 'for-of', spread, and destructuring when targeting 'ES5' or 'ES3'. */
    // "isolatedModules": true,               /* Transpile each file as a separate module (similar to 'ts.transpileModule'). */
                                              
    /* Strict Type-Checking Options */        
    "strict": true                            /* Enable all strict type-checking options. */
    // "noImplicitAny": true,                 /* Raise error on expressions and declarations with an implied 'any' type. */
    // "strictNullChecks": true,              /* Enable strict null checks. */
    // "noImplicitThis": true,                /* Raise error on 'this' expressions with an implied 'any' type. */
    // "alwaysStrict": true,                  /* Parse in strict mode and emit "use strict" for each source file. */
                                              
    /* Additional Checks */                   
    // "noUnusedLocals": true,                /* Report errors on unused locals. */
    // "noUnusedParameters": true,            /* Report errors on unused parameters. */
    // "noImplicitReturns": true,             /* Report error when not all code paths in function return a value. */
    // "noFallthroughCasesInSwitch": true,    /* Report errors for fallthrough cases in switch statement. */
                                              
    /* Module Resolution Options */           
    // "moduleResolution": "node",            /* Specify module resolution strategy: 'node' (Node.js) or 'classic' (TypeScript pre-1.6). */
    // "baseUrl": "./",                       /* Base directory to resolve non-absolute module names. */
    // "paths": {},                           /* A series of entries which re-map imports to lookup locations relative to the 'baseUrl'. */
    // "rootDirs": [],                        /* List of root folders whose combined content represents the structure of the project at runtime. */
    // "typeRoots": [],                       /* List of folders to include type definitions from. */
    // "types": [],                           /* Type declaration files to be included in compilation. */
    // "allowSyntheticDefaultImports": true,  /* Allow default imports from modules with no default export. This does not affect code emit, just typechecking. */
                                              
    /* Source Map Options */                  
    // "sourceRoot": "./",                    /* Specify the location where debugger should locate TypeScript files instead of source locations. */
    // "mapRoot": "./",                       /* Specify the location where debugger should locate map files instead of generated locations. */
    // "inlineSourceMap": true,               /* Emit a single file with source maps instead of having a separate file. */
    // "inlineSources": true,                 /* Emit the source alongside the sourcemaps within a single file; requires '--inlineSourceMap' or '--sourceMap' to be set. */
                                              
    /* Experimental Options */                
    // "experimentalDecorators": true,        /* Enables experimental support for ES7 decorators. */
    // "emitDecoratorMetadata": true,         /* Enables experimental support for emitting type metadata for decorators. */
  }
}
```

## `--plugins` オプションの追加

pull requestのタイトルが `Language service proxy` となっている通り、language serviceの処理をproxyし、自分の好きな結果を挿入したり変更したりできるようになるようです。
これを利用する変更はAngularに[入っている](https://github.com/angular/angular/pull/13716)[よう](https://github.com/angular/angular/tree/master/packages/language-service)です。
今後、Angularのtemplate内で入力補完やエディタ上でのエラー表示ができるようになってくると嬉しいですね。

その他 [参考になりそうなIssue](https://github.com/Microsoft/TypeScript/issues/11976)

後はQuramyパイセンの[使ってみよう編](http://qiita.com/Quramy/items/1fc9aee235b79236775c)と[作ってみよう編](http://qiita.com/Quramy/items/ecf83ecd4093cb7d948e)も大変よかったです。 :bow: 
