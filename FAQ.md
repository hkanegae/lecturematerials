### FAQ
#### Q1. Rでエラーが出てしまいました。どうしたら良いですか？
 - A1. エラーメッセージをコピーして、検索してみてください。

#### Q2. plotをPDF fileとして保存する方法を教えてください。
 - A2.  pdf関数を利用して保存できます。  
> pdf("plot.pdf")  # デバイスを開く   
> plot(outcim.hk, main ="Composite Interval Mapping")   
> add.cim.covar(outcim.hk, col = "green")  
> abline(h = summary(opermcim.hk, alpha = 0.05))    
> dev.off() # デバイスを閉じる   

##### Q3. 全ての形質をまとめて解析する場合のスクリプトを教えてください。
 - A3. 以下のスクリプトを使うと、まとめて解析できます。
> for(k in 2:nphe(cross)) {
>    print(paste(k, phenames(cross)[k]))
>    env.id <- k -1
>    outcim.hk <- cim(cross, pheno.col = env.id + 1, method = "hk", n.marcovar = n.covar, window = window.size)
> ...
>    }


