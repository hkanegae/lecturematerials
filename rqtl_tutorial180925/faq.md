## FAQ
- rqtl を使う上でよく質問されることをまとめました
- rqtlの公式のページも参照してください　http://www.rqtl.org/faq/
1. permutation testsは何回行うべきですか？
    - 通常は1000回行なっています
    - さらに正確な結果が必要な時は、10000回や100000回に増やしてください
1. RILのデータを使う時はどのようにすれば良いですか？  
    - ヘテロの遺伝子型をMissingとして使います  
    - cross <- convert2riself(cross) のコマンドを使います  
1. outcrossのデータを扱うことはできますか？  
    - 扱うことができません　onemapをお勧めします
