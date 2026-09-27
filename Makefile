.DEFAULT_GOAL := all
PYTHON := python3
CROSS := mips-linux-gnu-
IDO := .local/toolchain/5.3/cc
BASEROM ?= baseroms/us/baserom.z64
CFLAGS := -O2 -G 0 -non_shared -mips1 -32

.PHONY: all setup toolchain verify progress clean test analysis-setup analyze
all: build/us/robotron64.z64

setup: toolchain
	$(PYTHON) tools/extract.py "$(BASEROM)"

toolchain:
	$(PYTHON) tools/toolchain.py 5.3

$(IDO):
	$(PYTHON) tools/toolchain.py 5.3

build/us/extracted/.stamp: $(BASEROM) tools/extract.py tools/rom.py config/target.json
	$(PYTHON) tools/extract.py "$(BASEROM)"

build/us/fallback.o: build/us/extracted/.stamp
	$(CROSS)as -EB -32 -march=vr4300 -o $@ build/us/extracted/fallback.s

build/us/text.o: src/game/text.c include/text.h $(IDO) Makefile tools/trim_padding.py
	mkdir -p $(@D)
	$(IDO) -c $(CFLAGS) -o build/us/text.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text.raw.o build/us/text.rodata.o .rodata 0x128
	$(PYTHON) tools/trim_padding.py build/us/text.rodata.o $@ .text 0xaf8

build/us/text_wrapper.o: src/game/text_wrapper.c include/text.h $(IDO) Makefile tools/trim_padding.py
	mkdir -p $(@D)
	$(IDO) -c $(CFLAGS) -o build/us/text_wrapper.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text_wrapper.raw.o $@ .text 0xc4

build/us/text_edit.o: src/game/text_edit.c include/text.h $(IDO) Makefile
	mkdir -p $(@D)
	$(IDO) -c $(CFLAGS) -o $@ $<

build/us/entry.o: src/boot/entry.s
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<

build/us/robotron64.elf: build/us/fallback.o build/us/text.o build/us/text_wrapper.o build/us/text_edit.o build/us/entry.o linker_scripts/us.ld
	$(CROSS)ld -EB -T linker_scripts/us.ld -Map build/us/robotron64.map -o $@

build/us/robotron64.z64: build/us/robotron64.elf
	$(CROSS)objcopy -O binary $< $@

verify: all
	$(PYTHON) tools/verify.py "$(BASEROM)" build/us/robotron64.z64

progress: verify
	$(PYTHON) tools/progress.py

test:
	$(PYTHON) -m unittest discover -s tests -v

analysis-setup:
	$(PYTHON) -m venv .venv
	.venv/bin/python -m pip install -r requirements-analysis.txt

analyze:
	.venv/bin/python tools/analyze.py

clean:
	$(PYTHON) -c 'import shutil; shutil.rmtree("build", ignore_errors=True)'
