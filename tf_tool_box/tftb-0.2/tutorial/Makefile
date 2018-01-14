all: tutorial.pdf

html:
	latex tutorial.tex
	bibtex tutorial
	latex tutorial.tex
	latex tutorial.tex
	latex2html -local_icons tutorial.tex

tutorial.dvi: tutorial.tex
	latex tutorial.tex
	bibtex tutorial
	latex tutorial.tex
	latex tutorial.tex
	latex tutorial.tex

tutorial.pdf: tutorial.dvi
	dvipdfm -p a4 tutorial.dvi
clean:
	rm -f *.pdf *.dvi *~ *.aux *.log *.blg *.end *.bbl *.idx *.toc

