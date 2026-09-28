.DEFAULT_GOAL := all
PYTHON := python3
CROSS := mips-linux-gnu-
IDO := .local/toolchain/5.3/cc
BASEROM ?= baseroms/us/baserom.z64

.PHONY: all setup toolchain verify progress clean test analysis-setup analyze resources
all: build/us/robotron64.z64

resources:
	$(PYTHON) tools/resources.py "$(BASEROM)"

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

build/us/text.o: src/game/text.c include/text.h include/object.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text.raw.o build/us/text.rodata.o .rodata 0x128
	$(PYTHON) tools/trim_padding.py build/us/text.rodata.o $@ .text 0xaf8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_wrapper.o: src/game/text_wrapper.c include/text.h include/object.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_wrapper.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text_wrapper.raw.o $@ .text 0xc4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_edit.o: src/game/text_edit.c include/text.h include/object.h include/game_memory.h $(IDO) Makefile tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o $@ $<
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_properties.o: src/game/text_properties.c include/text.h include/object.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_properties.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text_properties.raw.o $@ .text 0x308
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_conversion.o: src/game/text_conversion.c include/text.h include/object.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_conversion.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text_conversion.raw.o $@ .text 0xa4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_transforms.o: src/game/object_transforms.c include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_transforms.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_transforms.raw.o $@ .text 0x7b8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/entry.o: src/boot/entry.s tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/startup.o: src/boot/startup.c include/audio_control.h include/audio_io.h include/audio_runtime.h include/frame.h include/graphics_tasks.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o $@ $<
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scheduler.o: src/boot/scheduler.c include/scheduler_runtime.h include/scheduler_task.h include/scheduler.h include/sdk_rsp.h include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scheduler.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scheduler.raw.o $@ .text 0xb70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scheduler_runtime_tail.o: src/boot/scheduler_runtime_tail.c include/scheduler_runtime.h include/scheduler_task.h include/scheduler.h include/audio_game.h include/audio_commands.h include/audio_control.h include/audio_runtime.h include/audio_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scheduler_runtime_tail.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scheduler_runtime_tail.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_helpers.o: src/boot/frame_helpers.c include/frame.h include/fixed_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_helpers.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_helpers.raw.o $@ .text 0x234
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_timing.o: src/boot/frame_timing.c include/frame.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_timing.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_timing.raw.o $@ .text 0x124
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_transform.o: src/game/frame_transform.c include/fixed_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_transform.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_transform.raw.o $@ .text 0xe8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_ucode.o: src/boot/graphics_ucode.c include/graphics_tasks.h include/scheduler_task.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_ucode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_ucode.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/fixed_math.o: src/game/fixed_math.c include/fixed_math.h include/sdk_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/fixed_math.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/fixed_math.raw.o $@ .text 0x134
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_setup.o: src/boot/graphics_setup.c include/graphics_tasks.h include/scheduler_runtime.h include/scheduler_task.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_setup.raw.o $@ .text 0x98
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_tasks.o: src/boot/graphics_tasks.c include/graphics_tasks.h include/scheduler_task.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_tasks.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_tasks.raw.o $@ .text 0x3bc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_render.o: src/boot/frame_render.c include/frame.h include/graphics_tasks.h include/scheduler_task.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_render.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_render.raw.o $@ .text 0x198
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_matrices.o: src/boot/frame_matrices.c include/frame.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_matrices.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_matrices.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/fixed_geometry.o: src/game/fixed_geometry.c include/fixed_geometry.h include/fixed_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/fixed_geometry.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/fixed_geometry.raw.o $@ .text 0x598
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_control.o: src/game/audio_control.c include/audio_control.h include/audio_commands.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_control.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_control.raw.o $@ .text 0x370
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_config.o: src/game/audio_config.c include/audio_config.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_config.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_config.raw.o $@ .text 0x280
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_game_helpers.o: src/game/audio_game_helpers.c include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_game_helpers.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_game_helpers.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_io.o: src/game/audio_io.c include/audio_io.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_io.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_io.raw.o $@ .text 0x12c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/heap.o: src/game/heap.c include/heap.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/heap.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/heap.raw.o $@ .text 0x21c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_history.o: src/game/object_history.c include/actor.h include/game_memory.h include/object.h include/object_history.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_history.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_history.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers.o: src/game/object_helpers.c include/object.h include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_index_limit.o: src/game/object_helpers_index_limit.c include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_index_limit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_index_limit.raw.o $@ .text 0x7c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_index_set.o: src/game/object_helpers_index_set.c include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_index_set.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_index_set.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_properties.o: src/game/object_helpers_properties.c include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_properties.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_properties.raw.o $@ .text 0xf4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_camera_state.o: src/game/object_helpers_camera_state.c include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_camera_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_camera_state.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_camera_position.o: src/game/object_helpers_camera_position.c include/frame.h include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_camera_position.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_camera_position.raw.o $@ .text 0xbc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_camera_position_alt.o: src/game/object_helpers_camera_position_alt.c include/frame.h include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_camera_position_alt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_camera_position_alt.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_camera_accessors.o: src/game/object_helpers_camera_accessors.c include/frame.h include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_camera_accessors.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_camera_accessors.raw.o $@ .text 0x130
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_pool_alloc.o: src/game/object_helpers_pool_alloc.c include/object.h include/object_helpers.h include/object_draw.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_pool_alloc.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_pool_alloc.raw.o $@ .text 0x100
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_pool_status.o: src/game/object_helpers_pool_status.c include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_pool_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_pool_status.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_draw_noop.o: src/game/object_helpers_draw_noop.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_draw_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_draw_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_draw.o: src/game/object_helpers_draw.c include/object.h include/object_draw.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_draw.raw.o $@ .text 0x284
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_draw_mode.o: src/game/object_helpers_draw_mode.c include/object.h include/object_draw.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_draw_mode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_draw_mode.raw.o $@ .text 0x138
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_play.o: src/game/audio_play.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_play.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_play.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_stop.o: src/game/audio_instance_stop.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_stop.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stop_commands.o: src/game/audio_stop_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stop_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stop_commands.raw.o $@ .text 0xbc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_stop.o: src/game/audio_voice_stop.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_stop.raw.o $@ .text 0x200
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_stop_all.o: src/game/audio_instance_stop_all.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_stop_all.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_stop_all.raw.o $@ .text 0xf0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stop_all_commands.o: src/game/audio_stop_all_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stop_all_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stop_all_commands.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_stop_all.o: src/game/audio_voice_stop_all.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_stop_all.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_stop_all.raw.o $@ .text 0x1ec
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_commands.o: src/game/audio_level_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_commands.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_commands_alt.o: src/game/audio_level_commands_alt.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_commands_alt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_commands_alt.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_mode.o: src/game/audio_mode.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_mode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_mode.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_play_arguments.o: src/game/audio_play_arguments.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_play_arguments.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_play_arguments.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_command_lock.o: src/game/audio_command_lock.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_command_lock.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_command_lock.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_command_queue.o: src/game/audio_command_queue.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_command_queue.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_command_queue.raw.o $@ .text 0x240
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_thread.o: src/game/audio_thread.c include/audio_control.h include/audio_io.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_thread.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_thread.raw.o $@ .text 0x230
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_update.o: src/game/audio_level_update.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_update.raw.o $@ .text 0x1e0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_update_alt.o: src/game/audio_level_update_alt.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_update_alt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_update_alt.raw.o $@ .text 0x1dc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_reset.o: src/game/object_reset.c include/object.h include/object_draw.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_reset.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup.o: src/game/audio_startup.c include/audio_config.h include/audio_control.h include/audio_io.h include/audio_runtime.h include/heap.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_startup.raw.o $@ .text 0x2e4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_memory.o: src/game/game_memory.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_memory.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_memory.raw.o $@ .text 0x274
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_number_format.o: src/game/game_number_format.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_number_format.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_number_format.raw.o $@ .text 0x284
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_character.o: src/game/game_character.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_character.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_character.raw.o $@ .text 0x1a0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/platform_empty.o: src/game/platform_empty.c include/frame.h include/platform_services.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/platform_empty.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/platform_empty.raw.o $@ .text 0x90
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/platform_io.o: src/game/platform_io.c include/heap.h include/object_runtime.h include/platform_services.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/platform_io.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/platform_io.raw.o $@ .text 0xf4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/fixed_geometry_setup.o: src/game/fixed_geometry_setup.c include/fixed_geometry.h include/fixed_math.h include/scalar_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/fixed_geometry_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/fixed_geometry_setup.raw.o $@ .text 0x5e4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_runtime_service.o: src/game/object_runtime_service.c include/object_runtime.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_runtime_service.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_runtime_service.raw.o $@ .text 0x5c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_generation.o: src/game/audio_generation.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_io.h include/audio_runtime.h include/heap.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_generation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_generation.raw.o $@ .text 0x2a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_task_select.o: src/game/audio_task_select.c include/audio_control.h include/audio_io.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_task_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_task_select.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_pool_callback.o: src/game/audio_pool_callback.c include/audio_callbacks.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pool_callback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pool_callback.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_shutdown.o: src/game/audio_shutdown.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_shutdown.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_shutdown.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_callback_registration.o: src/game/audio_callback_registration.c include/audio_callbacks.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_callback_registration.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_callback_registration.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_callback_return.o: src/game/audio_callback_return.c include/audio_callbacks.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_callback_return.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_callback_return.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/palette.o: src/game/palette.c include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette.raw.o $@ .text 0x194
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/rom_directory.o: src/game/rom_directory.c include/heap.h include/pi.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/rom_directory.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/rom_directory.raw.o $@ .text 0x194
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/rom_file_error.o: src/game/rom_file_error.c include/debug_output.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/rom_file_error.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/rom_file_error.raw.o $@ .text 0x64
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/rom_files.o: src/game/rom_files.c include/debug_output.h include/game_memory.h include/pi.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/rom_files.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/rom_files.raw.o $@ .text 0x230
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_runtime_active.o: src/game/object_runtime_active.c include/debug_output.h include/object_runtime.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_runtime_active.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_runtime_active.raw.o $@ .text 0x98
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_button.o: src/game/controller_button.c include/controller_input.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_button.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_button.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_axes.o: src/game/controller_axes.c include/controller_input.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_axes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_axes.raw.o $@ .text 0xfc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/debug_noop.o: src/game/debug_noop.c include/debug_output.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/debug_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/debug_noop.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_task_build.o: src/game/audio_task_build.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_task_build.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_task_build.raw.o $@ .text 0x1b0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_string_case_compare.o: src/game/game_string_case_compare.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_string_case_compare.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_string_case_compare.raw.o $@ .text 0x94
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_integer_parse.o: src/game/game_integer_parse.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_integer_parse.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_integer_parse.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/heap_empty.o: src/game/heap_empty.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/heap_empty.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/heap_empty.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_recovery_path_extension.o: src/game/object_recovery_path_extension.c include/game_memory.h include/object_recovery.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_recovery_path_extension.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_recovery_path_extension.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_recovery_fixed_trig.o: src/game/object_recovery_fixed_trig.c include/fixed_math.h include/object_recovery.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_recovery_fixed_trig.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_recovery_fixed_trig.raw.o $@ .text 0x90
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_recovery_integer_sqrt.o: src/game/object_recovery_integer_sqrt.c include/object_recovery.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_recovery_integer_sqrt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_recovery_integer_sqrt.raw.o $@ .text 0x64
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_recovery_angle_scale.o: src/game/object_recovery_angle_scale.c include/object_recovery.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_recovery_angle_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_recovery_angle_scale.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_recovery_direction_angle.o: src/game/object_recovery_direction_angle.c include/object_recovery.h include/scalar_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_recovery_direction_angle.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_recovery_direction_angle.raw.o $@ .text 0x184
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_recovery_angle_table.o: src/game/object_recovery_angle_table.c include/object_recovery.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_recovery_angle_table.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_recovery_angle_table.raw.o $@ .text 0x94
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_parameters.o: src/game/movie_parameters.c include/movie.h include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_parameters.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_parameters.raw.o $@ .text 0x118
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_commands.o: src/game/movie_commands.c include/game_memory.h include/movie.h include/object.h include/palette.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_commands.raw.o $@ .text 0x7b8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_channels.o: src/game/movie_channels.c include/game_memory.h include/movie.h include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_channels.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_channels.raw.o $@ .text 0x284
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_reset.o: src/game/movie_reset.c include/game_memory.h include/movie.h include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_reset.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_track_release.o: src/game/movie_track_release.c include/actor.h include/game_memory.h include/movie.h include/object.h include/palette.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_track_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_track_release.raw.o $@ .text 0x158
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_sample.o: src/game/movie_sample.c include/movie.h include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_sample.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_sample.raw.o $@ .text 0x1c0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_callback.o: src/game/movie_callback.c include/game_memory.h include/movie.h include/object.h include/palette.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_callback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_callback.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_prepare.o: src/game/movie_prepare.c include/command_script.h include/movie.h include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_prepare.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_prepare.raw.o build/us/movie_prepare.text.o .text 0x138
	$(PYTHON) tools/owned_sections.py $< build/us/movie_prepare.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/movie_status.o: src/game/movie_status.c include/movie.h include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_status.raw.o $@ .text 0xf8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_cleanup.o: src/game/movie_cleanup.c include/actor.h include/frame.h include/game_memory.h include/movie.h include/object.h include/object_helpers.h include/palette.h include/scene_audio.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_cleanup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_cleanup.raw.o $@ .text 0x114
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_audio_request.o: src/game/scene_audio_request.c include/scene_audio.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_audio_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_audio_request.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/command_machine.o: src/game/command_machine.c include/command_script.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/command_machine.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/command_machine.raw.o build/us/command_machine.text.o .text 0x80
	$(PYTHON) tools/owned_sections.py $< build/us/command_machine.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/string_resource.o: src/game/string_resource.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/string_resource.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/string_resource.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/palette_tint.o: src/game/palette_tint.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_tint.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette_tint.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_start.o: src/game/movie_start.c include/actor.h include/frame.h include/game_memory.h include/movie.h include/object.h include/object_helpers.h include/palette.h include/scene_audio.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_start.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_start.raw.o $@ .text 0x658
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_pool_reset.o: src/game/actor_pool_reset.c include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_pool_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_pool_reset.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_cleanup.o: src/game/actor_cleanup.c include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_cleanup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_cleanup.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_remove.o: src/game/actor_remove.c include/actor.h include/game_memory.h include/object.h include/object_history.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_remove.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_remove.raw.o $@ .text 0xf8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_sweep.o: src/game/actor_sweep.c include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_sweep.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_sweep.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_files.o: src/game/movie_files.c include/game_memory.h include/movie.h include/object.h include/palette.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_files.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_files.raw.o $@ .text 0x2f8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resource_reset.o: src/game/actor_resource_reset.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resource_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_resource_reset.raw.o $@ .text 0x190
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_options_capture.o: src/game/save_options_capture.c include/scene_definition.h include/game_memory.h include/pak_file.h include/save_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_options_capture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_options_capture.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_slot_capture.o: src/game/save_slot_capture.c include/scene_definition.h include/game_memory.h include/pak_file.h include/save_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_slot_capture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_slot_capture.raw.o $@ .text 0xd8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_options_restore.o: src/game/save_options_restore.c include/scene_definition.h include/audio_game.h include/game_memory.h include/pak_file.h include/save_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_options_restore.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_options_restore.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_slot_restore.o: src/game/save_slot_restore.c include/scene_definition.h include/game_memory.h include/pak_file.h include/save_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_slot_restore.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_slot_restore.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_slot_labels.o: src/game/save_slot_labels.c include/scene_definition.h include/game_memory.h include/object.h include/pak_file.h include/save_game.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_slot_labels.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_slot_labels.raw.o $@ .text 0x150
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_file_read.o: src/game/save_file_read.c include/scene_definition.h include/game_memory.h include/pak_file.h include/save_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_file_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_file_read.raw.o $@ .text 0x27c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_file_write.o: src/game/save_file_write.c include/scene_definition.h include/game_memory.h include/pak_file.h include/save_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_file_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_file_write.raw.o $@ .text 0x1d8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/palette_fade_controls.o: src/game/palette_fade_controls.c include/palette.h include/palette_effects.h include/scalar_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_fade_controls.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette_fade_controls.raw.o $@ .text 0x148
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/palette_transition_reset.o: src/game/palette_transition_reset.c include/game_memory.h include/palette.h include/palette_effects.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_transition_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette_transition_reset.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/palette_transition_range.o: src/game/palette_transition_range.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_transition_range.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette_transition_range.raw.o $@ .text 0x288
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/palette_commands.o: src/game/palette_commands.c include/command_script.h include/game_memory.h include/object.h include/palette.h include/palette_effects.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette_commands.raw.o $@ .text 0x1b8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/command_enable.o: src/game/command_enable.c include/command_script.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/command_enable.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/command_enable.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_number_convert.o: src/game/game_number_convert.c include/command_script.h include/scalar_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_number_convert.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_number_convert.raw.o $@ .text 0xfc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_legacy_initialize.o: src/game/controller_legacy_initialize.c include/controller_input.h include/controller_legacy.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_legacy_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_legacy_initialize.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_legacy_present.o: src/game/controller_legacy_present.c include/controller_input.h include/controller_legacy.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_legacy_present.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_legacy_present.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_status.o: src/game/pak_file_status.c include/controller_input.h include/controller_services.h include/pak_file.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_status.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_open.o: src/game/pak_file_open.c include/scene_definition.h include/controller_input.h include/controller_services.h include/pak_file.h include/save_game.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_open.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_open.raw.o $@ .text 0x1b8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_read.o: src/game/pak_file_read.c include/scene_definition.h include/controller_input.h include/controller_services.h include/game_memory.h include/pak_file.h include/save_game.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_read.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_write.o: src/game/pak_file_write.c include/scene_definition.h include/controller_input.h include/controller_services.h include/pak_file.h include/save_game.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_write.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_close.o: src/game/pak_file_close.c include/scene_definition.h include/pak_file.h include/save_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_close.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_close.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_encode_name.o: src/game/pak_file_encode_name.c include/pak_file.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_encode_name.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_encode_name.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_access.o: src/game/controller_access.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_access.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_access.raw.o $@ .text 0xbc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_motor_commands.o: src/game/controller_motor_commands.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_motor_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_motor_commands.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_scan.o: src/game/controller_scan.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_scan.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_scan.raw.o $@ .text 0x144
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_pak_info.o: src/game/controller_pak_info.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_info.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_pak_info.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_pak_delete.o: src/game/controller_pak_delete.c include/scene_definition.h include/controller_input.h include/controller_services.h include/pak_file.h include/save_game.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_delete.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_pak_delete.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_pak_name.o: src/game/controller_pak_name.c include/controller_input.h include/controller_services.h include/game_memory.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_name.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_pak_name.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_pak_directory.o: src/game/controller_pak_directory.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_directory.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_pak_directory.raw.o $@ .text 0x16c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resource_load.o: src/game/actor_resource_load.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resource_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_resource_load.raw.o $@ .text 0x2f8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_noop.o: src/game/session_setup_noop.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_globals.o: src/game/session_setup_globals.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_globals.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_globals.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value04.o: src/game/session_setup_value04.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value04.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value04.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value14.o: src/game/session_setup_value14.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value14.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value14.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value12.o: src/game/session_setup_value12.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value12.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value12.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_flag13.o: src/game/session_setup_flag13.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_flag13.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_flag13.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_values08_10.o: src/game/session_setup_values08_10.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_values08_10.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_values08_10.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value1a.o: src/game/session_setup_value1a.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value1a.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value1a.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_playback_speed.o: src/game/session_setup_playback_speed.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_playback_speed.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_playback_speed.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value16.o: src/game/session_setup_value16.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value16.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value16.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_validate.o: src/game/session_setup_validate.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_validate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_validate.raw.o $@ .text 0x18c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_script_stop.o: src/game/session_setup_script_stop.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_script_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_script_stop.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_animation_create.o: src/game/session_setup_animation_create.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_animation_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_animation_create.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_global_value.o: src/game/session_setup_global_value.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_global_value.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_global_value.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_animation_state.o: src/game/session_setup_animation_state.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_animation_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_animation_state.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_vulnerable.o: src/game/session_setup_vulnerable.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_vulnerable.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_vulnerable.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_model.o: src/game/session_setup_model.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_model.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_model.raw.o $@ .text 0x7c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_animation_file.o: src/game/session_setup_animation_file.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_animation_file.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_animation_file.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_texture_map.o: src/game/session_setup_texture_map.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_texture_map.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_texture_map.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_bitmap.o: src/game/session_setup_bitmap.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_bitmap.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_bitmap.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_pair.o: src/game/session_setup_pair.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_pair.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_pair.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value58_half.o: src/game/session_setup_value58_half.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value58_half.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value58_half.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value64.o: src/game/session_setup_value64.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value64.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value64.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value5a.o: src/game/session_setup_value5a.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value5a.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value5a.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_value58_word.o: src/game/session_setup_value58_word.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_value58_word.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_value58_word.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_selection.o: src/game/session_menu_selection.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_selection.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_selection.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_update.o: src/game/session_menu_preview_update.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_update.raw.o $@ .text 0x14c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_create.o: src/game/session_menu_preview_create.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_create.raw.o $@ .text 0x164
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_accept.o: src/game/session_menu_preview_accept.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_accept.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_accept.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_cancel.o: src/game/session_menu_preview_cancel.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_cancel.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_cancel.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_release.o: src/game/session_menu_preview_release.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_release.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_empty.o: src/game/session_setup_empty.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_empty.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_empty.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_exit_game.o: src/game/session_menu_exit_game.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_exit_game.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_exit_game.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_start_single.o: src/game/session_menu_start_single.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_start_single.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_start_single.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_menu_reset.o: src/game/session_setup_menu_reset.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_menu_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_menu_reset.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_show_main.o: src/game/session_menu_show_main.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_show_main.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_show_main.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_start_two.o: src/game/session_menu_start_two.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_start_two.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_start_two.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_start_alternate.o: src/game/session_menu_start_alternate.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_start_alternate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_start_alternate.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_return.o: src/game/session_menu_return.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_return.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_return.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_level_exit.o: src/game/session_menu_level_exit.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_level_exit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_level_exit.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_player_choice.o: src/game/session_menu_player_choice.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_player_choice.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_player_choice.raw.o $@ .text 0xb4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_pages.o: src/game/session_menu_pages.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_pages.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_pages.raw.o $@ .text 0x94
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_shell_reset.o: src/game/session_menu_shell_reset.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_shell_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_shell_reset.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_defaults.o: src/game/session_menu_defaults.c include/scene_definition.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_defaults.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_defaults.raw.o $@ .text 0xe0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_noop.o: src/game/actor_setup_noop.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_strings.o: src/game/actor_setup_strings.c include/actor.h include/actor_resource_internal.h include/actor_setup_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_strings.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_strings.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_animation_reset.o: src/game/actor_setup_animation_reset.c include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_animation_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_animation_reset.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_text_begin.o: src/game/actor_setup_text_begin.c include/game_memory.h include/object.h include/pak_file.h include/save_game.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_text_begin.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_text_begin.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_text_reset.o: src/game/actor_setup_text_reset.c include/actor.h include/actor_resource_internal.h include/actor_setup_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_text_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_text_reset.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_actor_create.o: src/game/scene_actor_create.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_create.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_file_idle.o: src/game/scene_file_idle.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_file_idle.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_file_idle.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_file_stubs.o: src/game/scene_file_stubs.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_file_stubs.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_file_stubs.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_file_select.o: src/game/scene_file_select.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_file_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_file_select.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_resource_limits.o: src/game/scene_resource_limits.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_resource_limits.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_resource_limits.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_display_flags.o: src/game/scene_display_flags.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_display_flags.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_display_flags.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_position.o: src/game/scene_position.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_position.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_position.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_value_d0c.o: src/game/scene_value_d0c.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_value_d0c.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_value_d0c.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_values_cd0.o: src/game/scene_values_cd0.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_values_cd0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_values_cd0.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_values_cdc.o: src/game/scene_values_cdc.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_values_cdc.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_values_cdc.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_values_cf0.o: src/game/scene_values_cf0.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_values_cf0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_values_cf0.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_effect_add.o: src/game/scene_effect_add.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_effect_add.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_effect_add.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_value_cec.o: src/game/scene_value_cec.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_value_cec.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_value_cec.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_unused_commands.o: src/game/scene_unused_commands.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_unused_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_unused_commands.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_resource_command.o: src/game/scene_resource_command.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_resource_command.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_resource_command.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_enemy_arrival.o: src/game/scene_enemy_arrival.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_enemy_arrival.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_enemy_arrival.raw.o $@ .text 0xf8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_category_arrivals.o: src/game/scene_category_arrivals.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_category_arrivals.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_category_arrivals.raw.o $@ .text 0x138
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_unused_arrivals.o: src/game/scene_unused_arrivals.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_unused_arrivals.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_unused_arrivals.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_positioned_arrival.o: src/game/scene_positioned_arrival.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_positioned_arrival.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_positioned_arrival.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_mark_dirty.o: src/game/scene_mark_dirty.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_mark_dirty.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_mark_dirty.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_effect_apply.o: src/game/scene_effect_apply.c include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_effect_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_effect_apply.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_background.o: src/game/scene_background.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_background.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_background.raw.o build/us/scene_background.text.o .text 0x3d8
	$(PYTHON) tools/owned_sections.py $< build/us/scene_background.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/save_menu_slot_write.o: src/game/save_menu_slot_write.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_slot_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_slot_write.raw.o $@ .text 0x114
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_cancel.o: src/game/save_menu_cancel.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_cancel.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_cancel.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_slot_prompt.o: src/game/save_menu_slot_prompt.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_slot_prompt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_slot_prompt.raw.o $@ .text 0xe8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_slot_callback.o: src/game/save_menu_slot_callback.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_slot_callback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_slot_callback.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_open.o: src/game/save_menu_open.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_open.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_open.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_status.o: src/game/save_menu_status.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_status.raw.o build/us/save_menu_status.text.o .text 0x340
	$(PYTHON) tools/owned_sections.py $< build/us/save_menu_status.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/save_menu_audio_index.o: src/game/save_menu_audio_index.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_audio_index.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_audio_index.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_sound_preview.o: src/game/save_menu_sound_preview.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_sound_preview.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_sound_preview.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_audio_apply.o: src/game/save_menu_audio_apply.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_audio_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_audio_apply.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_audio_secondary.o: src/game/save_menu_audio_secondary.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_audio_secondary.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_audio_secondary.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_write_return.o: src/game/save_menu_write_return.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_write_return.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_write_return.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_palette_index.o: src/game/save_menu_palette_index.c include/palette.h include/scalar_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_palette_index.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_palette_index.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_palette_load.o: src/game/scene_palette_load.c include/palette.h include/palette_effects.h include/platform_services.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_palette_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_palette_load.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS := build/us/frame_helpers.o \
    build/us/frame_timing.o \
    build/us/graphics_ucode.o \
    build/us/frame_transform.o \
    build/us/fixed_math.o \
    build/us/graphics_setup.o \
    build/us/graphics_tasks.o \
    build/us/scheduler_runtime_tail.o \
    build/us/frame_render.o \
    build/us/frame_matrices.o \
    build/us/fixed_geometry.o \
    build/us/audio_control.o \
    build/us/audio_config.o \
    build/us/audio_game_helpers.o \
    build/us/audio_io.o \
    build/us/heap.o \
    build/us/object_history.o \
    build/us/object_helpers.o \
    build/us/object_helpers_index_limit.o \
    build/us/object_helpers_index_set.o \
    build/us/object_helpers_properties.o \
    build/us/object_helpers_camera_state.o \
    build/us/object_helpers_camera_position.o \
    build/us/object_helpers_camera_position_alt.o \
    build/us/object_helpers_camera_accessors.o \
    build/us/object_helpers_pool_alloc.o \
    build/us/object_helpers_pool_status.o \
    build/us/object_helpers_draw_noop.o \
    build/us/object_helpers_draw.o \
    build/us/object_helpers_draw_mode.o \
    build/us/audio_play.o \
    build/us/audio_instance_stop.o \
    build/us/audio_stop_commands.o \
    build/us/audio_voice_stop.o \
    build/us/audio_instance_stop_all.o \
    build/us/audio_stop_all_commands.o \
    build/us/audio_voice_stop_all.o \
    build/us/audio_level_commands.o \
    build/us/audio_level_commands_alt.o \
    build/us/audio_mode.o \
    build/us/audio_play_arguments.o \
    build/us/audio_command_lock.o \
    build/us/audio_command_queue.o \
    build/us/audio_thread.o \
    build/us/audio_level_update.o \
    build/us/audio_level_update_alt.o \
    build/us/object_reset.o \
    build/us/audio_startup.o \
    build/us/game_memory.o \
    build/us/game_number_format.o \
    build/us/game_character.o \
    build/us/platform_empty.o \
    build/us/platform_io.o \
    build/us/fixed_geometry_setup.o \
    build/us/audio_generation.o \
    build/us/audio_pool_callback.o \
    build/us/audio_shutdown.o \
    build/us/audio_callback_registration.o \
    build/us/audio_callback_return.o \
    build/us/audio_task_select.o \
    build/us/object_runtime_service.o \
    build/us/palette.o \
    build/us/rom_directory.o \
    build/us/rom_file_error.o \
    build/us/rom_files.o \
    build/us/controller_button.o \
    build/us/controller_axes.o \
    build/us/debug_noop.o \
    build/us/object_runtime_active.o \

RUNTIME_OBJECTS += \
    build/us/audio_task_build.o \

RUNTIME_OBJECTS += \
    build/us/game_string_case_compare.o \
    build/us/game_integer_parse.o \
    build/us/heap_empty.o \

RUNTIME_OBJECTS += \
    build/us/object_recovery_path_extension.o \
    build/us/object_recovery_fixed_trig.o \
    build/us/object_recovery_integer_sqrt.o \
    build/us/object_recovery_angle_scale.o \
    build/us/object_recovery_direction_angle.o \
    build/us/object_recovery_angle_table.o \

RUNTIME_OBJECTS += \
    build/us/movie_parameters.o \
    build/us/movie_commands.o \
    build/us/movie_channels.o

RUNTIME_OBJECTS += \
    build/us/movie_reset.o \
    build/us/movie_track_release.o \
    build/us/movie_sample.o \
    build/us/movie_callback.o \
    build/us/movie_prepare.o \
    build/us/movie_status.o \
    build/us/movie_cleanup.o \
    build/us/scene_audio_request.o \
    build/us/command_machine.o \
    build/us/string_resource.o \
    build/us/palette_tint.o

RUNTIME_OBJECTS += \
    build/us/movie_start.o

RUNTIME_OBJECTS += \
    build/us/actor_pool_reset.o \
    build/us/actor_cleanup.o \
    build/us/actor_remove.o \
    build/us/actor_sweep.o

RUNTIME_OBJECTS += \
    build/us/movie_files.o \
    build/us/actor_resource_reset.o \
    build/us/save_options_capture.o \
    build/us/save_slot_capture.o \
    build/us/save_options_restore.o \
    build/us/save_slot_restore.o \
    build/us/save_slot_labels.o \
    build/us/save_file_read.o \
    build/us/save_file_write.o \
    build/us/palette_fade_controls.o \
    build/us/palette_transition_reset.o \
    build/us/palette_transition_range.o \
    build/us/palette_commands.o \
    build/us/command_enable.o \
    build/us/game_number_convert.o \
    build/us/controller_legacy_initialize.o \
    build/us/controller_legacy_present.o \
    build/us/pak_file_status.o \
    build/us/pak_file_open.o \
    build/us/pak_file_read.o \
    build/us/pak_file_write.o \
    build/us/pak_file_close.o \
    build/us/pak_file_encode_name.o \
    build/us/controller_access.o \
    build/us/controller_motor_commands.o \
    build/us/controller_scan.o \
    build/us/controller_pak_info.o \
    build/us/controller_pak_delete.o \
    build/us/controller_pak_name.o \
    build/us/controller_pak_directory.o

RUNTIME_OBJECTS += \
    build/us/actor_resource_load.o \
    build/us/session_setup_noop.o \
    build/us/session_setup_globals.o \
    build/us/session_setup_value04.o \
    build/us/session_setup_value14.o \
    build/us/session_setup_value12.o \
    build/us/session_setup_flag13.o \
    build/us/session_setup_values08_10.o \
    build/us/session_setup_value1a.o \
    build/us/session_setup_playback_speed.o \
    build/us/session_setup_value16.o \
    build/us/session_setup_validate.o \
    build/us/session_setup_script_stop.o \
    build/us/session_setup_animation_create.o \
    build/us/session_setup_global_value.o \
    build/us/session_setup_animation_state.o \
    build/us/session_setup_vulnerable.o \
    build/us/session_setup_model.o \
    build/us/session_setup_animation_file.o \
    build/us/session_setup_texture_map.o \
    build/us/session_setup_bitmap.o \
    build/us/session_setup_pair.o \
    build/us/session_setup_value58_half.o \
    build/us/session_setup_value64.o \
    build/us/session_setup_value5a.o \
    build/us/session_setup_value58_word.o \
    build/us/session_menu_selection.o \
    build/us/session_menu_preview_update.o \
    build/us/session_menu_preview_create.o \
    build/us/session_menu_preview_accept.o \
    build/us/session_menu_preview_cancel.o \
    build/us/session_menu_preview_release.o \
    build/us/session_setup_empty.o \
    build/us/session_menu_exit_game.o \
    build/us/session_menu_start_single.o \
    build/us/session_setup_menu_reset.o \
    build/us/session_menu_show_main.o \
    build/us/session_menu_start_two.o \
    build/us/session_menu_start_alternate.o \
    build/us/session_menu_return.o \
    build/us/session_menu_level_exit.o \
    build/us/session_menu_player_choice.o \
    build/us/session_menu_pages.o \
    build/us/session_menu_shell_reset.o \
    build/us/session_menu_defaults.o

RUNTIME_OBJECTS += \
    build/us/actor_setup_noop.o \
    build/us/actor_setup_strings.o \
    build/us/actor_setup_animation_reset.o \
    build/us/actor_setup_text_begin.o \
    build/us/actor_setup_text_reset.o \
    build/us/scene_actor_create.o \
    build/us/scene_file_idle.o \
    build/us/scene_file_stubs.o \
    build/us/scene_file_select.o \
    build/us/scene_resource_limits.o \
    build/us/scene_display_flags.o \
    build/us/scene_position.o \
    build/us/scene_value_d0c.o \
    build/us/scene_values_cd0.o \
    build/us/scene_values_cdc.o \
    build/us/scene_values_cf0.o \
    build/us/scene_effect_add.o \
    build/us/scene_value_cec.o \
    build/us/scene_unused_commands.o \
    build/us/scene_resource_command.o \
    build/us/scene_enemy_arrival.o \
    build/us/scene_category_arrivals.o \
    build/us/scene_unused_arrivals.o \
    build/us/scene_positioned_arrival.o \
    build/us/scene_mark_dirty.o \
    build/us/scene_effect_apply.o \
    build/us/scene_background.o \
    build/us/save_menu_slot_write.o \
    build/us/save_menu_cancel.o \
    build/us/save_menu_slot_prompt.o \
    build/us/save_menu_slot_callback.o \
    build/us/save_menu_open.o \
    build/us/save_menu_status.o \
    build/us/save_menu_audio_index.o \
    build/us/save_menu_sound_preview.o \
    build/us/save_menu_audio_apply.o \
    build/us/save_menu_audio_secondary.o \
    build/us/save_menu_write_return.o \
    build/us/save_menu_palette_index.o \
    build/us/scene_palette_load.o

build/us/robotron64.elf: build/us/fallback.o build/us/text.o build/us/text_wrapper.o build/us/text_edit.o build/us/text_properties.o build/us/text_conversion.o build/us/object_transforms.o build/us/entry.o build/us/startup.o build/us/scheduler.o $(RUNTIME_OBJECTS) linker_scripts/us.ld config/startup_symbols.ld config/runtime_symbols.ld
	$(CROSS)ld -EB -T linker_scripts/us.ld -Map build/us/robotron64.map -o $@

build/us/robotron64.z64: build/us/robotron64.elf
	$(CROSS)objcopy -O binary $< $@

verify: all
	$(PYTHON) tools/verify.py "$(BASEROM)" build/us/robotron64.z64

progress: verify
	$(PYTHON) tools/progress.py

test:
	$(PYTHON) -m unittest discover -s tests -v
	$(PYTHON) tools/manifest.py

analysis-setup:
	$(PYTHON) -m venv .venv
	.venv/bin/python -m pip install -r requirements-analysis.txt

analyze:
	.venv/bin/python tools/analyze.py

clean:
	$(PYTHON) -c 'import shutil; shutil.rmtree("build", ignore_errors=True)'
