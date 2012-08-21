WGET = wget
PERL = perl
PERL_ENV = PATH="$(abspath ../bin/perl-$(PERL_VERSION)/pm/bin):$(PERL_PATH):$(PATH)" PERL5LIB="$(shell cat ../config/perl/libs.txt)"

all: deps hatena.json

deps: 
	cd .. && $(MAKE) deps

hatena.json: ../bin/generate-hatena-emoji-collections.pl deps
	$(PERL_ENV) $(PERL) $< > $@
