 ## BGLRパッケージのインストール
 ### Mac版
  ####  Rのロードパスを確認
   - Rを開いて実行します（**********は，実行者の共通ID＝ユーザ名）
   ***
> .libPaths()  
[1] "/home/**********/Library/R/3.4/library"  
[2] "/Library/Frameworks/R.framework/Versions/3.4/Resources/library"  
***
   #### BGLR-1.0.7のバイナリパッケージのダウンロード  
   - ターミナルを開いて実行します
***
$ curl -O https://cran.r-project.org/bin/macosx/el-capitan/contrib/3.4/BGLR_1.0.7.tgz
***
  #### BGLR-1.0.7の展開，コピー  
   - ターミナルを開いて実行します
   ***
   $ mkdir -p ~/Library/R/3.4/library  
$ tar xzf BGLR_1.0.7.tgz  
$ mv BGLR ~/Library/R/3.4/library  
***
### Win版
#### BGLR-1.0.7のバイナリパッケージのダウンロード
- BGLRのページを開く[https://cran.r-project.org/web/packages/BGLR/index.html](https://cran.r-project.org/web/packages/BGLR/index.html)
- r-oldrel: BGLR_1.0.7.zip をクリックして、ダウンロード
#### BGLR-1.0.7のバイナリパッケージのインストール
- Rを開く
***
> install.packages(”../Downloads/BGLR_1.0.7.zip",repos=NULL)  
> require(BGLR)
***

 - [BGLRパッケージのインストールの資料](https://github.com/hkanegae/lecturematerials/blob/master/tutorial190110/InstallBGLR190110.pdf)
