---
title: TypeScript 1.7.3 変更点
date: 2015-12-01 12:00:00
tags: TypeScript
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/0441f248b349eba9e267)ものと同じ内容です。

---

TypeScript 1.7.3が出ました！
今回のアップデートは内容が少ないですね。
私はこのまま1.8に吸収されたりするんじゃないのか…と思っていたので、え、出たの？という気持ちです。
↑今回は[前回](http://qiita.com/vvakame/items/072fa78f9fe496edd1f0)のコピペではないです

変更点は[公式Blog](http://blogs.msdn.com/b/typescript/archive/2015/11/30/announcing-typescript-1-7.aspx)や[Roadmap](https://github.com/Microsoft/TypeScript/wiki/Roadmap#17)にも書かれていますが、ざっくり次のとおりです。

* [ES.nextの指数演算子の追加](https://github.com/Microsoft/TypeScript/issues/4812)
  * Stage 3になったので
* [型として`this`が使えるようになった](https://github.com/Microsoft/TypeScript/pull/4910)
  * `Polymorphic 'this' type` と表現されている
  * メソッドチェインが使いやすくなるとかそういうの
  * Function#bind とは関係ない
* [`--target es6`で`--module`が許可されるようになった](https://github.com/Microsoft/TypeScript/issues/4806)
  * 今まではes6ターゲットだと`import ... from ...`の形式での出力しか許可されていなかったが、CommonJSとかAMDとかで出せるようになった
  * external module周りだけdownpileできるようになったという認識でおｋ
* [es3ターゲットでdecoratorsが使えるようになった](https://github.com/Microsoft/TypeScript/pull/4741)
  * es3ターゲットまだメンテすんの…？？という気持ちがあるぞ！誰か使ってる？
* [async/awaitが普通に使えるようになった](https://github.com/Microsoft/TypeScript/pull/5231)
  * async/awaitがStage 3になったので `--experimentalAsyncFunctions` 無しで使えるようになった
  * --target es6でしか使えないのはそのまま es5対応は2.0(遠い未来)の予定
* [デフォルト値付き引数のでデストラクチャリングのチェックの改善](https://github.com/Microsoft/TypeScript/pull/4598)

ベストプラクティスに影響があるのは `型としてthisが使えるようになった` ですかね。
それ以外は使いたい時に使えばよさそう。

## ES.nextの指数演算子の追加

`1 ** 2` が `Math.pow(1, 2)` に展開されるだけ。

## 型としてthisが使えるようになった

```typescript
class A {
  _this: this;
  a(): this {
    return this;
  }

  d(arg: this): this {
    return arg;
  }
}

class B extends A {
  b() {
    console.log("B");
  }
}

interface C extends A {
  c(): void;
}

new B().a().b();
new B().d(new B()).b();
new B()._this.b();
(null as C).a().c();
```

こんな感じのコードが書けて、コンパイルが通る。
型注釈における `this` の振る舞いとして、呼び出し時のthisの型として解釈される。
今後、サンプル中の `_this` やメソッドの返り値の型は積極的にthisにしてしまって良いのではないかと思う。
A#dの `arg: this` 部分は例えば `new B().d(new A());` のコンパイルが通らなくなったりして制約がキツくなるので、特に必要がない限りは今まで通りにする必要もあるかと思う。

## --target es6で--moduleが許可されるようになった

```main.ts
import sub from "./sub";

sub("TypeScript");
```

```sub.ts
export default function hi(name: string) {
    return `Hi! ${name}`;
}
```

これをコンパイルしてみる。

ちなみに、なんか `export default function(){}` だと出力がバグるようだ。
[これ](https://github.com/Microsoft/TypeScript/issues/5594)とか[これ](https://github.com/Microsoft/TypeScript/issues/5844)とかっぽい。

### tsc --target es6 main.ts

今まで通りのやつ
tsc --target es6 --module es6 main.ts と等価

```main.js
import sub from "./sub";
sub("TypeScript");
```

```sub.js
export default function hi(name) {
    return `Hi! ${name}`;
}
```

### tsc --target es6 --module commonjs main.ts

```main.js
var sub_1 = require("./sub");
sub_1.default("TypeScript");
```

```sub.js
function hi(name) {
    return `Hi! ${name}`;
}
exports.default = hi;
```

### tsc --target es6 --module amd main.ts

```main.js
define(["require", "exports", "./sub"], function (require, exports, sub_1) {
    sub_1.default("TypeScript");
});
```

```sub.js
define(["require", "exports"], function (require, exports) {
    function hi(name) {
        return `Hi! ${name}`;
    }
    exports.default = hi;
});
```

### tsc --target es6 --module umd main.ts

```main.js
(function (factory) {
    if (typeof module === 'object' && typeof module.exports === 'object') {
        var v = factory(require, exports); if (v !== undefined) module.exports = v;
    }
    else if (typeof define === 'function' && define.amd) {
        define(["require", "exports", "./sub"], factory);
    }
})(function (require, exports) {
    var sub_1 = require("./sub");
    sub_1.default("TypeScript");
});
```

```sub.js
(function (factory) {
    if (typeof module === 'object' && typeof module.exports === 'object') {
        var v = factory(require, exports); if (v !== undefined) module.exports = v;
    }
    else if (typeof define === 'function' && define.amd) {
        define(["require", "exports"], factory);
    }
})(function (require, exports) {
    function hi(name) {
        return `Hi! ${name}`;
    }
    exports.default = hi;
});
```

### tsc --target es6 --module system main.ts

```main.js
System.register(["./sub"], function(exports_1) {
    var sub_1;
    return {
        setters:[
            function (sub_1_1) {
                sub_1 = sub_1_1;
            }],
        execute: function() {
            sub_1.default("TypeScript");
        }
    }
});
```

```sub.js
System.register([], function(exports_1) {
    function hi(name) {
        return `Hi! ${name}`;
    }
    exports_1("default", hi);
    return {
        setters:[],
        execute: function() {
        }
    }
});
```

## es3ターゲットでdecoratorsが使えるようになった

読んで字のごとくなんだと思う(試してない

## async/awaitが普通に使えるようになった

experimentalじゃなくなっただけといえばそれだけ。
TypeScriptでは[tc39 processのStage 3以降](https://gist.github.com/azu/460803cf1a95d90a47ed)になったものを実装していく方針らしいので、async/awaitがStage 3入りしたのでそれに対応した、という感じ。

現実的には多くのブラウザやNode.js 4未満でes6の他の要素が細々と使えないのでbabelが必要なままだろう。
`--target es6で--moduleが許可されるようになった` と組み合わせて、Node.js v4以上だけをターゲットにするならbabelなしでもいけるんじゃなかろうか(試してない

## デフォルト値付き引数のデストラクチャリングのチェックの改善

型推論がより賢くなったという感じっぽい。

## まとめ

breaking changeもない感じがするので何も考えずに1.6.2から移行していいんじゃないでしょうか。
