IN_DATA=data/test_data.csv
REPORT=report
NORM=data/norm_data.csv

.PHONY : all
all : $(REPORT).pdf

$(REPORT).pdf : $(REPORT).tex $(NORM) $(REPORT).png
	texi2pdf -b $(REPORT).tex

$(NORM) : $(IN_DATA) process.R
	Rscript process.R $< $@

$(REPORT).png : $(NORM)
	Rscript plot.R $< $@

.PHONY : clean
clean :
	rm -f $(NORM)
	rm -f $(REPORT).pdf
	rm -f $(REPORT).png
	rm -f $(REPORT).log
	rm -f $(REPORT).aux
