---
title: オープンソースプロジェクトで上手いことやってくための10の方法
date: 2015-01-01 03:00:00
tags: OSS
---

本記事は[Qiitaに書いた](http://qiita.com/vvakame/items/6dd8937806e5fab5b0b7)ものと同じ内容です。

---

何も考えずに書き始めたけど10の方法って書いちゃった。
いくつになるかはわかりません。
一般的なプロジェクト運用でもある程度同じ方法論でイケると思います。

なお、筆者である[vvakame](https://twitter.com/vvakame)は[DefinitelyTyped](https://github.com/orgs/DefinitelyTyped/people)のメンテナをしています。
そのため、これから先の文章について、TypeScriptやJavaScript関係固有の事象が含まれていると思います。
書かれている内容について、contributeする側、される側、両側へのアドバイスを書きます。

ちなみに、わかめ的には[TOMOYO Linuxに学ぶ説得術](http://d.hatena.ne.jp/hyoshiok/20090704/p1)とかはすごい参考になりました。

# こまけぇことはいいんだよ！まずはやろう！

貴方が世界に存在するためにはまず誰かに存在を知ってもらわなければいけません。
pull requestを出そう！無理だったらIssueを書こう！
まずはそこからだ！！

pull requestのmergeを拒否されたとしても、ちょっと悲しいだけで特に損をするわけではありません。
最初のうちはわけもなく恥ずかしさとかを感じた気になったりするかもしれませんが、電車に乗ってる時にお腹が痛くなってきた時に比べればなんてことはありません。

# 英語を使う

頑張りましょう。
基本的にみんな優しいので、こっちが変な英語を書いても、意味がそれなりに汲み取れれば何も問題にはなりません。
最終的にはコードで語りましょう。
英語でちゃんと説明できたか不安な時は、サンプルコード書いて、コードにコメント英語でちょいちょい入れて、「ここが辛い」とか「こうすると良さそう」とか一言添えるだけでとりあえずなんとかなります。

日本人同士の会話でも、後から来た人が理解できるよう、なるべく英語でやります。
どうしても日本語を使いたい場合、Twitterとかを使って直接連絡する場合がちょいちょいあります。
その場合も、GitHub上に残す証跡として英語でサマリを書いておきます。

# 敵はどこにもいない

オープンソースプロジェクト上で関わりが生まれる人は、全員敵ではありません。
喧嘩したり、主張がぶつかり合ったりする時もあるでしょうが、敵ではないのです。
仲間か、悪く言っても好敵手くらいのもんでしょう。

そこをうまくやるためのコツとして、主語を I ではなく We にします。
「俺はこれが正しいと思う！」より、「私達はこうするのが正しいと思う。」とします。
前者はただの主張の表明にすぎません。
後者はこれから行う意見のすり合わせの予告です。

この後は必ず「なぜなら△△だからである。」と続くと思います。
主語が I の場合、"自分が理解している理屈"が△△に入るでしょう。
相手がどう感じるかはわかりません。
主語が We の場合、"相手に理解してほしい理屈"が△△に入るでしょう。
相手が共感できればOK、できなかった場合、質問を受け取ることができるでしょう。

# 相手に敬意を払う・おもてなしの心

## contributeする側

困ってもあんまり怒ってIssueとか書いたりしないようにしましょう。
怒るんじゃなくて、相談するのです。
あなたが困っていて、それが他の人にも起こりうるとわかってもらえたら、ちゃんと対応してもらえるでしょう。
そうではない場合、もしかしたら「StackOverflowで聞け」などのアドバイスが貰えるかもしれません。
謝意を伝えて、アドバイスに従うのがよいでしょう。

## contributeしてもらう側

そもそも、pull requestをくれたりする人というのは、大変優しい行為を行ってくれる人なので、アザッス！という気持ちを胸に応対しましょう。
これは、相手を非難しないようにしようね、ということであって、批判してはいけない、という意味ではありません。
相手はなにか困ったり不便に思ったからアクションを起こしてきたのです。
なるべくならば、解決してあげたいものです。

欧米人(というくくりでいいのか？)の会話術に、「その意見はいいね！でも、○○という問題点があるので、××にしたらどうかな？」みたいなのがある気がします。
この言い回しは、問題を他人事にせず、俺達事として解決するために有効だと思います。

# emoji強い

とりあえず :+1: か :-1: をつけとけば間違いなくどういう立場かは伝わる。
[http://www.emoji-cheat-sheet.com/](http://www.emoji-cheat-sheet.com/)便利。

# 利用者を守る

ライブラリやツールなどを提供している時、既存の利用者を守る、というのは大事なことです。
具体的に、破壊的変更を気軽に行ったり、取り込んではいけません。
"改善だったらなんでもかんでもやっていいわけではない"という意味です。
そういった変更が含まれるpull requestは、おそらくmergeされることはないでしょう。

自分の使っているツールやライブラリがある日バージョンアップしたら動かなくなってしまった！というのは、ユーザとしては非常に強いストレスを感じます。
そういうのは、メジャーバージョンアップをする時だけにしましょう。
できれば、migrate用のドキュメントも書きましょう。めんどいけど。

# GitHubの仕様をよく理解する

具体的に以下の事をやられると地味に辛いです。
ただまぁ、やらないでくれると嬉しいなー、くらいなので、やっちゃっても大丈夫！
「それしんどいからこうしてくれ…」と言われたら素直に従いましょう。

* pull request出した後に、変更する度にcloseしてpull requestを出し直す
  * 普通に追加pushしてくれればpull request側に自動で反映されるから！
* 無関係なdiffが紛れ込む
  * pull request送る前のプレビューで、無関係なファイルがdiffに紛れ込んでたらrebaseしなおして綺麗にしてから送る
  * レビュアー的に空白diff系は[?w=](http://qiita.com/awakia/items/6a7028aa46928e376f32)で回避できる
* push -f を使う
  * 新しいコミット追加した後にsquashしてpush -fするのは全体をレビューしなおしになるのでだるい
    * ついでにソースコードに対してinlineでつけたコメントが消える(はず？
  * rebase して push -f も同じく困った気がする
* 相互に関係のない変更を1つのpull requestに突っ込む
  * 可能な限り分割してほしい
  * 個別にmergeするのがめんどくさいので全体まとめてrejectかmergeになりがち
  * レビューのコストやコメントでやりとりしたあとの再レビューコストも高いのでめんどくさくて放っておきたい気持ちになる事も
* 誰か自分のコメントを見てほしい人がいる場合、mentionを送る @vvakame など
  * 単純に見てもらえる確率があがります ping がこない限りほっとく というスタイルの人もいます
* レビューした後に修正してほしい箇所があった場合、[タスクリスト](https://github.com/blog/1375%0A-task-lists-in-gfm-issues-pulls-comments)を上手に使うと楽

一番いいのは、自分のリポジトリをGitHubに置いて、色々やってみることです。
1人でpull request出して、1人でmergeしてみたっていいんですよ！！

# ローカルルールに従う

ローカルルールには従いましょう。
Node.js界隈でのルール、そのプロジェクトでのルール、色々なレイヤーの色々なローカルルールがあります。

ローカルルールには意味があります。
プロジェクトでのルールは大抵、README.mdかCONTRIBUTING.mdなどにまとめられていると思うので目を通します。

逆に言うと、ローカルルールを整備しておくことで、"このルールを見てくれ！"と言うだけで色々と済ませることができます。
便利です。
DefinitelyTypedでは[この辺](http://definitelytyped.org/guides/contributing.html)にまとまってたりします。

理不尽なローカルルールが設けられている場合、たぶんそのリポジトリはバカが管理しているので利用を避けましょう。

# 人には好み、主義・主張がある

人には好み、主義・主張があります。
それは、話して変えられる場合もありますが、変えられない場合のほうが多いです。
自分の主張が受け入れられなかった場合、諦めましょう。
議論を切り上げてもいいですし、自分でforkを作ってもいいと思います。

これは、自分についても言えます。
自分には好みがあり、主義・主張があります。
なので、誰に何を言われようとも、嫌なことはやらなくてよいのです。
契約結んでたりお金貰ってるわけじゃないからね。
ただし、これは自分のやり方が常にベストだ！という意味ではありません。
「TypeScriptじゃなくてCoffeeScriptで書けよ」と言われたら「嫌だよ」でよいですが、「○○という構造にしたほうがいいんじゃない？」と言われたら、感情抜きに、良し悪しで判断するのが良いでしょう。
プライドは自分の底力は後押ししてくれますがその時点での技術力にはなんのプラスにもなりません。

# やりたいようにやる

お金を貰ってるわけでは多分ないので、やりたくない事はやらなくていいと思います。
今日は！[Shovel Knight](http://store.steampowered.com/app/250760/)という神ゲーをプレイするので！俺はpull requestのレビューをしないぞジョジョーッ！！

# DefinitelyTypedでは

現時点での僕の考えは[この辺](http://typescript.ninja/typescript-in-definitelyland/definition-file.html#h5-6)に書いた！
