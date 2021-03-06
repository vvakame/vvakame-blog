---
title: Programmer's Pocket Reference はいいぞ…！
date: 2019-12-01 09:00:00
tags: [技術書典]
---

本記事は[【推し祭り】技術書典で出会った良書 Advent Calendar 2019](https://adventar.org/calendars/4224)の1日目として書かれた記事です。

[vvakame](https://twitter.com/vvakame)です。

1日目ということで、熱っぽくやっていきたいと思います。

僕は技術書典7で[Nanoseconds Hunter](https://techbookfest.org/event/tbf07/circle/5720313589399552)さんが頒布した[Programmer's Pocket Reference](https://booth.pm/ja/items/1583656)を紹介します！

先に書いておきますが、現時点では上記リンクからBOOTHさん経由で電子版を購入することができます。
よかったですね。

時は技術書典7からおおよそ5日後、社で毎週金曜日に行われている社内勉強会で、僕が購入し、電子データがあった戦利品すべてに短評を述べ、みんなの購買意欲を煽る儀式をやりました。
そこで、あまりに熱のこもった本があったので気持ちになってしまった時のツイートがあるので引用しておきます。

<blockquote class="twitter-tweet" data-conversation="none"><p lang="ja" dir="ltr">社内で技術書典7で売ってたProgrammer’s Pocket Referenceは完全に頭のおかしい最高の本なので全員買ってほしい！見ろこの内容をよォ！と力説したんだけど電書販売を現在行ってないっぽくてしょげてる… <a href="https://t.co/J6zJLDoe93">https://t.co/J6zJLDoe93</a></p>&mdash; わかめ@毎日猫がいる (@vvakame) <a href="https://twitter.com/vvakame/status/1177492692235735042?ref_src=twsrc%5Etfw">September 27, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" data-conversation="none"><p lang="ja" dir="ltr">この本、前半は色々な言語でこれはこう書くみたいな話で、うんうんそうだね、って感じなんだけど後半ASCIIコードの話やx86のレジスタの話やBluetoothの規格やキーボードショートカットやPOSIXコマンドの解説やOSI参照モデルやUSB Type-Cの規格やピン配置、HDMIやetc etcが狂った情報量で書かれてて</p>&mdash; わかめ@毎日猫がいる (@vvakame) <a href="https://twitter.com/vvakame/status/1177496181376598016?ref_src=twsrc%5Etfw">September 27, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet" data-conversation="none"><p lang="ja" dir="ltr">なおかつ全ページフルカラーのデータでこれ1ページあたりの編集の手間どんだけかかってんの？みたいなのが200ページ超続いてるんですよ。やばい。到底真似できるものではない。みんなも買って目を通してみてほしい。売ってないんだけど。</p>&mdash; わかめ@毎日猫がいる (@vvakame) <a href="https://twitter.com/vvakame/status/1177496182458732547?ref_src=twsrc%5Etfw">September 27, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

繰り返しますが、この本、今は[BOOTH](https://booth.pm/ja/items/1583656)で入手できます！！

---

さて、改めて本書の内容を紹介していきます。

> 本書の内容に関しては、私の著作部に当たる部分に関しては、許可を得ることなくコピ ー・再配布を行い、教育や学習などの目的に使用することが出来ますが、出典を記載していただければ幸いです。

とのことなので、連絡しないほうが煩わしくなくてよかろう、ということで連絡なしにいきなりこの記事を書いています。
問題があったらご連絡ください…。

> 手帳の後ろの方についてくる付録部分が大好きでした。行ったことのない都市の地下鉄の路線図や、郵便料金の一覧表、元素記号表など眺めているだけでも楽しく感じていました。
> 本書は、プログラマー・エンジニア向けの手帳の付録です。「あれなんだったかな...」というときにすぐ調べれるよう、見開きサイズに情報を凝縮して、内容をまとめています。

あーそれめっちゃわーかーるー！
手帳の小さなページに、情報が詰め込まれて載っているのが面白かった記憶があります。
子供の頃に手帳の付録でワクワクした人、もしくは学校でもらえる副教材を見るのが好きだった人にぜひともおすすめしたい！


さて、本書は1部と2部に分かれています。
1部は様々なプログラミング言語の仕様がまとめられ、2部は様々な知識・仕様・規格がまとめられています。

私が好きなのは2部全般で、まずはASCIIコードの話。ジャブですね。

![ASCIIのお話 P.82, 83より引用 オリジナルはもちろん高精細です](/images/2019-12-01-tbf-advent/PPR-082-083.png)

ついでUnicode、こんな複雑な決め事やバリアントがあるのかと思うと具合が悪くなってきます。
これをみたら自分でバイト列を文字列として操作するコードを書きたくなくなることうけあいです。
標準ライブラリって偉大だ。
便利なフォントとして、Last ResortとGNU Unifontというのがあるそうです。R-Typeに出てくる機体みたいな名前だ。世の中色々あるなぁ…！

![Unicodeのお話 P.86, 87より引用 6P中の2P オリジナルはもちろん高精細です](/images/2019-12-01-tbf-advent/PPR-086-087.png)

この調子で、POSIX標準や正規表現についてなど、エンジニアならまれに参照したくなる情報がドンドン続きます。大量です。

軽く書いただけでもiPhoneの見分け方、PDFファイルの規格、HDMI規格の説明！
USB Type-C！文字化け！三角関数！
誰がそこまでやれといった！！

文字化けの説明に次のような説明がありました。

> 下駄(〓; U+3013)は、活版印刷で該当する字がない場合、とりあえず活字を裏返し に入れて印刷していた際に紙面に現れていた記号に由来する。

アレはなんかなんとなくバイト列の具合でそういうのが出てると思ってたけどちゃんと理由があったのか！？
知らねぇ〜〜〜知らねぇ〜〜〜〜〜俺は知らなかった…！

文字化けの解説の次がx86ですよ。
緩急ありすぎる…。
だがそれがいい……！！

そしてPOSIXの成り立ちや160個のユーティリティコマンド"すべて"の解説がされていたり、
Ethernetの物理層の説明がされていて、100BASE-Tがどういう意味なのか解説されていたり、
WPA3が2018年に策定されていたことが知れたり、
USB-Cのピンヘッダの図説が載っていたり、
USB4が最近制定されていたことが知れたり、
HDMIには6種類のケーブルがあることが知れたり、
抵抗器のカラーコードを見て懐かしい気持ちになったり、
浮動小数点の解説が読めたり（大学で習ったなぁ）、
盛りだくさんで眺めていて大変おもしろいのです。

組版も凝っていて、PDFを見るとちゃんと断ち切りまで塗り足しがあり、さらにリンクはちゃんとハイパーリンクになっています。
やりおる… 手間が… 手間がかかってるよぉ…。

そして本書は全編フルカラーという力の入りよう！
これは読むしかない…！
この本を読んで 知らなかった！ が1個もないエンジニアはおそらくいないでしょう。
駆け出しエンジニアの人でも楽しく読めると思います。
いい本だ！

技術書典7で頒布された紙版は本文はスミ1色だったそうですが、それもしかたのないこと…。なんとこの本、全204ページなのです。
日光企画さんでALLフルカラーの価格を調べるとなんと300冊スタート、かつページ数148Pまでしか掲載されておりません（問い合わせ確認まではしてない）。52ページと100ページ、100ページと148ページの価格差がともに17.6万円ほどなので安く見積もっても204Pの印刷はおよそ300冊73万円強となり余裕の原価2500円弱という雑な見積もりです。
それは印刷できんわガッハッハｗ


というわけで、皆様ぜひこの本を買って眺めて、ついでに職場などで人にチラ見せして布教していきましょう！

購入は！[＞＞＞ここ＜＜＜](https://booth.pm/ja/items/1583656)から！！

> よろしければ、この本を読んで思ったこと・間違っているところ・追加してほしいこと、なんでも良いので巻末のアンケートフォームよりぜひご意見いただければと思います。

とのことなので、本書を読んだ結果、手帳の付録力の高いネタをタレこんでいきましょう！（僕はしました）
