## 概要
http://co3k.org/blog/csrf-token-should-not-be-session-id について。

この記事では触れられていませんが、
- むかし、セッションIDをHTMLソース中に埋め込んでも脅威は変わらないと主張した人がいました
 - 正確には「hiddenの値のみ漏れやすいような特殊な脆弱性が無ければ」という前提であったけれど、実際にそのようなバグはあったし、予見されていた。
- とても影響のある人だったので、色々なサイトや書籍がその方法を紹介し、安全なウェブサイトの作り方にも載ってしまいました

この際ハッキリ言っておくべきだと思うので書きますが、そもそもセッションIDを(HTMLソース中に埋め込む)CSRF対策トークンとして使うのは間違いでした。最初から間違っていたのです。正確に言うとCSRFの話は関係ないですね。CSRF関係なく、特に「単体で」セッションハイジャックが可能になるような値を、HTMLソース中に埋め込むべきではありません。

## HTMLソースは漏洩する
理由は単純に、cookieに格納したセッションIDが漏洩するシナリオよりも、HTML本文が漏洩するシナリオの方が多いからです。MITM + 圧縮率の変化で推測、といった方法をとらなくてもHTML本文や断片が漏洩するシナリオはいくつかあります。

- ユーザー自身にHTMLソースをコピペさせるソーシャルエンジニアリングによるもの http://www.symantec.com/connect/blogs/facebook-csrf
- ログインしている状態でWebページを保存して、どこかにアップロードしたり他人に送信
- プロキシサーバーが他人向けのHTTPレスポンスをキャッシュしてしまうもの(Webサーバー側の設定不備 or 何でもキャッシュしちゃうダメなプロキシサーバー)
- クリッピング、スクラップ、あとで読む系のブックマークレットや拡張機能によるもの(表示中のHTMLソースを外部サーバーに送る)
- WebサイトのXSS (特にhttponlyのcookieが使われているケースではcookieは盗めないがHTMLソースは盗める)

ブラウザやプラグインや、Webサイトの脆弱性を使わなくても、CSRF対策トークンを盗み出すことは出来るのです。ログイン状態のWebページのソースをコピペしたり、保存してどこかに送ったりする行為が、それほど危険なことだとは想定できないでしょう。想定しろというのが無茶な話です。HTML中に埋めこまれているのがCSRF tokenではなく単体でセッションハイジャック可能なセッションIDが含まれていた場合は、これらの行為がセッションハイジャックに結びつきます。


## 参考文献
- https://www.owasp.org/index.php/Cross-Site_Request_Forgery_%28CSRF%29_Prevention_Cheat_Sheet#Double_Submit_Cookies

基本的なCSRF対策の推奨事項として"Synchronizer Token Pattern"を紹介して、セッションCookieの値をそのまま送るのは、セッションCookieの漏洩リスクを増加させる、XSSがあった時にhttponlyの保護機構を無効化する、として推奨されていない。

- http://www.jumperz.net/texts/csrf.htm

ワンタイムトークンが一番最初に挙がっているのは、CSSXSSを考慮しているためだ。初版 http://www.jumperz.net/texts/csrf1.2.htm これはフロー開始時からPOSTで始まっている(CSSXSSで盗めないように)

"この方法は「ブラウザに脆弱性がない」ことを前提として考案されたものである。しかし現実にはIEにCSSXSS脆弱性という「Cookieにはアクセス できないが、hiddenフィールドの値にはアクセスできる」バグが存在している。そのためこの方法を採用したウェブサイトは、リクエスト1でGETを使 える場合、CSSXSS脆弱性を悪用することによりセッションIDが盗まれ、結果としてセッションハイジャックされてしまう可能性がでてくる。セッション ハイジャックは明らかにCSRFよりも深刻なセキュリティ上の脅威である。つまりこの方法を採用することは、ウェブサイトを（対策を行わない状態に比べ て）危険な状態にさらしてしまうことになるのだ。"

"セッションIDそのものをトークンとして使うことには利点がないばかりか危険（CSSXSS脆弱性で現実になったように、何かのきっかけでセッションハイ ジャックに繋がるおそれがある）なので、この方式は採用してはならない。"

HTMLソース中に含まれるCSRF tokenが(ブラウザのバグにせよ他の攻撃手法にせよ)「漏洩しやすい」という前提に経つなら、ワンタイムにしたり有効期限を設けることで影響を軽減することができる。

## 結局どうすればいいの

ふつうにWebアプリケーションフレームワークやミドルウェアが提供しているCSRF対策機能を使うと良いです。セッションに関連付いた推測不可能な文字列を生成してフォームに自動で埋め込む、となっているでしょう。リファラ空だとエラーにするとか余計なことするのもたまにありますが、基本的に"Synchronizer Token Pattern”が使われているはずです。

CSRF tokenをワンタイムにしたり有効期限を設ける場合には、強制的にエラーにせずに確認画面を再表示する方が良いです(使い勝手を下げないようにするため)

ソーシャルエンジニアリング的な手法(HTMLソースコピペ)でCSRF tokenを盗みとられるような手口が現実的に無視できないような場合はCSRF tokenがHTMLソース中に含まれないようにするといいでしょう(JavaScript使える前提であれば、XHR postでCSRF tokenを取得すればいい)

## 他の対策方法について
- カスタムヘッダの存在で確認する方法について https://gist.github.com/mala/8857629

残念ながらまだ使うことが出来ません。Flashのバグが無ければ使えますが、実際に攻撃方法が開示されてから3年経っても直ってないということになります。3年です。責任の所在がどこにあるのかはともかく、実際にユーザーが被害にあう可能性があるならば、穴がある対策方法を使うべきではないと考えます。「それはブラウザやプラグインのバグだからWebサイト側では対策する必要がない」などと言って、ユーザーを危険にさらす訳にはいかないのです。


<!DOCTYPE HTML>
<html lang="ja">
    <head>
        <meta charset="UTF-8">
         <script src="http://code.createjs.com/easeljs-0.5.0.min.js"></script>
         <script src="http://code.createjs.com/tweenjs-0.3.0.min.js"></script>
         <script src="http://code.createjs.com/preloadjs-0.2.0.min.js"></script>
        <title>demo</title>
    </head>
    <body>
        <canvas id="demoCanvas" height="500" width="500">
            Canvasが使えるブラウザで見てね
        </canvas>
    </body>
    <script>
        var initialize = function(){
            var loader = new createjs.PreloadJS(false);
            var file = "http://blog.asial.co.jp/image/user_image_m/22.png";

            var demoCanvas = document.getElementById("demoCanvas");
            stage = new createjs.Stage(demoCanvas);
            loader.onFileLoad = draw;
            loader.loadFile(file);
        }
        
        var tick = function(){
            stage.update();
        }
        
        var draw = function(eventObject){
            var myImage = eventObject.result;
            myBitmap = new createjs.Bitmap(myImage);

            var halfWidth = myImage.width / 4;
            var halfHeight = myImage.height / 4;

            myBitmap.regX = halfWidth;
            myBitmap.regY = halfHeight;

            myBitmap.x = 0;
            myBitmap.y = 0;

            stage.addChild(myBitmap);
            stage.update();
            
            var point = new createjs.Point(100, 0);
            createjs.Tween.get(myBitmap).to({"x":point.x,"y":point.y}, 1000,createjs.Ease.bounceOut);
            createjs.Ticker.addListener(window);
            
        }
        initialize();
    </script>
</html>
