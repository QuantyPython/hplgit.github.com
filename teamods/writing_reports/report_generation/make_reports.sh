#!/bin/sh -x
# Make automatically generated Doconce report from a program in
# a wide variety of formats (for demonstrating the layout of
# the various formats)
set -x

report=tmp_report
dt="1.25 0.75 0.5 0.1"
dir=reports
failures=""

# Drop cleaning and running simulations if command line arguments
# and figure files exist
if [ $# -gt 0 -a -f BE.png -a -d $dir ]; then
  echo 'No new simulations - just report generation'
else
sh clean.sh
rm -rf $dir
mkdir $dir
python exper1_do.py $dt
fi

if [ $? -ne 0 ]; then failures="$failures:decay_exer1_do.py"; exit 1; fi
cp $report.do.txt $dir/report.do.txt
rm error.csv
cp .publish_references.pub publish_config.py BE.* FE.* CN.* error.* $dir

cd $dir

# blogger.com (Google) blog
cp report.do.txt report2.do.txt
# Remove title, author and date
doconce subst -m '^TITLE:.+$' '' report2.do.txt
doconce subst -m '^AUTHOR:.+$' '' report2.do.txt
doconce subst -m '^DATE:.+$' '' report2.do.txt
# Figures must have URLs to where they are stored on the web
for figname in BE FE CN error; do
  doconce replace "[$figname," "[https://raw.github.com/hplgit/hplgit.github.com/master/teamods/writing_reports/_static/$figname.png," report2.do.txt
done
doconce format html report2
mv -f report2.html report_blogger.html
# Paste report_blogger.html text into a new blog on your Google account

# Wordpress blog
doconce format html report2 --wordpress
mv -f report2.html report_wordpress.html

# Plain doconce html styles
styles="plain blueish bloodish tactile-red tactile-black rossant"
for style in $styles; do
doconce format html report --html_style=$style --html_output=report_$style
if [ $? -ne 0 ]; then failures="$failures:doconce-html-$style"; exit 1; fi
done
style=blueish2
doconce format html report --html_style=$style --html_output=report_$style --pygments_html_style=off

styles="solarized solarized2_light solarized3_light"
for style in $styles; do
doconce format html report --html_style=$style --html_output=report_$style
if [ $? -ne 0 ]; then failures="$failures:doconce-html-$style"; exit 1; fi
done
styles="solarized_dark solarized2_dark solarized3_dark"
for style in $styles; do
doconce format html report --html_style=$style --html_output=report_$style
if [ $? -ne 0 ]; then failures="$failures:doconce-html-$style"; exit 1; fi
done

# solarized_box template
soltemp=template_solarized_box_yellow.html
cp ~/vc/doconce/bundled/html_styles/style_solarized_box/$soltemp .
# Customize the template
doconce replace AUTHOR 'H. P. Langtangen' $soltemp
doconce replace YEAR '2014' $soltemp
# TOC, TITLE and AUTHOR are not usually appropriate with HTML templates
cp report.do.txt report2.do.txt
#doconce replace 'TITLE: '  '#TITLE: ' report2.do.txt
doconce replace 'AUTHOR: '  '#AUTHOR: ' report2.do.txt
doconce replace 'TOC: '  '#TOC: ' report2.do.txt
doconce format html report2 --html_style=solarized --html_template=$soltemp --html_output=report_solarized_box
if [ $? -ne 0 ]; then failures="$failures:doconce-html-solarized_box"; fi

# Plain doconce html bloodish with handwriting font
# Clicker+Script Stalemate Architects+Daughter
doconce format html report --html_style=bloodish --html_body_font=Architects+Daughter --html_heading_font=Architects+Daughter
if [ $? -ne 0 ]; then failures="$failures:doconce-html"; fi
mv -f report.html report_bloodish_Architects_Daughter.html

doconce format html report --html_style=bloodish --html_body_font=Clicker+Script --html_heading_font=Clicker+Script
if [ $? -ne 0 ]; then failures="$failures:doconce-html"; fi
mv -f report.html report_bloodish_Clicker_Script.html

doconce format html report --html_style=bloodish --html_body_font=Stalemate --html_heading_font=Stalemate
if [ $? -ne 0 ]; then failures="$failures:doconce-html"; fi
mv -f report.html report_bloodish_Stalemate.html

# Bootstrap themes with white background
# First insert a split before the first section so we get a jumbotron first page
doconce subst -m '^======= Mathematical ' '!split\n======= Mathematical ' report.do.txt
styles="bootstrap bootswatch_cosmo bootswatch_journal bootswatch_readable bootstrap_bloodish bootstrap_FlatUI bootstrap_bluegray"
for style in $styles; do
doconce format html report --html_style=$style --pygments_html_style=default --html_admon=bootstrap_alert --html_output=report_${style} --keep_pygments_html_bg --html_code_style=inherit --html_pre_style=inherit
doconce split_html report_$style.html
done
style=bootswatch_cyborg
doconce format html report --html_style=$style --pygments_html_style=monokai --html_admon=bootstrap_alert --html_output=report_${style} --keep_pygments_html_bg --html_code_style=inherit --html_pre_style=inherit
doconce split_html report_$style.html

# Vagrant doconce html
template=template_vagrant.html
cp ~/vc/doconce/bundled/html_styles/style_vagrant/template_vagrant.html $template
# Customize the template
doconce replace LogoWord 'DiffEq' $template
doconce replace withSubWord 'Project' $template
doconce replace '<a href="">GO TO 1</a>' '<a href="http://wikipedia.org" target="_blank">Wikipedia</a>' $template
doconce replace '<a href="">GO TO 2</a>' '<a href="http://wolframalpha.com" target="_blank">WolframAlpha</a>' $template
doconce subst '<!-- footer --> Here .+' 'H. P. Langtangen &copy; 2014' $template

# TOC, TITLE and AUTHOR are not usually appropriate with HTML templates
cp report.do.txt report2.do.txt
doconce replace 'TITLE: '  '#TITLE: ' report2.do.txt
doconce replace 'AUTHOR: '  '#AUTHOR: ' report2.do.txt
doconce replace 'TOC: '  '#TOC: ' report2.do.txt
doconce format html report2 --html_style=bootstrap --html_template=$template --html_output=report_vagrant --html_toc_indent=0
if [ $? -ne 0 ]; then failures="$failures:doconce-html-vagrant"; fi

# GitHub minimal theme
cp -r ~/vc/doconce/bundled/html_styles/style_github_minimal .
mv -f style_github_minimal/css .
mv -f style_github_minimal/js .
doconce replace 'Main Permanent Header' 'Project Report' style_github_minimal/template_github_minimal.html
doconce replace 'Permanent SubHeader' 'A Differential Equation Problem' style_github_minimal/template_github_minimal.html

doconce format html report2 --html_template=style_github_minimal/template_github_minimal.html
if [ $? -ne 0 ]; then failures="$failures:doconce-html-github-minimal"; fi

mv -f report2.html report_github_minimal.html

# Boostrap style with fixed toc on the right
template=template_bootstrap_wtoc.html
cp ~/vc/doconce/bundled/html_styles/style_bootstrap_wtoc/$template .
# Customize the template
doconce replace '<a href="">LINK1</a>' '<a href="http://wikipedia.org" target="_blank">Wikipedia</a>' $template
doconce replace '<a href="">LINK2</a>' '<a href="http://wolframalpha.com" target="_blank">WolframAlpha</a>' $template
doconce replace 'SHORT EXPLANATION' 'Investigation of numerical artifacts' $template
doconce subst '<!-- footer --> Here .+' 'H. P. Langtangen &copy; 2014' $template

cp report.do.txt report2.do.txt
doconce replace 'TITLE: '  '#TITLE: ' report2.do.txt
doconce replace 'AUTHOR: '  '#AUTHOR: ' report2.do.txt
doconce replace 'TOC: '  '#TOC: ' report2.do.txt
doconce format html report2 --html_style=bootstrap --html_template=$template --html_output=report_bootstrap_wtoc --pygments_html_style=none
if [ $? -ne 0 ]; then failures="$failures:doconce-html-bootstrap_wtoc"; fi

rm -f report2*

# IPython notebook
doconce format ipynb report
if [ $? -ne 0 ]; then failures="$failures:doconce-ipynb"; fi
cp report.ipynb ~/vc/hplgit.github.com/store/  # store so it's reachable on web

# MediaWiki
doconce format mwiki report
if [ $? -ne 0 ]; then failures="$failures:doconce-mwiki"; fi
cp report.mwiki ~/vc/hplgit.github.com.wiki/Experiments-with-Schemes-for-Exponential-Decay.mediawiki

# Sphinx
doconce sphinx_dir theme=pyramid report
python automake_sphinx.py
cd sphinx-rootdir
doconce replace solarized '' make_themes.sh # have it, but it doesn't work...
sh make_themes.sh
if [ $? -ne 0 ]; then failures="$failures:make_themes.sh"; fi
mv -f sphinx-* ../
cd ..
mv -f sphinx-rootdir rootdir

# Plain LaTeX PDF
doconce format pdflatex report --latex_code_style=vrb --device=paper
rm -f *.aux
pdflatex report
bibtex report
pdflatex report
pdflatex report
cp report.pdf report_plain.pdf

# PDF for printing
doconce format pdflatex report --device=paper --latex_font=palatino --latex_title_layout=titlepage --latex_admon=grayicon --latex_code_style=pyg
rm -f *.aux
pdflatex -shell-escape report
bibtex report
pdflatex -shell-escape report
pdflatex -shell-escape report
cp report.pdf report_4printing.pdf

# PDF for phone
doconce format pdflatex report --latex_papersize=a6 --latex_font=palatino --latex_code_style=pyg
rm -f *.aux
pdflatex -shell-escape report
bibtex report
pdflatex -shell-escape report
pdflatex -shell-escape report
cp report.pdf report_4phone.pdf

# PDF with yellow listings code block style (like in the FEniCS book)
doconce format pdflatex report --latex_papersize=a4 --latex_font=helvetica --latex_code_style=lst-yellow2
rm -f *.aux
pdflatex report
bibtex report
pdflatex report
pdflatex report
cp report.pdf report_fb.pdf

# PDF for screen viewing with an alternative look from classic LaTeX
doconce format pdflatex report --latex_font=helvetica --latex_admon=yellowicon '--latex_admon_color=yellow!5' --latex_fancy_header --latex_title_layout=std --latex_section_headings=blue --latex_colored_table_rows=blue --latex_code_style=pyg

# Substitute abstract envir with quote and \small font
doconce replace 'begin{abstract}' 'begin{quote}\small' report.tex
doconce replace 'end{abstract}' 'end{quote}' report.tex
doconce replace '[compact]{titlesec}' '[]{titlesec}' report.tex
# Do some polishing of report.tex for display of the latex source
# to the world
doconce subst -m '^%--+ begin preamble -+$' '' report.tex
doconce subst -m '^%--+ end preamble -+$' '' report.tex
doconce subst -m '^% --+ main content -+$' '' report.tex
doconce subst -m '^% --+ end of main content -+$' '' report.tex
#doconce replace "ptex2tex (extended LaTeX)" "LaTeX" report.tex
doconce subst -s "demonstrated\..+\\end\{abstract\}" "demonstrated.\n\end{abstract}" report.tex
doconce replace '\noindent' '' report.tex
rm -f *.aux
pdflatex -shell-escape report
bibtex report
pdflatex -shell-escape report
pdflatex -shell-escape report

# Markdown (could be omitted, very primitive)
doconce format pandoc report
# Remove title, author, etc. (does not work well)
doconce subst '% .*' '' report.md
doconce md2html report
cp report.html report_md.html

# Plain text
doconce format plain report

# Native HTML and LaTeX formats made from scripts
cd ..
python exper1_html.py $dt
if [ $? -ne 0 ]; then failures="$failures:exper1_html.py"; exit 1; fi
cp $report.html $dir/report_html.html

python exper1_mathjax.py $dt
if [ $? -ne 0 ]; then failures="$failures:exper1_mathjax.py"; exit 1; fi
cp $report.html $dir/report_mathjax.html

python exper1_latex.py $dt
if [ $? -ne 0 ]; then failures="$failures:exper1_latex.py"; exit 1; fi
pdflatex $report
bibtex $report
pdflatex $report
pdflatex $report
cp $report.pdf $dir/report_plain_latex.pdf
cp $report.tex $dir/report_plain_latex.tex

# Make top index.html file
cp decay_report_demo.do.txt $dir/tmp.do.txt
cd $dir
# All compiled sphinx themes are available in sphinx-themename directories
themes=`/bin/ls -d sphinx-*`
#themes="agogo basic bizstyle classic default epub haiku nature pyramid scrolls sphinxdoc traditional $themes bootstrap cloud solarized impressjs sphinx_rtd_theme"
for theme in $themes; do
    themeshort=`echo $theme | sed 's/sphinx-//g'`
    doconce replace XXXXX "\"$themeshort\": \"_static/$theme/index.html\", XXXXX" tmp.do.txt
done
doconce replace ", XXXXX" "" tmp.do.txt
doconce format html tmp --html_links_in_new_window --html_style=bootswatch
if [ $? -ne 0 ]; then failures="$failures:doconce-reports/tmp.do.txt"; fi
mv -f tmp.html index.html

# Compile index.html with shell instructions
doconce replace 'TITLE: Examples of scientific reports in different formats' 'TITLE: Examples of scientific reports in different formats and how they are made' tmp.do.txt
doconce format html tmp -DCODE --html_links_in_new_window --html_style=bootswatch_readable
if [ $? -ne 0 ]; then failures="$failures:doconce-reports/tmp.do.txt"; fi
mv -f tmp.html index_with_doconce_commands.html
ls *.html

echo "Making pygmentized HTML files"

pyg="pygmentize -f html -O full,style=emacs"
for file in *.html; do
  $pyg -o $file.html -l html $file
  doconce subst 'body\s+\.err\s+\{ .+' 'body  .err { border: 0; } /* drop error */' $file.html
done
rm -f index.html.html  report.md.html.html # not of interest
$pyg -o report_sphinx.rst.html -l rst rootdir/report.rst
$pyg -o report.p.tex.html -l latex report.p.tex
$pyg -o report.tex.html -l latex report.tex
$pyg -o report.md.html -l latex report.md
$pyg -o report.ipynb.html -l json report.ipynb
$pyg -o report.mwiki.html -l text report.mwiki
$pyg -o report_latex.html -l latex report_plain_latex.tex

doconce pygmentize report.do.txt perldoc

rm -f *.aux *.dvi *.log *.idx *.out *.toc *.bbl *.blg *.pyc tmp* *~ automake* *.tex *.rst *.md

# Copy all compiled reports from report.do.txt to _static
mkdir _static
mv -f *.png *.html ._*.html *.pdf sphinx-* js css *.ipynb *.mwiki report.txt _static
mv -f _static/index*.html .  # don't copy the index file
rm -rf index_with_doconce_commands.html.html style_github* .*_file_collection  # unwanted byproducts

# Copy all doconce source files to separate directory doconce_src
mkdir doconce_src
cp report.do.txt .publish_references.pub model.py publish_config.py _static/BE.* _static/FE.* _static/CN.* _static/error.* doconce_src
cp ../decay_mod.py doconce_src
cd doconce_src
doconce replace "../model.py" "model.py" report.do.txt
rm -f *~
cd ..

cd ..

# Archive
rm -rf archived-reports
cp -r $dir archived-reports
cd archived-reports
# not to be archived:
rm -rf rootdir  style* latex_figs html_images report.do.txt publish_config* css ipynb*
cd ..
rm -rf ../../archive/decay-reports
mv archived-reports ../../archive/decay-reports
cd ../../archive/decay-reports
rm -rf _minted_report report.md-ipynb
#cp -r archived-reports/* ~/vc/INF5620/doc/writing_reports/

#sh clean.sh
echo "failures: $failures"
exit
