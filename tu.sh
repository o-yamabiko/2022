#!/bin/bash
#
# やまびこ通信の utf-8 MultimediaDAISY2.02 を md に変換
# 印刷用ページも作成
# バックナンバーリストに追加
#
# MultimediaDAISY2.02 directory $1; できているテキストの編集だけするなら$1=text
# yyyy $2
# mm $3
# done: CD製作時間の改行（行詰め、  入れ）
# done: クイズの問題に付くルビが正しく認識できずq.tsvが空になる。やり方を根本的に変えて、xmri_nnnnを1個ずつ探し、開始時刻終了時刻を計算して入れ、nnnnを+1するのをxmri_nnnnがみつからなくなるまで繰り返す
# done: 原稿のルビ形式を全角＊に変更してみる
# done: blockquote が消えてしまう。残るようにする。
# todo: トップページの「最新号」リンクを自動更新
# todo: tugi を自動でありなし区別し、前月号にもtugiを挿入

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

# MultimediaDAISY2.02 directory に移動
cd ./$1

# index.html から temp.md に変換

# 改行コードを\nにする
LC_COLLATE=C.UTF-8 sed \
    -e ':a;N;$!ba;s/\r\n/\n/g' \
    index.html > temp.md

# htmlからmdへ
LC_COLLATE=C.UTF-8 sed \
    -e '/<?xml/d' \
    -e '/<!DOCTYPE/d' \
    -e '/<\/*html/d' \
    -e '/<\/*head/d' \
    -e '/<\/*meta/d' \
    -e '/<\/*link/d' \
    -e '/<\/*title/d' \
    -e '/<\/*body/d' \
    -e 's/<\/*div[^>]*>//g' \
    -e '/<h1.*h1>/d' \
    -e 's/<p>&ensp;<\/p>//g' \
    -e 's/<p>/\n/g' \
    -e 's/<\/p>//g' \
    -e 's/^\t\t*//' \
    -e 's/\(<span[^>]*>\)\(##*\)/\2 \1/g' \
    -e 's/<span class=\"infty_silent\">ケス<\/span>.*<span class=\"infty_silent\">スケ<\/span>//g' \
    -e 's/<span[^>]*><img .*image0000\([0-9]\)\.[jp][pn]g[^>]*\/><\/span>/![cut\1](media\/'$3'\/cut\1.png){: .migi}/' \
    -e 's/\([^:]\)|<\/span>/\1<\/span>|/g' \
    -e 's/\(<\/span>\)\(<span[^>]*>[0-9][0-9時間分][0-9時間分]*<\/span>\)/\1  \n\2/' \
    -e 's/<p align=\"right\" style=\"text-align:right;\"><span /<span class=\"haigo\" /' \
    -e 's/&ensp;/ /g' \
    -e 's/<rt>＊<\/rt>/<rt>（　　　）<\/rt>/g' \
    -e 's/ class=\"ruby_level_[0-9][0-9]*\"//g' \
    -e 's/\(<a [^>]*\)><span /\1 /g' \
    -e 's/<\/span><\/a>/<\/a>/g' \
    temp.md > temp2.md
mv temp2.md temp.md

# 改行を含む表のフォーマットを整える
LC_COLLATE=C.UTF-8 sed \
    -e ':a;N;$!ba;s/<span class=\"infty_silent\">\(|:---|---:|\)<\/span>[^<]*</\n\1\n</' \
    temp.md > temp2.md
mv temp2.md temp.md

# 2行以上の空きを1行の空きに減らす
LC_COLLATE=C.UTF-8 sed \
    -e ':a;N;$!ba;s/\n\n\n*/\n\n/g' \
    temp.md > temp2.md
mv temp2.md temp.md

# id="xmri_XXXX" ごとに、smilからbeginとendを抽出
n=$((1))
xmri=`printf '%04X' $n`
g=`grep "xmri_$xmri" mrii0001.smil`

# id="xmri_XXXX" ごとに、smil内のXXXXが尽きるまで繰り返す
while [[ $g != '' ]] ; do

begin=`echo $g | sed -e 's/.*clip-begin=\"npt=\([0-9]*\.[0-9]*\)s.*/\1/' | bc -l`
end=`echo $g | sed -e 's/.*clip-end=\"npt=\([0-9]*\.[0-9]*\)s.*/\1/' | bc -l`

# durを計算
dur="`echo $end-$begin | bc -l`"

echo $begin
echo $end
echo $dur
echo $n

# id="xmri_XXXX" ごとに、durとbeginをtemp.mdに書き込む
sed \
    -e "s|\(id=\"xmri_$xmri\"\)|data-dur=\"$dur\" data-begin=\"$begin\" \1 markdown=\"1\"|g" \
temp.md > temp2.md
mv temp2.md temp.md

# 次のidに進む
n=$(($n+1))
xmri=`printf '%04X' $n`
g=`grep -i "xmri_$xmri" mrii0001.smil`
done

# temp.md をmm.mdの続きに追加

cat temp.md >> ../$3.md


# wavからmp3とoggを生成
#cd sounds

for f in ./sounds/*.wav
  do
    ffmpeg -i "$f" -c:a libmp3lame -q:a 2 "${f/%wav/mp3}" -c:a libvorbis -q:a 4 "${f/%wav/ogg}"
  done

# mp3とoggを所定の場所に置く
#cd -
mkdir -p ../media/$3
cp -i ./sounds/*.mp3 ../media/$3
cp -i ./sounds/*.ogg ../media/$3
cd ..

# $1 == text の時 $3.md がすでにあれば
elif [ -f "$3.md" ]; then
# memoのデータに従ってmm.mdのヘッダ書き換え
mv $3.md $3old.md

sed \
    -e "s|^iro:.*|$iro|" \
    -e "s|^gra:.*|$gra|" \
    -e "s|^background:.*|$background|" \
    -e "s|^imagefrom:.*|$imagefrom|" \
    -e "s|^imagefromurl:.*|$imagefromurl|" \
    $3old.md > $3.md

rm $3old.md

# $1 == text なのに $3.md が無ければ
else
echo "まずDAISY2.02データからmdを生成してほしい"
# $1 != text のif elsif else閉じ
fi

# $3.md が無ければ
if [ ! -f "$3.md" ]; then
# 何もしない
    :
# $3.md があれば
else

# 音声付きページmm.mdから音声無しページmmp.md作成

sed \
    -e '/^oto:/d' \
    -e '/^gra:/d' \
    -e '/^background:/d' \
    -e '/^imagefrom:/d' \
    -e '/^imagefromurl:/d' \
    -e 's/^\(tugi:.*\)/\1\nnoindex: true\nprint: true/' \
    $3".md" > $3"p.md"


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
