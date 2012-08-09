WGET = wget
PERL = perl
PERL_ENV = PATH="bin/perl-$(PERL_VERSION)/pm/bin:$(PERL_PATH):$(PATH)" PERL5LIB="$(shell cat ../config/perl/libs.txt)"

all: deps hatena.json

deps: 
	cd .. && $(MAKE) deps

emoji4unicode.xml:
	$(WGET) -O $@ http://emoji4unicode.googlecode.com/svn/trunk/data/emoji4unicode.xml

imode_emoji.txt:
	$(WGET) -O $@ http://cgi.wap2.jp/download/imode_emoji.txt

mixi-emoji_list.html:
	$(WGET) -O $@ http://developer.mixi.co.jp/connect/mixi_graph_api/mixi_io_spec_top/emoji_list/

mixi-emoji_list.txt: mixi-emoji_list.html ../bin/parse-mixi-emoji-list.pl
	$(PERL_ENV) $(PERL) ../bin/parse-mixi-emoji-list.pl < $< > $@

NamesList.txt:
	$(WGET) -O $@ http://www.unicode.org/Public/UNIDATA/NamesList.txt

hatena.json: emoji4unicode.xml hatena-00e000.txt hatena-0fa700.txt \
    imode_emoji.txt mixi-emoji_list.txt NamesList.txt \
    ../bin/generate-hatena-json.pl
	$(PERL_ENV) $(PERL) ../bin/generate-hatena-json.pl

clean:
	rm -f emoji4unicode.xml NamesList.txt mixi-emoji_list.html \
	    imode_emoji.txt
