%%
%% stylesheet for the Apparatus Journal.
%%
%% Maintainer: lupino
%%
%% lualatex  -  texlive2019
%%
\NeedsTeXFormat{LaTeX2e}[2018/12/01]
\ProvidesClass{transcript}
    [2020/11/19 0.101 Transcript Books]
\frenchspacing
\clubpenalty10000
\widowpenalty10000
\RequirePackage{kvoptions-patch}%%%NEW
\RequirePackage{xkeyval}
\PassOptionsToPackage{cmyk}{xcolor}
\newif\ifcollection \collectionfalse
\newif\ifendnotes \endnotesfalse
\DeclareOptionX{book}{\global\collectionfalse}
\DeclareOptionX{collection}{\global\collectiontrue}
\DeclareOptionX{endnotes}{\global\endnotestrue}
\DeclareOptionX{ennotoc}{\global\endnotestrue\global\let\noendnotetoc\relax}
\DeclareOptionX{endnotesperchapter}{\global\endnotestrue\global\let\endnotes@per@chapter\relax}
\long\gdef\LayVar#1#2#3#4{#4}%
\global\let\lay=c\relax%% Standard-Layout
\define@choicekey{transcript.cls}{lay}[\p@ley\nr]{e,a,b,c}{%
  \ifcase\nr\relax
    \global\let\lay=e\relax
    \long\gdef\LayVar##1##2##3##4{##1}%
  \or
    \global\let\lay=a\relax
    \long\gdef\LayVar##1##2##3##4{##2}%
  \or
    \global\let\lay=b\relax
    \long\gdef\LayVar##1##2##3##4{##3}%
  \else
    \global\let\lay=c\relax
    \long\gdef\LayVar##1##2##3##4{##4}%
  \fi}%

\let\usescript\relax
\define@key{transcript.cls}{usescript}[none]{\def\usescript{#1}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptionsX

\def\parse@script#1,#2,\relax{%
  \expandafter\let\csname use@script@#1\endcsname\relax%
  \def\@argii{#2}%
  \let\next\relax
  \ifx\@argii\@empty\else
    \def\next{\parse@script#2,,\relax}%
  \fi\next}

\ifx\usescript\relax\else
  \expandafter\parse@script\usescript,,\relax
\fi

\message{^^JTranscript Class Layout Variant: \LayVar{e}{a}{b}{c}^^J}

\LoadClass[10pt,a4paper]{book}

%%%%%%%%%%%%
% Sprachen %
%%%%%%%%%%%%

\RequirePackage{babel}
\addto\captionsngerman{\def\contentsname{Inhalt}}
\addto\captionsngerman{\def\refname{Literaturverzeichnis}}

%%%%%%%%%%
% Fonts  %
%%%%%%%%%%

\usepackage{fontspec}
\setmainfont{Alegreya-Regular.ttf}[%
  Path=fonts/Alegreya/Alegreya/,%
  BoldFont = Alegreya-Bold.ttf,%
  FontFace = {eb}{n}{Alegreya-ExtraBold.ttf},
  FontFace = {eb}{it}{Alegreya-ExtraBoldItalic.ttf},
  FontFace = {sb}{n}{Alegreya-Medium.ttf},
  FontFace = {sb}{it}{Alegreya-MediumItalic.ttf},
  ItalicFont = Alegreya-Italic.ttf,%
  WordSpace = 1.25,
  BoldItalicFont = Alegreya-BoldItalic.ttf]

\setsansfont{BarlowCondensed-Regular.ttf}[%
  Path=fonts/Barlow/Barlow Condensed/,%
  BoldFont = BarlowCondensed-Bold.ttf,%
  FontFace = {up}{n}{../../Barlow/Barlow/Barlow-Light.ttf},
  FontFace = {up}{it}{../../Barlow/Barlow/Barlow-LightItalic.ttf},
  FontFace = {lt}{n}{BarlowCondensed-Light.ttf},
  FontFace = {lt}{it}{BarlowCondensed-LightItalic.ttf},
  FontFace = {md}{n}{BarlowCondensed-Medium.ttf},
  FontFace = {md}{it}{BarlowCondensed-MediumItalic.ttf},
  FontFace = {eb}{n}{BarlowCondensed-Black.ttf},
  FontFace = {eb}{it}{BarlowCondensed-BlackItalic.ttf},
  FontFace = {sb}{n}{BarlowCondensed-SemiBold.ttf},
  FontFace = {sb}{it}{BarlowCondensed-SemiBoldItalic.ttf},
  ItalicFont = BarlowCondensed-Italic.ttf,%
  BoldItalicFont = BarlowCondensed-BoldItalic.ttf,
  WordSpace=1.1,
  LetterSpace=1.1,
  FakeStretch=1.02,
  Color=353132]
\DeclareRobustCommand{\ltseries}{\fontseries{lt}\selectfont}
\DeclareRobustCommand{\ebseries}{\fontseries{eb}\selectfont}
\DeclareRobustCommand{\sbseries}{\fontseries{sb}\selectfont}
\DeclareRobustCommand{\mdseries}{\fontseries{md}\selectfont}
\DeclareRobustCommand{\upseries}{\fontseries{up}\selectfont}

\DeclareRobustCommand{\wideText}{\addfontfeature{LetterSpace=2.0}}

\newfontfamily\sfwide{BarlowCondensed-Regular.ttf}[%
  Path=fonts/Barlow/Barlow Condensed/,%
  BoldFont = BarlowCondensed-Bold.ttf,%
  FontFace = {up}{n}{../../Barlow/Barlow/Barlow-Light.ttf},
  FontFace = {up}{it}{../../Barlow/Barlow/Barlow-LightItalic.ttf},
  FontFace = {lt}{n}{BarlowCondensed-Light.ttf},
  FontFace = {lt}{it}{BarlowCondensed-LightItalic.ttf},
  FontFace = {md}{n}{BarlowCondensed-Medium.ttf},
  FontFace = {md}{it}{BarlowCondensed-MediumItalic.ttf},
  FontFace = {eb}{n}{BarlowCondensed-Black.ttf},
  FontFace = {eb}{it}{BarlowCondensed-BlackItalic.ttf},
  FontFace = {sb}{n}{BarlowCondensed-SemiBold.ttf},
  FontFace = {sb}{it}{BarlowCondensed-SemiBoldItalic.ttf},
  ItalicFont = BarlowCondensed-Italic.ttf,%
  BoldItalicFont = BarlowCondensed-BoldItalic.ttf,
  WordSpace=2.0,
  LetterSpace=2.0,
  FakeStretch=1.02,
  Color=353132]

\newfontfamily\sfwider{BarlowCondensed-Regular.ttf}[%
  Path=fonts/Barlow/Barlow Condensed/,%
  BoldFont = BarlowCondensed-Bold.ttf,%
  FontFace = {up}{n}{../../Barlow/Barlow/Barlow-Light.ttf},
  FontFace = {up}{it}{../../Barlow/Barlow/Barlow-LightItalic.ttf},
  FontFace = {lt}{n}{BarlowCondensed-Light.ttf},
  FontFace = {lt}{it}{BarlowCondensed-LightItalic.ttf},
  FontFace = {md}{n}{BarlowCondensed-Medium.ttf},
  FontFace = {md}{it}{BarlowCondensed-MediumItalic.ttf},
  FontFace = {eb}{n}{BarlowCondensed-Black.ttf},
  FontFace = {eb}{it}{BarlowCondensed-BlackItalic.ttf},
  FontFace = {sb}{n}{BarlowCondensed-SemiBold.ttf},
  FontFace = {sb}{it}{BarlowCondensed-SemiBoldItalic.ttf},
  ItalicFont = BarlowCondensed-Italic.ttf,%
  BoldItalicFont = BarlowCondensed-BoldItalic.ttf,
  WordSpace=2.0,
  LetterSpace=5.0,
  FakeStretch=1.02,
  Color=353132]

\newfontfamily\sfchap{BarlowCondensed-Regular.ttf}[%
  Path=fonts/Barlow/Barlow Condensed/,%
  BoldFont = BarlowCondensed-Bold.ttf,%
  FontFace = {up}{n}{../../Barlow/Barlow/Barlow-Light.ttf},
  FontFace = {up}{it}{../../Barlow/Barlow/Barlow-LightItalic.ttf},
  FontFace = {lt}{n}{BarlowCondensed-Light.ttf},
  FontFace = {lt}{it}{BarlowCondensed-LightItalic.ttf},
  FontFace = {md}{n}{BarlowCondensed-Medium.ttf},
  FontFace = {md}{it}{BarlowCondensed-MediumItalic.ttf},
  FontFace = {eb}{n}{BarlowCondensed-Black.ttf},
  FontFace = {eb}{it}{BarlowCondensed-BlackItalic.ttf},
  FontFace = {sb}{n}{BarlowCondensed-SemiBold.ttf},
  FontFace = {sb}{it}{BarlowCondensed-SemiBoldItalic.ttf},
  ItalicFont = BarlowCondensed-Italic.ttf,%
  BoldItalicFont = BarlowCondensed-BoldItalic.ttf,
  WordSpace=1.2,
  LetterSpace=2.0,
  FakeStretch=1.02,
  Color=353132]


\emergencystretch=2em

\newfontfamily\nsffamily{AlegreyaSans-Regular.ttf}[%
  Path=fonts/Alegreya/Alegreya Sans/,%
  BoldFont = AlegreyaSans-Bold.ttf,%
  FontFace = {eb}{n}{AlegreyaSans-ExtraBold.ttf},
  FontFace = {eb}{it}{AlegreyaSans-ExtraBoldItalic.ttf},
  FontFace = {md}{n}{AlegreyaSans-Regular.ttf},
  FontFace = {md}{it}{AlegreyaSans-Italic.ttf},
  FontFace = {sb}{n}{AlegreyaSans-Medium.ttf},
  FontFace = {sb}{n}{AlegreyaSans-MediumItalic.ttf},
  ItalicFont = AlegreyaSans-Italic.ttf,%
  BoldItalicFont = AlegreyaSans-BoldItalic.ttf]

\newfontfamily\nsfwider{AlegreyaSans-Regular.ttf}[%
  BoldFont = AlegreyaSans-Bold.ttf,%
  FontFace = {eb}{n}{AlegreyaSans-ExtraBold.ttf},
  FontFace = {eb}{it}{AlegreyaSans-ExtraBoldItalic.ttf},
  FontFace = {md}{n}{AlegreyaSans-Regular.ttf},
  FontFace = {md}{it}{AlegreyaSans-Italic.ttf},
  FontFace = {sb}{n}{AlegreyaSans-Medium.ttf},
  FontFace = {sb}{it}{AlegreyaSans-MediumItalic.ttf},
  ItalicFont = AlegreyaSans-Italic.ttf,%
  BoldItalicFont = AlegreyaSans-BoldItalic.ttf,
  WordSpace=1.2,
  Path=fonts/Alegreya/Alegreya Sans/,
  LetterSpace=1.2]

\newfontfamily\fallbackfont{NotoSans-Regular.ttf}%
[BoldFont = NotoSans-Bold.ttf,%
 ItalicFont = NotoSans-Italic.ttf,%
 BoldItalicFont = NotoSans-BoldItalic.ttf,%
 Path = fonts/NotoSans/,%
 WordSpace = 1.25]
\DeclareTextFontCommand\textfallback{\fallbackfont}

\ifx\use@script@armenian\relax
  \message{^^JLoaded Script: Armenian^^J}
  \babelprovide{armenian}%
  \newfontfamily\fallbackfont@armenian{NotoSansArmenian-Regular.ttf}%
    [BoldFont = NotoSansArmenian-Bold.ttf,%
    Path = fonts/NotoSans/Armenian/,%
    WordSpace = 1.25]
  \DeclareTextFontCommand\armenian{\selectlanguage{armenian}\fallbackfont@armenian}
\fi

\ifx\use@script@chinese\relax
  \babelprovide{chinese}%
  \message{^^JLoaded Script: Chinese^^J}%
  \newfontfamily\fallbackfont@chinese{NotoSansCJKsc-Light.otf}%
    [BoldFont = NotoSansCJKsc-Regular.otf,%
    Path = fonts/NotoSans/Chinese/,%
    WordSpace = 1.25]
  \DeclareTextFontCommand\chin{\selectlanguage{chinese}\fallbackfont@chinese}
\fi

%\ifx\use@script@chinese\relax
%  \babelprovide{chinese}%
%  \message{^^JLoaded Script: Chinese^^J}
%  \newfontfamily\fallbackfont@chinese{NotoSansCJKsc-Regular.otf}%
%    [BoldFont = NotoSansCJKsc-Bold.otf,%
%    Path = fonts/NotoSans/Chinese/,%
%    WordSpace = 1.25]
%  \DeclareTextFontCommand\chin{\selectlanguage{chinese}\fallbackfont@chinese}
%\fi

\ifx\use@script@arabic\relax
  \babelprovide{arabic}%
  \message{^^JLoaded Script: Arabic^^J}
  \newfontfamily\fallbackfont@arabic{NotoNaskhArabic-Regular.ttf}%
    [BoldFont = NotoNaskhArabic-Bold.ttf,%
    Path = fonts/NotoSans/Arabic/,%
    WordSpace = 1.25]
  \DeclareTextFontCommand\arab{\selectlanguage{arabic}\fallbackfont@arabic}
\fi


\usepackage{newunicodechar}
%\newunicodechar{↩}{\ifmmode\hookleftarrow\else$\hookleftarrow$\fi}% 8617
\newunicodechar{‐}{\penalty\@M-\hskip\z@skip}% 8617
\newunicodechar{‑}{\hbox{-}\penalty\@M\hskip\z@skip}% 8617
\newunicodechar{↩}{\hskip\z@skip}
\newunicodechar{。}{\hbox{$_\circ$\enskip\ignorespaces}}
\newunicodechar{、}{,\enskip\ignorespaces}
\newunicodechar{；}{;\enskip\ignorespaces}
\newunicodechar{：}{:\enskip\ignorespaces}
\newunicodechar{，}{,\enskip\ignorespaces}

\DeclareRobustCommand\unichar[1]{\textfallback{#1}}

%%%%%%%%%%%%%%
% Font sizes %
%%%%%%%%%%%%%%

\renewcommand\normalsize{%
   \@setfontsize\normalsize{9.2bp}{12.8bp}%
   \abovedisplayskip 9.3\p@ \@plus2\p@ \@minus5\p@
   \abovedisplayshortskip \z@ \@plus3\p@
   \belowdisplayshortskip 5\p@ \@plus3\p@ \@minus3\p@
   \belowdisplayskip \abovedisplayskip
   \let\@listi\@listI}
\normalsize
\renewcommand\small{%
   \@setfontsize\small{9bp}{11}% head
   \abovedisplayskip 8.5\p@ \@plus3\p@ \@minus4\p@
   \abovedisplayshortskip \z@ \@plus2\p@
   \belowdisplayshortskip 4\p@ \@plus2\p@ \@minus2\p@
   \def\@listi{\leftmargin\leftmargini
               \topsep 6.4bp
               \parsep 3.2bp
               \itemsep \parsep}%
   \belowdisplayskip \abovedisplayskip
}
\renewcommand\footnotesize{% footnotes
   \@setfontsize\footnotesize{8bp}{11bp}%
   \abovedisplayskip 6\p@ \@plus2\p@ \@minus4\p@
   \abovedisplayshortskip \z@ \@plus\p@
   \belowdisplayshortskip 3\p@ \@plus\p@ \@minus2\p@
   \def\@listi{\leftmargin\leftmargini
               \topsep 3.2bp
               \parsep 2\p@ \@plus\p@ \@minus\p@
               \itemsep \parsep}%
   \belowdisplayskip \abovedisplayskip
}
\renewcommand\scriptsize{\@setfontsize\scriptsize\@viipt\@viiipt}
\renewcommand\tiny{\@setfontsize\tiny\@vpt\@vipt}
\renewcommand\large{\@setfontsize\large{10bp}{12.8bp}}% chapter in TOC
\renewcommand\Large{\@setfontsize\Large{11bp}{12.8bp}}% subsection
\renewcommand\LARGE{\@setfontsize\LARGE{11.5bp}{12.8bp}}% section
\renewcommand\huge{\@setfontsize\huge{13bp}{16}}% part in TOC
\renewcommand\Huge{\@setfontsize\Huge{15bp}{18.3bp}}% chapter
\newcommand\HUGE{\@setfontsize\HUGE{17.5bp}{25.6bp}}% part

\parskip\z@

%%%%%%%%%%%%%%%
% page layout %
%%%%%%%%%%%%%%%

\voffset-1in\relax
\hoffset-1in\relax

\LayVar{\paperwidth=155mm\relax}{\paperwidth=148mm\relax}{\paperwidth=148mm\relax}{\paperwidth=148mm\relax}
\LayVar{\paperheight=240mm\relax}{\paperheight=225mm\relax}{\paperheight=225mm\relax}{\paperheight=225mm\relax}

\headheight=12.8bp\relax
\topskip=9.2bp\relax
\LayVar{\topmargin=\dimexpr15mm-\headheight\relax}{\topmargin=\dimexpr21.5mm-\headheight\relax}{\topmargin=\dimexpr17mm-\headheight\relax}{\topmargin=\dimexpr15.35mm-\headheight\relax}
\LayVar{\headsep=\dimexpr9mm-\topskip\relax}{\headsep=\dimexpr14mm-\topskip\relax}{\headsep=\dimexpr13.35mm-\topskip\relax}{\headsep=\dimexpr10.5mm-\topskip\relax}

\LayVar{\evensidemargin=22mm\relax}{\evensidemargin=32mm\relax}{\evensidemargin=27mm\relax}{\evensidemargin=21.5mm\relax}
\LayVar{\oddsidemargin=18mm\relax}{\oddsidemargin=22mm\relax}{\oddsidemargin=19mm\relax}{\oddsidemargin=17.5mm\relax}

\LayVar{\textwidth=115mm\relax}{\textwidth=94mm\relax}{\textwidth=102mm\relax}{\textwidth=109mm\relax}
\LayVar{\textheight=\dimexpr44\baselineskip+\topskip\relax}{\textheight=\dimexpr34\baselineskip+\topskip\relax}{\textheight=\dimexpr37\baselineskip+\topskip\relax}{\textheight=\dimexpr40\baselineskip+\topskip\relax}
\newlength\headingsep
\LayVar{\headingsep=35mm\relax}{\headingsep=16mm\relax}{\headingsep=16mm\relax}{\headingsep=16mm\relax}
\parsep\z@
%% Abstand von part und chapter nach oben

\parindent5mm

\setlength{\skip\footins}{12.8bp \@plus 25.6bp}
\flushbottom
%\raggedbottom
\vfuzz=\z@

%%%%%%%%%%%%%%%
% Page Styles %
%%%%%%%%%%%%%%%

\def\ps@empty{%
  \let\@oddhead\@empty
  \let\@oddfoot\@empty
  \let\@evenhead\@empty
  \let\@evenfoot\@empty
}
\newif\ifhasparts \haspartsfalse

\def\ps@headings{%
  \def\left@side{\ifx\partmarkoverride\@undefined\ifcollection\ifx\authormark\@empty\leftmark\else\authormark\fi\else\ifhasparts\partmark\else\@title\fi\fi\else\partmarkoverride\fi}%
  \def\@oddhead{\hfill{\small\sffamily\leftmark\rlap{\hb@xt@8mm{\hfill\thepage}}%
      % \ifx\lay b\relax\llap{\smash{\lower1.35mm\hb@xt@\textwidth{\rule{\textwidth}{.4\p@}}}}\fi
    }}%
  \def\@evenhead{%
    % \ifx\lay b\relax\rlap{\smash{\lower1.35mm\hb@xt@\textwidth{\rule{\textwidth}{.4\p@}}}}\fi
    {\small\sffamily\llap{\hb@xt@8mm{\thepage\hfill}}\left@side}\hfill}%
  \let\@oddfoot\@empty
  \let\@evenfoot\@empty
    \def\chaptermark##1{%
  \ifcollection
    \markboth {##1}{}%
  \else
    \ifnum \c@secnumdepth >\m@ne
      \markboth {\thechapter\enskip##1}{}%
    \else
      \markboth {##1}{}%
    \fi
  \fi%
  }%
}
\pagestyle{headings}

\gdef\cleardoublepage{%
  \clearpage
  \ifodd\c@page\relax\else
    \ifx\lay f\else
      \hbox{}\thispagestyle{empty}\newpage
      \if@twocolumn\hbox{}\thispagestyle{empty}\newpage\fi
    \fi
  \fi}

\usepackage{color}
\usepackage{graphicx}

%%%%%%%%%%%%%%%%%
% Überschriften %
%%%%%%%%%%%%%%%%%

\renewcommand\thepart{\@Roman\c@part}
\renewcommand\part{%
  \cleardoublepage
  \pagestyle{empty}%
  \@tempswafalse
  \secdef\@part\@spart}

\def\partmark{}%
\let\oldaddcontentsline\addcontentsline

\def\@part[#1]#2{%
    \ifnum \c@secnumdepth >-2\relax
      \refstepcounter{part}%
    \fi
    \addcontentsline{toc}{part}{{#1}}%
    \def\partmark{#2}%
    \global\let\partmarkoverride\@undefined
    \markboth{}{}%
    {\interlinepenalty \@M
     \parindent\z@
     \null\vskip\headingsep%
     \sffamily\sbseries\HUGE
     \def\numberline##1{##1}%
     \HUGE #2\par}%
    \global\c@footnote0\relax
    \@endpart}

\def\@spart#1{%
    {\interlinepenalty \@M
     \parindent\z@
     \null\vskip\headingsep%
     \normalfont
     \sffamily\sbseries\HUGE
     #1\par}%
    \@endpart}

\newcount\real@chap \real@chap\z@
\renewcommand\chapter{\cleardoublepage
                    \pagestyle{headings}%
                    \thispagestyle{empty}%
                    \global\@topnum\z@
                    \@afterindentfalse
                    \global\c@footnote0\relax
                    \secdef\@chapter\@schapter}

\ifcollection\c@tocdepth=0\relax\else\c@tocdepth=3\relax\fi

\let\old@thechapter\thechapter
\newcount\realchap\realchap\z@

\def\@chapter[#1]#2{%
  \ifx\endnotes@per@chapter\relax
    \ifnum\c@endnote>\z@
      \expandafter\global\expandafter\let\csname enotes@in@\the\realchap\endcsname\@empty
    \fi
    \advance\realchap\@ne
    \global\c@endnote\z@
    \addtoendnotes{\noexpand\expandafter\noexpand\ifx\noexpand\csname enotes@in@\the\realchap\noexpand\endcsname\noexpand\@empty\bgroup\leftskip\z@\protect\section*{#1}\egroup\noexpand\fi}%
  \fi
  \hypersetup{bookmarksdepth=-1}%
  \ifx\@subtitle\@empty\else
    \addcontentsline{toc}{chapsub}{\@subtitle}%
  \fi
  \ifx\@author\@empty\else
    \addcontentsline{toc}{chapauthor}{\@author}%
  \fi
  \hypersetup{bookmarksdepth}%
  \ifnum \c@secnumdepth >\m@ne
    \if@mainmatter
      \refstepcounter{chapter}%
      \typeout{\@chapapp\space\thechapter.}%
      \ifcollection
        \addcontentsline{toc}{chapter}{#1}%
      \else
        \addtocontents{toc}{\protect\let\string\usenumberline\protect\relax}%
        \addcontentsline{toc}{chapter}{\numberline{\thechapter}#1}%
      \fi
    \else
      \addcontentsline{toc}{chapter}{#1}%
    \fi
  \else
    \addcontentsline{toc}{chapter}{#1}%
  \fi
  \chaptermark{#1}%
  \if@twocolumn
    \@topnewpage[\@makechapterhead{#2}]%
  \else
    \@makechapterhead{#2}%
    \@afterheading
  \fi
  %\let\thechapter\old@thechapter
}

\long\def\chapterquote#1{\long\gdef\@chapterquote{#1}}

\def\@makechapterhead#1{{%
  \parindent\z@
  \null\vskip\headingsep\vskip-.45mm\relax%
  {\parindent \z@ \raggedright \normalfont
    \Huge\sbseries
    \interlinepenalty\@M
    \if@mainmatter
      \bgroup
        \par
        \ifnum \c@secnumdepth >\m@ne
          \leftskip7mm
          {\sfchap
            \hskip-7mm\hb@xt@7mm{\thechapter\hfill}#1}\par%
          \ifx\@subtitle\@empty\else
            % \vskip.25\baselineskip
            {\normalfont\fontsize{14.7bp}{17.2bp}\selectfont\sffamily\@subtitle}\par
          \fi
          \global\let\partmarkoverride\@undefined
        \else
          {\sfchap#1}\par%
          \ifx\@subtitle\@empty\else
            {\normalfont\fontsize{14.7bp}{17.2bp}\selectfont\sffamily\@subtitle}\par%\vskip2mm
          \fi
        \fi
      \egroup
    \else
      {\sfchap#1}\par\nobreak
    \fi
  }%
  \vskip\dimexpr-1\baselineskip\relax\smash{\rlap{\lower3.5mm\vbox{\rule{\textwidth}{.4\p@}}}}\par%
  \global\let\authormark\@empty
  % \ifcollection
    \ifx\@author\@empty\else
      \bgroup\large
        \vskip\baselineskip
        \sfwide\itshape\@author%
        \xdef\authormark{\@author}%
      \egroup
    \fi
  % \fi
  \par%
  \ifx\@chapterquote\@undefined\else
    \ifx\@author\@empty\vskip\baselineskip\par\fi
    \savenotes
    \hfill\vbox{\hsize.5\textwidth%
      \vskip\baselineskip
      \normalsize\nsfwider
      \@chapterquote
    }%
    \spewnotes
  \fi
  \vskip1.68\baselineskip\relax
  \ifx\@author\@empty\ifx\@chapterquote\@undefined\vskip2\baselineskip\fi\fi
  \global\let\@subtitle\@empty
  \global\let\@author\@empty
  \global\let\@chapterquote\@undefined
}}

% \def\@schapter[#1]#2{\if@twocolumn
%                    \@topnewpage[\@makeschapterhead{#1}]%
%                  \else
%                    \@makeschapterhead{#1}%
%                    \@afterheading
%                  \fi}

\def\@makeschapterhead#1{%
  % \@makechapterhead{#1}%
  \null\vskip\headingsep\vskip-.45mm\relax%
  {\parindent \z@ \raggedright
    \Huge\sbseries\sffamily
    \interlinepenalty\@M
    #1\par\nobreak
    \vskip-\baselineskip\rlap{\lower3.1mm\vbox{\rule{\textwidth}{.4\p@}}}\par%
    \vskip1.62\baselineskip\relax
  }%
}

\long\def\secquote#1{%
    \savenotes
    \hfill\vbox{\hsize.5\textwidth%
      \normalsize\nsfwider\mdseries
      \noindent
      #1}%
    \vskip\baselineskip
    \spewnotes
    \@afterheading
    \ignorespaces}

\def\subheading{\@startsection{section}{1}{\z@}%
  {-1sp}%
  {12.8bp}%
  {\vskip-\lastskip\sffamily\LARGE}*}
\def\subsubheading{\@startsection{subsection}{1}{\z@}%
  {-12.8bp}%
  {\baselineskip}%
  {\vskip-\lastskip\sffamily\LARGE}*}

\renewcommand\section{\@startsection {section}{1}{\z@}%
  {-24.2bp}%
  {12.8bp}%
  {\sffamily\LARGE\sbseries
    % \ifx\lay b\relax \scshape\fi
  }}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
  {-11.5\p@}%
  {12.8bp}%
  {\sffamily\mdseries\Large}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
  {-12.8bp}%
  {1sp}%
  {\sffamily\Large\mdseries}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
  {-12.8bp}%
  {1sp}%
  {\normalfont\sfwide\normalsize}}
\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\z@}%
  {-12.8bp}%
  {-.5em}%
  {\sffamily\normalsize\mdseries}}

\let\old@thesection\thesection
\let\old@thesubsection\thesubsection
\let\old@thesubsubsection\thesubsubsection

\def\@startsection#1#2#3#4#5#6{%
  \expandafter\expandafter\expandafter\def\expandafter\expandafter\expandafter\@tempa\expandafter\expandafter\expandafter{\expandafter\expandafter\expandafter\global\expandafter\expandafter\expandafter\let\expandafter\expandafter\csname the#1\endcsname\csname old@the#1\endcsname}%
  \if@noskipsec \leavevmode \fi
  \par
  \@tempskipa #4\relax
  \@afterindenttrue
  \ifdim \@tempskipa <\z@
    \@tempskipa -\@tempskipa \@afterindentfalse
  \fi
  \if@nobreak
    \everypar{}%
  \else
    \addpenalty\@secpenalty\addvspace\@tempskipa
  \fi
  \@ifstar
    {\@ssect{#3}{#4}{#5}{#6}}%
    {\@dblarg{\@sect{#1}{#2}{#3}{#4}{#5}{#6}}}}

\def\@sect#1#2#3#4#5#6[#7]#8{%
  \ifnum #2>\c@secnumdepth
    \let\@svsec\@empty
  \else
    \refstepcounter{#1}%
    \protected@edef\@svsec{\@seccntformat{#1}\relax}%
  \fi
  \@tempskipa #5\relax
  \ifdim \@tempskipa>\z@
    \begingroup
      \raggedright
      #6{%
        \@hangfrom{\hskip #3\relax\@svsec}%
          \interlinepenalty \@M #8\@@par}%
    \endgroup
    \csname #1mark\endcsname{#7}%
    \ifnum #2>\c@secnumdepth \else
      \addtocontents{toc}{\protect\let\string\usenumberline\protect\relax}%
    \fi
    \ifnum #2>\c@tocdepth \else
      \addcontentsline{toc}{#1}{%
        \ifnum #2>\c@secnumdepth \else
          \protect\numberline{\csname the#1\endcsname}%
        \fi
        #7}%
    \fi
  \else
    \def\@svsechd{%
      #6{\hskip #3\relax
      \@svsec #8}%
      \csname #1mark\endcsname{#7}%
      \ifnum #2>\c@tocdepth \else
        \ifnum #2>\c@secnumdepth \else
          \addtocontents{toc}{\protect\let\string\usenumberline\protect\relax}%
        \fi
        \addcontentsline{toc}{#1}{%
          \ifnum #2>\c@secnumdepth \else
            \protect\numberline{\csname the#1\endcsname}%
          \fi
          #7}%
      \fi
    }%
  \fi
  \@xsect{#5}}

\def\@xsect#1{%
  \@tempskipa #1\relax
  \ifdim \@tempskipa>\z@
    \par \nobreak
    \vskip \@tempskipa
    \@afterheading
  \else
    \@nobreakfalse
    \global\@noskipsectrue
    \everypar{%
      \if@noskipsec
        \global\@noskipsecfalse
       {\setbox\z@\lastbox}%
        \clubpenalty\@M
        \begingroup \@svsechd \endgroup
        \unskip
        \@tempskipa #1\relax
        \hskip -\@tempskipa
      \else
        \clubpenalty \@clubpenalty
        \everypar{}%
      \fi}%
  \fi
  \@tempa
  \ignorespaces}


%%%%%%%
% TOC %
%%%%%%%
% \RequirePackage{bookmark}

\def\contentsname{Inhalt}%
\renewcommand\@dotsep{.5}
\renewcommand\tableofcontents{%
  \chapter*{\contentsname}\label{tableofcontents}%
  \pdfbookmark[0]{\contentsname}{tableofcontents}%
  \pagestyle{empty}%
  \@starttoc{toc}%
  \clearpage\pagestyle{headings}%
}

% \newif\ifusenumberline \usenumberlinetrue

\def\@dottedtocline#1#2#3#4#5{%
  \ifnum #1>\c@tocdepth \else
    \vskip \z@
    {\leftskip #2\relax \rightskip \@tocrmarg \parfillskip -\rightskip
     \parindent #2\relax\@afterindenttrue
     \interlinepenalty\@M
     \leavevmode
      \ifx\usenumberline\relax
        \@tempdima #3\relax
      \else
        \@tempdima\z@\relax
      \fi
     \advance\leftskip \@tempdima \null\nobreak\hskip -\leftskip
     \sffamily
     {#4}\nobreak
     \leaders\hbox{$\m@th
        \mkern \@dotsep mu\textnormal{\hbox{.}}\mkern \@dotsep
        mu$}\hfill
     \nobreak
     \kern.5\p@#5%
     \par}%
  \fi}

\def\@freedottedtocline#1#2#3#4#5{%%giovanni, 2019-11-27 (damit auch unter \c@tocdepth=0 was passiert)
    \vskip \z@
    {\leftskip #2\relax \rightskip \@tocrmarg \parfillskip -\rightskip
     \parindent #2\relax\@afterindenttrue
     \interlinepenalty\@M
     \leavevmode
      \ifx\usenumberline\relax
        \@tempdima #3\relax
      \else
        \@tempdima\z@\relax
      \fi
     \advance\leftskip \@tempdima \null\nobreak\hskip -\leftskip
     \sffamily
     {#4}\nobreak
     \leaders\hbox{$\m@th
        \mkern \@dotsep mu\textnormal{\hbox{.}}\mkern \@dotsep
        mu$}\hfill
     \nobreak
     \kern.5\p@#5%
     \par}}
\renewcommand*\l@figure{\@freedottedtocline{1}{0pt}{2.3em}}%giovanni, 2019-11-27
\let\l@table\l@figure%giovanni, 2019-11-27

\def\afterfi#1\fi{\fi#1}

\renewcommand*\l@chapter[2]{%
  \ifnum \c@tocdepth >\m@ne
    \ifcollection
      \vskip \baselineskip
      \begingroup
      \parindent \z@
      \raggedright
      \rightskip \@pnumwidth \@plus 1fil
      \hyphenpenalty=\@M
      \parfillskip -\@pnumwidth
      \leavevmode \sfwide\Large
      {\sbseries #1}%
      \ifx\toc@chapter@sub\@undefined\else
        \par\nopagebreak\toc@chapter@sub%
      \fi%
      \ifx\toc@chapter@aut\@undefined\else
        \par\nopagebreak%
        {\normalsize\itshape\toc@chapter@aut}%
      \fi%
      {\normalsize\leaders\hbox{$\m@th
          \mkern \@dotsep mu\textnormal{\hbox{.}}\mkern \@dotsep
          mu$}\hfill
        \kern.5\p@#2}\par
      \endgroup
      \global\let\toc@chapter@sub\@undefined
      \global\let\toc@chapter@aut\@undefined
    \else
      \addpenalty{-\@highpenalty}%
      \vskip \baselineskip
      \ifx\usenumberline\relax
        \@tempdima 2em\relax
      \else
        \@tempdima\z@\relax
      \fi
      \begingroup
      \parindent \z@
      \raggedright
      \rightskip \@pnumwidth \@plus 1fil
      \parfillskip -\@pnumwidth
      \hyphenpenalty=\@M
      \leavevmode \sffamily
      \advance\leftskip\@tempdima
      \hskip -\leftskip
      {\sbseries#1}%
      \ifx\toc@chapter@sub\@undefined\else
        \par\nopagebreak\toc@chapter@sub%
        \global\let\toc@chapter@sub\@undefined
      \fi%
      \nobreak
      \leaders\hbox{$\m@th
        \mkern \@dotsep mu\textnormal{\hbox{.}}\mkern \@dotsep
        mu$}\hfill
      \kern.5\p@#2\par
      \penalty\@highpenalty
      \endgroup
    \fi
  \fi
  \let\usenumberline\@undefined}

\renewcommand*\l@part[2]{%
  \ifnum \c@tocdepth >-2\relax
    \addpenalty{-\@highpenalty}%
    \addvspace{2.25em}%
    \setlength\@tempdima{3em}%
    \begingroup
    \parindent \z@ \rightskip \@pnumwidth
    \parfillskip -\@pnumwidth
    {\leavevmode
      \raggedright
      \sfwide\sbseries\huge
      \def\numberline##1{##1\nopagebreak}%
      #1\hfill\strut}\par
    \nobreak
    \global\@nobreaktrue
    \everypar{\global\@nobreakfalse\everypar{}}%
    \endgroup
  \fi}

\newcommand*\l@chapsub[2]{\gdef\toc@chapter@sub{\nobreak #1}}
\newcommand*\l@chapauthor[2]{\gdef\toc@chapter@aut{\nobreak #1}}

\renewcommand*\l@section{\@dottedtocline{1}{\z@}{2em}}
\renewcommand*\l@subsection{\@dottedtocline{2}{2em}{2.5em}}
\renewcommand*\l@subsubsection{\@dottedtocline{3}{4.5em}{3.0em}}
\renewcommand*\l@paragraph{\@dottedtocline{4}{7.5em}{3.5em}}
\renewcommand*\l@subparagraph{\@dottedtocline{5}{11.0em}{4.0em}}
% \ifx\lay b\relax
%   \ifcollection\else
%     \RequirePackage{titletoc}%
%     \setcounter{tocdepth}{1}%
%     \def\mytocrule{\nobreak\lower1\p@\hbox{\rule{1\p@}{\ht\strutbox}}}%
%     \titlecontents{part}[\z@]%
%       {\addvspace{1\baselineskip}%
%         \sfwide\sbseries\huge}%
%       {}%
%       {}%
%       {\enskip\mytocrule\enskip\thecontentspage}%
%     \titlecontents{chapter}[0em]%
%       {\addvspace{.5\baselineskip}\sbseries\sffamily\large\ifx\thecontentslabel\@empty\else\hangindent1em\hangafter1\fi\@tempdima.9em}%
%       {\hbox to 1em{\thecontentslabel\hss}}%
%       {}%
%       {\nobreak\enskip\mytocrule\enskip\nobreak{\normalfont\sffamily\thecontentspage}}%
%     \titlecontents*{section}[1em]%
%       {\sffamily\filright}%
%       {\ifx\thecontentslabel\@empty\else\thecontentslabel\enskip\fi}%
%       {}%
%       {\enskip\nobreak\thecontentspage}[\enskip\mytocrule\enskip][]%
%   \fi
% \fi

%%%%%%%%%%%%%
% Footnotes %
%%%%%%%%%%%%%
\usepackage{footnote}
%\@removefromreset{footnote}{chapter}
\def\footnoterule{\kern-6.4bp\hrule \@height .4bp \@width 33mm \kern 6bp} % the \hrule is .4pt high


% \def\@makefnmark{\smash{\textsuperscript{\@thefnmark}}}
\def\@makefnmark{\hbox{\@textsuperscript{\selectfont\@thefnmark}}}%(giovanni, 2019-07-30)
\newlength\fnumwidth \fnumwidth2em


% Define the \urlx command which works like \url, but with line brakes
% \def\fnurlhref#1#2{\old@href{#1}{#2}}

\renewcommand\@makefntext[1]{%
    \parindent\z@%
    \leftskip\fnumwidth
    \bgroup\nsfwider
      \hskip-\fnumwidth\hb@xt@\fnumwidth{{\nsfwider\@thefnmark}\hss}%
      \let\href\fn@href
      #1%
    \egroup}

\newif\if@enotesopen
\ifendnotes
  \RequirePackage{endnotes}
  \let\footnote=\endnote
  \def\enotesize{\normalsize}%
  \def\enoteformat{\leavevmode\hskip-2em\hb@xt@2em{\@theenmark\hss}}%
  \def\enoteheading{%
    \ifcollection
      \ifx\endnotes@per@chapter\relax
        \chapter*{\notesname}%
        \ifx\noendnotetoc\@undefined
          \addcontentsline{toc}{chapter}{\notesname}%
        \fi
      \else
        \section*{\notesname}%
        \ifx\noendnotetoc\@undefined
          \addcontentsline{toc}{chapter}{\notesname}%
        \fi
      \fi
    \else
      \chapter*{\notesname}%
      \ifx\noendnotetoc\@undefined
        \addcontentsline{toc}{chapter}{\notesname}%
      \fi
    \fi
    \leftskip2em
  }%
  \def\printnotes{%
    \ifx\endnotes@per@chapter\relax
      \ifnum\c@endnote>\z@
        \expandafter\global\expandafter\let\csname enotes@in@\the\realchap\endcsname\@empty
      \fi
    \fi
    \if@enotesopen
      \global\c@endnote\z@%
      \bgroup
      \parindent\z@
      \parskip\z@
      \theendnotes
      \egroup
    \fi}
\else
  \let\printnotes\relax
\fi

%%%%%%%%%%%%%%%%
% Gleitobjekte %
%%%%%%%%%%%%%%%%
\usepackage[figuresright]{rotating}
\usepackage{tabularx}
\usepackage{multirow}

\newcolumntype{Q}{>{\raggedright\arraybackslash\unskip}X} % gleich wie X, nur bei einer Kolumne verwenden, mk
\newcolumntype{W}{>{\raggedleft\arraybackslash\unskip}X} % rechtsbündig, wie X, nur 1x verwenden
\newcolumntype{L}{>{\raggedright\arraybackslash\unskip}p} % wie p nur linksbündig*
\newcolumntype{P}{>{\RaggedRight\arraybackslash\unskip}p} % wie p und linksbündig und erlaubt Silbentrennung*
\newcolumntype{R}{>{\raggedleft\arraybackslash\unskip}p} % rechtsbündig, wie p*
\newcolumntype{C}{>{\centering\arraybackslash\unskip}X} % zentriert wie X
\newcolumntype{Z}{>{\centering\arraybackslash\unskip}p} % zentriert wie p*
\newcolumntype{e}{!{\extracolsep{\fill}}} % wird nicht verwendet

\usepackage{caption}

\renewcommand \thefigure
     {\@arabic\c@figure}
\@removefromreset{figure}{chapter}

\renewcommand \thetable
     {\@arabic\c@table}
\@removefromreset{table}{chapter}

\captionsetup{%
   format=plain
  ,labelformat=empty
  ,font+=it
  ,singlelinecheck=false
  ,justification=RaggedRight
  ,listformat=empty
}

\newlength\aboveSourceSkip \aboveSourceSkip0mm
\newcommand\transcriptBild[2]{\tr@nscriptFloat{#1}{#2}}
\newcommand\transcriptTab[2]{\aboveSourceSkip1mm\let\use@depth\relax\tr@nscriptFloat{#1}{#2}}

\newbox\tr@nscriptFlt
\newdimen\tr@nscriptFltWd
\newdimen\tr@nscriptWd
\newdimen\tr@nscriptHt
\newdimen\tr@nscriptSep


%% BEGIN: sameheight
\newbox\@includesubgraphicsbox
\newcount\c@includesubgraphics \c@includesubgraphics\z@
\newdimen\includesubgraphics@maxheight
\newdimen\subgraphicssep \subgraphicssep\fboxsep
\newdimen\shhsize \shhsize=\hsize\relax
\newdimen\sh@margins
\RequirePackage{ltxcmds}

\newcommand*\includesubgraphics[2]{%
  \global\advance\c@includesubgraphics\@ne
  \ltx@LocalExpandAfter\gdef\csname subgraphics@caption@\the\c@includesubgraphics\endcsname{#1}%
  \ltx@LocalExpandAfter\gdef\csname subgraphics@name@\the\c@includesubgraphics\endcsname{#2}%
  \setbox\@includesubgraphicsbox\hbox{\includegraphics{#2}}%
  \ltx@LocalExpandAfter\xdef\csname subgraphics@width@\the\c@includesubgraphics\endcsname{\the\wd\@includesubgraphicsbox}%
  \ltx@LocalExpandAfter\xdef\csname subgraphics@height@\the\c@includesubgraphics\endcsname{\the\ht\@includesubgraphicsbox}%
  \expandafter\ifdim\csname subgraphics@height@\the\c@includesubgraphics\endcsname>\includesubgraphics@maxheight\relax
    \ltx@LocalExpandAfter\global\expandafter\includesubgraphics@maxheight=\csname subgraphics@height@\the\c@includesubgraphics\endcsname\relax
  \fi}

\def\CalcRatio#1#2{\strip@pt\dimexpr\number\numexpr\number\dimexpr#1\relax*65536/\number\dimexpr#2\relax\relax sp}

%% Gehe schrittweise durch counter #1, startend bei #2 bis einschließlich #3 und tue nach jeder Inkrementierung #4 (aus forloop.sty):
\long\def\sh@iterate#1#2#3#4{% #1=counter; #2=Startwert; #3=Endwert; #4=Anweisungen
  \advance#1\@ne\relax
  #1=#2\relax%
  \expandafter\ifnum#1>#3\relax%
  \else
    #4%
    \sh@iterate{#1}{\the#1}{#3}{#4}%
  \fi}%


\def\sameheight#1{%
  \bgroup
  \let\c@psource\@undefined
  \c@includesubgraphics=\z@\relax
  \let\@shhsize\shhsize
  \includesubgraphics@maxheight=\z@\relax
  %% Measurement
  \setbox\@tempboxa\hbox{#1}%
  %% 1st iteration: Calculate widths of all subfigures when scaled up to the highest subfigure's height:
  %% \@tempdima: total sum of those widths
  \@tempdima=\z@\relax
  \sh@iterate{\@tempcnta}{\@ne}{\c@includesubgraphics}{%
    \edef\@tempa{\CalcRatio{\includesubgraphics@maxheight}{\csname subgraphics@height@\the\@tempcnta\endcsname}}%
    \ifnum\@tempcnta>\@ne\global\advance\@shhsize-\subgraphicssep\relax\fi
    \expandafter\@tempdimc\csname subgraphics@width@\the\@tempcnta\endcsname\relax
    \@tempdimb=\@tempa\@tempdimc\relax
    \expandafter\xdef\csname  subgraphics@adjusted@width@\the\@tempcnta\endcsname{\the\@tempdimb}%
    \global\advance\@tempdima\@tempdimb
  }%
  %% 2nd iteration: Calculate width ratio of all adjusted subfigures against total width of all figures plus separators and output:
  \@tempcnta\z@
  \sh@iterate{\@tempcnta}{\@ne}{\c@includesubgraphics}{%
    \edef\@tempa{\CalcRatio{\csname subgraphics@adjusted@width@\the\@tempcnta\endcsname}{\@tempdima}}%
    \@tempdimb\@tempa\@shhsize\relax
    \edef\@tempb{\csname subgraphics@name@\the\@tempcnta\endcsname}%
    \ifnum\@tempcnta>\@ne\hskip\subgraphicssep\fi
    \def\@igopts{width=\linewidth}%
    \begin{minipage}[b]{\@tempdimb}%
      \captionsetup{margin=\z@}%
      \expandafter\ifx\csname subgraphics@caption@\the\@tempcnta\endcsname\relax\else%
        \csname subgraphics@caption@\the\@tempcnta\endcsname%
      \fi
      \expandafter\expandafter\expandafter\includegraphics\expandafter\expandafter\expandafter[\expandafter\@igopts\expandafter]\expandafter{\@tempb}%
      \ifx\c@psource\@undefined\else
        \ifhmode\par\fi
        \vskip\dimexpr-\topskip+\aboveSourceSkip+.5mm\relax
        \vtop{\captionsetup{font=footnotesize}\caption*{\c@psource}}%
        \global\let\c@psource\@undefined
      \fi
    \end{minipage}%
  }%
  \egroup
}

%% END: sameheight

\newcommand\transcriptFixedFigure[3]{% #1: caption, #2: Layout-Variante, #3 Teilbilder
  \bgroup
    \def\@captype{figure}%
  \shhsize\hsize
  \subgraphicssep2mm
  \ifx#2A\relax
    \@tempdima\z@
  \else
    \ifx#2B\relax
      \@tempdima20mm
    \else
      \ifx#2C\relax
        \@tempdima30mm
      \else
        \ifx#2D\relax
          \@tempdima60mm
        \fi
      \fi
    \fi
  \fi
  \advance\shhsize-\@tempdima
  \sh@margins.5\@tempdima
  \vskip1\baselineskip
  \captionsetup{margin=\sh@margins\relax}%
  \if!#1!\else#1\fi
  \ifhmode\par\fi
  \noindent\hskip\sh@margins\sameheight{#3}%
  \ifx\c@psource\@undefined\else
    \ifhmode\par\fi
    \vskip\aboveSourceSkip
    \captionsetup{font=footnotesize,skip=-1mm}%
    \caption*{\c@psource}%
    \global\let\c@psource\@undefined
  \fi
  \egroup}

\def\capsource#1{\def\c@psource{#1}}%

\let\oldfigure\figure
\let\oldendfigure\endfigure

\renewenvironment{figure}{\savenotes\oldfigure}{\oldendfigure\spewnotes}


\long\def\tr@nscriptFloat#1#2{%
  \def\@rgi{#1}%
  \setbox\tr@nscriptFlt\hbox{\ignorespaces#2}%
  \tr@nscriptFltWd=\wd\tr@nscriptFlt\relax
  \tr@nscriptHt=\dimexpr\ht\tr@nscriptFlt\ifx\use@depth\relax+\dp\tr@nscriptFlt\fi\relax
  \tr@nscriptSep\dimexpr(\textwidth-\tr@nscriptFltWd)/2\relax
  \vskip\baselineskip
  \ifx\@rgi\@empty
    \begin{minipage}{\tr@nscriptFltWd}\centering%
      \unhbox\tr@nscriptFlt\par
    \end{minipage}%
  \else
    \ifdim\tr@nscriptFltWd<.5\textwidth\relax
      \bgroup
        % \tr@nscriptSep4mm
        \tr@nscriptWd\dimexpr\textwidth-\tr@nscriptFltWd\relax
        \noindent\begin{minipage}[\ifx\use@depth\relax t\else b\fi][\tr@nscriptHt][t]{\tr@nscriptWd}%
          \captionsetup{justification=RaggedRight}%
          \def\@captype{figure}%
          #1%
          \ifx\c@psource\@undefined\else
            \vfill
            \captionsetup{font=footnotesize,skip=\z@}%
            \caption*{\c@psource}%
            \vspace*{\dimexpr-\dp\tr@nscriptFlt-1mm}%
            \global\let\c@psource\@undefined
          \fi
        \end{minipage}\hfill
        \begin{minipage}[t][\tr@nscriptHt]{\tr@nscriptFltWd}\centering
          \unhbox\tr@nscriptFlt%
        \end{minipage}%
      \egroup
    \else
      \noindent\hskip\tr@nscriptSep
      \begin{minipage}{\tr@nscriptFltWd}\centering%
        \def\@captype{figure}%
        #1%
        \unhbox\tr@nscriptFlt\par
        \ifx\c@psource\@undefined\else
          \ifhmode\par\fi
          \vskip\aboveSourceSkip
          \captionsetup{font=footnotesize,skip=-1mm}%
          \captionof*{figure}{\c@psource}%
          \vspace*{\dimexpr-\dp\tr@nscriptFlt-1mm}%
          \global\let\c@psource\@undefined
        \fi
      \end{minipage}%
    \fi
  \fi
  \vskip\baselineskip
  \global\let\use@depth\@undefined
  \tr@nscriptWd\z@% \tr@nscriptSep\z@
}

\def\tablefont{\nsffamily\footnotesize}
\def\arraystretch{1.3}
\def\@tabular{%
  \leavevmode
  \hbox \bgroup\tablefont $\col@sep\tabcolsep \let\d@llarbegin\begingroup%$
                                    \let\d@llarend\endgroup
  \ifx\ST@tableformat\@undefined\gdef\@tablefont{\tablefont}\fi
  \@tabarray}
\let\@classzold\@classz
\def\@classz{%
   \expandafter\ifx\d@llarbegin\begingroup
     \toks \count@ =
     \expandafter{\expandafter\@tablefont\the\toks\count@}%
   \fi
   \@classzold}
\def\endtabular{%
  \endarray
  $\egroup}%$
\expandafter\let\csname endtabular*\endcsname=\endtabular



%%%%%%%%%%%%%%%%%%%%%%%
% Gestaltungselemente %
%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{framed}
\def\FrameHeightAdjust{\topskip}
\FrameRule\z@
\FrameSep2mm

\def\@afterbox{%
  \everypar{%
    \if@nobreak
      \@nobreakfalse
      \clubpenalty \@M
      \if@afterindent \else
        {\setbox\z@\lastbox}%
        \everypar{}%2015-04-09
      \fi
    \else
      \clubpenalty \@clubpenalty
      {\setbox\z@\lastbox}%
      \everypar{}%
    \fi}}

\let\orig@doendpe\@doendpe
\newenvironment{kastengrau}{%
  \def\FrameCommand{\fboxsep\FrameSep \colorbox[gray]{0.75}}%
  \savenotes
  \begin{framed}%
    \noindent\nsffamily\ignorespaces
  }{\end{framed}%
  \spewnotes
  \aftergroup\@afterbox}

\newenvironment{kastenlinie}{%
  \FrameSep3mm
  \fboxrule.5bp
  \savenotes
  \def\FrameCommand{\fboxsep\FrameSep \fbox}%
  \begin{framed}%
    \noindent\nsffamily\ignorespaces\@afterheading
  }{\end{framed}%
  \spewnotes
  \aftergroup\@afterbox}

\renewenvironment{quotation}
{\noindent\list{}{%
    \listparindent\z@%
    \parindent\z@
    \itemindent    \listparindent
    \leftmargin \parindent
    \rightmargin   \z@
    \nsfwider
    \topsep6.4bp
    \parsep        \z@}%
\item\noindent\ignorespaces}
{\endlist
 \noindent
 \gdef\@doendpe{%
    \@endpetrue
    \everypar{{\setbox\z@\lastbox}\global\everypar{}\@endpefalse}%
    \global\let\@doendpe\orig@doendpe}}

\renewenvironment{quote}
{\noindent\par\list{}{\rightmargin\leftmargin\nsfwider}%
\item\relax}
{\endlist\par\gdef\@doendpe{%
    \@endpetrue
    \everypar{{\setbox\z@\lastbox}\global\everypar{}\@endpefalse}%
    \global\let\@doendpe\orig@doendpe}}

\renewenvironment{verse}
{\noindent\par\list{}{%
    \listparindent\z@%
    \parindent\z@
    \itemindent    \listparindent
    \leftmargin 5mm
    \rightmargin   \z@
    \rightskip\rightmargin\@plus1fil
    \nsfwider
    \topsep6.4bp
    \parsep        .5\baselineskip}%
\item\noindent\ignorespaces}
{\endlist
 \par
 \gdef\@doendpe{%
   \@endpetrue
   \everypar{{\setbox\z@\lastbox}\global\everypar{}\@endpefalse}%
   \global\let\@doendpe\orig@doendpe}}
\newenvironment{versecentered}
{\noindent\par\list{}{%
    \listparindent\z@%
    \parindent\z@
    \itemindent    \listparindent
    \leftmargin \z@
    \rightmargin   \z@
    \rightskip \z@
    \nsfwider
    \topsep6.4bp
    \parsep        .5\baselineskip}%
    \centering
\item\noindent\ignorespaces}
{\endlist
 \par
 \gdef\@doendpe{%
   \@endpetrue
   \everypar{{\setbox\z@\lastbox}\global\everypar{}\@endpefalse}%
   \global\let\@doendpe\orig@doendpe}}

\newenvironment{motto}
               {\noindent\par\list{}{\rightmargin\leftmargin
                   \parsep6.4bp
                   \partopsep\z@
                   \parindent\z@
                   \nsfwider}%
                \item\relax}
               {\endlist\par\gdef\@doendpe{%
    \@endpetrue
    \everypar{{\setbox\z@\lastbox}\global\everypar{}\@endpefalse}%
    \global\let\@doendpe\orig@doendpe}}

\newenvironment{widmung}{%
  \cleardoublepage
  \bgroup
    \parindent\z@
    \thispagestyle{empty}%
    \null\vskip\dimexpr\headingsep+1\baselineskip-.45mm\relax%
    \parindent \z@
    \raggedright \normalfont
    \itshape
    \centering\par
  }{\par\egroup\aftergroup\cleardoublepage}


\usepackage{enumerate}

\leftmargini\parindent
\leftmarginii2\parindent

%% Überdef
\def\@enum@{%
  \list{\csname label\@enumctr\endcsname}%
  {\labelsep\z@
   \itemsep\z@
   \ifnum \@enumdepth=\@ne
     \leftmargin\parindent
     \labelwidth\parindent
   \else
     \@tempdima3mm
     \leftmargin\dimexpr\@enumdepth\@tempdima\relax
     \labelwidth\dimexpr\@enumdepth\@tempdima\relax
     \itemindent\z@%\leftmargin
   \fi
   \parsep\z@
   \ifnum \@enumdepth=\@ne\topsep12.8bp\else\topsep\z@\fi
   \usecounter\@enumctr%
   \def\makelabel##1{\small##1\hss}}}

\def\itemize{%
  \ifnum \@itemdepth >\thr@@\@toodeep\else
    \advance\@itemdepth\@ne
    \@enumdepth=\@itemdepth
    \edef\@itemitem{labelitem\romannumeral\the\@itemdepth}%
    \expandafter
    \list
      \csname\@itemitem\endcsname
      {\topsep12.8bp
       \labelsep\z@
       \itemsep\z@
       \parsep\z@
       \labelwidth\csname leftmargin\romannumeral\the\@itemdepth\endcsname
       \def\makelabel##1{##1\hss}}%
  \fi}

\newenvironment{dialog}{%
  \list{}%
  {\leftmargin5mm
   \labelsep1em
   \labelwidth\dimexpr5mm-\labelsep\relax
   \itemsep\z@
   \itemindent\z@
   \parsep\z@
   \topsep12.8bp
   \def\makelabel##1{{\ignorespaces\itshape##1\ignorespaces}}}%
}{\endlist}


%%%%%%%%%%%%%%%%%%%%%%%%
% Literaturverzeichnis %
%%%%%%%%%%%%%%%%%%%%%%%%

\usepackage{placeins}
\usepackage{natbib}
\bibsep\z@
\bibhang\parindent

\def\bibfont{\ifx\NoAutoSpacing\@undefined\else\NoAutoSpacing\fi}%Ticket 7647 (giovanni, 2019-11-04)

\@ifundefined{chapter}{%
  \renewcommand\bibsection{\FloatBarrier\section*{\refname}%
  }}{\@ifxundefined\NAT@sectionbib{\FloatBarrier\renewcommand\bibsection{\chapter*{\bibname}%
    }}{\renewcommand\bibsection{\FloatBarrier\section*{\bibname}}}}%

\renewenvironment{thebibliography}[1]{%
  \FloatBarrier
  %\bibsection
  % \chaptermark{\chaptername}
  \parindent\z@
  \bibpreamble
  \bibfont
  \list{\@biblabel{\the\c@NAT@ctr}}{\@bibsetup{#1}\global\c@NAT@ctr\z@}%
 \ifNAT@openbib
   \renewcommand\newblock{\par}%
 \else
   \renewcommand\newblock{\hskip .11em \@plus.33em \@minus.07em}%
 \fi
 \sloppy
  \clubpenalty\@M
  \widowpenalty\@M
 \sfcode`\.\@m
 \let\NAT@bibitem@first@sw\@firstoftwo
    \let\citeN\cite \let\shortcite\cite
    \let\citeasnoun\cite
}{%
 \bibitem@fin
 \bibpostamble
 \def\@noitemerr{%
  \PackageWarning{natbib}{Empty `thebibliography' environment}%
 }%
 \endlist
 \bibcleanup
}%


\def\source#1{\leavevmode\par#1}

%% Titelei

\def\@tempa{%
  \def\lectoratename{Lectorate: }%
  \def\qualificationname{Qualification: }%
  \def\translatorname{Translator: }%
  \def\appraisername{Appraiser: }%
  \def\coverdesignname{Cover design: }%
  \def\coverimagename{Cover illustration: }%
  \def\QandAname{Quality Assurance: }%
  \def\typesettername{Layout: }%
  \def\printname{Printed by }%
  \def\isbnname{Print-ISBN}%
  \def\eisbnname{PDF-ISBN}%
  \def\epubisbnname{EPUB-ISBN}%
  \def\editorabbrevname{(Ed.)}%
  \def\conversionname{Conversion: }%
  \def\volname{Volume}%
  \def\keywordsname{Keywords: }%
  \def\copyrightDisclaimername{All rights reserved!}%
  \def\discussionname{Discussion: }%
  \def\biblioinfoname{{\sffamily\sbseries Bibliographic information published by the Deutsche Nationalbibliothek}\\
    The Deutsche Nationalbibliothek lists this publication in the Deutsche Nati-onalbibliografie; detailed bibliographic data are available in the Internet at \url{http://dnb.d-nb.de}}%
  \def\cctextname{PLEASE SPECIFY THE LICENCE TEXT WITH THE \verb»\cctext» MACRO!}%
}
\expandafter\addto\expandafter\captionsbritish\expandafter{\@tempa}
\expandafter\addto\expandafter\captionsUKenglish\expandafter{\@tempa}
\expandafter\addto\expandafter\captionsenglish\expandafter{\@tempa}
\expandafter\addto\expandafter\captionsamerican\expandafter{\@tempa}
\expandafter\addto\expandafter\captionsUSenglish\expandafter{\@tempa}

\def\@tempa{%
  \def\lectoratename{Lektorat: }
  \def\translatorname{Übersetzer: }%
  \def\qualificationname{Qualifikationsnachweis: }%
  \def\coverdesignname{Umschlaggestaltung: }%
  \def\coverimagename{Umschlagabbildung: }%
  \def\appraisername{Gutachter: }%
  \def\QandAname{Korrektorat: }%
  \def\typesettername{Satz: }%
  \def\printname{Druck: }%
  \def\isbnname{Print-ISBN}%
  \def\eisbnname{PDF-ISBN}%
  \def\epubisbnname{EPUB-ISBN}%
  \def\editorabbrevname{(Hg.)}%
  \def\conversionname{Konvertierung: }
  \def\volname{Band}%
  \def\keywordsname{Schlagworte: }%
  \def\discussionname{Besprechung: }%
  \def\copyrightDisclaimername{Alle Rechte vorbehalten. Die Verwertung der Texte
  und Bilder ist ohne Zustimmung des Verlages urheberrechtswidrig und
  strafbar. Das gilt auch für Vervielfältigungen, Übersetzungen,
  Mikroverfilmungen und für die Verarbeitung mit elektronischen
  Systemen.}%
  \def\biblioinfoname{{\sffamily\sbseries Bibliografische Information der Deutschen Nationalbibliothek}\\
    Die Deutsche Nationalbibliothek verzeichnet diese Publikation in der Deutschen Nationalbibliografie; detaillierte bibliografische Daten sind im Internet über \url{http://dnb.d-nb.de} abrufbar.}%
  \def\cctextname{Dieses Werk ist lizenziert unter der Creative Commons Attribution-NonCommercial-NoDerivs 4.0 Lizenz (BY-NC-ND). Diese Lizenz erlaubt die private Nutzung, gestattet aber keine Bearbeitung und keine kommerzielle Nutzung. Weitere Informationen finden Sie unter \url{https://creativecommons.org/licenses/by-nc-nd/4.0/deed.de}\\
Um Genehmigungen für Adaptionen, Übersetzungen, Derivate oder Wiederverwendung zu kommerziellen Zwecken einzuholen, wenden Sie sich bitte an \url{rights@transcript-verlag.de}\\
Die Bedingungen der Creative-Commons-Lizenz gelten nur für Originalmaterial. Die Wiederverwendung von Material aus anderen Quellen (gekennzeichnet mit Quellenangabe) wie z.B. Schaubilder, Abbildungen, Fotos und Textauszüge erfordert ggf. weitere Nutzungsgenehmigungen durch den jeweiligen Rechteinhaber.}
}
\expandafter\addto\expandafter\captionsgerman\expandafter{\@tempa}
\expandafter\addto\expandafter\captionsngerman\expandafter{\@tempa}


\def\the@authorinfos{}
\let\authormark\@empty
\def\authorinfo#1#2{\expandafter\def\expandafter\the@authorinfos\expandafter{\the@authorinfos{\sbseries #1} #2\par}}
\def\edition#1{\def\@edition{#1}} \edition{}%
\def\editor#1{\def\@editor{#1}} \editor{}%
\def\volume#1{\def\@volume{#1}}       \volume{}%
\def\subtitle#1{\def\@subtitle{#1}} \subtitle{}%
\def\logo#1{\let\@logo\@empty\if!#1!\else\def\@logo{\includegraphics{#1}}\fi} \logo{}
\def\thanks#1{\def\@thanks{#1}} \thanks{}
\def\biblioInfo#1{%
  \def\@biblioInfo{\biblioinfoname}%
  \if!#1!\else\def\@biblioInfo{#1}\fi} \biblioInfo{}
\def\publ#1{\def\@publ{#1}} \publ{transcript Verlag}
\def\publyear#1{\def\@publyear{#1}} \publyear{2019}
\def\place#1{\def\@place{#1}} \place{Bielefeld}
\long\def\editorial#1{\long\def\@editorial{#1}} \editorial{}
\newif\ifdocopydisclaimer \docopydisclaimertrue

\def\copyrightDisclaimer#1{\def\@copyrightDiscl{#1}}
\copyrightDisclaimer{\copyrightDisclaimername}

\newif\ifprintpublinfo \printpublinfotrue
\def\environmentDisclaimer#1{\def\@envdiscl{#1}} \environmentDisclaimer{Gedruckt auf alterungsbeständigem Papier mit chlorfrei gebleichtem Zellstoff.}
\def\publweb#1{\def\@publweb{#1}}                \publweb{Besuchen Sie uns im Internet: \url{https://www.transcript-verlag.de}}
\def\publgesamt#1{\def\@publgesamt{#1}}          \publgesamt{Bitte fordern Sie unser Gesamtverzeichnis und andere Broschüren an unter:\\\url{info@transcript-verlag.de}}

\def\granttext#1{\def\@granttext{#1}}     \granttext{}

\def\dedication#1{\def\@dedication{#1}}     \dedication{}
\def\lectorate#1{\def\@lectorate{#1}}     \lectorate{}
\def\translator#1{\def\@translator{#1}}     \translator{}
\def\qualification#1{\def\@qualification{#1}}     \qualification{}
\def\appraiser#1{\def\@appraiser{#1}}     \appraiser{}
\def\coverDesign#1{\def\@coverdesign{#1}} \coverDesign{}
\def\coverImage#1{\def\@coverimage{#1}}   \coverImage{}
\def\QandA#1{\def\@QandA{#1}}             \QandA{}
\def\typesetter#1{\def\@typesetter{#1}}   \typesetter{}
\def\print#1{\def\@print{#1}}             \print{}
\def\isbn#1{\def\@isbn{#1}}               \isbn{}
\def\eisbn#1{\def\@eisbn{#1}}             \eisbn{}
\def\epubisbn#1{\def\@epubisbn{#1}}       \epubisbn{}
\def\doi#1{\def\@doi{#1}}                 \doi{}
\def\conversion#1{\def\@conversion{#1}}   \conversion{}
\def\shorttext#1{\def\@shorttext{#1}}     \shorttext{}
\def\keywords#1{\def\@keywords{#1}}       \keywords{}
\def\discussion#1{\def\@discussion{#1}}   \discussion{}

\def\ccimage#1{\def\@ccimage{#1}}         \ccimage{}
\def\cctext#1{\def\cctextname{#1}} \AtBeginDocument{\cctext{\cctextname}}

\def\grantlogo#1{\def\@grantlogo{#1}}     \grantlogo{}
\def\granttext#1{\def\@granttext{#1}}     \granttext{}



\def\maketitle{%
  \bgroup
    \parindent\z@
    \def\UrlFont{\rmfamily\itshape}%
    \fontsize{9.5}{11}\selectfont
    %% Seite i
    \thispagestyle{empty}%
    \ifx\@editor\@empty
      \@author
    \else
      \@editor\space\editorabbrevname
    \fi\par
    \@title\par
    \vfill
    \ifx\@edition\@empty\else{\fontsize{10.5}{11}\selectfont\sfwider\@edition}\ifx\@band\@empty\else\enskip\lower.5\dp\strutbox\hbox{\rule{.5\p@}{\ht\strutbox}}\enskip \volname~\@volume\fi\fi
    \clearpage
    %% Seite ii
    \thispagestyle{empty}%
    \if\@editorial\@empty\null\else{\parskip\baselineskip\textsf{Editorial}\par\@editorial}\fi\par
    \vfill
    \ifx\the@authorinfos\@empty\else\the@authorinfos\fi
    \clearpage
    %% Seite iii
    \thispagestyle{empty}%
    \textsc{\large\ifx\@editor\@empty
      \@author
    \else
      \@editor\space(Hg.)
    \fi}\par
    \vskip5\p@
    {\sfwider{\fontsize{15.5}{19}\selectfont\@title}\par
      \vskip5\p@
      \fontsize{10.5}{12}\selectfont\ifx\@subtitle\@empty\else\@subtitle\par\fi}%
    \vfill
    \@logo
    \clearpage
    %% Seite iv
    \thispagestyle{empty}%
    \ifx\@thanks\@empty\null\else\@thanks\fi\par
    \ifx\@dedication\@empty\else\vskip\baselineskip{\itshape\@dedication}\par\fi
    \ifx\@shorttext\@empty\else\vskip\baselineskip\@shorttext\par\fi
    \vfill
    {\@biblioInfo}\par%
    \ifx\@ccimage\@empty\else
      \vskip\baselineskip
      \includegraphics{\@ccimage}\\
      {\footnotesize\cctextname}\par
    \fi
    \ifx\@grantlogo\@empty\else
      \vskip\baselineskip
      \includegraphics{\@grantlogo}\\
      {\footnotesize\@granttext}\par
    \fi
    \vskip\baselineskip
    {\sfwide\bfseries \textcopyright\space\@publyear\space\@publ,\space\@place}\par%
    \vskip\baselineskip
    \ifdocopydisclaimer\@copyrightDiscl\fi\par
    \vskip\baselineskip
    \bgroup
    \parindent-5mm\leftskip5mm
      \ifx\@qualification\@empty\else \qualificationname\@qualification\par\fi
      \ifx\@conversion\@empty\else \conversionname\@conversion\par\fi
      \ifx\@coverdesign\@empty\else \coverdesignname\@coverdesign\par\fi
      \ifx\@coverimage\@empty\else \coverimagename\@coverimage\par\fi
      \ifx\@lectorate\@empty\else \lectoratename\@lectorate\par\fi
      \ifx\@QandA\@empty\else \QandAname\@QandA\par\fi
      \ifx\@translator\@empty\else \translatorname\@translator\par\fi
      \ifx\@appraiser\@empty\else \appraisername\@appraiser\par\fi
      \ifx\@discussion\@empty\else \discussionname\space\@discussion\par\fi
      \ifx\@typesetter\@empty\else \typesettername\@typesetter\par\fi
      \ifx\@print\@empty\else \printname\@print\par\fi
      \ifx\@isbn\@empty\else \isbnname\space\@isbn\par\fi
      \ifx\@eisbn\@empty\else \eisbnname\space\@eisbn\par\fi
      \ifx\@epubisbn\@empty\else \epubisbnname\space\@epubisbn\par\fi
      \ifx\@doi\@empty\else {\def\UrlFont{\rmfamily}\url{https://doi.org/\@doi}}\par\fi
      \ifx\@keywords\@empty\else \keywordsname\space\@keywords\par\fi
    \egroup
    \ifprintpublinfo
      \vskip\baselineskip
      \@envdiscl\\
      \@publweb\\
      \@publgesamt
    \fi
  \egroup
  \global\let\@subtitle\@empty
  \global\let\@author\@empty
  \clearpage}
\global\let\@author\@empty

\newenvironment{authorbio}{\noindent\ignorespaces}{\par\vskip\baselineskip}
\def\flq{‹}
\def\frq{›}

\usepackage[breaklinks=true,linktocpage,pdfborder={0 0 0},pdfencoding=auto,bookmarksnumbered=true,linktoc=all]{hyperref}
\usepackage[normalem]{ulem}
\usepackage{soul}


%% Register
\usepackage{index}
\makeindex
%% aus index.sty

\renewenvironment{theindex}{%
        \edef\indexname{\the\@nameuse{idxtitle@\@indextype}}%
        \if@twocolumn
            \@restonecolfalse
        \else
            \@restonecoltrue
        \fi
        \columnseprule \z@
        \columnsep 35\p@
        \twocolumn[%
            \@makeschapterhead{\indexname}%
            \addcontentsline{toc}{chapter}{\indexname}%
            \ifx\index@prologue\@empty\else
                \index@prologue
                \bigskip
            \fi
        ]%
        \@mkboth{\indexname}{\indexname}%
        \thispagestyle{empty}%
        \parindent\z@
        \parskip\z@ \@plus .3\p@\relax
        \let\item\@idxitem
    }{%
        \if@restonecol
            \onecolumn
        \else
            \clearpage
        \fi
    }

\let\oldhref\href

\def\@nohyphen#1\@nil#2#3\relax{\oldhref{#1}{#2}\discretionary{}{}{}\ifx\relax#3\else\@nohyphen#1\@nil#3\relax\fi}
\protected\def\href#1#2{\@nohyphen#1\@nil#2\relax\relax}
\let\fn@href\href
% \bgroup
% \let↩\relax
% \gdef\fn@href#1#2{\@fn@href #1\@nil #2↩↩\@nil}%
% \gdef\href#1#2{\@fn@href #1\@nil #2↩↩\@nil}%
% \gdef\@fn@href #1\@nil #2↩#3↩\@nil{\oldhref{#1}{#2}\hskip\z@skip\if!#3!\else\@fn@href #1\@nil #3↩\@nil\fi}
% \egroup
\endinput
