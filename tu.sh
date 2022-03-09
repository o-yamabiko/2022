#!/bin/bash
#
# やまびこ通信の utf-8 MultimediaDAISY2.02 を md に変換
# 印刷用ページも作成
# バックナンバーリストに追加
#
# MultimediaDAISY2.02 directory $1; できているテキストの編集だけするなら$1=text
# yyyy $2
# mm $3
# todo: CD製作時間の改行（行詰め、  入れ）
# todo: tugi を自動でありなし区別する
# todo: github の jekyll が_tusin に追加したファイルを認識しないので、すべてのmdを2022直下に置いた。そのために ./_tusin 関連を書き直す必要がある。

# 今号、前号、次号の年と月を取り出し
if [[ $3 == '01' ]] ; then
maey="`echo $2 | bc -l` - 1" #yyyy文字列$2を数値に変換して計算
printf -v maey "%04d" $((maey)) #数値を4桁文字列に変換してmaeyに再代入
maem=12
tugy=$2
tugm=02

elif [[ $3 == '12' ]] ; then
maey=$2
maem=11
tugy="`echo $2 | bc -l` + 1" #yyyy文字列$2を数値に変換して計算
printf -v tugy "%04d" $((tugy)) #数値を4桁文字列に変換してtugyに再代入
tugm=01

else
maey=$2
maem="`echo $3 | bc -l` - 1" #mm文字列$3を数値に変換して計算
printf -v maem "%02d" $((maem)) #数値を2桁文字列に変換してmaemに再代入
tugy=$2
tugm="`echo $3 | bc -l` + 1" #mm文字列$3を数値に変換して計算
printf -v tugm "%02d" $((tugm)) #数値を2桁文字列に変換してtugmに再代入
fi

# 月を表す2桁文字列$3を数値に変換してgatuに代入
gatu=`echo $3 | bc -l`

# media/$3/memo があれば内容抽出、無ければそれを作りiro gra background imagefrom imagefromurl 欄を作成
# memo がすでにあれば
    if [ -f ./media/$3/memo ]; then

# 内容を変数に代入
iro="`grep -e "iro: " ./media/$3/memo`"
gra="`grep -e "gra: " ./media/$3/memo`"
background="`grep -e "background: " ./media/$3/memo`"
imagefrom="`grep -e "imagefrom: " ./media/$3/memo`"
imagefromurl="`grep -e "imagefromurl: " ./media/$3/memo`"

# memo が無ければ作る
    else
iro="iro: "
gra="gra: "
background="background: "$3"/default.png"
imagefrom="imagefrom:  @ Illust AC"
imagefromurl="imagefromurl: "

echo "$iro" > ./media/$3/memo
echo "$gra" >> ./media/$3/memo
echo "$background" >> ./media/$3/memo
echo "$imagefrom" >> ./media/$3/memo
echo "$imagefromurl" >> ./media/$3/memo
    fi


# $1 != text の時は以下をやる
if [[ $1 != 'text' ]] ; then

# create base md
mkdir -p _tusin
cd _tusin

echo '---' > $3.md
echo 'layout: caymanyomi' >> $3.md
echo 'title: やまびこ通信'$2'年'$gatu'月号' >> $3.md
echo 'author: 音訳グループ やまびこ' >> $3.md
echo 'date: '`date +%Y-%m-%dT%TZ` >> $3.md
echo 'oto: '$3'/sound0001' >> $3.md
echo "$iro" >> $3.md
echo "$gra" >> $3.md
echo "$background" >> $3.md
echo "$imagefrom" >> $3.md
echo "$imagefromurl" >> $3.md
echo 'navigation: true' >> $3.md
echo 'mae: '$maey'/'$maem >> $3.md
echo 'kore: '$2'/'$3 >> $3.md
echo 'tugi: '$tugy'/'$tugm >> $3.md
echo '---' >> $3.md

cd ..

# MultimediaDAISY2.02 directory に移動
cd ./$1

# extract begin-end time
sed \
    -e 's/^.* id=\"\([a-zA-Z0-9_]*\)\".*npt=\([0-9\.]*\)s.*npt=\([0-9\.]*\)s.*/\2\t\3\t\1\t/' \
    -e '/ *</d' \
    -e 's/<\/*b>//g' \
    mrii0001.smil > begin-end.tsv
# extract paroles
LC_COLLATE=C.UTF-8 sed \
    -e 's/<span class=\"infty_silent\">\([^<]*\)<\/span>/\1/g' \
    -e 's/\(ケス\)\(<span[^>]*>\)/\2\1/g' \
    -e 's/\(<\/span>\)\(スケ\)/\2\1/g' \
    -e 's/<\/span>/{endspan}/g' \
    -e 's/\r//' \
    index.html > temp0
LC_COLLATE=C.UTF-8 sed \
    -e 's/<p align=\"right\" style=\"text-align:right;\">\(<span[^>]*>\)/\1classhaigo/g' \
    -e 's/\({endspan}\)\([^<]*\)</\2\1</g' \
    -e 's/<p>//' \
    -e 's/\(<[^>]*>\)<\/p>/ppp\1/g' \
    -e 's/\({endspan}\)<\/p>/ppp\1/g' \
    -e 's/\(_+-[^+]*+-_\)\(<span id[^>]*>\)/\2\1/g' \
    -e 's/<span class=\"infty_silent_space\">\([^{]*\){endspan}/ /g' \
    -e 's/\(_+-[^+]*+-_\)\(<span[^>]*>\)/\2\1/g' \
    -e 's/<span class=\"ja\">\([^{]*\){endspan}/\1/g' \
    -e 's/{endspan}<span id=/{endspan}\n<span id=/g' \
    -e 's/\(<span id=[^>]*>\)##\({endspan}\)\&ensp;\(<span id=[^>]*>\)Let/\1\2\n\3## Let/g' \
    -e 's/{endspan}\&ensp;<span id=/{endspan}\n<span id=/g' \
    -e 's/{endspan}\&nbsp; <span id=/{endspan}\n<span id=/g' \
    -e 's/&lt;/</g' \
    -e 's/&gt;/>/g' \
    -e 's/<h1>.*/xmrii_0001\t /' \
    -e 's/<img src=\"images\/image[0]*\([1-9]*\)\.[jp][pn]g\" .*\/>/cut\1.png/' \
    -e 's/<a\([^>]*\)>\([^<]*\)\(<span[^>]*>\)/\3\1((\2/g' \
    -e 's/\({endspan}\)\([^<]*\)<\/a>/))\1\2/g' \
    temp0 > temp1

LC_COLLATE=C.UTF-8 sed \
    -e 's/.*_+-\(.*blockquote.*\)+-_.*/\1/' \
    -e 's/_+-\(#*\)+-_\(<span id=\"[a-zA-Z0-9_]*\">\)/\2\1/' \
    -e 's/_+-\(ケス\)+-_\(<span id=\"[a-zA-Z0-9_]*\">\)/\2\1/' \
    -e 's/\({endspan}\)_+-\(|:---|---:|\)+-_/\2\1/' \
    -e 's/\({endspan}\)_+-\(（カット[0-9]*）\)+-_/\2\1/' \
    -e 's/\({endspan}\)\( *_+-[^+]*+-_ *\)/\2\1/g' \
    -e 's/<span id=\"\([a-zA-Z0-9_]*\)\">\([^{]*\){endspan}/\1\t\2\n/g' \
    -e 's/<span class=\"infty_silent\">\([^{]*\){endspan}/\1/g' \
    temp1 > temp1a
LC_COLLATE=C.UTF-8 sed \
    -e 's/\(<rp>(<\/rp><rt>（<\/rt><rp>)<\/rp>\)\([ぁ-ゟ゠ァ-ヿ　（）]*\)<rp>(<\/rp><rt>）<\/rt><rp>)<\/rp>/\2\1/g' \
    -e 's/<rt>（<\/rt>/<rt>（　　　）<\/rt>/g' \
    -e 's/&ensp;<\/p>/<\/p>/g' \
    -e 's/ class=\"ruby_level_[0-9]\"//g' \
    -e 's/_+-//g' \
    -e 's/+-_//g' \
    temp1a > temp1b
csplit temp1b /blockquote.*markdown/ /月.*の答/

LC_COLLATE=C.UTF-8 sed \
    -e 's/&ensp;/ /g' \
    -e 's/ppp/\n/g' \
    -e 's/<\/p>//' \
    -e 's/	//g' \
    -e '/^$/d' \
   xx01 > q.tsv
sed \
    -e 's/<span [a-zA-Z0-9_\"=]*>//g' \
    -e 's/{endspan}//g' \
    -e 's/^[ \t]*//' \
    temp1b > temp1m
sed \
    -e '/^[^x].*/d' \
    -e '/^$/d' \
    temp1m > paroles.tsv
# calculate dur-begin.tsv
awk '{
    printf("%s\t%3.3f\n", $2-$1, $1)
    }' \
    begin-end.tsv > dur-begin.tsv
# combine dur-begin.tsv and paroles.tsv
paste dur-begin.tsv paroles.tsv > base.tsv
# make span
sed \
    -e 's/\([0-9\.]*\)\t\([0-9\.]*\)\t\([a-z]*_[0-9A-Z]*\)\t\(（リンク）\)/<a href=\"\" data-dur=\"\1\" data-begin=\"\2\" id=\"\3\">\4<\/a><\/span>/' \
    -e 's/\([0-9\.]*\)\t\([0-9\.]*\)\t\([a-z]*_[0-9A-Z]*\)\t\(.*\)/<span data-dur=\"\1\" data-begin=\"\2\" id=\"\3\" markdown=\"1\">\4<\/span>/' \
    base.tsv > temp3
LC_COLLATE=C.UTF-8 sed \
    -e ':a;N;$!ba;s/<\/span>\n<a/<a/g' \
    -e ':a;N;$!ba;s/<span[^>]*>\(#*\)<\/span>\n<span/\1 <span/g' \
    -e ':a;N;$!ba;s/\(<span[^>]*>[0-9]*\.<\/span>\)\n\(<span\)/\n\1\2/g' \
    temp3 > temp4
LC_COLLATE=C.UTF-8 sed \
    -e 's/<span[^>]*>\(cut[0-9]\)\(\.[jp][pn]g\)ppp<\/span>/![\1](media\/'$2'\/\1\2){: .migi}\n/g' \
    -e 's/ppp<\/span>/<\/span>\n/g' \
    -e 's/\(<span[^>]*>\)\(#*\)&ensp;/\n\2 \1/g' \
    -e 's/<span\([^>]*\)>\( href[^(]*\)((\([^)]*\)))<\/span>/<a\1\2>\3<\/a>/g' \
    -e 's/\([^月]*月.*の答.*\)/\1\n<blockquote markdown=\"1\">/' \
    -e 's/^\(<span[^>]*>定例会：<\/span>\)$/<\/blockquote>\n\n\1/' \
    -e 's/ケス[^ス]*スケ//g' \
    -e '/>ケス/d' \
    -e '/スケ</d' \
    -e 's/|:---|---:|<\/span>/<\/span>\n|:---|---:|/g' \
    -e 's/<span[^>]*> *<\/span>//g' \
    -e 's/|<\/span>/<\/span>|/g' \
    -e 's/>classhaigo/ class=\"haigo\">/g' \
    -e 's/&ensp;/ /g' \
    -e '/<span[^>]*>&thinsp;&thinsp;p*<\/span>/d' \
    temp4 > temp41

LC_COLLATE=C.UTF-8 sed \
    -e ':a;N;$!ba;s/<span[^>]*>\(#*\)<\/span>\n\(<span[^>]*>[^\n]*<\/span>\)/\1 \2\n/g' \
    -e 's/ppp<\/a>/<\/a>\n/g' \
    -e ':a;N;$!ba;s/|\n/|/g' \
    temp41 > temp42

LC_COLLATE=C.UTF-8 sed \
    -e ':a;N;$!ba;s/\(##*\) *\n/\1 /g' \
    temp42 > temp5

LC_COLLATE=C.UTF-8 sed \
    -e '/xmrii/d' \
    -e 's/　/ /g' \
    -e 's/\(.*>\)\(.*\)\(<a.*>\)\(（リンク）\)\(.*\)/\1\3\2\5/' \
    -e 's/\(.*>やまびこ通信.*バックナンバー<.*\)$/\n# \1\n/' \
    -e 's/\(.*>[0-9]*年[0-9]*月号<.*\)$/- \1/' \
    -e 's/\([^>]*>\)\(#* \)\(.*\)$/\n\2\1\3\n/' \
    -e 's/\(.*>定例会：<.*\)$/\n\1/' \
    -e 's/\(.*中央図書館3階.*\)$/\1  /' \
    -e 's/\(.*\)やまびこ代表 *大川 *薫\(.*\)$/\1やまびこ代表 大川 薫\2  /' \
    -e 's/\(.*03-3910-7331.*\)$/\1  /' \
    -e 's/\(.*href="\)\(".*このサイトについて.*\)$/\1mailto:ymbk2016ml@gmail\.com?Subject=やまびこウェブサイトについて\2/' \
    -e 's/\(<rp>(<\/rp><rt>（<\/rt><rp>)<\/rp>\)\([ぁ-ゟ゠ァ-ヿ　（）]*\)<rp>(<\/rp><rt>）<\/rt><rp>)<\/rp>/\2\1/g' \
    -e 's/（カット\([0-9]*\)）<\/span>/<\/span>\n\n<img class=\"migi\" src=\"media\/'$2'\/cut\1\.png" alt=\"\" \/>\n/' \
    -e 's/\(<span[^>]*>No\.[0-9 ]*<\/span>\)/\1/' \
    temp5 > temp6


    if [[ `grep "読み上げは省略" temp6` == '' ]] ; then

      csplit temp6 /月.*の.*答/
      cat xx00 q.tsv xx01 >> ../_tusin/$3.md

    else

      csplit temp6 /読み上げは省略/
      LC_COLLATE=C.UTF-8 sed \
          -e '/読み上げは省略/d' \
          xx01 > xx01m
      cat xx00 q.tsv xx01m >> ../_tusin/$3.md

    fi


# wavからmp3とoggを生成
cd sounds

for f in *.wav
  do
    ffmpeg -i "$f" -c:a libmp3lame -q:a 2 "${f/%wav/mp3}" -c:a libvorbis -q:a 4 "${f/%wav/ogg}"
  done

# mp3とoggを所定の場所に置く
cd -
mkdir -p ../media/$3
cp -i sounds/*.mp3 ../media/$3
cp -i sounds/*.ogg ../media/$3
cd ..

# $1 == text の時 $3.md がすでにあれば
elif [ -f "./_tusin/$3.md" ]; then
# memoのデータに従ってmm.mdのヘッダ書き換え
mv ./_tusin/$3.md ./_tusin/$3old.md

sed \
    -e "s|^iro:.*|$iro|" \
    -e "s|^gra:.*|$gra|" \
    -e "s|^background:.*|$background|" \
    -e "s|^imagefrom:.*|$imagefrom|" \
    -e "s|^imagefromurl:.*|$imagefromurl|" \
    "./_tusin/"$3"old.md" > "./_tusin/"$3".md"

rm ./_tusin/$3old.md

# $1 == text なのに $3.md が無ければ
else
echo "まずDAISY2.02データからmdを生成してほしい"
# $1 != text のif elsif else閉じ
fi

# $3.md が無ければ
if [ ! -f "./_tusin/$3.md" ]; then
# 何もしない
    :
# $3.md があれば
else

# 音声付きページmm.mdから音声無しページmmp.md作成
cd _tusin

sed \
    -e '/^oto:/d' \
    -e '/^gra:/d' \
    -e '/^background:/d' \
    -e '/^imagefrom:/d' \
    -e '/^imagefromurl:/d' \
    -e 's/^\(tugi:.*\)/\1\nnoindex: true\nprint: true/' \
    $3".md" > $3"p.md"

cd -

# バックナンバーリストに追加
# index.md がすでにあれば
    if [ -f "index.md" ]; then

# すでにあるリストを保存
grep -e "- <.*音声付き" index.md > soundlist
grep -e "- <.*p.html" index.md > printlist

# index.mdが無ければ空のリストを作っておく
    else
touch soundlist
touch printlist

    fi

# 今月号がすでにリストにあれば何もしない
grep $2"/"$3 soundlist > search
    if [ -s search ]; then
    # 1バイトでも中身があれば何もしない
        :
    else
    # 0バイトだったら追加

# 今月号の行を作る
new='- <a href="../'$2'/'$3'.html">'$2'年'$gatu'月号 <img src="media/Speaker_Icon_gray.png" srcset="media/Speaker_Icon_gray.svg" alt="音声付き" class="gyo" /></a>{: .highline}'
newp='- <a href="../'$2'/'$3'p.html">'$2'年'$gatu'月号</a>{: .highline}'

# index.md を新たに作る

echo '---' > index.md
echo 'layout: caymanyomi' >> index.md
echo 'title: やまびこ通信 '$2'年' >> index.md
echo 'author: 音訳グループ やまびこ' >> index.md
echo 'date: '`date +%Y-%m-%dT%TZ` >> index.md
echo 'iro: 2679B9' >> index.md
echo 'gra: 95B926' >> index.md
echo -e '---\n' >> index.md
echo -e '# やまびこ通信 '$2'年\n' >> index.md
echo -e '## 音声付き\n' >> index.md
echo $new >> index.md
cat soundlist >> index.md
echo -e '\n## 音声無し\n' >> index.md
echo $newp >> index.md
cat printlist >> index.md

    fi

# 使い終わったファイルを削除
rm soundlist printlist search

# $3.md が無ければ、のif else 閉じ
fi
