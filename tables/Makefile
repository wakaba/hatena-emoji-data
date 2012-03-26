WGET = wget

all: hatena.json

emoji4unicode.xml:
	$(WGET) -O $@ http://emoji4unicode.googlecode.com/svn/trunk/data/emoji4unicode.xml

imode_emoji.txt:
	$(WGET) -O $@ http://cgi.wap2.jp/download/imode_emoji.txt

ezweb_emoji.txt:
	$(WGET) -O $@ http://cgi.wap2.jp/download/ezweb_emoji.txt

mixi-emoji_list.html:
	$(WGET) -O $@ http://developer.mixi.co.jp/connect/mixi_graph_api/mixi_io_spec_top/emoji_list/

mixi-emoji_list.txt: mixi-emoji_list.html ../bin/parse-mixi-emoji-list.pl
	perl ../bin/parse-mixi-emoji-list.pl < $< > $@

hatena.json: emoji4unicode.xml hatena-00e000.txt hatena-0fa700.txt \
    imode_emoji.txt mixi-emoji_list.txt \
    ../bin/generate-hatena-json.pl
	perl ../bin/generate-hatena-json.pl

clean:
	rm -f emoji4unicode.xml
