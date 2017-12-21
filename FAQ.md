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
