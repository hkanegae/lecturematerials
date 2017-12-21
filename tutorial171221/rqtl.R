# rqtlデータの読み込み
# まずは、qtlパッケージを読み込む。
require(qtl) # 
cross <- read.cross(format = "csvs", genfile = "geno_bc.csv", phefile = "yield.csv")
cross <- jittermap(cross)
# 連鎖地図を表示
plot.map(cross)
# 2 cM間隔でpseudo markerを配置
interval <- 2
cross <- calc.genoprob(cross, step = interval)
cross <- sim.geno(cross, step = interval, n.draws = 1000)
# 16環境で計測された収量データのうち、16番目（env.id = 16）を解析
env.id <- 16

# コンポジットインターバルマッピング（composite interval mapping、CIM）
# Haley and Knott regressionに基づく方法（“hk”）で行う
n.covar <- 7 # マーカー共変量の数
window.size <- 5 
outcim.hk <- cim(cross, pheno.col = env.id + 1, method = "hk", n.marcovar = n.covar, window = window.size)

# 並べ替え検定を行って しきい値を決定
opermcim.hk <- cim(cross, pheno.col = env.id + 1, method = "hk", n.marcovar = n.covar, window = window.size, n.perm = 100)

# 解析結果を表示
plot(outcim.hk, main = "Composite Interval Mapping")
add.cim.covar(outcim.hk, col = "green")
abline(h = summary(opermcim.hk, alpha = 0.05))

#5%の有意水準でしきい値を出力
summary(opermcim.hk, alpha = 0.05)
# LOD値のピークのうち、5%水準で QTL検出
# QTLの情報を表示
summary(outcim.hk, perms = opermcim.hk, alpha = 0.05) 

# QTLの位置の修正・寄与率の計算

# 検出されたQTLの情報をtempに保存
temp <- summary(outcim.hk, perms = opermcim.hk, alpha = 0.05) 
# 第2染色体Ppd-H1と第3染色体Dfr を指定している
print(temp)
# makeqtl関数で検出されたQTLの位置の遺伝子型を抜き出す
qtl <- makeqtl(cross, chr = temp$chr, pos = temp$pos, what = "prob")
qtl
# QTLの位置をプロット
plot(qtl)

# QTL モデルの Fitting
# 相加モデルを仮定
createqtl<- paste("Q", 1:nrow(temp), sep="")
formula<-as.formula(paste("y ~ ", paste(createqtl, collapse= "+")))
# モデルを表示
formula
# 今回はformula='y~Q1+Q2'
# 今回の場合は Q1 -> Ppd-H1, Q2 -> Dfr

# モデルに基づいて、QTLの位置を修正
rqtl<-refineqtl(cross, pheno.col=env.id + 1, qtl=qtl,formula=formula, method="hk", model="normal",keeplodprofile=TRUE)
summary(rqtl)
plotLodProfile(rqtl)
# 修正したQTLの位置を独立変数（説明変数）として、表現型データ（従属変数、被説明変数）を回帰
res <- fitqtl(cross, qtl = rqtl, get.ests = T, method = "hk", pheno.col = env.id + 1)

#回帰分析におけるF検定の結果を表示
summary(res)
# %var値を確認 Ppd-H1とDfrの寄与率が計算できる

# QTLの位置の推定
# QTLが検出された染色体のみをプロット
for (i in 1:length(rqtl$chr)){
plot(outcim.hk, main = paste0(phenames(cross)[env.id + 1]," Composite Interval Mapping chr",rqtl$chr[i],sep=""),chr=rqtl$chr[i])
abline(h = summary(opermcim.hk, alpha = 0.05),col = "red")
abline(h = 3,col = "gray")
}
# QTLから最も近いマーカーを探す
# marker情報の入れ物を準備
marker<-data.frame(rqtl$chr,rep(NA,length(rqtl$chr)))
colnames(marker)=c("chr","marker")
# markerを探す
for (i in 1:length(rqtl$chr)){
marker[i,2]<-find.marker(cross,chr=rqtl$chr[i],pos=rqtl$pos[i])
}
print(marker)

# 1.5-LOD support interval
for ( i in rqtl$chr) {
lod_table<-lodint(outcim.hk,chr=i,expandtomarkers=TRUE)
print(lod_table)
}
# 各QTLの1.5-LOD support intervalが表示される

# 遺伝子型の効果をプロット

# plotPXG関数
for (i in 1:length(rqtl$chr)){
plotPXG(cross,marker=marker[i,2],pheno.col=env.id + 1)
}
# 赤色のドットがある場合は、遺伝子型をimputationした個体の表現型値
# effectplot
for (k in 1:length(rqtl$chr)){
effectplot(cross,mname1=marker[k,2],pheno.col=env.id + 1)
}
