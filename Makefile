# Use bash
SHELL:=/bin/bash

# Transcrpit base name
BASENAME=transcript.adoc

# Parts
PARTS=$(shell find parts -type f -name \*.adoc)

# Configuration files
ASCIIDOC_CONF=conf/asciidoc.conf
MACROS_CONF=conf/asciidoc.conf

# Generated files
PDF_FILE=$(BASENAME:.adoc=.pdf)
HTML_FILE=$(BASENAME:.adoc=.html)

WATCH_PID=watch.PID

pdf: $(PDF_FILE)

html: $(HTML_FILE)

$(PDF_FILE): $(BASENAME) $(PARTS) $(ASCIIDOC_CONF) $(MACROS_CONF)
	a2x --conf-file $(ASCIIDOC_CONF) -f pdf $<

$(HTML_FILE): $(BASENAME) $(PARTS) $(ASCIIDOC_CONF) $(MACROS_CONF)
	asciidoc -b html5 -a icons -a toc2 -a theme=flask -f $(MACROS_CONF) $<

clean:
	rm -f $(PDF_FILE) $(HTML_FILE)

view:
	zathura $(PDF_FILE) &>/dev/null &

edit:
	emc $(BASENAME) $(PARTS)

watch:
	while true; \
	do \
	inotifywait -r -e modify . && $(MAKE) pdf; \
	done

watch_start:
	@test -f ${WATCH_PID} || ($(MAKE) watch &>/dev/null & echo $$! > ${WATCH_PID})

watch_stop:
	@test -f ${WATCH_PID} && kill `cat ${WATCH_PID}` && rm ${WATCH_PID}

ide: 
	$(MAKE) watch_start
	$(MAKE) view
	$(MAKE) edit
	$(MAKE) watch_stop

.PHONY: pdf html $(PDF_FILE) $(HTML_FILE) clean view edit ide

