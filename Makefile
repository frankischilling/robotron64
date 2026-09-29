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

build/us/early_render_color.o: src/game/early_render_color.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_color.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_render_color.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_render_presets.o: src/game/early_render_presets.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_presets.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_render_presets.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_render_dispatch.o: src/game/early_render_dispatch.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_dispatch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_render_dispatch.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_pool_entry_clear.o: src/game/early_pool_entry_clear.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_pool_entry_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_pool_entry_clear.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_pool_count.o: src/game/early_pool_count.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_pool_count.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_pool_count.raw.o $@ .text 0x5c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_pool_index.o: src/game/early_pool_index.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_pool_index.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_pool_index.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_byte_clear.o: src/game/early_byte_clear.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_byte_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_byte_clear.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_angle_normalize.o: src/game/early_angle_normalize.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_angle_normalize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_angle_normalize.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_float_step.o: src/game/early_float_step.c include/early_game_state.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/actor_behavior_internal.h include/object_recovery.h include/scalar_math.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_float_step.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_float_step.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_selection_state.o: src/game/early_selection_state.c include/early_game_state.h include/actor.h include/text.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/actor_behavior_internal.h include/object_recovery.h include/scalar_math.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_selection_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_selection_state.raw.o $@ .text 0x1e4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_callbacks_true.o: src/game/early_callbacks_true.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_callbacks_true.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_callbacks_true.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_create.o: src/game/early_actor_create.c include/early_game_state.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/actor_behavior_internal.h include/object_recovery.h include/scalar_math.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_create.raw.o $@ .text 0x164
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_state.o: src/game/early_actor_state.c include/early_game_state.h include/actor.h include/text.h include/game_memory.h include/object.h include/scalar_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/object_recovery.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_state.raw.o $@ .text 0x128
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_mode3.o: src/game/early_actor_mode3.c include/early_game_helpers.h include/actor.h include/text.h include/object.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_mode3.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_mode3.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_mode0.o: src/game/early_actor_mode0.c include/early_game_helpers.h include/actor.h include/text.h include/object.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_mode0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_mode0.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_six_arg_forward.o: src/game/early_six_arg_forward.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_six_arg_forward.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_six_arg_forward.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_callback_false.o: src/game/early_callback_false.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_callback_false.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_callback_false.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_transition.o: src/game/early_actor_transition.c include/early_game_medium.h include/early_game_state.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/object_recovery.h include/scalar_math.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_transition.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_transition.raw.o $@ .text 0xcc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_pointer_state.o: src/game/early_pointer_state.c include/early_game_medium.h include/early_game_state.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/actor_behavior_internal.h include/object_recovery.h include/scalar_math.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_pointer_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_pointer_state.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_resource_state.o: src/game/early_resource_state.c include/early_resource_state.h include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_resource_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_resource_state.raw.o $@ .text 0x1a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_simple_forward.o: src/game/early_simple_forward.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_simple_forward.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_simple_forward.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_value_lookup.o: src/game/early_value_lookup.c include/early_game_medium.h include/early_game_state.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/actor_behavior_internal.h include/object_recovery.h include/scalar_math.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_value_lookup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_value_lookup.raw.o $@ .text 0xec
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

build/us/startup.o: src/boot/startup.c include/audio_control.h include/audio_io.h include/audio_runtime.h include/frame.h include/graphics_tasks.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o $@ $<
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scheduler.o: src/boot/scheduler.c include/scheduler_runtime.h include/scheduler_task.h include/scheduler.h include/sdk_rsp.h include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scheduler.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scheduler.raw.o $@ .text 0xb70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scheduler_runtime_tail.o: src/boot/scheduler_runtime_tail.c include/scheduler_runtime.h include/scheduler_task.h include/scheduler.h include/audio_game.h include/audio_commands.h include/audio_control.h include/audio_runtime.h include/audio_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
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

build/us/audio_control.o: src/game/audio_control.c include/audio_control.h include/audio_commands.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
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

build/us/audio_play.o: src/game/audio_play.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_play.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_play.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_stop.o: src/game/audio_instance_stop.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_stop.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stop_commands.o: src/game/audio_stop_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stop_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stop_commands.raw.o $@ .text 0xbc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_stop.o: src/game/audio_voice_stop.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_stop.raw.o $@ .text 0x200
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_stop_all.o: src/game/audio_instance_stop_all.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_stop_all.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_stop_all.raw.o $@ .text 0xf0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stop_all_commands.o: src/game/audio_stop_all_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stop_all_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stop_all_commands.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_stop_all.o: src/game/audio_voice_stop_all.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_stop_all.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_stop_all.raw.o $@ .text 0x1ec
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_commands.o: src/game/audio_level_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_commands.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_commands_alt.o: src/game/audio_level_commands_alt.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_commands_alt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_commands_alt.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_mode.o: src/game/audio_mode.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_mode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_mode.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_state_query.o: src/game/audio_instance_state_query.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_state_query.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_state_query.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_voice_pause_state.o: src/game/audio_voice_pause_state.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_pause_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_pause_state.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_request.o: src/game/audio_pause_request.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_request.raw.o $@ .text 0xc8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_decode.o: src/game/audio_pause_decode.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_decode.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_apply.o: src/game/audio_pause_apply.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_apply.raw.o $@ .text 0x1cc
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_request.o: src/game/audio_resume_request.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_request.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_decode.o: src/game/audio_resume_decode.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_decode.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_apply.o: src/game/audio_resume_apply.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_apply.raw.o $@ .text 0x168
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_all_request.o: src/game/audio_pause_all_request.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_all_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_all_request.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_all_decode.o: src/game/audio_pause_all_decode.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_all_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_all_decode.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_all_apply.o: src/game/audio_pause_all_apply.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_all_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_all_apply.raw.o $@ .text 0x1e8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_all_request.o: src/game/audio_resume_all_request.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_all_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_all_request.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_all_decode.o: src/game/audio_resume_all_decode.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_all_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_all_decode.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_all_apply.o: src/game/audio_resume_all_apply.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_all_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_all_apply.raw.o $@ .text 0x18c
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_voice_properties_initial.o: src/game/audio_voice_properties_initial.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_properties_initial.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_properties_initial.raw.o $@ .text 0x264
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_properties_request.o: src/game/audio_owner_properties_request.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_properties_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_properties_request.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_properties_decode.o: src/game/audio_owner_properties_decode.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_properties_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_properties_decode.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_properties_apply.o: src/game/audio_owner_properties_apply.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_properties_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_properties_apply.raw.o $@ .text 0x184
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_state_query.o: src/game/audio_owner_state_query.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_state_query.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_state_query.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_stop_request.o: src/game/audio_owner_stop_request.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_stop_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_stop_request.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_stop_commands.o: src/game/audio_owner_stop_commands.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_stop_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_stop_commands.raw.o $@ .text 0xbc
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_stop_apply.o: src/game/audio_owner_stop_apply.c src/game/audio_properties_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_stop_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_stop_apply.raw.o $@ .text 0x200
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h
build/us/audio_play_arguments.o: src/game/audio_play_arguments.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_play_arguments.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_play_arguments.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_instance.o: src/game/audio_handle_instance.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_instance.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_instance.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_create.o: src/game/audio_handle_create.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_create.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_state.o: src/game/audio_handle_state.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_state.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_release.o: src/game/audio_handle_release.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_release.raw.o $@ .text 0x138
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_resume.o: src/game/audio_handle_resume.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_resume.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_resume.raw.o $@ .text 0x118
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_resume_default.o: src/game/audio_handle_resume_default.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_resume_default.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_resume_default.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_voice_resume.o: src/game/audio_handle_voice_resume.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_voice_resume.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_voice_resume.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_voice_resume_default.o: src/game/audio_handle_voice_resume_default.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_voice_resume_default.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_voice_resume_default.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_properties_capture.o: src/game/audio_handle_properties_capture.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_properties_capture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_properties_capture.raw.o $@ .text 0xf0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_properties_apply.o: src/game/audio_handle_properties_apply.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_properties_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_properties_apply.raw.o $@ .text 0xf0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_stop.o: src/game/audio_handle_stop.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_stop.raw.o $@ .text 0x114
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_rate.o: src/game/audio_handle_rate.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_rate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_rate.raw.o $@ .text 0x130
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_validate_only.o: src/game/audio_handle_validate_only.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_validate_only.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_validate_only.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_rewind.o: src/game/audio_handle_rewind.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_rewind.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_rewind.raw.o $@ .text 0x140
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_command_parameter.o: src/game/audio_voice_command_parameter.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_command_parameter.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_command_parameter.raw.o $@ .text 0x178
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_command_temporary.o: src/game/audio_voice_command_temporary.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_command_temporary.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_command_temporary.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_properties_apply.o: src/game/audio_voice_properties_apply.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_properties_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_properties_apply.raw.o $@ .text 0x26c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_properties_capture.o: src/game/audio_voice_properties_capture.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_properties_capture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_properties_capture.raw.o $@ .text 0x15c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_57c70.o: src/game/audio_handle_parameter_57c70.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_57c70.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_57c70.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_pair_request.o: src/game/audio_handle_pair_request.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_pair_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_pair_request.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_pair_decode.o: src/game/audio_handle_pair_decode.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_pair_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_pair_decode.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_pair_apply.o: src/game/audio_handle_pair_apply.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_pair_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_pair_apply.raw.o $@ .text 0xd4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_command_18.o: src/game/audio_voice_command_18.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_command_18.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_command_18.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_57e94.o: src/game/audio_handle_parameter_57e94.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_57e94.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_57e94.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_57ec0.o: src/game/audio_handle_parameter_57ec0.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_57ec0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_57ec0.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_command_10.o: src/game/audio_voice_command_10.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_command_10.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_command_10.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_57f48.o: src/game/audio_handle_parameter_57f48.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_57f48.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_57f48.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_command_11.o: src/game/audio_voice_command_11.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_command_11.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_command_11.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_57fcc.o: src/game/audio_handle_parameter_57fcc.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_57fcc.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_57fcc.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_57ff8.o: src/game/audio_handle_parameter_57ff8.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_57ff8.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_57ff8.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_58024.o: src/game/audio_handle_parameter_58024.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_58024.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_58024.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_command_14.o: src/game/audio_voice_command_14.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_command_14.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_command_14.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_580a8.o: src/game/audio_handle_parameter_580a8.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_580a8.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_580a8.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_command_15.o: src/game/audio_voice_command_15.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_command_15.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_command_15.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_5812c.o: src/game/audio_handle_parameter_5812c.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_5812c.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_5812c.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_command_16.o: src/game/audio_voice_command_16.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_command_16.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_command_16.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_581b0.o: src/game/audio_handle_parameter_581b0.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_581b0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_581b0.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_request.o: src/game/audio_handle_parameter_request.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_request.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_decode.o: src/game/audio_handle_parameter_decode.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_decode.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_parameter_apply.o: src/game/audio_handle_parameter_apply.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_parameter_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_parameter_apply.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stream_storage.o: src/game/audio_stream_storage.c include/audio_properties_internal.h include/audio_host_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stream_storage.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stream_storage.raw.o $@ .text 0x94
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_host_callbacks.o: src/game/audio_host_callbacks.c include/audio_properties_internal.h include/audio_host_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_host_callbacks.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_host_callbacks.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_timing_rate.o: src/game/audio_timing_rate.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_timing_rate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_timing_rate.raw.o $@ .text 0x7c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stream_variable_read.o: src/game/audio_stream_variable_read.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stream_variable_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stream_variable_read.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_command_lock.o: src/game/audio_command_lock.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_command_lock.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_command_lock.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_command_queue.o: src/game/audio_command_queue.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_command_queue.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_command_queue.raw.o $@ .text 0x240
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_thread.o: src/game/audio_thread.c include/audio_control.h include/audio_io.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_thread.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_thread.raw.o $@ .text 0x230
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_update.o: src/game/audio_level_update.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_update.raw.o $@ .text 0x1e0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_update_alt.o: src/game/audio_level_update_alt.c include/audio_commands.h include/audio_control.h include/audio_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_update_alt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_update_alt.raw.o $@ .text 0x1dc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_reset.o: src/game/object_reset.c include/object.h include/object_draw.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_reset.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup.o: src/game/audio_startup.c include/audio_config.h include/audio_control.h include/audio_io.h include/audio_runtime.h include/heap.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
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

build/us/audio_generation.o: src/game/audio_generation.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_io.h include/audio_runtime.h include/heap.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_generation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_generation.raw.o $@ .text 0x2a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_task_select.o: src/game/audio_task_select.c include/audio_control.h include/audio_io.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_task_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_task_select.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_pool_callback.o: src/game/audio_pool_callback.c include/audio_callbacks.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pool_callback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pool_callback.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_shutdown.o: src/game/audio_shutdown.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
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

build/us/audio_task_build.o: src/game/audio_task_build.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/audio_properties_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_task_build.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_task_build.raw.o $@ .text 0x1b0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_string_case_compare.o: src/game/game_string_case_compare.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_string_case_compare.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_string_case_compare.raw.o $@ .text 0x94
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_string_compare.o: src/game/game_string_compare.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_string_compare.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_string_compare.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_string_compare_n.o: src/game/game_string_compare_n.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_string_compare_n.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_string_compare_n.raw.o $@ .text 0x48
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

build/us/game_debug_format.o: src/game/game_debug_format.c include/game_memory.h include/game_stdarg.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_debug_format.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_debug_format.raw.o $@ .text 0x1dc
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

build/us/save_slot_select.o: src/game/save_slot_select.c include/scene_definition.h include/game_memory.h include/pak_file.h include/save_game.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_slot_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_slot_select.raw.o $@ .text 0x1a0
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

build/us/session_setup_kinemation.o: src/game/session_setup_kinemation.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_kinemation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_kinemation.raw.o $@ .text 0x98
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

build/us/script_service_cache_reset.o: src/game/script_service_cache_reset.c include/command_script.h include/script_service_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_service_cache_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/script_service_cache_reset.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_service_cache_access.o: src/game/script_service_cache_access.c include/command_script.h include/game_memory.h include/platform_services.h include/script_service_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_service_cache_access.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/script_service_cache_access.raw.o $@ .text 0x284
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_service_commands.o: src/game/script_service_commands.c include/actor.h include/actor_resource_internal.h include/command_script.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/resource_strings.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/script_service_internal.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_service_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/script_service_commands.raw.o $@ .text 0x244
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_service_platform.o: src/game/script_service_platform.c include/command_script.h include/platform_services.h include/script_service_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_service_platform.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/script_service_platform.raw.o $@ .text 0xd0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_animation_resolve.o: src/game/script_animation_resolve.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/platform_services.h include/resource_bridge_internal.h include/resource_strings.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_animation_resolve.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/script_animation_resolve.raw.o $@ .text 0xf8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_animation.o: src/game/actor_animation.c include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_animation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_animation.raw.o $@ .text 0xe4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_motion_mode.o: src/game/actor_motion_mode.c include/actor.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_motion_mode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_motion_mode.raw.o $@ .text 0x148
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/debug_context_set.o: src/game/debug_context_set.c include/debug_text_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/debug_context_set.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/debug_context_set.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/debug_text_draw.o: src/game/debug_text_draw.c include/debug_text_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/debug_text_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/debug_text_draw.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_reset.o: src/game/tweak_reset.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_reset.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_page.o: src/game/tweak_page.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_page.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_page.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_define.o: src/game/tweak_define.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_define.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_define.raw.o $@ .text 0xa4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_difficulty_apply.o: src/game/tweak_difficulty_apply.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_difficulty_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_difficulty_apply.raw.o $@ .text 0xe4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_bind.o: src/game/tweak_bind.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_bind.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_bind.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_bind_all.o: src/game/tweak_bind_all.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_bind_all.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_bind_all.raw.o $@ .text 0x808
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_scale_enemy_speeds.o: src/game/tweak_scale_enemy_speeds.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_scale_enemy_speeds.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_scale_enemy_speeds.raw.o $@ .text 0x168
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_string_reset.o: src/game/resource_string_reset.c include/game_memory.h include/platform_services.h include/resource_strings.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_string_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_string_reset.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_string_find.o: src/game/resource_string_find.c include/game_memory.h include/platform_services.h include/resource_strings.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_string_find.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_string_find.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_string_load.o: src/game/resource_string_load.c include/game_memory.h include/platform_services.h include/resource_strings.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_string_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_string_load.raw.o $@ .text 0xd4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_service_files.o: src/game/script_service_files.c include/command_script.h include/game_memory.h include/script_service_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_service_files.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/script_service_files.raw.o $@ .text 0x134
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_state.o: src/game/actor_behavior_state.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_state.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_blend_velocity.o: src/game/actor_behavior_blend_velocity.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_blend_velocity.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_blend_velocity.raw.o $@ .text 0x1c8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_blend_motion.o: src/game/actor_behavior_blend_motion.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_blend_motion.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_blend_motion.raw.o $@ .text 0x22c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_height.o: src/game/actor_behavior_height.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_height.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_height.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_extra_b32c.o: src/game/actor_behavior_extra_b32c.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_extra_b32c.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_extra_b32c.raw.o $@ .text 0x244
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_noop_b570.o: src/game/actor_behavior_noop_b570.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_noop_b570.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_noop_b570.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_extra_b57c.o: src/game/actor_behavior_extra_b57c.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_extra_b57c.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_extra_b57c.raw.o $@ .text 0x228
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_noop_b7a4.o: src/game/actor_behavior_noop_b7a4.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_noop_b7a4.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_noop_b7a4.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_noop_b7b0.o: src/game/actor_behavior_noop_b7b0.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_noop_b7b0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_noop_b7b0.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_repeat.o: src/game/actor_behavior_repeat.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_repeat.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_repeat.raw.o $@ .text 0x124
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_extra_d918.o: src/game/actor_behavior_extra_d918.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_extra_d918.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_extra_d918.raw.o $@ .text 0x308
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_countdown.o: src/game/actor_behavior_countdown.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_countdown.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_countdown.raw.o $@ .text 0x98
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_countdown_begin.o: src/game/actor_behavior_countdown_begin.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_countdown_begin.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_countdown_begin.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_countdown_trigger.o: src/game/actor_behavior_countdown_trigger.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_countdown_trigger.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_countdown_trigger.raw.o $@ .text 0x7c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sound_bridge_core.o: src/game/sound_bridge_core.c include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_core.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_core.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sound_bridge_definitions.o: src/game/sound_bridge_definitions.c include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_definitions.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_definitions.raw.o $@ .text 0x5c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sound_bridge_future_reset.o: src/game/sound_bridge_future_reset.c include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_future_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_future_reset.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sound_bridge_future_queue.o: src/game/sound_bridge_future_queue.c include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_future_queue.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_future_queue.raw.o build/us/sound_bridge_future_queue.text.o .text 0x90
	$(PYTHON) tools/owned_sections.py $< build/us/sound_bridge_future_queue.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/sound_bridge_future_update.o: src/game/sound_bridge_future_update.c include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_future_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_future_update.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/geometry_debug_bridge.o: src/game/geometry_debug_bridge.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/geometry_debug_bridge.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/geometry_debug_bridge.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/geometry_bridge_apply.o: src/game/geometry_bridge_apply.c include/fixed_geometry.h include/fixed_math.h include/geometry_bridge_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/geometry_bridge_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/geometry_bridge_apply.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/geometry_bridge_rotate.o: src/game/geometry_bridge_rotate.c include/fixed_geometry.h include/fixed_math.h include/geometry_bridge_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/geometry_bridge_rotate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/geometry_bridge_rotate.raw.o $@ .text 0xb4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_vertex_attributes.o: src/game/renderer_vertex_attributes.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_vertex_attributes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_vertex_attributes.raw.o build/us/renderer_vertex_attributes.text.o .text 0x438
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_vertex_attributes.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/renderer_material_texture.o: src/game/renderer_material_texture.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_texture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_texture.raw.o $@ .text 0x118
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_material_light.o: src/game/renderer_material_light.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_light.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_light.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_material_combined.o: src/game/renderer_material_combined.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_combined.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_combined.raw.o $@ .text 0x290
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_light_select.o: src/game/renderer_light_select.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_light_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_light_select.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_material_untextured.o: src/game/renderer_material_untextured.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_untextured.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_untextured.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_material_reset.o: src/game/renderer_material_reset.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_reset.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_vertex_copy.o: src/game/renderer_vertex_copy.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_vertex_copy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_vertex_copy.raw.o $@ .text 0x39c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_texture_load.o: src/game/renderer_texture_load.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_texture_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_texture_load.raw.o $@ .text 0x218
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_display_list.o: src/game/graphics_display_list.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_display_list.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_display_list.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_resource.o: src/game/graphics_resource.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_resource.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_resource.raw.o build/us/graphics_resource.text.o .text 0x70
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_resource.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/graphics_modes.o: src/game/graphics_modes.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_modes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_modes.raw.o $@ .text 0x624
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_lights.o: src/game/graphics_lights.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_lights.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_lights.raw.o $@ .text 0x258
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_pool.o: src/game/graphics_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_pool.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_pool.raw.o build/us/graphics_pool.text.o .text 0x1a4
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_pool.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/graphics_pool_initialize.o: src/game/graphics_pool_initialize.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_pool_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_pool_initialize.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_frame_reset.o: src/game/graphics_frame_reset.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_frame_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_frame_reset.raw.o $@ .text 0x120
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_mode_dispatch.o: src/game/graphics_mode_dispatch.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_mode_dispatch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_mode_dispatch.raw.o build/us/graphics_mode_dispatch.text.o .text 0x21c
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_mode_dispatch.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/graphics_environment.o: src/game/graphics_environment.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_environment.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_environment.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_level_lookup.o: src/game/save_level_lookup.c include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_level_lookup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_level_lookup.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_conditional_copy.o: src/game/save_menu_conditional_copy.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_conditional_copy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_conditional_copy.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_flag_setter.o: src/game/save_menu_flag_setter.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_flag_setter.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_flag_setter.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_text_flags.o: src/game/save_menu_text_flags.c include/game_memory.h include/movie.h include/object.h include/palette.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_text_flags.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_text_flags.raw.o $@ .text 0x170
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_state_reset.o: src/game/save_menu_state_reset.c include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_state_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_state_reset.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_reset.o: src/game/save_menu_legacy_reset.c include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_reset.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_heap.o: src/game/save_menu_legacy_heap.c include/heap.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_heap.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_heap.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_pages.o: src/game/save_menu_legacy_pages.c include/controller_input.h include/controller_legacy.h include/controller_services.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_pages.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_pages.raw.o $@ .text 0x18c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_pak_status.o: src/game/save_menu_legacy_pak_status.c include/controller_input.h include/controller_legacy.h include/controller_services.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_pak_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_pak_status.raw.o $@ .text 0x2a8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_exit.o: src/game/save_menu_legacy_exit.c include/movie.h include/pak_file.h include/palette.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_exit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_exit.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_pages_tail.o: src/game/save_menu_legacy_pages_tail.c include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_pages_tail.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_pages_tail.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_state_helpers.o: src/game/graphics_state_helpers.c include/frame.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_state_helpers.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_state_helpers.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_retry.o: src/game/save_menu_pak_retry.c include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_retry.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_retry.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_reset.o: src/game/save_menu_pak_reset.c include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_reset.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_refresh.o: src/game/save_menu_pak_refresh.c include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_refresh.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_refresh.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_result.o: src/game/save_menu_pak_result.c include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_result.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_result.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_refresh.o: src/game/save_menu_nav_refresh.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_refresh.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_refresh.raw.o $@ .text 0x90
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_open_primary.o: src/game/save_menu_nav_open_primary.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_open_primary.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_open_primary.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_open_secondary.o: src/game/save_menu_nav_open_secondary.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_open_secondary.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_open_secondary.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_open_return.o: src/game/save_menu_nav_open_return.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_open_return.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_open_return.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_noop.o: src/game/save_menu_nav_noop.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_reset.o: src/game/save_menu_nav_reset.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_reset.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_actor_disable.o: src/game/save_menu_nav_actor_disable.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_actor_disable.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_actor_disable.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_actor_forward.o: src/game/save_menu_nav_actor_forward.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_actor_forward.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_actor_forward.raw.o $@ .text 0xcc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_actor_back.o: src/game/save_menu_nav_actor_back.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_actor_back.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_actor_back.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_preview_create.o: src/game/save_menu_nav_preview_create.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_preview_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_preview_create.raw.o $@ .text 0x154
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_preview_release.o: src/game/save_menu_nav_preview_release.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_preview_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_preview_release.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_cleanup.o: src/game/save_menu_nav_cleanup.c include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_cleanup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_cleanup.raw.o $@ .text 0x10c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_frame_sync.o: src/game/actor_behavior_frame_sync.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_frame_sync.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_frame_sync.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_motion_begin.o: src/game/actor_behavior_motion_begin.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_motion_begin.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_motion_begin.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_motion_guarded.o: src/game/actor_behavior_motion_guarded.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_motion_guarded.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_motion_guarded.raw.o $@ .text 0xc0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_motion_scaled.o: src/game/actor_behavior_motion_scaled.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_motion_scaled.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_motion_scaled.raw.o $@ .text 0xe0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_animation_2945c.o: src/game/actor_behavior_animation_2945c.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_animation_2945c.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_animation_2945c.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_callback_29544.o: src/game/actor_behavior_callback_29544.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_callback_29544.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_callback_29544.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_spawn.o: src/game/actor_behavior_spawn.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_spawn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_spawn.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_spawn_restore.o: src/game/actor_behavior_spawn_restore.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_spawn_restore.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_spawn_restore.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_release_29d6c.o: src/game/actor_behavior_release_29d6c.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_release_29d6c.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_release_29d6c.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_next_a244.o: src/game/actor_behavior_next_a244.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_behavior_next_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_next_a244.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_next_a244.raw.o build/us/actor_behavior_next_a244.text.o .text 0x1a4
	$(PYTHON) tools/owned_sections.py $< build/us/actor_behavior_next_a244.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/save_menu_continue_encode.o: src/game/save_menu_continue_encode.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_continue_encode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_continue_encode.raw.o $@ .text 0x170
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_vertex_positions.o: src/game/renderer_vertex_positions.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_vertex_positions.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_vertex_positions.raw.o build/us/renderer_vertex_positions.text.o .text 0x288
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_vertex_positions.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/renderer_mesh_positions.o: src/game/renderer_mesh_positions.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_mesh_positions.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_mesh_positions.raw.o build/us/renderer_mesh_positions.text.o .text 0xd4
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_mesh_positions.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/movie_camera.o: src/game/movie_camera.c include/movie.h include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_camera.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_camera.raw.o $@ .text 0x1cc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_actor.o: src/game/movie_actor.c include/actor.h include/game_memory.h include/movie.h include/object.h include/palette.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_actor.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_actor.raw.o $@ .text 0x1b4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_motion_facing.o: src/game/actor_motion_facing.c include/actor.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_motion_facing.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_motion_facing.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_transition_open.o: src/game/scene_transition_open.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_transition_open.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_transition_open.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_transition_close.o: src/game/scene_transition_close.c include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_transition_close.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_transition_close.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_transition_draw.o: src/game/scene_transition_draw.c include/debug_text_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_transition_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_transition_draw.raw.o $@ .text 0x120
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_player_setup.o: src/game/scene_player_setup.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_player_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_player_setup.raw.o $@ .text 0x248
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_signed_shift.o: src/game/scene_signed_shift.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_signed_shift.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_signed_shift.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_actor_parameter_reset.o: src/game/scene_actor_parameter_reset.c include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_parameter_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_parameter_reset.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_glyph_release.o: src/game/scene_glyph_release.c include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_glyph_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_glyph_release.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_actor_scale.o: src/game/scene_actor_scale.c include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_scale.raw.o $@ .text 0x138
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_actor_motion_reset.o: src/game/scene_actor_motion_reset.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_motion_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_motion_reset.raw.o $@ .text 0x108
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_service_noop.o: src/game/scene_service_noop.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_service_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_service_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_parent_follow.o: src/game/scene_parent_follow.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_parent_follow.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_parent_follow.raw.o $@ .text 0x178
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_bucket_counter.o: src/game/scene_bucket_counter.c include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_bucket_counter.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_bucket_counter.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_scene_apply.o: src/game/tweak_scene_apply.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_scene_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_scene_apply.raw.o $@ .text 0xe8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_timer_capture.o: src/game/scene_timer_capture.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_timer_capture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_timer_capture.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_timer_initialize.o: src/game/scene_timer_initialize.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_timer_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_timer_initialize.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_timer_service.o: src/game/scene_timer_service.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_timer_service.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_timer_service.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_service.o: src/game/object_service.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_service.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_service.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_registration.o: src/game/object_registration.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_registration.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_registration.raw.o $@ .text 0x5c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_creation.o: src/game/object_creation.c include/object.h include/object_draw.h include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_creation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_creation.raw.o $@ .text 0x1c0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_model_access.o: src/game/object_model_access.c include/object.h include/object_draw.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_model_access.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_model_access.raw.o $@ .text 0xe4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_bridge_model_cache.o: src/game/resource_bridge_model_cache.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_bridge_model_cache.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_bridge_model_cache.raw.o $@ .text 0xd8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_bridge_texture_stub.o: src/game/resource_bridge_texture_stub.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_bridge_texture_stub.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_bridge_texture_stub.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_bridge_bitmap.o: src/game/resource_bridge_bitmap.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_bridge_bitmap.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_bridge_bitmap.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_bridge_animation.o: src/game/resource_bridge_animation.c include/actor.h include/actor_resource_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_bridge_animation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_bridge_animation.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_rotation.o: src/game/model_rotation.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_rotation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_rotation.raw.o $@ .text 0x17c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_polygons_plain.o: src/game/model_polygons_plain.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_polygons_plain.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_polygons_plain.raw.o $@ .text 0x11c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_polygons_color.o: src/game/model_polygons_color.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_polygons_color.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_polygons_color.raw.o $@ .text 0x188
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_hierarchy_vertices.o: src/game/model_hierarchy_vertices.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_hierarchy_vertices.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_hierarchy_vertices.raw.o $@ .text 0x1ac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_camera_identity.o: src/game/model_camera_identity.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_camera_identity.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_camera_identity.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_camera_rotation.o: src/game/model_camera_rotation.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_camera_rotation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_camera_rotation.raw.o $@ .text 0x1a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_mesh_iteration.o: src/game/model_mesh_iteration.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_mesh_iteration.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_mesh_iteration.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_normals_blend.o: src/game/model_normals_blend.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_normals_blend.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_normals_blend.raw.o $@ .text 0x200
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_vertices_scatter.o: src/game/model_vertices_scatter.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_vertices_scatter.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_vertices_scatter.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_framebuffer_copy.o: src/game/model_framebuffer_copy.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_framebuffer_copy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_framebuffer_copy.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_framebuffer_draw.o: src/game/model_framebuffer_draw.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_framebuffer_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_framebuffer_draw.raw.o $@ .text 0x1c4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_framebuffer_texture.o: src/game/model_framebuffer_texture.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_framebuffer_texture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_framebuffer_texture.raw.o $@ .text 0xf4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_legacy_scan.o: src/game/controller_legacy_scan.c include/controller_input.h include/controller_legacy.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_legacy_scan.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_legacy_scan.raw.o $@ .text 0xf4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS := build/us/frame_helpers.o \
    build/us/early_render_color.o \
    build/us/early_render_presets.o \
    build/us/early_render_dispatch.o \
    build/us/early_pool_entry_clear.o \
    build/us/early_pool_count.o \
    build/us/early_pool_index.o \
    build/us/early_byte_clear.o \
    build/us/early_angle_normalize.o \
    build/us/early_float_step.o \
    build/us/early_selection_state.o \
    build/us/early_callbacks_true.o \
    build/us/early_actor_create.o \
    build/us/early_actor_state.o \
    build/us/early_actor_mode3.o \
    build/us/early_actor_mode0.o \
    build/us/early_six_arg_forward.o \
    build/us/early_callback_false.o \
    build/us/early_actor_transition.o \
    build/us/early_pointer_state.o \
    build/us/early_resource_state.o \
    build/us/early_simple_forward.o \
    build/us/early_value_lookup.o \
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
    build/us/audio_instance_state_query.o \
    build/us/audio_instance_stop.o \
    build/us/audio_stop_commands.o \
    build/us/audio_voice_stop.o \
    build/us/audio_instance_stop_all.o \
    build/us/audio_stop_all_commands.o \
    build/us/audio_voice_stop_all.o \
    build/us/audio_level_commands.o \
    build/us/audio_level_commands_alt.o \
    build/us/audio_mode.o \
    build/us/audio_voice_pause_state.o \
    build/us/audio_pause_request.o \
    build/us/audio_pause_decode.o \
    build/us/audio_pause_apply.o \
    build/us/audio_resume_request.o \
    build/us/audio_resume_decode.o \
    build/us/audio_resume_apply.o \
    build/us/audio_pause_all_request.o \
    build/us/audio_pause_all_decode.o \
    build/us/audio_pause_all_apply.o \
    build/us/audio_resume_all_request.o \
    build/us/audio_resume_all_decode.o \
    build/us/audio_resume_all_apply.o \
    build/us/audio_play_arguments.o \
    build/us/audio_voice_properties_initial.o \
    build/us/audio_owner_properties_request.o \
    build/us/audio_owner_properties_decode.o \
    build/us/audio_owner_properties_apply.o \
    build/us/audio_owner_state_query.o \
    build/us/audio_owner_stop_request.o \
    build/us/audio_owner_stop_commands.o \
    build/us/audio_owner_stop_apply.o \
    build/us/audio_handle_instance.o \
    build/us/audio_handle_create.o \
    build/us/audio_handle_state.o \
    build/us/audio_handle_release.o \
    build/us/audio_handle_resume.o \
    build/us/audio_handle_resume_default.o \
    build/us/audio_handle_voice_resume.o \
    build/us/audio_handle_voice_resume_default.o \
    build/us/audio_handle_properties_capture.o \
    build/us/audio_handle_properties_apply.o \
    build/us/audio_handle_stop.o \
    build/us/audio_handle_rate.o \
    build/us/audio_handle_validate_only.o \
    build/us/audio_handle_rewind.o \
    build/us/audio_voice_command_parameter.o \
    build/us/audio_voice_command_temporary.o \
    build/us/audio_voice_properties_apply.o \
    build/us/audio_voice_properties_capture.o \
    build/us/audio_handle_parameter_57c70.o \
    build/us/audio_handle_pair_request.o \
    build/us/audio_handle_pair_decode.o \
    build/us/audio_handle_pair_apply.o \
    build/us/audio_voice_command_18.o \
    build/us/audio_handle_parameter_57e94.o \
    build/us/audio_handle_parameter_57ec0.o \
    build/us/audio_voice_command_10.o \
    build/us/audio_handle_parameter_57f48.o \
    build/us/audio_voice_command_11.o \
    build/us/audio_handle_parameter_57fcc.o \
    build/us/audio_handle_parameter_57ff8.o \
    build/us/audio_handle_parameter_58024.o \
    build/us/audio_voice_command_14.o \
    build/us/audio_handle_parameter_580a8.o \
    build/us/audio_voice_command_15.o \
    build/us/audio_handle_parameter_5812c.o \
    build/us/audio_voice_command_16.o \
    build/us/audio_handle_parameter_581b0.o \
    build/us/audio_handle_parameter_request.o \
    build/us/audio_handle_parameter_decode.o \
    build/us/audio_handle_parameter_apply.o \
    build/us/audio_stream_storage.o \
    build/us/audio_host_callbacks.o \
    build/us/audio_timing_rate.o \
    build/us/audio_stream_variable_read.o \
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
    build/us/game_string_compare.o \
    build/us/game_string_compare_n.o \
    build/us/game_integer_parse.o \
    build/us/heap_empty.o \

RUNTIME_OBJECTS += \
    build/us/object_recovery_path_extension.o \
    build/us/object_recovery_fixed_trig.o \
    build/us/object_recovery_integer_sqrt.o \
    build/us/object_recovery_angle_scale.o \
    build/us/object_recovery_direction_angle.o \
    build/us/object_recovery_angle_table.o \
    build/us/game_debug_format.o \

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
    build/us/save_slot_select.o \
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
    build/us/session_setup_kinemation.o \
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

RUNTIME_OBJECTS += \
    build/us/script_service_cache_reset.o \
    build/us/script_service_cache_access.o \
    build/us/script_service_commands.o \
    build/us/script_service_platform.o \
    build/us/script_animation_resolve.o \
    build/us/actor_animation.o \
    build/us/actor_motion_mode.o \
    build/us/debug_context_set.o \
    build/us/debug_text_draw.o \
    build/us/tweak_reset.o \
    build/us/tweak_page.o \
    build/us/tweak_define.o \
    build/us/tweak_difficulty_apply.o \
    build/us/tweak_bind.o \
    build/us/tweak_bind_all.o \
    build/us/tweak_scale_enemy_speeds.o \
    build/us/resource_string_reset.o \
    build/us/resource_string_find.o \
    build/us/resource_string_load.o

RUNTIME_OBJECTS += \
    build/us/script_service_files.o \
    build/us/actor_behavior_state.o \
    build/us/actor_behavior_blend_velocity.o \
    build/us/actor_behavior_blend_motion.o \
    build/us/actor_behavior_height.o \
    build/us/actor_behavior_extra_b32c.o \
    build/us/actor_behavior_noop_b570.o \
    build/us/actor_behavior_extra_b57c.o \
    build/us/actor_behavior_noop_b7a4.o \
    build/us/actor_behavior_noop_b7b0.o \
    build/us/actor_behavior_repeat.o \
    build/us/actor_behavior_extra_d918.o \
    build/us/actor_behavior_countdown.o \
    build/us/actor_behavior_countdown_begin.o \
    build/us/actor_behavior_countdown_trigger.o \
    build/us/sound_bridge_core.o \
    build/us/sound_bridge_definitions.o \
    build/us/sound_bridge_future_reset.o \
    build/us/sound_bridge_future_queue.o \
    build/us/sound_bridge_future_update.o \
    build/us/geometry_debug_bridge.o \
    build/us/geometry_bridge_apply.o \
    build/us/geometry_bridge_rotate.o \
    build/us/renderer_vertex_attributes.o \
    build/us/renderer_material_texture.o \
    build/us/renderer_material_light.o \
    build/us/renderer_material_combined.o \
    build/us/renderer_light_select.o \
    build/us/renderer_material_untextured.o \
    build/us/renderer_material_reset.o \
    build/us/renderer_vertex_copy.o \
    build/us/renderer_texture_load.o \
    build/us/graphics_display_list.o \
    build/us/graphics_resource.o \
    build/us/graphics_modes.o \
    build/us/graphics_lights.o \
    build/us/graphics_pool.o \
    build/us/graphics_pool_initialize.o \
    build/us/graphics_frame_reset.o \
    build/us/graphics_mode_dispatch.o \
    build/us/graphics_environment.o \
    build/us/graphics_state_helpers.o

RUNTIME_OBJECTS += \
    build/us/save_level_lookup.o \
    build/us/save_menu_conditional_copy.o \
    build/us/save_menu_flag_setter.o \
    build/us/save_menu_text_flags.o \
    build/us/save_menu_state_reset.o \
    build/us/save_menu_legacy_reset.o \
    build/us/save_menu_legacy_heap.o \
    build/us/save_menu_legacy_pages.o \
    build/us/save_menu_legacy_pak_status.o \
    build/us/save_menu_legacy_exit.o \
    build/us/save_menu_legacy_pages_tail.o \
    build/us/save_menu_nav_refresh.o \
    build/us/save_menu_nav_open_primary.o \
    build/us/save_menu_nav_open_secondary.o \
    build/us/save_menu_nav_open_return.o \
    build/us/save_menu_nav_noop.o \
    build/us/save_menu_nav_reset.o \
    build/us/save_menu_nav_actor_disable.o \
    build/us/save_menu_nav_actor_forward.o \
    build/us/save_menu_nav_actor_back.o \
    build/us/save_menu_nav_preview_create.o \
    build/us/save_menu_nav_preview_release.o \
    build/us/save_menu_nav_cleanup.o \
    build/us/save_menu_pak_retry.o \
    build/us/save_menu_pak_reset.o \
    build/us/save_menu_pak_refresh.o \
    build/us/save_menu_pak_result.o \
    build/us/actor_behavior_frame_sync.o \
    build/us/actor_behavior_motion_begin.o \
    build/us/actor_behavior_motion_guarded.o \
    build/us/actor_behavior_motion_scaled.o \
    build/us/actor_behavior_animation_2945c.o \
    build/us/actor_behavior_callback_29544.o \
    build/us/actor_behavior_spawn.o \
    build/us/actor_behavior_spawn_restore.o \
    build/us/actor_behavior_release_29d6c.o \
    build/us/actor_behavior_next_a244.o \
    build/us/save_menu_continue_encode.o \
    build/us/renderer_vertex_positions.o \
    build/us/renderer_mesh_positions.o

RUNTIME_OBJECTS += \
    build/us/movie_camera.o \
    build/us/movie_actor.o \
    build/us/actor_motion_facing.o \
    build/us/scene_transition_open.o \
    build/us/scene_transition_close.o \
    build/us/scene_transition_draw.o \
    build/us/scene_player_setup.o \
    build/us/scene_signed_shift.o \
    build/us/scene_actor_parameter_reset.o \
    build/us/scene_glyph_release.o \
    build/us/scene_actor_scale.o \
    build/us/scene_actor_motion_reset.o \
    build/us/scene_service_noop.o \
    build/us/scene_parent_follow.o \
    build/us/scene_bucket_counter.o \
    build/us/tweak_scene_apply.o \
    build/us/scene_timer_capture.o \
    build/us/scene_timer_initialize.o \
    build/us/scene_timer_service.o \
    build/us/object_service.o \
    build/us/object_registration.o \
    build/us/object_creation.o \
    build/us/object_model_access.o \
    build/us/resource_bridge_model_cache.o \
    build/us/resource_bridge_texture_stub.o \
    build/us/resource_bridge_bitmap.o \
    build/us/resource_bridge_animation.o \
    build/us/model_rotation.o \
    build/us/model_polygons_plain.o \
    build/us/model_polygons_color.o \
    build/us/model_hierarchy_vertices.o \
    build/us/model_camera_identity.o \
    build/us/model_camera_rotation.o \
    build/us/model_mesh_iteration.o \
    build/us/model_normals_blend.o \
    build/us/model_vertices_scatter.o \
    build/us/model_framebuffer_copy.o \
    build/us/model_framebuffer_draw.o \
    build/us/model_framebuffer_texture.o \
    build/us/controller_legacy_scan.o

build/us/audio_handle_voice.o: src/game/audio_handle_voice.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_voice.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_voice.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_seek_relative.o: src/game/audio_handle_seek_relative.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_seek_relative.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_seek_relative.raw.o $@ .text 0x160
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_seek_absolute.o: src/game/audio_handle_seek_absolute.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_seek_absolute.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_seek_absolute.raw.o $@ .text 0x158
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_position.o: src/game/audio_handle_position.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_position.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_position.raw.o $@ .text 0xd0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_host_control.o: src/game/audio_host_control.c include/audio_host_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_host_control.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_host_control.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_host_files.o: src/game/audio_host_files.c include/audio_io.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_host_files.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_host_files.raw.o $@ .text 0x124
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stream_variable_write.o: src/game/audio_stream_variable_write.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stream_variable_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stream_variable_write.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_handle_voice.o \
    build/us/audio_handle_seek_relative.o \
    build/us/audio_handle_seek_absolute.o \
    build/us/audio_handle_position.o \
    build/us/audio_host_control.o \
    build/us/audio_host_files.o \
    build/us/audio_stream_variable_write.o

build/us/audio_diagnostics.o: src/game/audio_diagnostics.c include/audio_control.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_diagnostics.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_diagnostics.raw.o $@ .text 0x6c0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_setup.o: src/game/audio_engine_setup.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_setup.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_voice_stop.o: src/game/audio_engine_voice_stop.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_voice_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_voice_stop.raw.o build/us/audio_engine_voice_stop.text.o .text 0x17c
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_voice_stop.text.o $@ .bss 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_parameters.o: src/game/audio_engine_parameters.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_parameters.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_parameters.raw.o $@ .text 0xcc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_tempo.o: src/game/audio_engine_tempo.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_tempo.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_tempo.raw.o build/us/audio_engine_tempo.text.o .text 0x19c
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_tempo.text.o $@ .bss 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_sequence_call.o: src/game/audio_engine_sequence_call.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_sequence_call.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_sequence_call.raw.o build/us/audio_engine_sequence_call.text.o .text 0x1b8
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_sequence_call.text.o $@ .bss 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_sequence_jump.o: src/game/audio_engine_sequence_jump.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_sequence_jump.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_sequence_jump.raw.o build/us/audio_engine_sequence_jump.text.o .text 0x190
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_sequence_jump.text.o $@ .bss 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_sequence_return.o: src/game/audio_engine_sequence_return.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_sequence_return.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_sequence_return.raw.o build/us/audio_engine_sequence_return.text.o .text 0x138
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_sequence_return.text.o $@ .bss 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_sequence_stop.o: src/game/audio_engine_sequence_stop.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_sequence_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_sequence_stop.raw.o build/us/audio_engine_sequence_stop.text.o .text 0x290
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_sequence_stop.text.o $@ .bss 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_voice_tempo.o: src/game/audio_engine_voice_tempo.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_voice_tempo.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_voice_tempo.raw.o $@ .text 0x64
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_voice_call.o: src/game/audio_engine_voice_call.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_voice_call.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_voice_call.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_voice_jump.o: src/game/audio_engine_voice_jump.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_voice_jump.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_voice_jump.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_voice_return.o: src/game/audio_engine_voice_return.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_voice_return.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_voice_return.raw.o $@ .text 0x5c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_voice_end.o: src/game/audio_engine_voice_end.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_voice_end.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_voice_end.raw.o $@ .text 0x120
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_rate_scale.o: src/game/audio_rate_scale.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_rate_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_rate_scale.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_capture_control.o: src/game/audio_voice_capture_control.c include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_capture_control.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_capture_control.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_capture_resume.o: src/game/audio_voice_capture_resume.c include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_capture_resume.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_capture_resume.raw.o $@ .text 0xd8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_capture_append.o: src/game/audio_voice_capture_append.c include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_capture_append.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_capture_append.raw.o $@ .text 0x13c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_argument.o: src/game/audio_voice_argument.c include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_argument.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_argument.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_diagnostics.o \
    build/us/audio_engine_setup.o \
    build/us/audio_engine_voice_stop.o \
    build/us/audio_engine_parameters.o \
    build/us/audio_engine_tempo.o \
    build/us/audio_engine_sequence_call.o \
    build/us/audio_engine_sequence_jump.o \
    build/us/audio_engine_sequence_return.o \
    build/us/audio_engine_sequence_stop.o \
    build/us/audio_engine_voice_tempo.o \
    build/us/audio_engine_voice_call.o \
    build/us/audio_engine_voice_jump.o \
    build/us/audio_engine_voice_return.o \
    build/us/audio_engine_voice_end.o \
    build/us/audio_rate_scale.o \
    build/us/audio_voice_capture_control.o \
    build/us/audio_voice_capture_resume.o \
    build/us/audio_voice_capture_append.o \
    build/us/audio_voice_argument.o

build/us/audio_pitch_scale.o: src/game/audio_pitch_scale.c  $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pitch_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pitch_scale.raw.o build/us/audio_pitch_scale.text.o .text 0x64
	$(PYTHON) tools/owned_sections.py $< build/us/audio_pitch_scale.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_update.o: src/game/audio_backend_update.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_update.raw.o build/us/audio_backend_update.text.o .text 0x150
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_update.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_voice_stop.o: src/game/audio_backend_voice_stop.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_voice_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_voice_stop.raw.o build/us/audio_backend_voice_stop.text.o .text 0x98
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_voice_stop.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_patch.o: src/game/audio_backend_patch.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_patch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_patch.raw.o build/us/audio_backend_patch.text.o .text 0x2c
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_patch.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_release.o: src/game/audio_backend_release.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_release.raw.o $@ .text 0x18c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_decay.o: src/game/audio_backend_decay.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_decay.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_decay.raw.o build/us/audio_backend_decay.text.o .text 0x174
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_decay.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_allocate.o: src/game/audio_backend_allocate.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_allocate.raw.o build/us/audio_backend_allocate.text.o .text 0x23c
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_allocate.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_file_services.o: src/game/audio_file_services.c include/audio_file_services_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_file_services.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_file_services.raw.o $@ .text 0x14c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_pitch_scale.o \
    build/us/audio_backend_update.o \
    build/us/audio_backend_voice_stop.o \
    build/us/audio_backend_patch.o \
    build/us/audio_backend_release.o \
    build/us/audio_backend_decay.o \
    build/us/audio_backend_allocate.o \
    build/us/audio_file_services.o

build/us/audio_sequence_table_size.o: src/game/audio_sequence_table_size.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_table_size.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_table_size.raw.o $@ .text 0xc4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_table_load.o: src/game/audio_sequence_table_load.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_table_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_table_load.raw.o $@ .text 0x1c0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_table_close.o: src/game/audio_sequence_table_close.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_table_close.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_table_close.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_size.o: src/game/audio_sequence_size.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_size.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_size.raw.o $@ .text 0xbc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_load.o: src/game/audio_sequence_load.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_load.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_release.o: src/game/audio_sequence_release.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_release.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_range_size.o: src/game/audio_sequence_range_size.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_range_size.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_range_size.raw.o $@ .text 0x7c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_range_load.o: src/game/audio_sequence_range_load.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_range_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_range_load.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_range_release.o: src/game/audio_sequence_range_release.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_range_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_range_release.raw.o $@ .text 0x7c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_sequence_table_size.o \
    build/us/audio_sequence_table_load.o \
    build/us/audio_sequence_table_close.o \
    build/us/audio_sequence_size.o \
    build/us/audio_sequence_load.o \
    build/us/audio_sequence_release.o \
    build/us/audio_sequence_range_size.o \
    build/us/audio_sequence_range_load.o \
    build/us/audio_sequence_range_release.o

build/us/compression_table_release.o: src/game/compression_table_release.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_table_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_table_release.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_fixed_release.o: src/game/compression_fixed_release.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_fixed_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_fixed_release.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_workspace.o: src/game/compression_workspace.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_workspace.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_workspace.raw.o build/us/compression_workspace.text.o .text 0xc4
	$(PYTHON) tools/owned_sections.py $< build/us/compression_workspace.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_allocate.o: src/game/compression_allocate.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_allocate.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_refill.o: src/game/compression_refill.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_refill.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_refill.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_decode.o: src/game/compression_decode.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_decode.raw.o $@ .text 0x238
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_memory.o: src/game/compression_memory.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_memory.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_memory.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_cartridge.o: src/game/compression_cartridge.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_cartridge.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_cartridge.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_cartridge_bounded.o: src/game/compression_cartridge_bounded.c include/audio_io.h include/compression_internal.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_cartridge_bounded.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_cartridge_bounded.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/compression_table_release.o \
    build/us/compression_fixed_release.o \
    build/us/compression_workspace.o \
    build/us/compression_allocate.o \
    build/us/compression_refill.o \
    build/us/compression_decode.o \
    build/us/compression_memory.o \
    build/us/compression_cartridge.o \
    build/us/compression_cartridge_bounded.o

build/us/session_setup_extra_kinemation.o: src/game/session_setup_extra_kinemation.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_extra_kinemation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_extra_kinemation.raw.o $@ .text 0xe0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/session_setup_extra_kinemation.o

build/us/audio_backend_initialize.o: src/game/audio_backend_initialize.c include/audio_backend_internal.h include/audio_bank_layout_internal.h include/audio_callbacks.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_initialize.raw.o build/us/audio_backend_initialize.text.o .text 0x2c4
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_initialize.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_backend_initialize.o

build/us/audio_backend_volume.o: src/game/audio_backend_volume.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_volume.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_volume.raw.o build/us/audio_backend_volume.text.o .text 0x234
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_volume.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_pan_pedal.o: src/game/audio_backend_pan_pedal.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_pan_pedal.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_pan_pedal.raw.o build/us/audio_backend_pan_pedal.text.o .text 0x2dc
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_pan_pedal.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_backend_volume.o \
    build/us/audio_backend_pan_pedal.o

build/us/audio_sequence_list_size.o: src/game/audio_sequence_list_size.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_list_size.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_list_size.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_list_load.o: src/game/audio_sequence_list_load.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_list_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_list_load.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_list_release.o: src/game/audio_sequence_list_release.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_list_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_list_release.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_sequence_list_size.o \
    build/us/audio_sequence_list_load.o \
    build/us/audio_sequence_list_release.o

build/us/audio_backend_voice_start.o: src/game/audio_backend_voice_start.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_properties_internal.h include/audio_voice_capture_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_voice_start.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_voice_start.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_backend_voice_start.o

build/us/audio_engine_gate_reset.o: src/game/audio_engine_gate_reset.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_gate_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_gate_reset.raw.o build/us/audio_engine_gate_reset.text.o .text 0xcc
	$(PYTHON) tools/owned_sections.py $< build/us/audio_engine_gate_reset.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_iteration_reset.o: src/game/audio_engine_iteration_reset.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_iteration_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_iteration_reset.raw.o build/us/audio_engine_iteration_reset.text.o .text 0xcc
	$(PYTHON) tools/owned_sections.py $< build/us/audio_engine_iteration_reset.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_engine_gate_reset.o \
    build/us/audio_engine_iteration_reset.o

build/us/audio_engine_iteration_set.o: src/game/audio_engine_iteration_set.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_iteration_set.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_iteration_set.raw.o build/us/audio_engine_iteration_set.text.o .text 0x40
	$(PYTHON) tools/owned_sections.py $< build/us/audio_engine_iteration_set.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_engine_iteration_set.o

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
