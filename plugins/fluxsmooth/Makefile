include ../../config.mak

LIBNAME = fluxsmooth

ifeq ($(HAVE_X86_64),yes)
ifeq ($(HAVE_YASM),yes)
VSASFLAGS = -DARCH_X86_64=1 -DPIC -f elf64

%.o: %.asm
	$(asmcompile)
endif #HAVE_YASM
endif #x86_64

ifeq ($(HAVE_I686),yes)
NOASM = yes
endif

include ../../cc.inc

