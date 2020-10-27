#!/bin/bash

if [ $# != 1 ]; then
    echo "Benutzung: $0 [.idx-Datei ohne Suffix]"
    exit 1
fi

# if egrep '[^\\]"' $1.idx >/dev/null ; then
#   echo "Unescaptes Gänsefüßchen in \"$1.idx\" gefunden. Bitte escapen oder ersetzen, denn xindy schluckt unescapte Gänsefüßchen."
#   exit 1
# fi


sed -i -e 's/"|/\\\//g' $1.idx
sed -i -e 's/"=/-/g' $1.idx
sed -i -e 's/"~/-/g' $1.idx
sed -i -e 's/"|hyperindexformat{\\\([^}]\)/\\\/\1/g' $1.idx
# if egrep '[^\\]"' $1.idx >/dev/null ; then
#   echo "Unescaptes Gänsefüßchen in \"$1.idx\" gefunden. Bitte escapen oder ersetzen, denn xindy schluckt unescapte Gänsefüßchen."
#   exit 1
# fi

perl -i -p -0 -e 's/hyperindexformat{\\see ?({[^}]+)}/see$1/g' $1.idx
perl -i -p -0 -e 's/hyperindexformat{\\seealso ?({[^}]+)}/seealso$1/g' $1.idx
perl -i -p -0 -e 's/(\\indexentry ?{.+)(\|seealso{.+})}{(.+)}/$1}{$3}\n$1$2}{$3}/g' $1.idx #seealso-Eintrag verdoppeln, um Seitenzahl vor texindy zu retten
perl -i -p -0 -e 's/\(hyperpage/\(/g' $1.idx
xindy -d keep_tmpfiles -v -d script -L general -C utf8 -M tex/inputenc/utf8 -M german-sty.xdy -M texindy -M page-ranges -M word-order -M german-sty.xdy -M transcript.xdy -I latex $1.idx
perl -i -p -0 -e 's/(item[^\n]+)(\\enskip [0-9]{1,2}\n)/$1\\nobreak$2/g' $1.ind

perl -i -p -0 -e 's/(\n {2,2}\\item[^\n]+\n\n {2,2}\\indexspace)/\\nopagebreak$1/g' $1.ind                  #kein Eintrag-Hurenkind
perl -i -p -0 -e 's/(\\lettergroup.+\n {2,2}\\item[^\n]+)(\n {2,4}\\s?u?b?item)/$1\\nopagebreak$2/g' $1.ind #kein Eintrag-Schusterjunge
perl -i -p -0 -e 's/(\n {4,4}\\subitem[^\n]+\n\n {2,2}\\indexspace)/\\nopagebreak$1/g' $1.ind               #kein Untereintrag-Hurenkind
perl -i -p -0 -e 's/(\n {4,4}\\subitem[^\n]+\n {2,2}\\item)/\\nopagebreak$1/g' $1.ind                       #kein Untereintrag-Hurenkind
perl -i -p -0 -e 's/(\n {6,6}\\subsubitem[^\n]+\n\n {2,2}\\indexspace)/\\nopagebreak$1/g' $1.ind            #kein Unteruntereintrag-Hurenkind
perl -i -p -0 -e 's/(\n {6,6}\\subsubitem[^\n]+\n {2,2}\\item)/\\nopagebreak$1/g' $1.ind                    #kein Unteruntereintrag-Hurenkind
perl -i -p -0 -e 's/(\n {6,6}\\subsubitem[^\n]+\n {4,4}\\subitem)/\\nopagebreak$1/g' $1.ind                 #kein Unteruntereintrag-Hurenkind
perl -i -p -0 -e 's/(\n {6,6}\\subsubitem[^\n]+\n\n {2,2}\\indexspace)/\\nopagebreak$1/g' $1.ind            #kein Unteruntereintrag-Hurenkind

# Aufruf zum Überschreiben der texindy-spezifischen Unsichtbarmachung von LaTeX-Makros
# xindy -v -d script -L general -C latin -M tex/inputenc/latin -M my-german-sty.xdy -M texindy -M page-ranges -M word-order -M my-german-sty.xdy -I latex test.idx
