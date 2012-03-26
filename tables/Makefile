WGET = wget

all: hatena.json

emoji4unicode.xml:
	$(WGET) -O $@ http://emoji4unicode.googlecode.com/svn/trunk/data/emoji4unicode.xml

imode_emoji.txt:
	$(WGET) -O $@ http://cgi.wap2.jp/download/imode_emoji.txt

ezweb_emoji.txt:
	$(WGET) -O $@ http://cgi.wap2.jp/download/ezweb_emoji.txt

hatena.json: emoji4unicode.xml hatena-00e000.txt \
    ../bin/generate-hatena-json.pl
	perl ../bin/generate-hatena-json.pl

clean:
	rm -f emoji4unicode.xml
