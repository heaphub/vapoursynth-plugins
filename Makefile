include config.mak

PLUGINS = $(shell ls -d plugins/*)
pluginsdir := $(libdir)/vapoursynth
dist-packages := $(prefix)/lib/python3.8/dist-packages

models = noise1_model.json noise2_model.json noise3_model.json scale2.0x_model.json

ifeq ($(V), 1)
MAKE = make V=1
else
MAKE = make
endif

define NL


endef


all:
	$(foreach DIR,$(PLUGINS),$(MAKE) -C $(DIR) $(NL))

install:
	$(INSTALL) -d $(DESTDIR)$(pluginsdir)
	$(INSTALL) -d $(DESTDIR)$(docdir)
	$(INSTALL) -d $(DESTDIR)$(datarootdir)/nnedi3
	$(INSTALL) -d $(DESTDIR)$(datarootdir)/vsscripts
	$(INSTALL) -d $(DESTDIR)$(dist-packages)
	ln -rs $(DESTDIR)$(datarootdir)/vsscripts $(DESTDIR)$(dist-packages)/vsscripts

	$(foreach LIB,$(shell ls plugins/*/*.so),$(INSTALL_DATA) $(LIB) $(DESTDIR)$(pluginsdir) $(NL))
	$(foreach SCRIPT,$(shell ls plugins/*/*.py scripts/*.py), \
		$(INSTALL_DATA) $(SCRIPT) $(DESTDIR)$(datarootdir)/vsscripts/$$(basename $(SCRIPT)) $(NL))

	$(foreach FILE,$(shell ls plugins/*/readme* plugins/*/README*), \
		$(INSTALL_DATA) $(FILE) $(DESTDIR)$(docdir)/$(shell echo $$(basename $$(dirname $(FILE)))) $(NL))
	$(foreach FILE,$(shell ls scripts/*.txt plugins/flash3kyuu_deband/*.txt), \
		$(INSTALL_DATA) $(FILE) $(DESTDIR)$(docdir) $(NL))

	$(INSTALL_DATA) README.md $(DESTDIR)$(docdir)
	$(INSTALL_DATA) scripts/README.md $(DESTDIR)$(docdir)/scripts.md
	$(INSTALL_DATA) scripts/vsTAAmbk.md $(DESTDIR)$(docdir)
	$(INSTALL_DATA) plugins/rawsource/format_list.txt $(DESTDIR)$(docdir)/rawsource_format_list
	$(INSTALL_DATA) plugins/fmtconv/doc/fmtconv.html $(DESTDIR)$(docdir)
	$(INSTALL_DATA) plugins/fmtconv/doc/colorspace-subsampling.png $(DESTDIR)$(docdir)
	$(INSTALL_DATA) plugins/fmtconv/doc/vapourdoc.css $(DESTDIR)$(docdir)

ifneq ($(INSTALL_MODEL_WEIGHTS),0)
	$(INSTALL_DATA) models/nnedi3_weights.bin $(DESTDIR)$(datarootdir)/nnedi3

	$(foreach DIR,anime_style_art anime_style_art_rgb photo,\
		$(INSTALL) -d $(DESTDIR)$(pluginsdir)/models/$(DIR) $(NL)\
		$(foreach FILE,$(models), \
			$(INSTALL_DATA) models/$(DIR)/$(FILE) $(DESTDIR)$(pluginsdir)/models/$(DIR) $(NL)))
	$(foreach MDL,$(models),ln -s models/anime_style_art/$(MDL) $(DESTDIR)$(pluginsdir)/$(MDL) $(NL))
endif

clean:
	$(MAKE) -f ffmpeg.mak $@
	$(foreach DIR,$(PLUGINS),$(MAKE) -C $(DIR) clean || true $(NL))

distclean: clean
	$(MAKE) -f ffmpeg.mak $@
	$(foreach DIR,$(PLUGINS),$(MAKE) -C $(DIR) distclean || true $(NL))
	rm -f config.log config.status config.mak

maintainer-clean: distclean
	rm -rf autom4te.cache plugins/imagereader/libjpeg-turbo/autom4te.cache

config.mak:
	./configure

