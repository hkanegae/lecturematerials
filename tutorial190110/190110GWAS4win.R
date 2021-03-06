#' ---
#' title: "ゲノムワイドアソシエーション解析（GWAS）のチュートリアル"
#' author: "Laboratory of Biometry and Bioinformatics"
#' date: "2019/1/10"
#' ---

#' 現在の作業ディレクトリを確認する
getwd() 

#' SNPsデータ（geno.csv）を読み込む
geno <- read.csv("gwas_geno.csv", row.names = 1)

#' データのサイズを調べる
dim(geno)           
#' 337系統×1311SNPsのデータ

#' 最初の5SNPsの最初の5系統のデータを表示する
head(geno)[,1:5]
#' 今回の場合、1つの塩基のホモ接合（たとえば、AA）と別の塩基のホモ接合（たとえば、TT）が0, 2とスコア化 

#' 物理地図データを読み込む
map <- read.csv("gwas_map.csv", row.names = 1)

#' 最初の6行を表示する
head(map)

#' 表現型データを読み込む
pheno <- read.csv("gwas_pheno.csv", row.names = 1)

#' データのサイズを調べる
dim(pheno)            
#'  337系統×10形質のデータ

#' 最初の6行を表示する
head(pheno)

#' 早速gwasを行ってみる。必要なパッケージはrrBLUP
require(rrBLUP)          
#'  あらかじめパッケージのインストールを行っておく必要がある

#' 種子長でgwasを行ってみる。そのための準備をする。<br>
#' 表現型のうちseed.lengthを抜き出しyに代入。
y <- pheno$Seed.width / pheno$Seed.length 
#'genoを行列データとしてxに代入
X <- as.matrix(geno)                  

#' まずは単回帰分析で関係を調べる。<br>
#' まずは１番目のSNPだけについて調べる。
#' 1番目のSNPとyの間のアソシエーションを回帰分析する
model <- lm(y ~ X[,1])
#' 回帰結果の表示。なんと、高度に有意！
summary(model)
#' 回帰係数の有意性を表すp値を抜き出す
p <- summary(model)$coefficients[2,4]
p 
#' p = 0.0104....で、5%水準で有意

#' 全SNPについて調べる。先にp値を入れる入れ物を準備しておき、そこに代入していく
#' まずは、p値の入れ物を準備。
p.naive <- rep(NA, ncol(X)) 
#' 次に、全てのマーカーについて上と同じ解析を行う。
for(i in 1:ncol(X)) {
  model <- lm(y ~ X[,i])
  p.naive[i] <- summary(model)$coefficients[2,4] 
}
head(p.naive)

#' 結果をマンハッタンプロットとして表示してみる。
plot(map$cum.pos, -log10(p.naive), col = (map$chr) %% 2 + 1, xlab = "Position (bp)", ylab = "-log10(p)", main = "GWAS - naive")

#' マンハッタンプロットをPDFに保存する。
pdf("gwas_naive.pdf", width = 10, height = 5)
plot(map$cum.pos, -log10(p.naive), col = (map$chr) %% 2 + 1, xlab = "Position (bp)", ylab = "-log10(p)", main = "GWAS - naive")
dev.off()

#' 各品種のもつ遺伝的背景を主成分分析で推定する。強い遺伝構造があると偽陽性が多数生じる。
#' 主成分分析には、prcomp関数を用いる。
pca <- prcomp(X)    

#' 主成分の寄与率や累積寄与率を表示する。
summary(pca)
#' 第2主成分までで42%が説明される

#' 次に、主成分得点の散布図を作成する。
plot(pca$x[,c(1,2)])
plot(pca$x[,c(3,4)])
#' 変わった形に分布している。

#' 実は、このイネの遺伝資源では、それぞれの品種・系統が所属している
#' グループ（分集団）がわかっている。
#' 各品種・系統が所属する分集団名が記載されているパスポートデータを読み込む
attr <- read.csv("attr.csv", row.names = 1)

#' 中身を眺める
head(attr)     
#' 品種名、国、緯度経度、分集団構造の順でデータが並んでいる。

#' 主成分分析の結果を分集団ごとに色付けして表示する。
plot(pca$x[,c(1,2)], col = as.integer(attr$Sub.pop))
#' グラフに凡例を付ける
legend("topright", legend = levels(attr$Sub.population), col = 1:length(levels(attr$Sub.population)), pch = 1, bty="n")
plot(pca$x[,c(3,4)], col = as.integer(attr$Sub.pop))
legend("topright", legend = levels(attr$Sub.population), col = 1:length(levels(attr$Sub.population)), pch = 1, bty="n")
#' 主成分得点は、分集団の違いを良く反映していることがわかる。

#' PDFに保存しておく。
pdf("gwas_pca.pdf", width = 14)
par(mfrow = c(1,2))
plot(pca$x[,c(1,2)], col = as.integer(attr$Sub.pop))
legend("topright", legend = levels(attr$Sub.population), col = 1:length(levels(attr$Sub.population)), pch = 1, bty="n")
plot(pca$x[,c(3,4)], col = as.integer(attr$Sub.pop))
legend("topright", legend = levels(attr$Sub.population), col = 1:length(levels(attr$Sub.population)), pch = 1, bty="n")
dev.off()

#' 次に、集団構造によって生じる偽陽性を抑えるために、まずは上位10主成分で重回帰を行う。
model <- lm(y ~ pca$x[, 1] + pca$x[, 2] + pca$x[, 3] + pca$x[, 4] + pca$x[, 5] + pca$x[, 6] + pca$x[, 7] + pca$x[, 8] + pca$x[, 9] + pca$x[, 10])
#' 上位10主成分からstep関数を用いて変数減少法で変数選択する。
step(model)
#' すると1, 2, 4, 5, 6, 7, 8, 9が選ばれる
#' 選ばれた主成分を保存しておく。
#' なお、形質が違うと選ばれる変数が異なることに注意する。
select <- c(1, 2, 4, 5, 6, 7, 8, 9)

#' 主成分得点として抽出された遺伝的背景も含めた回帰分析を行う。まずは、p値の入れ物の準備。
p.q <- rep(NA, ncol(X))
#' 次に、回帰分析を繰り返し行う。主成分得点も含めて重回帰分析を行っていることに注意する。
for(i in 1:ncol(X)) {
  model <- lm(y ~ X[,i] + pca$x[, select]) # pca$x[, select]とすることで、有意な主成分を説明変数として取り込んでいる。
  p.q[i] <- summary(model)$coefficients[2, 4]
}

#' 結果をマンハッタンプロットとして散布する。
plot(map$cum.pos, -log10(p.q), col = (map$chr) %% 2 + 1, xlab = "Position (bp)", ylab = "-log10(p)", main = "GWAS - Q")

#' PDFに保存する。
pdf("gwas_q.pdf", width = 10, height = 5)
plot(map$cum.pos, -log10(p.q), col = (map$chr) %% 2 + 1, xlab = "Position (bp)", ylab = "-log10(p)", main = "GWAS - Q")
dev.off()

#' 血縁関係も含めた解析を行ってみる。
#' rrBLUPパッケージにあるA.mat関数を用いると、
#' マーカーから推定される品種・系統間の血縁を計算してくれる。
amat <- A.mat(X, shrink = T)       # 血縁行列の計算
#' 最初の6系統間の遺伝的関係を表示してみる。
amat[1:6, 1:6]                            

#' rrBLUPを用いたGWASのためのデータの準備（これが結構面倒）をする。
#' マーカーデータを準備する。
#' マーカー名、染色体番号、物理位置、データ（行がマーカー)の順でデータを並べる。
g <- data.frame(rownames(map), map$chr, map$pos, t(X)) 
#' gに行名をつける
rownames(g) <- 1:nrow(g)  
#' gに列名をつける
colnames(g) <- c("marker", "chrom", "pos", rownames(X)) 
#' 表現型データも準備する。系統名、計測値、の順でデータを並べる。
p <- data.frame(rownames(X), y) 
#' pに列名をつける
colnames(p) <- c("gid", "y") 
#' 最後に、血縁行列にも列名、行名をつける。いずれも品種・系統の名前。
colnames(amat) <- rownames(amat) <- rownames(X)  

#' GWASをrrBLUPのGWAS関数を用いて解析を実行する。
res.gwas <- GWAS(p, g, K = amat, n.PC = 9, min.MAF = 0.05, plot = F) # 有意でない第3主成分が含まれてしまうが。。。
#' 結果を眺めてみる。4列目が有意性を示す-log10(p)の値である。
head(res.gwas)            

#' 結果をマンハッタンプロットとして表示する。
plot(map$cum.pos, res.gwas[,4], col = (map$chr) %% 2 + 1, xlab = "Position (bp)", ylab = "-log10(p)", main = "GWAS - QK")
#' 結果はQモデルよりかなり明瞭になっている

#' 結果をPDFに保存する。
pdf("gwas_qk.pdf", width = 10, height = 5)
plot(map$cum.pos, res.gwas[,4], col = (map$chr) %% 2 + 1, xlab = "Position (bp)", ylab = "-log10(p)", main = "GWAS - QK")
dev.off()

#' ベイズ回帰を用いて全てのマーカーについて一度に解析を行う。
#' 次のコマンドを実行する前に、BGLRパッケージを事前にインストールしておく必要がある。
require(BGLR)  

#' 早速BayesBと呼ばれる方法を用いて解析を行ってみる。
ETA <- list(MRK = list(X = X, model = "BayesB")) 
fmBB <- BGLR(y, ETA = ETA, nIter = 15000, burnIn = 5000, thin = 10, verbose = F) 

#' -log(p)は計算されないので、回帰係数をプロットする。係数の絶対値を表示する。
plot(map$cum.pos, abs(fmBB$ETA$MRK$b), col = (map$chr) %% 2 + 1, xlab = "Position (bp)", ylab = "Absolute values of coefficients", main = "GWAS - BayesB")

#' PDFに出力する。
pdf(paste("gwas_BayesB.pdf", sep = ""), width = 10, height = 5)
plot(map$cum.pos, abs(fmBB$ETA$MRK$b), col = (map$chr) %% 2 + 1, xlab = "Position (bp)", ylab = "Absolute values of coefficients", main = "GWAS - BayesB")
abline(h = 2, lty = "dotted")
dev.off()

#' 係数の絶対値を保存する
coefficients<-abs(fmBB$ETA$MRK$b)
data<-cbind(map,coefficients)
dim(data)
head(data)
#' csv形式で保存
write.csv(data,"coefficients.csv",quote=F)

#' coefficientsの降順に並べ替え
data2<-data[order(data$coefficients, decreasing=T),]
#' coefficientsの順に表示
head(data2)

