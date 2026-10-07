.DEFAULT_GOAL := all
PYTHON := python3
CROSS := mips-linux-gnu-
IDO := .local/toolchain/5.3/cc
BASEROM ?= baseroms/us/baserom.z64

.PHONY: all setup toolchain verify progress remaining clean test analysis-setup analyze resources compare-data check-palette-color-tables

compare-data: toolchain
	$(PYTHON) tools/compare_data.py

check-palette-color-tables: toolchain
	$(PYTHON) tools/check_palette_color_tables.py

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

build/us/text.o: src/game/text.c include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text.raw.o build/us/text.text.o .text 0xaf8
	$(PYTHON) tools/owned_sections.py $< build/us/text.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_wrapper.o: src/game/text_wrapper.c include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_wrapper.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text_wrapper.raw.o $@ .text 0xc4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_edit.o: src/game/text_edit.c include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o $@ $<
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_properties.o: src/game/text_properties.c include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_properties.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text_properties.raw.o $@ .text 0x308
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_conversion.o: src/game/text_conversion.c include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_conversion.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/text_conversion.raw.o $@ .text 0xa4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_tick.o: src/game/early_actor_tick.c include/actor.h include/actor_behavior_internal.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_tick.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_tick.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_render_color.o: src/game/early_render_color.c include/debug_output.h include/early_game_helpers.h include/early_render_internal.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_color.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_render_color.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_render_presets.o: src/game/early_render_presets.c include/actor.h include/actor_behavior_internal.h include/debug_output.h include/early_game_helpers.h include/early_game_state.h include/early_render_effects_internal.h include/early_render_internal.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/game_memory.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/object_recovery.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/scalar_math.h include/sdk_matrix.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
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

build/us/early_actor_vector_clear.o: src/game/early_actor_vector_clear.c include/actor.h include/actor_behavior_internal.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_vector_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_vector_clear.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_global_reset.o: src/game/early_global_reset.c include/early_game_more.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_global_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_global_reset.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_float_step.o: src/game/early_float_step.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_float_step.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_float_step.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_selection_state.o: src/game/early_selection_state.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_helpers.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_selection_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_selection_state.raw.o $@ .text 0x1e4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_callbacks_true.o: src/game/early_callbacks_true.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_callbacks_true.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_callbacks_true.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_pair_balance.o: src/game/early_actor_pair_balance.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_pair_balance.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_pair_balance.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_create.o: src/game/early_actor_create.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h include/actor_collision_separation_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_create.raw.o $@ .text 0x164
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_state.o: src/game/early_actor_state.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_state.raw.o $@ .text 0x128
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_mode3.o: src/game/early_actor_mode3.c include/actor.h include/early_game_helpers.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_mode3.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_mode3.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_guarded_service.o: src/game/early_actor_guarded_service.c include/actor_damage_internal.h include/actor.h include/actor_behavior_internal.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_guarded_service.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_guarded_service.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_mode0.o: src/game/early_actor_mode0.c include/actor.h include/early_game_helpers.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_mode0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_mode0.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_six_arg_forward.o: src/game/early_six_arg_forward.c include/early_game_helpers.h include/actor_collision_separation_internal.h include/actor_behavior_internal.h include/actor.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_six_arg_forward.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_six_arg_forward.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_callback_false.o: src/game/early_callback_false.c include/early_game_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_callback_false.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_callback_false.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_transition.o: src/game/early_actor_transition.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/early_game_medium.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_transition.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_transition.raw.o $@ .text 0xcc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_pointer_state.o: src/game/early_pointer_state.c include/actor.h include/actor_behavior_internal.h include/early_game_medium.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_pointer_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_pointer_state.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_resource_state.o: src/game/early_resource_state.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/early_resource_state.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_resource_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_resource_state.raw.o $@ .text 0x1a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_spawn_helper.o: src/game/early_actor_spawn_helper.c include/actor.h include/actor_behavior_internal.h include/early_game_medium_next.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_spawn_helper.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_spawn_helper.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_file_state_reset.o: src/game/early_file_state_reset.c include/destination_format.h include/controller_input.h include/early_game_medium_next.h include/early_input_internal.h include/game_memory.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_file_state_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_file_state_reset.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_name_mask_lookup.o: src/game/early_name_mask_lookup.c include/early_game_medium_next.h include/early_name_table.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_name_mask_lookup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_name_mask_lookup.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_name_mask_parse.o: src/game/early_name_mask_parse.c include/early_game_medium_next.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_name_mask_parse.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_name_mask_parse.raw.o $@ .text 0x108
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_simple_forward.o: src/game/early_simple_forward.c include/early_game_helpers.h include/early_game_more.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_simple_forward.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_simple_forward.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_value_lookup.o: src/game/early_value_lookup.c include/actor.h include/actor_behavior_internal.h include/early_game_medium.h include/early_game_state.h include/early_name_table.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/startup.o: src/boot/startup.c include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/frame.h include/graphics_tasks.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/renderer_projection_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o $@ $<
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scheduler.o: src/boot/scheduler.c include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_io.h include/sdk_rsp.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scheduler.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scheduler.raw.o $@ .text 0xb70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scheduler_runtime_tail.o: src/boot/scheduler_runtime_tail.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scheduler_runtime_tail.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scheduler_runtime_tail.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_helpers.o: src/boot/frame_helpers.c include/fixed_math.h include/frame.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_helpers.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_helpers.raw.o $@ .text 0x234
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_timing.o: src/boot/frame_timing.c include/frame.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_timing.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_timing.raw.o $@ .text 0x124
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_transform.o: src/game/frame_transform.c include/fixed_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_transform.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_transform.raw.o $@ .text 0xe8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_ucode.o: src/boot/graphics_ucode.c include/graphics_tasks.h include/scheduler.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_ucode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_ucode.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/fixed_math.o: src/game/fixed_math.c include/fixed_math.h include/sdk_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/fixed_math.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/fixed_math.raw.o $@ .text 0x134
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_setup.o: src/boot/graphics_setup.c include/graphics_tasks.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_setup.raw.o build/us/graphics_setup.text.o .text 0x274
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_setup.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_tasks.o: src/boot/graphics_tasks.c include/graphics_tasks.h include/scheduler.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_tasks.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_tasks.raw.o $@ .text 0x3bc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_render.o: src/boot/frame_render.c include/frame.h include/graphics_tasks.h include/scheduler.h include/scheduler_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_render.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_render.raw.o $@ .text 0x198
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_matrices.o: src/boot/frame_matrices.c include/frame.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/renderer_projection_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_matrices.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_matrices.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_projection.o: src/boot/frame_projection.c include/frame.h include/object_recovery.h include/runtime_angle.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_projection.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_projection.raw.o build/us/frame_projection.text.o .text 0x120
	$(PYTHON) tools/owned_sections.py $< build/us/frame_projection.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/fixed_geometry.o: src/game/fixed_geometry.c include/fixed_geometry.h include/fixed_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/fixed_geometry.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/fixed_geometry.raw.o $@ .text 0x598
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_control.o: src/game/audio_control.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/audio_io.o: src/game/audio_io.c include/audio_io.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_io.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_io.raw.o $@ .text 0x12c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/heap.o: src/game/heap.c include/heap.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/heap.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/heap.raw.o $@ .text 0x21c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_history.o: src/game/object_history.c include/actor_history_internal.h include/actor_projectile_internal.h include/object_recovery.h include/actor.h include/game_memory.h include/object.h include/object_history.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/object_helpers_pool_alloc.o: src/game/object_helpers_pool_alloc.c include/object.h include/object_draw.h include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_pool_alloc.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_pool_alloc.raw.o $@ .text 0x100
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_pool_status.o: src/game/object_helpers_pool_status.c include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_pool_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_pool_status.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_draw_noop.o: src/game/object_helpers_draw_noop.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_draw_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_draw_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_draw.o: src/game/object_helpers_draw.c include/object.h include/object_draw.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_draw.raw.o $@ .text 0x284
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_helpers_draw_mode.o: src/game/object_helpers_draw_mode.c include/object.h include/object_draw.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/fixed_math.h include/frame.h include/renderer_draw_state_internal.h include/renderer_object_glyph_internal.h include/sdk_matrix.h include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h include/palette.h include/static_menu_internal.h $(wildcard include/*.h)
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_helpers_draw_mode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_helpers_draw_mode.raw.o $@ .text 0x138
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_play.o: src/game/audio_play.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_play.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_play.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_stop.o: src/game/audio_instance_stop.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_stop.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stop_commands.o: src/game/audio_stop_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stop_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stop_commands.raw.o $@ .text 0xbc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_stop.o: src/game/audio_voice_stop.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_stop.raw.o $@ .text 0x200
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_stop_all.o: src/game/audio_instance_stop_all.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_stop_all.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_stop_all.raw.o $@ .text 0xf0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_stop_all_commands.o: src/game/audio_stop_all_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stop_all_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stop_all_commands.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_stop_all.o: src/game/audio_voice_stop_all.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_stop_all.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_stop_all.raw.o $@ .text 0x1ec
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_commands.o: src/game/audio_level_commands.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_commands.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_commands_alt.o: src/game/audio_level_commands_alt.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_commands_alt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_commands_alt.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_mode.o: src/game/audio_mode.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_mode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_mode.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_state_query.o: src/game/audio_instance_state_query.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_state_query.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_state_query.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_voice_pause_state.o: src/game/audio_voice_pause_state.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_pause_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_pause_state.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_request.o: src/game/audio_pause_request.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_request.raw.o $@ .text 0xc8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_decode.o: src/game/audio_pause_decode.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_decode.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_apply.o: src/game/audio_pause_apply.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_apply.raw.o $@ .text 0x1cc
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_request.o: src/game/audio_resume_request.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_request.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_decode.o: src/game/audio_resume_decode.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_decode.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_apply.o: src/game/audio_resume_apply.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_apply.raw.o $@ .text 0x168
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_all_request.o: src/game/audio_pause_all_request.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_all_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_all_request.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_all_decode.o: src/game/audio_pause_all_decode.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_all_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_all_decode.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_pause_all_apply.o: src/game/audio_pause_all_apply.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pause_all_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pause_all_apply.raw.o $@ .text 0x1e8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_all_request.o: src/game/audio_resume_all_request.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_all_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_all_request.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_all_decode.o: src/game/audio_resume_all_decode.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_all_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_all_decode.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_resume_all_apply.o: src/game/audio_resume_all_apply.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resume_all_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resume_all_apply.raw.o $@ .text 0x18c
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_voice_properties_initial.o: src/game/audio_voice_properties_initial.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_properties_initial.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_properties_initial.raw.o $@ .text 0x264
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_properties_request.o: src/game/audio_owner_properties_request.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_properties_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_properties_request.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_properties_decode.o: src/game/audio_owner_properties_decode.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_properties_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_properties_decode.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_properties_apply.o: src/game/audio_owner_properties_apply.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_properties_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_properties_apply.raw.o $@ .text 0x184
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_state_query.o: src/game/audio_owner_state_query.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_state_query.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_state_query.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_stop_request.o: src/game/audio_owner_stop_request.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_stop_request.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_stop_request.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_stop_commands.o: src/game/audio_owner_stop_commands.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_stop_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_stop_commands.raw.o $@ .text 0xbc
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h

build/us/audio_owner_stop_apply.o: src/game/audio_owner_stop_apply.c include/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h src/game/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_stop_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_stop_apply.raw.o $@ .text 0x200
	$(PYTHON) tools/provenance.py $< $@ src/game/audio_properties_internal.h include/audio_properties_internal.h
build/us/audio_play_arguments.o: src/game/audio_play_arguments.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/audio_stream_storage.o: src/game/audio_stream_storage.c include/audio_host_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_stream_storage.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_stream_storage.raw.o $@ .text 0x94
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_host_callbacks.o: src/game/audio_host_callbacks.c include/audio_host_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/audio_command_lock.o: src/game/audio_command_lock.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_command_lock.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_command_lock.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_command_queue.o: src/game/audio_command_queue.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_command_queue.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_command_queue.raw.o $@ .text 0x240
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_thread.o: src/game/audio_thread.c include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_thread.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_thread.raw.o $@ .text 0x230
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_update.o: src/game/audio_level_update.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_update.raw.o $@ .text 0x1e0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_level_update_alt.o: src/game/audio_level_update_alt.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_level_update_alt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_level_update_alt.raw.o $@ .text 0x1dc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_reset.o: src/game/object_reset.c include/game_memory.h include/object.h include/object_draw.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_reset.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup.o: src/game/audio_startup.c include/audio_backend_internal.h include/audio_bank_layout_internal.h include/audio_callbacks.h include/audio_config.h include/audio_control.h include/audio_file_services_internal.h include/audio_host_internal.h include/audio_io.h include/audio_loader_internal.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/heap.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/fixed_geometry_setup.o: src/game/fixed_geometry_setup.c include/fixed_geometry.h include/fixed_math.h include/scalar_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/fixed_geometry_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/fixed_geometry_setup.raw.o $@ .text 0x5e4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_runtime_service.o: src/game/object_runtime_service.c include/object_runtime.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_runtime_service.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_runtime_service.raw.o $@ .text 0x5c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_generation.o: src/game/audio_generation.c include/audio_commands.h include/audio_control.h include/audio_game.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/heap.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_generation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_generation.raw.o $@ .text 0x2a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_task_select.o: src/game/audio_task_select.c include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_task_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_task_select.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_pool_callback.o: src/game/audio_pool_callback.c include/audio_callbacks.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pool_callback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pool_callback.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_shutdown.o: src/game/audio_shutdown.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/rom_files.o: src/game/rom_files.c include/debug_output.h include/game_memory.h include/pi.h include/rom_files.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/audio_task_build.o: src/game/audio_task_build.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/game_string_case_compare_n.o: src/game/game_string_case_compare_n.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_string_case_compare_n.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_string_case_compare_n.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_string_compare_n.o: src/game/game_string_compare_n.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_string_compare_n.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_string_compare_n.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/runtime_random.o: src/game/runtime_random.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/runtime_random.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/runtime_random.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/runtime_float_truncate.o: src/game/runtime_float_truncate.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/runtime_float_truncate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/runtime_float_truncate.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_history_byte_clear.o: src/game/actor_history_byte_clear.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_history_byte_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_history_byte_clear.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/game_integer_parse.o: src/game/game_integer_parse.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_integer_parse.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_integer_parse.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/heap_empty.o: src/game/heap_empty.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/heap_empty.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/heap_empty.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_recovery_path_extension.o: src/game/object_recovery_path_extension.c include/game_memory.h include/object_recovery.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_recovery_path_extension.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_recovery_path_extension.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_recovery_fixed_trig.o: src/game/object_recovery_fixed_trig.c include/fixed_math.h include/object_recovery.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/string_resource.o: src/game/string_resource.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/string_resource.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/string_resource.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/palette_tint.o: src/game/palette_tint.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/actor_resource_reset.o: src/game/actor_resource_reset.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resource_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_resource_reset.raw.o $@ .text 0x190
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_options_capture.o: src/game/save_options_capture.c include/destination_format.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_options_capture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_options_capture.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_slot_capture.o: src/game/save_slot_capture.c include/destination_format.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_slot_capture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_slot_capture.raw.o $@ .text 0xd8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_options_restore.o: src/game/save_options_restore.c include/destination_format.h include/audio_game.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_options_restore.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_options_restore.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_slot_restore.o: src/game/save_slot_restore.c include/destination_format.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_slot_restore.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_slot_restore.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_slot_labels.o: src/game/save_slot_labels.c include/destination_format.h include/game_memory.h include/object.h include/pak_file.h include/save_game.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_slot_labels.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_slot_labels.raw.o $@ .text 0x150
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_file_read.o: src/game/save_file_read.c include/destination_format.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_file_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_file_read.raw.o $@ .text 0x27c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_file_write.o: src/game/save_file_write.c include/destination_format.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_file_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_file_write.raw.o $@ .text 0x1d8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_slot_select.o: src/game/save_slot_select.c include/destination_format.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/pak_file_open.o: src/game/pak_file_open.c include/destination_format.h include/controller_input.h include/controller_services.h include/pak_file.h include/save_game.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_open.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_open.raw.o $@ .text 0x1b8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_read.o: src/game/pak_file_read.c include/destination_format.h include/controller_input.h include/controller_services.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_read.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_write.o: src/game/pak_file_write.c include/destination_format.h include/controller_input.h include/controller_services.h include/pak_file.h include/save_game.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_file_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_file_write.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pak_file_close.o: src/game/pak_file_close.c include/destination_format.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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
	$(PYTHON) tools/trim_padding.py build/us/controller_access.raw.o $@ .text 0x1c8
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

build/us/controller_pak_delete.o: src/game/controller_pak_delete.c include/destination_format.h include/controller_input.h include/controller_services.h include/pak_file.h include/save_game.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_delete.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_pak_delete.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_pak_name.o: src/game/controller_pak_name.c include/controller_input.h include/controller_services.h include/game_memory.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_name.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_pak_name.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_pak_entry.o: src/game/controller_pak_entry.c include/destination_format.h include/controller_input.h include/controller_services.h include/game_memory.h include/object.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_entry.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_pak_entry.raw.o $@ .text 0x150
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_pak_directory.o: src/game/controller_pak_directory.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_directory.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_pak_directory.raw.o $@ .text 0x16c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resource_load.o: src/game/actor_resource_load.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/session_menu_selection.o: src/game/session_menu_selection.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_selection.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_selection.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_update.o: src/game/session_menu_preview_update.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_update.raw.o $@ .text 0x14c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_create.o: src/game/session_menu_preview_create.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_create.raw.o $@ .text 0x164
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_accept.o: src/game/session_menu_preview_accept.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_accept.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_accept.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_cancel.o: src/game/session_menu_preview_cancel.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_cancel.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_cancel.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_preview_release.o: src/game/session_menu_preview_release.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_preview_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_preview_release.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_empty.o: src/game/session_setup_empty.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_empty.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_empty.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_exit_game.o: src/game/session_menu_exit_game.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_exit_game.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_exit_game.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_start_single.o: src/game/session_menu_start_single.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_start_single.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_start_single.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_setup_menu_reset.o: src/game/session_setup_menu_reset.c include/game_memory.h include/object.h include/session_setup_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_setup_menu_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_setup_menu_reset.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_show_main.o: src/game/session_menu_show_main.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_show_main.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_show_main.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_start_two.o: src/game/session_menu_start_two.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_start_two.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_start_two.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_start_alternate.o: src/game/session_menu_start_alternate.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_start_alternate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_start_alternate.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_return.o: src/game/session_menu_return.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_return.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_return.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_level_exit.o: src/game/session_menu_level_exit.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_level_exit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_level_exit.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_player_choice.o: src/game/session_menu_player_choice.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_player_choice.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_player_choice.raw.o $@ .text 0xb4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_pages.o: src/game/session_menu_pages.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_pages.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_pages.raw.o $@ .text 0x94
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_shell_reset.o: src/game/session_menu_shell_reset.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_shell_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_shell_reset.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_menu_defaults.o: src/game/session_menu_defaults.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_menu_defaults.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_menu_defaults.raw.o $@ .text 0xe0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_noop.o: src/game/actor_setup_noop.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_strings.o: src/game/actor_setup_strings.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_strings.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_strings.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_animation_reset.o: src/game/actor_setup_animation_reset.c include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_animation_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_animation_reset.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_text_begin.o: src/game/actor_setup_text_begin.c include/destination_format.h include/game_memory.h include/object.h include/pak_file.h include/save_game.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_text_begin.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_text_begin.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_setup_text_reset.o: src/game/actor_setup_text_reset.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_setup_text_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_setup_text_reset.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_actor_create.o: src/game/scene_actor_create.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_create.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_file_idle.o: src/game/scene_file_idle.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_file_idle.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_file_idle.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_file_stubs.o: src/game/scene_file_stubs.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_file_stubs.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_file_stubs.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_file_select.o: src/game/scene_file_select.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_file_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_file_select.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_resource_limits.o: src/game/scene_resource_limits.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_resource_limits.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_resource_limits.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_display_flags.o: src/game/scene_display_flags.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_display_flags.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_display_flags.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_position.o: src/game/scene_position.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_position.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_position.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_value_d0c.o: src/game/scene_value_d0c.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_value_d0c.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_value_d0c.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_values_cd0.o: src/game/scene_values_cd0.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_values_cd0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_values_cd0.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_values_cdc.o: src/game/scene_values_cdc.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_values_cdc.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_values_cdc.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_values_cf0.o: src/game/scene_values_cf0.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_values_cf0.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_values_cf0.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_effect_add.o: src/game/scene_effect_add.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_effect_add.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_effect_add.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_value_cec.o: src/game/scene_value_cec.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_value_cec.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_value_cec.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_unused_commands.o: src/game/scene_unused_commands.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_unused_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_unused_commands.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_resource_command.o: src/game/scene_resource_command.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_resource_command.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_resource_command.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_enemy_arrival.o: src/game/scene_enemy_arrival.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_enemy_arrival.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_enemy_arrival.raw.o $@ .text 0xf8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_category_arrivals.o: src/game/scene_category_arrivals.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_category_arrivals.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_category_arrivals.raw.o $@ .text 0x138
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_unused_arrivals.o: src/game/scene_unused_arrivals.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_unused_arrivals.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_unused_arrivals.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_positioned_arrival.o: src/game/scene_positioned_arrival.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_positioned_arrival.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_positioned_arrival.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_mark_dirty.o: src/game/scene_mark_dirty.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_mark_dirty.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_mark_dirty.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_effect_apply.o: src/game/scene_effect_apply.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_effect_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_effect_apply.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_background.o: src/game/scene_background.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_background.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_background.raw.o build/us/scene_background.text.o .text 0x3d8
	$(PYTHON) tools/owned_sections.py $< build/us/scene_background.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/save_menu_slot_write.o: src/game/save_menu_slot_write.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_slot_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_slot_write.raw.o $@ .text 0x114
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_cancel.o: src/game/save_menu_cancel.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_cancel.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_cancel.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_slot_prompt.o: src/game/save_menu_slot_prompt.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_slot_prompt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_slot_prompt.raw.o $@ .text 0xe8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_slot_callback.o: src/game/save_menu_slot_callback.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_slot_callback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_slot_callback.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_open.o: src/game/save_menu_open.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_open.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_open.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_status.o: src/game/save_menu_status.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_status.raw.o build/us/save_menu_status.text.o .text 0x340
	$(PYTHON) tools/owned_sections.py $< build/us/save_menu_status.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/save_menu_audio_index.o: src/game/save_menu_audio_index.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_audio_index.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_audio_index.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_sound_preview.o: src/game/save_menu_sound_preview.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_sound_preview.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_sound_preview.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_audio_apply.o: src/game/save_menu_audio_apply.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_audio_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_audio_apply.raw.o $@ .text 0x44
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_audio_secondary.o: src/game/save_menu_audio_secondary.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_audio_secondary.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_audio_secondary.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_write_return.o: src/game/save_menu_write_return.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
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

build/us/script_service_commands.o: src/game/script_service_commands.c include/destination_format.h include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/command_script.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/resource_strings.h include/save_game.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/script_service_internal.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_service_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/script_service_commands.raw.o $@ .text 0x244
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_service_platform.o: src/game/script_service_platform.c include/command_script.h include/platform_services.h include/script_service_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_service_platform.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/script_service_platform.raw.o $@ .text 0xd0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_animation_resolve.o: src/game/script_animation_resolve.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/platform_services.h include/resource_strings.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/tweak_reset.o: src/game/tweak_reset.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_reset.raw.o $@ .text 0x38
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_page.o: src/game/tweak_page.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_page.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_page.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_define.o: src/game/tweak_define.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_define.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_define.raw.o $@ .text 0xa4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_difficulty_apply.o: src/game/tweak_difficulty_apply.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_difficulty_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_difficulty_apply.raw.o $@ .text 0xe4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_bind.o: src/game/tweak_bind.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_bind.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_bind.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_bind_all.o: src/game/tweak_bind_all.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_bind_all.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_bind_all.raw.o $@ .text 0x808
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_scale_enemy_speeds.o: src/game/tweak_scale_enemy_speeds.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/sound_bridge_core.o: src/game/sound_bridge_core.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_core.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_core.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sound_bridge_definitions.o: src/game/sound_bridge_definitions.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_definitions.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_definitions.raw.o $@ .text 0x5c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sound_bridge_future_reset.o: src/game/sound_bridge_future_reset.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_future_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_future_reset.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sound_bridge_future_queue.o: src/game/sound_bridge_future_queue.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_future_queue.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_future_queue.raw.o build/us/sound_bridge_future_queue.text.o .text 0x90
	$(PYTHON) tools/owned_sections.py $< build/us/sound_bridge_future_queue.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/sound_bridge_future_update.o: src/game/sound_bridge_future_update.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_bridge_future_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_bridge_future_update.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/geometry_debug_bridge.o: src/game/geometry_debug_bridge.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/geometry_debug_bridge.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/geometry_debug_bridge.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/geometry_bridge_apply.o: src/game/geometry_bridge_apply.c include/fixed_geometry.h include/fixed_math.h include/geometry_bridge_internal.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/geometry_bridge_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/geometry_bridge_apply.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/geometry_bridge_rotate.o: src/game/geometry_bridge_rotate.c include/fixed_geometry.h include/fixed_math.h include/geometry_bridge_internal.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/geometry_bridge_rotate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/geometry_bridge_rotate.raw.o $@ .text 0xb4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_vertex_attributes.o: src/game/renderer_vertex_attributes.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_vertex_attributes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_vertex_attributes.raw.o build/us/renderer_vertex_attributes.text.o .text 0x438
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_vertex_attributes.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/renderer_material_texture.o: src/game/renderer_material_texture.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_texture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_texture.raw.o $@ .text 0x118
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_material_light.o: src/game/renderer_material_light.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_light.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_light.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_material_combined.o: src/game/renderer_material_combined.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_combined.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_combined.raw.o $@ .text 0x290
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_light_select.o: src/game/renderer_light_select.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_light_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_light_select.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_material_untextured.o: src/game/renderer_material_untextured.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_untextured.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_untextured.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_material_reset.o: src/game/renderer_material_reset.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_reset.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_vertex_copy.o: src/game/renderer_vertex_copy.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_vertex_copy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_vertex_copy.raw.o $@ .text 0x39c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_texture_load.o: src/game/renderer_texture_load.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_texture_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_texture_load.raw.o $@ .text 0x218
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_display_list.o: src/game/graphics_display_list.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_display_list.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_display_list.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_resource.o: src/game/graphics_resource.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_resource.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_resource.raw.o build/us/graphics_resource.text.o .text 0x70
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_resource.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/graphics_modes.o: src/game/graphics_modes.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_modes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_modes.raw.o $@ .text 0x624
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_lights.o: src/game/graphics_lights.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_lights.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_lights.raw.o $@ .text 0x258
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_pool.o: src/game/graphics_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_pool.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_pool.raw.o build/us/graphics_pool.text.o .text 0x1a4
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_pool.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/graphics_pool_initialize.o: src/game/graphics_pool_initialize.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_pool_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_pool_initialize.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_frame_reset.o: src/game/graphics_frame_reset.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_frame_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_frame_reset.raw.o $@ .text 0x120
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_mode_dispatch.o: src/game/graphics_mode_dispatch.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_mode_dispatch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_mode_dispatch.raw.o build/us/graphics_mode_dispatch.text.o .text 0x21c
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_mode_dispatch.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/graphics_environment.o: src/game/graphics_environment.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_environment.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_environment.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_level_lookup.o: src/game/save_level_lookup.c include/destination_format.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/save_menu_state_reset.o: src/game/save_menu_state_reset.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_state_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_state_reset.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_reset.o: src/game/save_menu_legacy_reset.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_reset.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_heap.o: src/game/save_menu_legacy_heap.c include/destination_format.h include/heap.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_heap.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_heap.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_pages.o: src/game/save_menu_legacy_pages.c include/destination_format.h include/controller_input.h include/controller_legacy.h include/controller_services.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_pages.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_pages.raw.o $@ .text 0x18c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_pak_status.o: src/game/save_menu_legacy_pak_status.c include/destination_format.h include/controller_input.h include/controller_legacy.h include/controller_services.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_pak_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_pak_status.raw.o $@ .text 0x2a8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_exit.o: src/game/save_menu_legacy_exit.c include/destination_format.h include/movie.h include/pak_file.h include/palette.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_exit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_exit.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_legacy_pages_tail.o: src/game/save_menu_legacy_pages_tail.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_legacy_pages_tail.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_legacy_pages_tail.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/graphics_state_helpers.o: src/game/graphics_state_helpers.c include/debug_output.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_image_setup_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_state_helpers.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/graphics_state_helpers.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_platform.o: src/game/renderer_platform.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_platform.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_platform.raw.o $@ .text 0x2d8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_retry.o: src/game/save_menu_pak_retry.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_retry.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_retry.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_reset.o: src/game/save_menu_pak_reset.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_reset.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_refresh.o: src/game/save_menu_pak_refresh.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h $(wildcard include/*.h)
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_refresh.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_refresh.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_result.o: src/game/save_menu_pak_result.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_result.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_result.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_refresh.o: src/game/save_menu_nav_refresh.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_refresh.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_refresh.raw.o $@ .text 0x90
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_open_primary.o: src/game/save_menu_nav_open_primary.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_open_primary.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_open_primary.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_open_secondary.o: src/game/save_menu_nav_open_secondary.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_open_secondary.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_open_secondary.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_open_return.o: src/game/save_menu_nav_open_return.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_open_return.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_open_return.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_noop.o: src/game/save_menu_nav_noop.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_reset.o: src/game/save_menu_nav_reset.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_reset.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_actor_disable.o: src/game/save_menu_nav_actor_disable.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_actor_disable.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_actor_disable.raw.o $@ .text 0x14
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_actor_forward.o: src/game/save_menu_nav_actor_forward.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_actor_forward.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_actor_forward.raw.o $@ .text 0xcc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_actor_back.o: src/game/save_menu_nav_actor_back.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_actor_back.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_actor_back.raw.o $@ .text 0x88
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_preview_create.o: src/game/save_menu_nav_preview_create.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_preview_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_preview_create.raw.o $@ .text 0x154
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_preview_release.o: src/game/save_menu_nav_preview_release.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_nav_preview_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_nav_preview_release.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_nav_cleanup.o: src/game/save_menu_nav_cleanup.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
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

build/us/save_menu_continue_encode.o: src/game/save_menu_continue_encode.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_continue_encode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_continue_encode.raw.o $@ .text 0x170
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_vertex_positions.o: src/game/renderer_vertex_positions.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_vertex_positions.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_vertex_positions.raw.o build/us/renderer_vertex_positions.text.o .text 0x288
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_vertex_positions.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) tools/owned_sections.py config/owned_sections.json tools/trim_padding.py

build/us/renderer_mesh_positions.o: src/game/renderer_mesh_positions.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/palette.h
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

build/us/scene_transition_open.o: src/game/scene_transition_open.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_transition_open.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_transition_open.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_transition_close.o: src/game/scene_transition_close.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_transition_close.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_transition_close.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_transition_draw.o: src/game/scene_transition_draw.c include/destination_format.h include/debug_text_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_transition_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_transition_draw.raw.o $@ .text 0x120
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_player_setup.o: src/game/scene_player_setup.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_definition.h include/scene_player_runtime_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_player_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_player_setup.raw.o $@ .text 0x248
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_signed_shift.o: src/game/scene_signed_shift.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/scene_actor_scale.o: src/game/scene_actor_scale.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_scale.raw.o $@ .text 0x138
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_actor_motion_reset.o: src/game/scene_actor_motion_reset.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_motion_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_motion_reset.raw.o $@ .text 0x108
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_service_noop.o: src/game/scene_service_noop.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_service_noop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_service_noop.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_parent_follow.o: src/game/scene_parent_follow.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_parent_follow.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_parent_follow.raw.o $@ .text 0x178
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_bucket_counter.o: src/game/scene_bucket_counter.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_bucket_counter.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_bucket_counter.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/tweak_scene_apply.o: src/game/tweak_scene_apply.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_scene_apply.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_scene_apply.raw.o $@ .text 0xe8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_timer_capture.o: src/game/scene_timer_capture.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_timer_capture.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_timer_capture.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_timer_initialize.o: src/game/scene_timer_initialize.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_timer_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_timer_initialize.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_timer_service.o: src/game/scene_timer_service.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_timer_service.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_timer_service.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_service.o: src/game/object_service.c include/actor.h include/actor_projectile_internal.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_service.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_service.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_registration.o: src/game/object_registration.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/resource_bridge_model_cache.o: src/game/resource_bridge_model_cache.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_bridge_model_cache.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_bridge_model_cache.raw.o $@ .text 0xd8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_bridge_texture_stub.o: src/game/resource_bridge_texture_stub.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_bridge_texture_stub.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_bridge_texture_stub.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_bridge_bitmap.o: src/game/resource_bridge_bitmap.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_bridge_bitmap.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_bridge_bitmap.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_bridge_animation.o: src/game/resource_bridge_animation.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_bridge_animation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_bridge_animation.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_rotation.o: src/game/model_rotation.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_rotation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_rotation.raw.o $@ .text 0x17c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_polygons_plain.o: src/game/model_polygons_plain.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_polygons_plain.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_polygons_plain.raw.o $@ .text 0x11c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_polygons_color.o: src/game/model_polygons_color.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_polygons_color.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_polygons_color.raw.o $@ .text 0x188
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_hierarchy_vertices.o: src/game/model_hierarchy_vertices.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_hierarchy_vertices.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_hierarchy_vertices.raw.o $@ .text 0x1ac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_camera_identity.o: src/game/model_camera_identity.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_camera_identity.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_camera_identity.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_camera_rotation.o: src/game/model_camera_rotation.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_camera_rotation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_camera_rotation.raw.o $@ .text 0x1a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_mesh_iteration.o: src/game/model_mesh_iteration.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_mesh_iteration.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_mesh_iteration.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_normals_blend.o: src/game/model_normals_blend.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_normals_blend.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_normals_blend.raw.o $@ .text 0x200
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_vertices_scatter.o: src/game/model_vertices_scatter.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_vertices_scatter.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_vertices_scatter.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_framebuffer_copy.o: src/game/model_framebuffer_copy.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_framebuffer_copy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_framebuffer_copy.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_framebuffer_draw.o: src/game/model_framebuffer_draw.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_framebuffer_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_framebuffer_draw.raw.o $@ .text 0x1c4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/model_framebuffer_texture.o: src/game/model_framebuffer_texture.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
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
    build/us/early_actor_tick.o \
    build/us/early_render_color.o \
    build/us/early_render_presets.o \
    build/us/early_render_dispatch.o \
    build/us/early_pool_entry_clear.o \
    build/us/early_pool_count.o \
    build/us/early_pool_index.o \
    build/us/early_byte_clear.o \
    build/us/early_angle_normalize.o \
    build/us/early_actor_vector_clear.o \
    build/us/early_global_reset.o \
    build/us/early_float_step.o \
    build/us/early_selection_state.o \
    build/us/early_callbacks_true.o \
    build/us/early_actor_pair_balance.o \
    build/us/early_actor_create.o \
    build/us/early_actor_state.o \
    build/us/early_actor_mode3.o \
    build/us/early_actor_guarded_service.o \
    build/us/early_actor_mode0.o \
    build/us/early_six_arg_forward.o \
    build/us/early_callback_false.o \
    build/us/early_actor_transition.o \
    build/us/early_pointer_state.o \
    build/us/early_resource_state.o \
    build/us/early_actor_spawn_helper.o \
    build/us/early_simple_forward.o \
    build/us/early_file_state_reset.o \
    build/us/early_name_mask_lookup.o \
    build/us/early_value_lookup.o \
    build/us/early_name_mask_parse.o \
    build/us/frame_timing.o \
    build/us/graphics_ucode.o \
    build/us/frame_transform.o \
    build/us/fixed_math.o \
    build/us/graphics_setup.o \
    build/us/graphics_tasks.o \
    build/us/scheduler_runtime_tail.o \
    build/us/frame_render.o \
    build/us/frame_projection.o \
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
    build/us/object_runtime_active.o

RUNTIME_OBJECTS += \
    build/us/audio_task_build.o

RUNTIME_OBJECTS += \
    build/us/game_string_case_compare.o \
    build/us/game_string_compare.o \
    build/us/game_string_case_compare_n.o \
    build/us/game_string_compare_n.o \
    build/us/game_integer_parse.o \
    build/us/heap_empty.o \
    build/us/runtime_random.o \
    build/us/runtime_float_truncate.o \
    build/us/actor_history_byte_clear.o

RUNTIME_OBJECTS += \
    build/us/object_recovery_path_extension.o \
    build/us/object_recovery_fixed_trig.o \
    build/us/object_recovery_integer_sqrt.o \
    build/us/object_recovery_angle_scale.o \
    build/us/object_recovery_direction_angle.o \
    build/us/object_recovery_angle_table.o \
    build/us/game_debug_format.o

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
    build/us/movie_start.o \
    build/us/movie_update.o \
    build/us/game_hud_state.o

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
    build/us/controller_pak_entry.o \
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
    build/us/renderer_platform.o \
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

build/us/audio_host_files.o: src/game/audio_host_files.c include/audio_io.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/audio_engine_parameters.o: src/game/audio_engine_parameters.c tools/owned_sections.py config/owned_sections.json include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_parameters.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_parameters.raw.o build/us/audio_engine_parameters.text.o .text 0x1f0
	$(PYTHON) tools/owned_sections.py $< build/us/audio_engine_parameters.text.o $@
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

build/us/audio_rate_scale.o: src/game/audio_rate_scale.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/audio_pitch_scale.o: src/game/audio_pitch_scale.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pitch_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_pitch_scale.raw.o build/us/audio_pitch_scale.text.o .text 0x64
	$(PYTHON) tools/owned_sections.py $< build/us/audio_pitch_scale.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_update.o: src/game/audio_backend_update.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_update.raw.o build/us/audio_backend_update.text.o .text 0x150
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_update.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_voice_stop.o: src/game/audio_backend_voice_stop.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
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

build/us/audio_backend_release.o: src/game/audio_backend_release.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_release.raw.o $@ .text 0x18c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_decay.o: src/game/audio_backend_decay.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_decay.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_decay.raw.o build/us/audio_backend_decay.text.o .text 0x174
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_decay.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_allocate.o: src/game/audio_backend_allocate.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
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

build/us/compression_table_release.o: src/game/compression_table_release.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_table_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_table_release.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_fixed.o: src/game/compression_fixed.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_fixed.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_fixed.raw.o $@ .text 0x1f0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_fixed_release.o: src/game/compression_fixed_release.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_fixed_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_fixed_release.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_workspace.o: src/game/compression_workspace.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_workspace.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_workspace.raw.o build/us/compression_workspace.text.o .text 0xc4
	$(PYTHON) tools/owned_sections.py $< build/us/compression_workspace.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_allocate.o: src/game/compression_allocate.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_allocate.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_refill.o: src/game/compression_refill.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_refill.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_refill.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_decode.o: src/game/compression_decode.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_decode.raw.o $@ .text 0x238
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_memory.o: src/game/compression_memory.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_memory.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_memory.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_cartridge.o: src/game/compression_cartridge.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_cartridge.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_cartridge.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_cartridge_bounded.o: src/game/compression_cartridge_bounded.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_cartridge_bounded.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_cartridge_bounded.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/compression_table_release.o \
    build/us/compression_fixed.o \
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

build/us/audio_backend_initialize.o: src/game/audio_backend_initialize.c include/audio_backend_internal.h include/audio_bank_layout_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_initialize.raw.o build/us/audio_backend_initialize.text.o .text 0x2c4
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_initialize.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_backend_initialize.o

build/us/audio_backend_volume.o: src/game/audio_backend_volume.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_volume.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_volume.raw.o build/us/audio_backend_volume.text.o .text 0x234
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_volume.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_pan_pedal.o: src/game/audio_backend_pan_pedal.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
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

build/us/audio_backend_voice_start.o: src/game/audio_backend_voice_start.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
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

build/us/audio_engine_gate.o: src/game/audio_engine_gate.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_gate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_gate.raw.o build/us/audio_engine_gate.text.o .text 0xe0
	$(PYTHON) tools/owned_sections.py $< build/us/audio_engine_gate.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_iteration.o: src/game/audio_engine_iteration.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_iteration.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_engine_iteration.raw.o build/us/audio_engine_iteration.text.o .text 0xec
	$(PYTHON) tools/owned_sections.py $< build/us/audio_engine_iteration.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_interrupt_service.o: src/game/audio_interrupt_service.s tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_interrupt.o: src/sdk/os_interrupt.s tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_probe_tlb.o: src/sdk/os_probe_tlb.s tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_get_count.o: src/sdk/os_get_count.s tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_set_compare.o: src/sdk/os_set_compare.s tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += \
    build/us/audio_engine_gate.o \
    build/us/audio_engine_iteration.o \
    build/us/audio_interrupt_service.o \
    build/us/os_interrupt.o \
    build/us/os_probe_tlb.o \
    build/us/os_get_count.o \
    build/us/os_set_compare.o

build/us/audio_backend_note_release.o: src/game/audio_backend_note_release.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_note_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_note_release.raw.o build/us/audio_backend_note_release.text.o .text 0x108
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_note_release.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_backend_note_release.o

build/us/thread_create.o: src/sdk/thread_create.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/thread_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/thread_create.raw.o $@ .text 0x144
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/thread_start.o: src/sdk/thread_start.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/thread_start.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/thread_start.raw.o $@ .text 0x150
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/message_queue.o: src/sdk/message_queue.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/message_queue.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/message_queue.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/vi_features.o: src/sdk/vi_features.c include/scheduler.h include/sdk_time.h include/sdk_video_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/vi_features.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/vi_features.raw.o $@ .text 0x1b8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/virtual_to_physical.o: src/sdk/virtual_to_physical.c include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/virtual_to_physical.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/virtual_to_physical.raw.o $@ .text 0x7c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compiler_integer64.o: src/sdk/compiler_integer64.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compiler_integer64.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compiler_integer64.raw.o $@ .text 0x2c0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/message_receive.o: src/sdk/message_receive.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/message_receive.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/message_receive.raw.o $@ .text 0x138
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/gu_random.o: src/sdk/gu_random.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/gu_random.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/gu_random.raw.o build/us/gu_random.text.o .text 0x2c
	$(PYTHON) tools/owned_sections.py $< build/us/gu_random.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_read.o: src/sdk/pi_read.c include/pi.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_read.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/message_send.o: src/sdk/message_send.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/message_send.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/message_send.raw.o $@ .text 0x14c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/event_message.o: src/sdk/event_message.c include/scheduler.h include/sdk_events.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/event_message.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/event_message.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/vi_mode.o: src/sdk/vi_mode.c include/scheduler.h include/sdk_time.h include/sdk_video_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/vi_mode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/vi_mode.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/vi_black.o: src/sdk/vi_black.c include/scheduler.h include/sdk_time.h include/sdk_video_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/vi_black.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/vi_black.raw.o $@ .text 0x70
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/vi_event.o: src/sdk/vi_event.c include/scheduler.h include/sdk_time.h include/sdk_video_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/vi_event.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/vi_event.raw.o $@ .text 0x6c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_yield.o: src/sdk/sp_yield.c include/scheduler.h include/scheduler_task.h include/sdk_io.h include/sdk_rsp.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_yield.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_yield.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_yielded.o: src/sdk/sp_yielded.c include/scheduler.h include/scheduler_task.h include/sdk_io.h include/sdk_rsp.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_yielded.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_yielded.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_start.o: src/sdk/sp_start.c include/scheduler.h include/scheduler_task.h include/sdk_io.h include/sdk_rsp.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_start.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_start.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/vi_framebuffer.o: src/sdk/vi_framebuffer.c include/scheduler.h include/sdk_time.h include/sdk_video_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/vi_framebuffer.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/vi_framebuffer.raw.o $@ .text 0xd0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_heap_init.o: src/sdk/audio_heap_init.c include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_heap_init.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_heap_init.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_heap_allocate.o: src/sdk/audio_heap_allocate.c include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_heap_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_heap_allocate.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/si_raw_read.o: src/sdk/si_raw_read.c include/scheduler.h include/sdk_si.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/si_raw_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/si_raw_read.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/si_raw_write.o: src/sdk/si_raw_write.c include/scheduler.h include/sdk_si.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/si_raw_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/si_raw_write.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/thread_dequeue.o: src/sdk/thread_dequeue.c include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/thread_dequeue.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/thread_dequeue.raw.o $@ .text 0x40
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_access.o: src/sdk/pi_access.c include/pi.h include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_access.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_access.raw.o $@ .text 0xc0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/thread_get_priority.o: src/sdk/thread_get_priority.c include/scheduler.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/thread_get_priority.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/thread_get_priority.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_raw_dma.o: src/sdk/pi_raw_dma.c include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_raw_dma.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_raw_dma.raw.o $@ .text 0xe0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/si_access.o: src/sdk/si_access.c include/scheduler.h include/sdk_si.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/si_access.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/si_access.raw.o $@ .text 0xc0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/si_dma.o: src/sdk/si_dma.c include/audio_io.h include/scheduler.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_si.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/si_dma.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/si_dma.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_set_status.o: src/sdk/sp_set_status.c include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_set_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_set_status.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_get_status.o: src/sdk/sp_get_status.c include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_get_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_get_status.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_set_pc.o: src/sdk/sp_set_pc.c include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_set_pc.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_set_pc.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_dma.o: src/sdk/sp_dma.c include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_dma.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_dma.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_busy.o: src/sdk/sp_busy.c include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_busy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_busy.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/ai_busy.o: src/sdk/ai_busy.c include/sdk_io.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/ai_busy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/ai_busy.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/si_busy.o: src/sdk/si_busy.c include/scheduler.h include/sdk_si.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/si_busy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/si_busy.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/thread_create.o \
    build/us/thread_start.o \
    build/us/message_queue.o \
    build/us/vi_features.o \
    build/us/virtual_to_physical.o \
    build/us/compiler_integer64.o \
    build/us/message_receive.o \
    build/us/gu_random.o \
    build/us/pi_read.o \
    build/us/message_send.o \
    build/us/event_message.o \
    build/us/vi_mode.o \
    build/us/vi_black.o \
    build/us/vi_event.o \
    build/us/sp_yield.o \
    build/us/sp_yielded.o \
    build/us/sp_start.o \
    build/us/vi_framebuffer.o \
    build/us/audio_heap_init.o \
    build/us/audio_heap_allocate.o \
    build/us/si_raw_read.o \
    build/us/si_raw_write.o \
    build/us/thread_dequeue.o \
    build/us/pi_access.o \
    build/us/thread_get_priority.o \
    build/us/pi_raw_dma.o \
    build/us/si_access.o \
    build/us/si_dma.o \
    build/us/sp_set_status.o \
    build/us/sp_get_status.o \
    build/us/sp_set_pc.o \
    build/us/sp_dma.o \
    build/us/sp_busy.o \
    build/us/ai_busy.o \
    build/us/si_busy.o

build/us/pi_cartridge_read.o: src/sdk/pi_cartridge_read.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_cartridge_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_cartridge_read.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/thread_set_priority.o: src/sdk/thread_set_priority.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/thread_set_priority.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/thread_set_priority.raw.o $@ .text 0xe0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/system_time.o: src/sdk/system_time.c include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/system_time.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/system_time.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/timer_initialize.o: src/sdk/timer_initialize.c include/scheduler.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/timer_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/timer_initialize.raw.o build/us/timer_initialize.text.o .text 0x8c
	$(PYTHON) tools/owned_sections.py $< build/us/timer_initialize.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/timer_interrupt.o: src/sdk/timer_interrupt.c include/scheduler.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/timer_interrupt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/timer_interrupt.raw.o $@ .text 0x178
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/timer_compare.o: src/sdk/timer_compare.c include/scheduler.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/timer_compare.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/timer_compare.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/timer_insert.o: src/sdk/timer_insert.c include/scheduler.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/timer_insert.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/timer_insert.raw.o $@ .text 0x188
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/pi_cartridge_read.o \
    build/us/thread_set_priority.o \
    build/us/system_time.o \
    build/us/timer_initialize.o \
    build/us/timer_interrupt.o \
    build/us/timer_compare.o \
    build/us/timer_insert.o

build/us/matrix_translate.o: src/sdk/matrix_translate.c include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/matrix_translate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/matrix_translate.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_link_nodes.o: src/sdk/audio_link_nodes.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_link_nodes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_link_nodes.raw.o $@ .text 0x54
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_synth_lifecycle.o: src/sdk/audio_synth_lifecycle.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synth_lifecycle.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_synth_lifecycle.raw.o build/us/audio_synth_lifecycle.text.o .text 0x6c
	$(PYTHON) tools/owned_sections.py $< build/us/audio_synth_lifecycle.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_buffer_submit.o: src/sdk/audio_buffer_submit.c include/audio_io.h include/scheduler.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_buffer_submit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_buffer_submit.raw.o build/us/audio_buffer_submit.text.o .text 0xa8
	$(PYTHON) tools/owned_sections.py $< build/us/audio_buffer_submit.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_remaining_bytes.o: src/sdk/audio_remaining_bytes.c include/audio_io.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_remaining_bytes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_remaining_bytes.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_callback_attach.o: src/sdk/audio_callback_attach.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_callback_attach.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_callback_attach.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/timer_schedule.o: src/sdk/timer_schedule.c include/scheduler.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/timer_schedule.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/timer_schedule.raw.o $@ .text 0xd4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/video_context_get.o: src/sdk/video_context_get.c include/scheduler.h include/sdk_time.h include/sdk_video_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/video_context_get.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/video_context_get.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/message_prepend.o: src/sdk/message_prepend.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/message_prepend.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/message_prepend.raw.o $@ .text 0x150
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_synth_clear.o: src/sdk/audio_synth_clear.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synth_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_synth_clear.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_copy_bytes.o: src/sdk/audio_copy_bytes.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_copy_bytes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_copy_bytes.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/matrix_translate.o \
    build/us/audio_link_nodes.o \
    build/us/audio_synth_lifecycle.o \
    build/us/audio_buffer_submit.o \
    build/us/audio_remaining_bytes.o \
    build/us/audio_callback_attach.o \
    build/us/timer_schedule.o \
    build/us/video_context_get.o \
    build/us/message_prepend.o \
    build/us/audio_synth_clear.o \
    build/us/audio_copy_bytes.o

build/us/matrix_convert.o: src/sdk/matrix_convert.c include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/matrix_convert.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/matrix_convert.raw.o $@ .text 0x26c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/matrix_convert.o

build/us/voice_allocate.o: src/sdk/voice_allocate.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/voice_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/voice_allocate.raw.o $@ .text 0x228
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/voice_start.o: src/sdk/voice_start.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/voice_start.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/voice_start.raw.o $@ .text 0xe4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/voice_pitch.o: src/sdk/voice_pitch.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/voice_pitch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/voice_pitch.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/voice_volume.o: src/sdk/voice_volume.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/voice_volume.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/voice_volume.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/voice_pan.o: src/sdk/voice_pan.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/voice_pan.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/voice_pan.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/voice_stop.o: src/sdk/voice_stop.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/voice_stop.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/voice_stop.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/voice_release.o: src/sdk/voice_release.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/voice_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/voice_release.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/voice_priority.o: src/sdk/voice_priority.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/voice_priority.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/voice_priority.raw.o $@ .text 0x10
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/voice_allocate.o \
    build/us/voice_start.o \
    build/us/voice_pitch.o \
    build/us/voice_volume.o \
    build/us/voice_pan.o \
    build/us/voice_stop.o \
    build/us/voice_release.o \
    build/us/voice_priority.o

build/us/audio_filter_create.o: src/sdk/audio_filter_create.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_filter_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_filter_create.raw.o $@ .text 0x2c0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_filter_base.o: src/sdk/audio_filter_base.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_filter_base.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_filter_base.raw.o $@ .text 0x1c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_filter_create.o \
    build/us/audio_filter_base.o

build/us/audio_synthesizer.o: src/sdk/audio_synthesizer.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synthesizer.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_synthesizer.raw.o build/us/audio_synthesizer.text.o .text 0x6e0
	$(PYTHON) tools/owned_sections.py $< build/us/audio_synthesizer.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_synthesizer.o

build/us/audio_main_bus.o: src/sdk/audio_main_bus.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_main_bus.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_main_bus.raw.o $@ .text 0x150
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_resample.o: src/sdk/audio_resample.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_resample.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_resample.raw.o build/us/audio_resample.text.o .text 0x2f4
	$(PYTHON) tools/owned_sections.py $< build/us/audio_resample.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_auxiliary_bus.o: src/sdk/audio_auxiliary_bus.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_auxiliary_bus.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_auxiliary_bus.raw.o $@ .text 0x108
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_save_filter.o: src/sdk/audio_save_filter.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_save_filter.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_save_filter.raw.o $@ .text 0xc0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_main_bus.o \
    build/us/audio_resample.o \
    build/us/audio_auxiliary_bus.o \
    build/us/audio_save_filter.o

build/us/audio_decoder.o: src/sdk/audio_decoder.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_decoder.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_decoder.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_decoder.raw.o $@ .text 0xb4c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_decoder.o

build/us/audio_envelope.o: src/sdk/audio_envelope.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_envelope.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_envelope.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_envelope.raw.o build/us/audio_envelope.text.o .text 0xc54
	$(PYTHON) tools/owned_sections.py $< build/us/audio_envelope.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_envelope.o

build/us/audio_low_pass.o: src/sdk/audio_low_pass.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_effect.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_low_pass.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_low_pass.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_effect_create.o: src/sdk/audio_effect_create.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_effect.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_effect_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_effect_create.raw.o build/us/audio_effect_create.text.o .text 0x43c
	$(PYTHON) tools/owned_sections.py $< build/us/audio_effect_create.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_effect_allocate.o: src/sdk/audio_effect_allocate.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_effect.h include/sdk_audio_pipeline.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_effect_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_effect_allocate.raw.o $@ .text 0x98
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_low_pass.o \
    build/us/audio_effect_create.o \
    build/us/audio_effect_allocate.o

build/us/audio_effect_modulation.o: src/sdk/audio_effect_modulation.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_decoder.h include/sdk_audio_effect.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_audio_reverb.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_effect_modulation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_effect_modulation.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_effect_buffers.o: src/sdk/audio_effect_buffers.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_decoder.h include/sdk_audio_effect.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_audio_reverb.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_effect_buffers.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_effect_buffers.raw.o $@ .text 0x5f0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_effect_parameters.o: src/sdk/audio_effect_parameters.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_decoder.h include/sdk_audio_effect.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_audio_reverb.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_effect_parameters.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_effect_parameters.raw.o build/us/audio_effect_parameters.text.o .text 0x25c
	$(PYTHON) tools/owned_sections.py $< build/us/audio_effect_parameters.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_effect_source.o: src/sdk/audio_effect_source.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_decoder.h include/sdk_audio_effect.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_audio_reverb.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_effect_source.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_effect_source.raw.o $@ .text 0x18
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_effect_pull.o: src/sdk/audio_effect_pull.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_audio_commands.h include/sdk_audio_decoder.h include/sdk_audio_effect.h include/sdk_audio_mix_commands.h include/sdk_audio_pipeline.h include/sdk_audio_reverb.h include/sdk_device_manager.h include/sdk_io.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_effect_pull.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_effect_pull.raw.o $@ .text 0x340
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_effect_modulation.o \
    build/us/audio_effect_buffers.o \
    build/us/audio_effect_parameters.o \
    build/us/audio_effect_source.o \
    build/us/audio_effect_pull.o

build/us/early_actor_callback_install.o: src/game/early_actor_callback_install.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_callback_install.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_callback_install.raw.o $@ .text 0x90
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_glyph_map.o: src/game/renderer_glyph_map.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_glyph_map.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_glyph_map.raw.o $@ .text 0x1e8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_count.o: src/game/audio_instance_count.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_count.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_count.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_instance_enumerate.o: src/game/audio_instance_enumerate.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_enumerate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_enumerate.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_owner_count.o: src/game/audio_owner_count.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_count.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_count.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_owner_enumerate.o: src/game/audio_owner_enumerate.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_owner_enumerate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_owner_enumerate.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_actor_callback_install.o \
    build/us/renderer_glyph_map.o \
    build/us/audio_instance_count.o \
    build/us/audio_instance_enumerate.o \
    build/us/audio_owner_count.o \
    build/us/audio_owner_enumerate.o

build/us/runtime_angle.o: src/game/runtime_angle.c include/object_recovery.h include/runtime_angle.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/runtime_angle.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/runtime_angle.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/camera_perspective.o: src/sdk/camera_perspective.c include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/camera_perspective.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/camera_perspective.raw.o build/us/camera_perspective.text.o .text 0x288
	$(PYTHON) tools/owned_sections.py $< build/us/camera_perspective.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/camera_highlights.o: src/sdk/camera_highlights.c include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/camera_highlights.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/camera_highlights.raw.o build/us/camera_highlights.text.o .text 0x824
	$(PYTHON) tools/owned_sections.py $< build/us/camera_highlights.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/matrix_rotation.o: src/sdk/matrix_rotation.c include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/matrix_rotation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/matrix_rotation.raw.o build/us/matrix_rotation.text.o .text 0x194
	$(PYTHON) tools/owned_sections.py $< build/us/matrix_rotation.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/runtime_angle.o \
    build/us/camera_perspective.o \
    build/us/camera_highlights.o \
    build/us/matrix_rotation.o

build/us/pfs_is_plug.o: src/sdk/pfs_is_plug.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_is_plug.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_is_plug.raw.o build/us/pfs_is_plug.text.o .text 0x36c
	$(PYTHON) tools/owned_sections.py $< build/us/pfs_is_plug.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_init_pak.o: src/sdk/pfs_init_pak.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_init_pak.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_init_pak.raw.o $@ .text 0x264
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_read.o: src/sdk/controller_read.c include/scheduler.h include/sdk_controller.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_read.raw.o build/us/controller_read.text.o .text 0x258
	$(PYTHON) tools/owned_sections.py $< build/us/controller_read.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_search_file.o: src/sdk/pfs_search_file.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_search_file.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_search_file.raw.o $@ .text 0x1b4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_allocate_file.o: src/sdk/pfs_allocate_file.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_allocate_file.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_allocate_file.raw.o $@ .text 0x7a8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_read_write_file.o: src/sdk/pfs_read_write_file.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_read_write_file.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_read_write_file.raw.o $@ .text 0x4fc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_motor.o: src/sdk/pfs_motor.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_motor.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_motor.raw.o build/us/pfs_motor.text.o .text 0x614
	$(PYTHON) tools/owned_sections.py $< build/us/pfs_motor.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_init.o: src/sdk/controller_init.c include/scheduler.h include/sdk_controller.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_init.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_init.raw.o build/us/controller_init.text.o .text 0x3bc
	$(PYTHON) tools/owned_sections.py $< build/us/controller_init.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_free_blocks.o: src/sdk/pfs_free_blocks.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_free_blocks.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_free_blocks.raw.o $@ .text 0x14c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_num_files.o: src/sdk/pfs_num_files.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_num_files.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_num_files.raw.o $@ .text 0x144
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_delete_file.o: src/sdk/pfs_delete_file.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_delete_file.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_delete_file.raw.o $@ .text 0x608
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_file_state.o: src/sdk/pfs_file_state.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_file_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_file_state.raw.o $@ .text 0x2f0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_contpfs.o: src/sdk/pfs_contpfs.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_contpfs.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_contpfs.raw.o $@ .text 0xd58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_cont_ram_read.o: src/sdk/pfs_cont_ram_read.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_cont_ram_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_cont_ram_read.raw.o $@ .text 0x384
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_get_status.o: src/sdk/pfs_get_status.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_get_status.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_get_status.raw.o $@ .text 0x10c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_checker.o: src/sdk/pfs_checker.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_checker.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_checker.raw.o $@ .text 0xa60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_cont_ram_write.o: src/sdk/pfs_cont_ram_write.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_cont_ram_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_cont_ram_write.raw.o $@ .text 0x380
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_crc.o: src/sdk/controller_crc.c include/scheduler.h include/sdk_si.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_crc.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_crc.raw.o $@ .text 0x180
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/pfs_is_plug.o \
    build/us/pfs_init_pak.o \
    build/us/controller_read.o \
    build/us/pfs_search_file.o \
    build/us/pfs_allocate_file.o \
    build/us/pfs_read_write_file.o \
    build/us/pfs_motor.o \
    build/us/controller_init.o \
    build/us/pfs_free_blocks.o \
    build/us/pfs_num_files.o \
    build/us/pfs_delete_file.o \
    build/us/pfs_file_state.o \
    build/us/pfs_contpfs.o \
    build/us/pfs_cont_ram_read.o \
    build/us/pfs_get_status.o \
    build/us/pfs_checker.o \
    build/us/pfs_cont_ram_write.o \
    build/us/controller_crc.o

build/us/runtime_sign.o: src/game/runtime_sign.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/runtime_sign.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/runtime_sign.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/runtime_sine.o: src/game/runtime_sine.c include/sdk_float_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/runtime_sine.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/runtime_sine.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_interval_set.o: src/game/frame_interval_set.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_interval_set.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_interval_set.raw.o $@ .text 0x24
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_flag_set.o: src/game/renderer_flag_set.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_flag_set.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_flag_set.raw.o $@ .text 0xc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_unused_command.o: src/game/audio_unused_command.c include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_unused_command.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_unused_command.raw.o $@ .text 0x8
	$(PYTHON) tools/provenance.py $< $@ include/audio_properties_internal.h $(filter include/%,$^)

build/us/early_pool_initialize.o: src/game/early_pool_initialize.c include/early_pool_tick.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_pool_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_pool_initialize.raw.o $@ .text 0x5c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_coordinate_rescale.o: src/game/early_coordinate_rescale.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_coordinate_rescale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_coordinate_rescale.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_index_code.o: src/game/scene_index_code.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_index_code.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_index_code.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_digit_extract.o: src/game/renderer_digit_extract.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_digit_extract.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_digit_extract.raw.o $@ .text 0x60
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_selection_activate.o: src/game/early_selection_activate.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_selection_activate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_selection_activate.raw.o $@ .text 0x20
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/frame_slot_allocate.o: src/game/frame_slot_allocate.c include/frame_slot.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/frame_slot_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/frame_slot_allocate.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_handle_tests.o: src/game/audio_handle_tests.c include/audio_control.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_handle_tests.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_handle_tests.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_player_counter_reset.o: src/game/early_player_counter_reset.c include/destination_format.h include/early_input_internal.h include/save_game.h include/pak_file.h include/scene_definition.h include/controller_input.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_player_counter_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_player_counter_reset.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_stored.o: src/game/compression_stored.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_stored.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_stored.raw.o $@ .text 0x2d8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/video_vertical_scale.o: src/sdk/video_vertical_scale.c include/scheduler.h include/sdk_time.h include/sdk_video_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/video_vertical_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/video_vertical_scale.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/thread_yield.o: src/sdk/thread_yield.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/thread_yield.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/thread_yield.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/interrupt_mask_set.o: src/sdk/interrupt_mask_set.c include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/interrupt_mask_set.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/interrupt_mask_set.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/interrupt_mask_reset.o: src/sdk/interrupt_mask_reset.c include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/interrupt_mask_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/interrupt_mask_reset.raw.o $@ .text 0x58
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_extended_write.o: src/sdk/pi_extended_write.c include/sdk_pi_word.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_extended_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_extended_write.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_extended_read.o: src/sdk/pi_extended_read.c include/sdk_pi_word.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_extended_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_extended_read.raw.o $@ .text 0x50
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/os_status.o: src/sdk/os_status.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_fpcsr.o: src/sdk/os_fpcsr.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_invalidate_cache_all.o: src/sdk/os_invalidate_cache_all.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_map_debug_tlb.o: src/sdk/os_map_debug_tlb.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/square_root.o: src/sdk/square_root.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += \
    build/us/runtime_sign.o \
    build/us/runtime_sine.o \
    build/us/frame_interval_set.o \
    build/us/renderer_flag_set.o \
    build/us/audio_unused_command.o \
    build/us/early_pool_initialize.o \
    build/us/early_coordinate_rescale.o \
    build/us/scene_index_code.o \
    build/us/renderer_digit_extract.o \
    build/us/early_selection_activate.o \
    build/us/frame_slot_allocate.o \
    build/us/audio_handle_tests.o \
    build/us/early_player_counter_reset.o \
    build/us/compression_stored.o \
    build/us/video_vertical_scale.o \
    build/us/thread_yield.o \
    build/us/interrupt_mask_set.o \
    build/us/interrupt_mask_reset.o \
    build/us/pi_extended_write.o \
    build/us/pi_extended_read.o \
    build/us/os_status.o \
    build/us/os_fpcsr.o \
    build/us/os_invalidate_cache_all.o \
    build/us/os_map_debug_tlb.o \
    build/us/square_root.o

build/us/pi_queue_get.o: src/sdk/pi_queue_get.c include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_queue_get.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_queue_get.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/pi_queue_get.o

build/us/player_fields_clear.o: src/game/player_fields_clear.c include/destination_format.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/player_fields_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/player_fields_clear.raw.o $@ .text 0x28
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/runtime_buffer_clear.o: src/game/runtime_buffer_clear.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/runtime_buffer_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/runtime_buffer_clear.raw.o $@ .text 0x2c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/render_buffer_allocate.o: src/game/render_buffer_allocate.c include/heap.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/resource_arena.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/render_buffer_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/render_buffer_allocate.raw.o $@ .text 0x48
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_arrival_reactivate.o: src/game/scene_arrival_reactivate.c include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_arrival_reactivate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_arrival_reactivate.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/short_sine.o: src/sdk/short_sine.c include/sdk_short_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py tools/generate_short_sine_table.py
	mkdir -p $(@D)
	$(PYTHON) tools/generate_short_sine_table.py --check
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/short_sine.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/short_sine.raw.o build/us/short_sine.text.o .text 0x70
	$(PYTHON) tools/owned_sections.py $< build/us/short_sine.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/short_cosine.o: src/sdk/short_cosine.c include/sdk_short_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/short_cosine.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/short_cosine.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/ai_frequency.o: src/sdk/ai_frequency.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/ai_frequency.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/ai_frequency.raw.o $@ .text 0x160
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/thread_destroy.o: src/sdk/thread_destroy.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/thread_destroy.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/thread_destroy.raw.o $@ .text 0xf8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_start_dma.o: src/sdk/pi_start_dma.c include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_start_dma.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_start_dma.raw.o $@ .text 0x10c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/player_fields_clear.o \
    build/us/runtime_buffer_clear.o \
    build/us/render_buffer_allocate.o \
    build/us/scene_arrival_reactivate.o \
    build/us/short_sine.o \
    build/us/short_cosine.o \
    build/us/ai_frequency.o \
    build/us/thread_destroy.o \
    build/us/pi_start_dma.o

build/us/pi_event_notify.o: src/sdk/pi_event_notify.c include/scheduler.h include/sdk_events.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_event_notify.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_event_notify.raw.o $@ .text 0xec
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/pi_event_notify.o

build/us/pi_extended_dma.o: src/sdk/pi_extended_dma.c include/sdk_pi_word.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_extended_dma.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_extended_dma.raw.o $@ .text 0x224
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sine_float.o: src/sdk/sine_float.c include/sdk_float_values.h $(IDO) Makefile tools/trim_padding.py tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sine_float.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sine_float.raw.o build/us/sine_float.text.o .text 0x1c0
	$(PYTHON) tools/owned_sections.py $< build/us/sine_float.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/cosine_float.o: src/sdk/cosine_float.c include/sdk_float_values.h $(IDO) Makefile tools/trim_padding.py tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/cosine_float.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/cosine_float.raw.o build/us/cosine_float.text.o .text 0x168
	$(PYTHON) tools/owned_sections.py $< build/us/cosine_float.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_voice_sequence_bind.o: src/game/audio_voice_sequence_bind.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_sequence_bind.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_sequence_bind.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/render_buffer_reserve.o: src/game/render_buffer_reserve.c include/debug_output.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/resource_arena.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/render_buffer_reserve.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/render_buffer_reserve.raw.o build/us/render_buffer_reserve.text.o .text 0x74
	$(PYTHON) tools/owned_sections.py $< build/us/render_buffer_reserve.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/os_writeback_cache.o: src/sdk/os_writeback_cache.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_invalidate_instruction_cache.o: src/sdk/os_invalidate_instruction_cache.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_invalidate_data_cache.o: src/sdk/os_invalidate_data_cache.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_block_clear.o: src/sdk/os_block_clear.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

build/us/os_interrupt_mask.o: src/sdk/os_interrupt_mask.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += \
    build/us/pi_extended_dma.o \
    build/us/sine_float.o \
    build/us/cosine_float.o \
    build/us/audio_voice_sequence_bind.o \
    build/us/render_buffer_reserve.o \
    build/us/os_writeback_cache.o \
    build/us/os_invalidate_instruction_cache.o \
    build/us/os_invalidate_data_cache.o \
    build/us/os_block_clear.o \
    build/us/os_interrupt_mask.o

build/us/sp_task_physical.o: src/sdk/sp_task_physical.c include/scheduler.h include/scheduler_task.h include/sdk_io.h include/sdk_sp_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_task_physical.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_task_physical.raw.o $@ .text 0x11c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/sp_task_load.o: src/sdk/sp_task_load.c include/scheduler.h include/scheduler_task.h include/sdk_io.h include/sdk_sp_task.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sp_task_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sp_task_load.raw.o $@ .text 0x190
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_disk_recover.o: src/sdk/pi_disk_recover.c include/sdk_pi_disk.h include/sdk_pi_word.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_disk_recover.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_disk_recover.raw.o $@ .text 0xe8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_forward_and_guard.o: src/game/early_actor_forward_and_guard.c include/actor_damage_internal.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h include/actor_collision_separation_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_forward_and_guard.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_forward_and_guard.raw.o $@ .text 0x78
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/sp_task_physical.o \
    build/us/sp_task_load.o \
    build/us/pi_disk_recover.o \
    build/us/early_actor_forward_and_guard.o

build/us/os_block_copy.o: src/sdk/os_block_copy.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += \
    build/us/os_block_copy.o

build/us/video_manager.o: src/sdk/video_manager.c include/scheduler.h include/sdk_device_manager.h include/sdk_pi_word.h include/sdk_time.h include/sdk_timers.h include/sdk_video_internal.h include/sdk_video_manager.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/video_manager.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/video_manager.raw.o build/us/video_manager.text.o .text 0x354
	$(PYTHON) tools/owned_sections.py $< build/us/video_manager.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/video_initialize.o: src/sdk/video_initialize.c include/scheduler.h include/sdk_device_manager.h include/sdk_pi_word.h include/sdk_time.h include/sdk_video_internal.h include/sdk_video_manager.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/video_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/video_initialize.raw.o build/us/video_initialize.text.o .text 0x13c
	$(PYTHON) tools/owned_sections.py $< build/us/video_initialize.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_cartridge_initialize.o: src/sdk/pi_cartridge_initialize.c include/sdk_pi_device.h include/sdk_pi_transfer.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_cartridge_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_cartridge_initialize.raw.o build/us/pi_cartridge_initialize.text.o .text 0xec
	$(PYTHON) tools/owned_sections.py $< build/us/pi_cartridge_initialize.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_disk_initialize.o: src/sdk/pi_disk_initialize.c include/sdk_pi_device.h include/sdk_pi_disk.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_disk_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_disk_initialize.raw.o build/us/pi_disk_initialize.text.o .text 0xf8
	$(PYTHON) tools/owned_sections.py $< build/us/pi_disk_initialize.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/video_manager.o \
    build/us/video_initialize.o \
    build/us/pi_cartridge_initialize.o \
    build/us/pi_disk_initialize.o

build/us/video_context_swap.o: src/sdk/video_context_swap.c include/scheduler.h include/sdk_io.h include/sdk_time.h include/sdk_video_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/video_context_swap.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/video_context_swap.raw.o $@ .text 0x35c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/video_context_swap.o

build/us/video_modes.o: src/sdk/video_modes.c include/scheduler.h tools/generate_video_modes.py $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/generate_video_modes.py --check
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/video_modes.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/video_modes.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/video_default_modes.o: src/sdk/video_default_modes.c include/scheduler.h tools/generate_video_modes.py $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/generate_video_modes.py --check
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/video_default_modes.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/video_default_modes.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/video_modes.o build/us/video_default_modes.o

build/us/pi_manager_create.o: src/sdk/pi_manager_create.c include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_manager_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_manager_create.raw.o build/us/pi_manager_create.text.o .text 0x188
	$(PYTHON) tools/owned_sections.py $< build/us/pi_manager_create.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pi_device_manager.o: src/sdk/pi_device_manager.c include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_device_manager.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_device_manager.raw.o build/us/pi_device_manager.text.o .text 0x490
	$(PYTHON) tools/owned_sections.py $< build/us/pi_device_manager.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/pi_manager_create.o \
    build/us/pi_device_manager.o

build/us/pi_disk_interrupt.o: src/sdk/pi_disk_interrupt.c include/sdk_pi_device.h include/sdk_pi_disk.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pi_disk_interrupt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pi_disk_interrupt.raw.o $@ .text 0x6a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/pi_disk_interrupt.o

build/us/initialize.o: src/sdk/initialize.c include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/initialize.raw.o build/us/initialize.text.o .text 0x28c
	$(PYTHON) tools/owned_sections.py $< build/us/initialize.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/pfs_repair_id.o: src/sdk/pfs_repair_id.c include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pfs_repair_id.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pfs_repair_id.raw.o $@ .text 0x25c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/initialize.o \
    build/us/pfs_repair_id.o

build/us/exception_context.o: src/sdk/exception_context.s Makefile tools/provenance.py
	mkdir -p $(@D)
	$(CROSS)as -EB -32 -march=vr4300 -o $@ $<
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += build/us/exception_context.o

build/us/cpu_interrupt_tables.o: src/sdk/cpu_interrupt_tables.c tools/generate_interrupt_tables.py $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/generate_interrupt_tables.py --check
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/cpu_interrupt_tables.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/cpu_interrupt_tables.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/exception_state.o: src/sdk/exception_state.c include/scheduler.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/exception_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/exception_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/rcp_interrupt_masks.o: src/sdk/rcp_interrupt_masks.c tools/generate_interrupt_tables.py $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/generate_interrupt_tables.py --check
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/rcp_interrupt_masks.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/rcp_interrupt_masks.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/thread_state.o: src/sdk/thread_state.c include/scheduler.h include/sdk_thread_internal.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/thread_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/thread_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/cpu_interrupt_tables.o build/us/exception_state.o build/us/rcp_interrupt_masks.o build/us/thread_state.o

build/us/early_actor_counter_decrement.o: src/game/early_actor_counter_decrement.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_counter_decrement.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_counter_decrement.raw.o $@ .text 0x30
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_animation_callback.o: src/game/early_animation_callback.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_animation_callback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_animation_callback.raw.o $@ .text 0xfc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_session_animation.o: src/game/early_session_animation.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_session_animation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_session_animation.raw.o $@ .text 0x68
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_reset_parameter.o: src/game/early_reset_parameter.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_reset_parameter.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_reset_parameter.raw.o build/us/early_reset_parameter.text.o .text 0x3c
	$(PYTHON) tools/owned_sections.py $< build/us/early_reset_parameter.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_actor_counter_decrement.o \
    build/us/early_animation_callback.o \
    build/us/early_session_animation.o \
    build/us/early_reset_parameter.o

build/us/early_animation_restart.o: src/game/early_animation_restart.c include/actor.h include/actor_behavior_internal.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_animation_restart.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_animation_restart.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_transition_arrays_clear.o: src/game/early_transition_arrays_clear.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/early_game_more.h include/early_game_state.h include/early_parameter_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_transition_arrays_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_transition_arrays_clear.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_animation_restart.o \
    build/us/early_transition_arrays_clear.o

build/us/actor_repeat_expire.o: src/game/actor_repeat_expire.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_repeat_expire.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_repeat_expire.raw.o $@ .text 0xc8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_repeat_delay.o: src/game/actor_repeat_delay.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_repeat_delay.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_repeat_delay.raw.o $@ .text 0xac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_scene_counter_expire.o: src/game/actor_scene_counter_expire.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_scene_counter_expire.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_scene_counter_expire.raw.o $@ .text 0xc4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_animation_auxiliary.o: src/game/actor_animation_auxiliary.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_animation_auxiliary.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_animation_auxiliary.raw.o $@ .text 0x7c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_child_animation.o: src/game/actor_child_animation.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_child_animation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_child_animation.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_repeat_expire.o \
    build/us/actor_repeat_delay.o \
    build/us/actor_scene_counter_expire.o \
    build/us/actor_animation_auxiliary.o \
    build/us/actor_child_animation.o

build/us/early_render_handler_select.o: src/game/early_render_handler_select.c include/early_game_helpers.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_handler_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_render_handler_select.raw.o build/us/early_render_handler_select.text.o .text 0x84
	$(PYTHON) tools/owned_sections.py $< build/us/early_render_handler_select.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_collision_kind_dispatch.o: src/game/actor_collision_kind_dispatch.c include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_kind_dispatch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_kind_dispatch.raw.o build/us/actor_collision_kind_dispatch.text.o .text 0x84
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_kind_dispatch.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/name_table_lookup.o: src/game/name_table_lookup.c include/game_memory.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/name_table_lookup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/name_table_lookup.raw.o build/us/name_table_lookup.text.o .text 0xa0
	$(PYTHON) tools/owned_sections.py $< build/us/name_table_lookup.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_mode_advance.o: src/game/session_mode_advance.c include/destination_format.h include/actor.h include/audio_game.h include/frame.h include/game_memory.h include/object.h include/pak_file.h include/platform_services.h include/save_game.h include/scene_audio.h include/scene_definition.h include/session_menu_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/control_setup_internal.h include/menu_display_internal.h include/object_helpers.h include/save_menu_nav_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_mode_advance.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_mode_advance.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/resource_selection_clear.o: src/game/resource_selection_clear.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/resource_selection_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/resource_selection_clear.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_render_handler_select.o \
    build/us/actor_collision_kind_dispatch.o \
    build/us/name_table_lookup.o \
    build/us/session_mode_advance.o \
    build/us/resource_selection_clear.o

build/us/menu_transition_start.o: src/game/menu_transition_start.c include/destination_format.h include/actor.h include/game_memory.h include/object.h include/object_helpers.h include/pak_file.h include/palette.h include/palette_effects.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_transition_start.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/menu_transition_start.raw.o build/us/menu_transition_start.text.o .text 0x94
	$(PYTHON) tools/owned_sections.py $< build/us/menu_transition_start.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_texture_file_cache.o: src/game/renderer_texture_file_cache.c include/controller_input.h include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_texture_cache.h include/rom_files.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_texture_file_cache.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_texture_file_cache.raw.o build/us/renderer_texture_file_cache.text.o .text 0x90
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_texture_file_cache.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/menu_transition_start.o \
    build/us/renderer_texture_file_cache.o

build/us/renderer_number_forward.o: src/game/renderer_number_forward.c include/renderer_debug_text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_number_forward.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_number_forward.raw.o $@ .text 0x9c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_number_reverse.o: src/game/renderer_number_reverse.c include/renderer_debug_text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_number_reverse.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_number_reverse.raw.o $@ .text 0x98
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_position_pair_add.o: src/game/actor_position_pair_add.c include/actor.h include/actor_behavior_internal.h include/actor_position_pairs.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_position_pair_add.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_position_pair_add.raw.o build/us/actor_position_pair_add.text.o .text 0xa8
	$(PYTHON) tools/owned_sections.py $< build/us/actor_position_pair_add.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/menu_label_assign.o: src/game/menu_label_assign.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_label_assign.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/menu_label_assign.raw.o $@ .text 0xc8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/random_between.o: src/game/random_between.c $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/random_between.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/random_between.raw.o $@ .text 0xc4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/session_input_initialize.o: src/game/session_input_initialize.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_medium.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/platform_services.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_input_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_input_initialize.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_value_transition.o: src/game/actor_value_transition.c include/destination_format.h include/actor_damage_internal.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_value_transition.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_value_transition.raw.o $@ .text 0xb4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_random_spawn.o: src/game/actor_random_spawn.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_random_spawn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_random_spawn.raw.o build/us/actor_random_spawn.text.o .text 0xc0
	$(PYTHON) tools/owned_sections.py $< build/us/actor_random_spawn.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/renderer_number_forward.o \
    build/us/renderer_number_reverse.o \
    build/us/actor_position_pair_add.o \
    build/us/menu_label_assign.o \
    build/us/random_between.o \
    build/us/session_input_initialize.o \
    build/us/actor_value_transition.o \
    build/us/actor_random_spawn.o

build/us/actor_relative_geometry.o: src/game/actor_relative_geometry.c include/actor.h include/actor_behavior_internal.h include/early_game_helpers.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_relative_geometry.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_relative_geometry.raw.o $@ .text 0xa8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_quad_submit.o: src/game/renderer_quad_submit.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_quad_submit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_quad_submit.raw.o $@ .text 0xf0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_texture_defaults.o: src/game/renderer_texture_defaults.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_texture_defaults.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_texture_defaults.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_metrics_update.o: src/game/renderer_metrics_update.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_metrics_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_metrics_update.raw.o $@ .text 0xe4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_dynamic_group_allocate.o: src/game/actor_dynamic_group_allocate.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/debug_output.h include/game_memory.h include/heap.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_dynamic_group_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_dynamic_group_allocate.raw.o $@ .text 0xb0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_dynamic_pair_append.o: src/game/actor_dynamic_pair_append.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/debug_output.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_dynamic_pair_append.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_dynamic_pair_append.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_dynamic_parameter_append.o: src/game/actor_dynamic_parameter_append.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/debug_output.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_dynamic_parameter_append.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_dynamic_parameter_append.raw.o $@ .text 0xb8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_texture_index_draw.o: src/game/renderer_texture_index_draw.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_texture_index.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_texture_index_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_texture_index_draw.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_behavior_counter_expire.o: src/game/actor_behavior_counter_expire.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_counter_expire.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_counter_expire.raw.o build/us/actor_behavior_counter_expire.text.o .text 0xb8
	$(PYTHON) tools/owned_sections.py $< build/us/actor_behavior_counter_expire.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_relative_geometry.o \
    build/us/renderer_quad_submit.o \
    build/us/renderer_texture_defaults.o \
    build/us/renderer_metrics_update.o \
    build/us/actor_dynamic_group_allocate.o \
    build/us/actor_dynamic_pair_append.o \
    build/us/actor_dynamic_parameter_append.o \
    build/us/renderer_texture_index_draw.o \
    build/us/actor_behavior_counter_expire.o

build/us/session_background_select.o: src/game/session_background_select.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_texture_cache.h include/rom_files.h include/scene_background_internal.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_background_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_background_select.raw.o build/us/session_background_select.text.o .text 0xfc
	$(PYTHON) tools/owned_sections.py $< build/us/session_background_select.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_definition_byteorder.o: src/game/scene_definition_byteorder.c include/rom_files.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_definition_byteorder.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_definition_byteorder.raw.o $@ .text 0xdc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_effect_spawn.o: src/game/early_effect_spawn.c include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_definition.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_effect_spawn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_effect_spawn.raw.o build/us/early_effect_spawn.text.o .text 0xe4
	$(PYTHON) tools/owned_sections.py $< build/us/early_effect_spawn.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_bonus_spawn.o: src/game/scene_bonus_spawn.c include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_bonus_spawn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_bonus_spawn.raw.o $@ .text 0xf4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_collision_distance.o: src/game/early_collision_distance.c include/actor.h include/actor_behavior_internal.h include/command_script.h include/early_collision_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/script_service_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_collision_distance.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_collision_distance.raw.o $@ .text 0xe0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_pool_tick.o: src/game/early_pool_tick.c include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/early_pool_tick.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_pool_tick.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_pool_tick.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_collision_turn.o: src/game/actor_collision_turn.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_turn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_turn.raw.o $@ .text 0x118
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/session_background_select.o \
    build/us/scene_definition_byteorder.o \
    build/us/early_effect_spawn.o \
    build/us/scene_bonus_spawn.o \
    build/us/early_collision_distance.o \
    build/us/early_pool_tick.o \
    build/us/actor_collision_turn.o

build/us/early_parameter_schedule.o: src/game/early_parameter_schedule.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/early_game_more.h include/early_game_state.h include/early_parameter_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_parameter_schedule.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_parameter_schedule.raw.o $@ .text 0x13c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_parameter_complete.o: src/game/early_parameter_complete.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/early_game_more.h include/early_game_state.h include/early_parameter_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_parameter_complete.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_parameter_complete.raw.o $@ .text 0x130
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_menu_pak_page_select.o: src/game/save_menu_pak_page_select.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_page_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_page_select.raw.o $@ .text 0xfc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_tile_origin_mode.o: src/game/renderer_tile_origin_mode.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_tile_origin_mode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_tile_origin_mode.raw.o $@ .text 0xcc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/fixed_matrix_rsp.o: src/game/fixed_matrix_rsp.c include/fixed_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/fixed_matrix_rsp.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/fixed_matrix_rsp.raw.o $@ .text 0x144
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/object_history_write.o: src/game/object_history_write.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_history_internal.h include/object_recovery.h include/scalar_math.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_history_write.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_history_write.raw.o build/us/object_history_write.text.o .text 0x148
	$(PYTHON) tools/owned_sections.py $< build/us/object_history_write.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_parameter_schedule.o \
    build/us/early_parameter_complete.o \
    build/us/save_menu_pak_page_select.o \
    build/us/renderer_tile_origin_mode.o \
    build/us/fixed_matrix_rsp.o \
    build/us/object_history_write.o

build/us/actor_dynamic_first_append.o: src/game/actor_dynamic_first_append.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_dynamic_first_append.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_dynamic_first_append.raw.o $@ .text 0x98
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_actor_scale_decay.o: src/game/early_actor_scale_decay.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_more.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_scale_decay.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_scale_decay.raw.o $@ .text 0x128
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_cache_flags_clear.o: src/game/renderer_cache_flags_clear.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_runtime.h include/renderer_peak_metrics.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/resource_arena.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_cache_flags_clear.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_cache_flags_clear.raw.o $@ .text 0x74
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_dynamic_first_append.o \
    build/us/early_actor_scale_decay.o \
    build/us/renderer_cache_flags_clear.o

build/us/audio_callback_add.o: src/game/audio_callback_add.c include/audio_properties_internal.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_callback_add.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_callback_add.raw.o build/us/audio_callback_add.text.o .text 0x100
	$(PYTHON) tools/owned_sections.py $< build/us/audio_callback_add.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_callback_remove.o: src/game/audio_callback_remove.c include/audio_properties_internal.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_callback_remove.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_callback_remove.raw.o build/us/audio_callback_remove.text.o .text 0x130
	$(PYTHON) tools/owned_sections.py $< build/us/audio_callback_remove.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_voice_release.o: src/game/audio_backend_voice_release.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_voice_release.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_voice_release.raw.o build/us/audio_backend_voice_release.text.o .text 0x114
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_voice_release.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_collision_health_result.o: src/game/actor_collision_health_result.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_health_result.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_health_result.raw.o $@ .text 0x144
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_callback_add.o \
    build/us/audio_callback_remove.o \
    build/us/audio_backend_voice_release.o \
    build/us/actor_collision_health_result.o

build/us/audio_backend_pan_command.o: src/game/audio_backend_pan_command.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_pan_command.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_pan_command.raw.o build/us/audio_backend_pan_command.text.o .text 0x154
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_pan_command.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_backend_patch_trigger.o: src/game/audio_backend_patch_trigger.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_patch_trigger.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_patch_trigger.raw.o build/us/audio_backend_patch_trigger.text.o .text 0x180
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_patch_trigger.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_dynamic_point_append.o: src/game/actor_dynamic_point_append.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/debug_output.h include/game_memory.h include/object.h include/object_recovery.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_dynamic_point_append.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_dynamic_point_append.raw.o $@ .text 0x16c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_backend_pan_command.o \
    build/us/audio_backend_patch_trigger.o \
    build/us/actor_dynamic_point_append.o

build/us/save_menu_pak_name_select.o: src/game/save_menu_pak_name_select.c include/controller_pak_menu_internal.h include/destination_format.h include/controller_input.h include/controller_services.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h $(wildcard include/*.h)
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_pak_name_select.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_pak_name_select.raw.o $@ .text 0x90
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_signature_gate.o: src/game/early_signature_gate.c include/destination_format.h include/game_memory.h include/pak_file.h include/save_game.h include/scene_definition.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_action_internal.h include/scene_player_runtime_internal.h include/text.h include/front_menu_internal.h include/menu_label_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_signature_gate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_signature_gate.raw.o build/us/early_signature_gate.text.o .text 0x94
	$(PYTHON) tools/owned_sections.py $< build/us/early_signature_gate.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_resource_arguments.o: src/game/early_resource_arguments.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_resource_arguments.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_resource_arguments.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/save_menu_pak_name_select.o \
    build/us/early_signature_gate.o \
    build/us/early_resource_arguments.o

build/us/audio_dma_read.o: src/game/audio_dma_read.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_dma_read.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_dma_read.raw.o build/us/audio_dma_read.text.o .text 0x1d4
	$(PYTHON) tools/owned_sections.py $< build/us/audio_dma_read.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_dma_recycle.o: src/game/audio_dma_recycle.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_dma_recycle.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_dma_recycle.raw.o build/us/audio_dma_recycle.text.o .text 0x150
	$(PYTHON) tools/owned_sections.py $< build/us/audio_dma_recycle.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_dma_read.o \
    build/us/audio_dma_recycle.o

build/us/actor_collision_animation.o: src/game/actor_collision_animation.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h include/actor_collision_separation_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_animation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_animation.raw.o $@ .text 0xa0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_collision_score_result.o: src/game/actor_collision_score_result.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_score_result.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_score_result.raw.o $@ .text 0x14c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_collision_animation.o \
    build/us/actor_collision_score_result.o

build/us/geometry_axis_scale.o: src/game/geometry_axis_scale.c include/fixed_geometry.h include/fixed_math.h include/geometry_bridge_internal.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/geometry_axis_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/geometry_axis_scale.raw.o $@ .text 0x1fc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/geometry_uniform_scale.o: src/game/geometry_uniform_scale.c include/fixed_geometry.h include/fixed_math.h include/geometry_bridge_internal.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/geometry_uniform_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/geometry_uniform_scale.raw.o $@ .text 0x1b0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/geometry_axis_scale.o \
    build/us/geometry_uniform_scale.o

build/us/actor_collision_death_result.o: src/game/actor_collision_death_result.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/sound_bridge_internal.h include/text.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_death_result.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_death_result.raw.o build/us/actor_collision_death_result.text.o .text 0x174
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_death_result.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_collision_death_result.o

build/us/session_selection_lookup.o: src/game/session_selection_lookup.c include/destination_format.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_selection_lookup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_selection_lookup.raw.o $@ .text 0x8c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/session_selection_lookup.o

build/us/early_angle_step.o: src/game/early_angle_step.c include/early_game_helpers.h include/scalar_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_angle_step.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_angle_step.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_angle_step.o

build/us/scene_actor_mode_list.o: src/game/scene_actor_mode_list.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_mode_list.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_mode_list.raw.o $@ .text 0x174
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_child_random_motion.o: src/game/actor_child_random_motion.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/frame_slot.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/platform_services.h include/save_game.h include/scalar_math.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_child_random_motion.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_child_random_motion.raw.o $@ .text 0x17c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_collision_separate.o: src/game/actor_collision_separate.c include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/actor_motion_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_separate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_separate.raw.o $@ .text 0x154
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/scene_actor_mode_list.o \
    build/us/actor_child_random_motion.o \
    build/us/actor_collision_separate.o

build/us/actor_nearest_match.o: src/game/actor_nearest_match.c include/actor.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_nearest_match.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_nearest_match.raw.o $@ .text 0x148
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_random_fan.o: src/game/actor_random_fan.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_projectile_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_random_fan.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_random_fan.raw.o $@ .text 0x194
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_nearest_match.o \
    build/us/actor_random_fan.o

build/us/actor_list_animation_tick.o: src/game/actor_list_animation_tick.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_motion_internal.h include/actor_position_pairs.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_list_animation_tick.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_list_animation_tick.raw.o $@ .text 0x26c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/early_bonus_pattern.o: src/game/early_bonus_pattern.c include/destination_format.h include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/early_bonus_internal.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_bonus_pattern.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_bonus_pattern.raw.o $@ .text 0x1c8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_list_animation_tick.o \
    build/us/early_bonus_pattern.o

build/us/actor_position_follow.o: src/game/actor_position_follow.c include/actor.h include/actor_behavior_internal.h include/actor_position_pairs.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_position_follow.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_position_follow.raw.o $@ .text 0x90
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_value_follow.o: src/game/actor_value_follow.c include/actor.h include/actor_behavior_internal.h include/actor_position_pairs.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_value_follow.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_value_follow.raw.o $@ .text 0x144
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_position_follow.o \
    build/us/actor_value_follow.o

build/us/early_parameter_slot_tick.o: src/game/early_parameter_slot_tick.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/early_game_more.h include/early_game_state.h include/early_parameter_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_parameter_slot_tick.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_parameter_slot_tick.raw.o $@ .text 0xd8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_parameter_slot_tick.o

build/us/early_actor_follow_owner.o: src/game/early_actor_follow_owner.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_more.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_follow_owner.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_follow_owner.raw.o $@ .text 0x11c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_actor_follow_owner.o

build/us/renderer_status_text.o: src/game/renderer_status_text.c include/debug_output.h include/frame.h include/game_memory.h include/graphics_state_internal.h include/heap.h include/renderer_debug_text.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_status_text.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_status_text.raw.o build/us/renderer_status_text.text.o .text 0x11c
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_status_text.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/renderer_status_text.o

build/us/early_boundary_actor_spawn.o: src/game/early_boundary_actor_spawn.c include/actor.h include/actor_behavior_internal.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_boundary_actor_spawn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_boundary_actor_spawn.raw.o $@ .text 0x18c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_boundary_actor_spawn.o

build/us/controller_service_setup.o: src/game/controller_service_setup.c include/controller_input.h include/controller_services.h include/debug_output.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_service_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_service_setup.raw.o $@ .text 0x378
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/controller_service_setup.o

build/us/controller_motor_state.o: src/game/controller_motor_state.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_motor_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_motor_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/controller_thread_state.o: src/game/controller_thread_state.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_thread_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_thread_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_motor_state.o build/us/controller_thread_state.o

build/us/renderer_textured_submit.o: src/game/renderer_textured_submit.c tools/owned_sections.py config/owned_sections.json include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_textured_submit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_textured_submit.raw.o build/us/renderer_textured_submit.text.o .text 0x448
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_textured_submit.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/renderer_textured_submit.o

build/us/renderer_texture_squares.o: src/game/renderer_texture_squares.c tools/owned_sections.py config/owned_sections.json include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_texture_squares.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_texture_squares.raw.o build/us/renderer_texture_squares.text.o .text 0x508
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_texture_squares.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_image_quad_ci.o: src/game/renderer_image_quad_ci.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_image_quad_ci.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_image_quad_ci.raw.o $@ .text 0x240
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/renderer_image_quad_rgba.o: src/game/renderer_image_quad_rgba.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_image_quad_rgba.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_image_quad_rgba.raw.o $@ .text 0x240
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/renderer_texture_squares.o \
    build/us/renderer_image_quad_ci.o \
    build/us/renderer_image_quad_rgba.o

build/us/renderer_expanded_triangle.o: src/game/renderer_expanded_triangle.c tools/owned_sections.py config/owned_sections.json include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_expanded_triangle.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_expanded_triangle.raw.o build/us/renderer_expanded_triangle.text.o .text 0x2d8
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_expanded_triangle.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/renderer_expanded_triangle.o

build/us/renderer_camera_square.o: src/game/renderer_camera_square.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_camera_square.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_camera_square.raw.o $@ .text 0x150
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/renderer_camera_square.o

build/us/early_pool_scene_reset.o: src/game/early_pool_scene_reset.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/early_pool_tick.h include/game_memory.h include/object.h include/object_helpers.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_pool_scene_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_pool_scene_reset.raw.o $@ .text 0x11c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_pool_scene_reset.o

build/us/scene_actor_reset_begin.o: src/game/scene_actor_reset_begin.c include/destination_format.h include/actor.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/palette.h include/palette_effects.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_actor_reset_begin.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_actor_reset_begin.raw.o $@ .text 0x188
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/scene_actor_reset_begin.o

build/us/scene_menu_string_refresh.o: src/game/scene_menu_string_refresh.c include/game_memory.h include/movie.h include/object.h include/palette.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_menu_string_refresh.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_menu_string_refresh.raw.o $@ .text 0x170
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/scene_menu_string_refresh.o

build/us/movie_string_position_submit.o: src/game/movie_string_position_submit.c tools/owned_sections.py config/owned_sections.json include/movie.h include/palette.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_string_position_submit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_string_position_submit.raw.o build/us/movie_string_position_submit.text.o .text 0x170
	$(PYTHON) tools/owned_sections.py $< build/us/movie_string_position_submit.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/movie_string_position_submit.o

build/us/model_normal_polygon_dispatch.o: src/game/model_normal_polygon_dispatch.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_normal_polygon_dispatch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_normal_polygon_dispatch.raw.o $@ .text 0x348
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/scene_menu_string_schedule.o: src/game/scene_menu_string_schedule.c include/game_memory.h include/movie.h include/object.h include/palette.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_menu_string_schedule.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_menu_string_schedule.raw.o $@ .text 0x1b0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/model_normal_polygon_dispatch.o \
    build/us/scene_menu_string_schedule.o

build/us/session_scene_start.o: src/game/session_scene_start.c include/destination_format.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/session_scene_start.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/session_scene_start.raw.o $@ .text 0x1c0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/session_scene_start.o

build/us/early_scene_animation_advance.o: src/game/early_scene_animation_advance.c include/destination_format.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_scene_animation_advance.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_scene_animation_advance.raw.o $@ .text 0x1e8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_scene_animation_advance.o

build/us/save_menu_continue_decode.o: src/game/save_menu_continue_decode.c include/destination_format.h include/game_memory.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_continue_decode.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_continue_decode.raw.o $@ .text 0x230
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/save_menu_continue_decode.o

build/us/scene_frame_tick.o: src/game/scene_frame_tick.c tools/owned_sections.py config/owned_sections.json include/game_memory.h include/platform_services.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_frame_tick.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_frame_tick.raw.o build/us/scene_frame_tick.text.o .text 0x230
	$(PYTHON) tools/owned_sections.py $< build/us/scene_frame_tick.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/scene_frame_tick.o

build/us/early_actor_pair_spawn.o: src/game/early_actor_pair_spawn.c include/actor.h include/actor_behavior_internal.h include/early_game_medium_next.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_pair_spawn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_pair_spawn.raw.o $@ .text 0x274
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/early_actor_pair_spawn.o

build/us/actor_pickup.o: src/game/actor_pickup.c tools/owned_sections.py config/owned_sections.json include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_audio.h include/scene_counter_internal.h include/scene_player_runtime_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_pickup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_pickup.raw.o build/us/actor_pickup.text.o .text 0x26c
	$(PYTHON) tools/owned_sections.py $< build/us/actor_pickup.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_pickup.o

build/us/save_menu_continue_character.o: src/game/save_menu_continue_character.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_continue_character.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_continue_character.raw.o $@ .text 0x4c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/save_menu_continue_character.o

build/us/object_history_render.o: src/game/object_history_render.c include/actor.h include/actor_behavior_internal.h include/debug_output.h include/early_game_helpers.h include/early_game_state.h include/fixed_math.h include/frame.h include/game_memory.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/object_history_internal.h include/object_recovery.h include/renderer_draw_state_internal.h include/rom_files.h include/scalar_math.h include/sdk_matrix.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_history_render.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_history_render.raw.o $@ .text 0x1f8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/object_history_render.o

build/us/renderer_matrix_submit.o: src/game/renderer_matrix_submit.c include/debug_output.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_matrix_submit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_matrix_submit.raw.o build/us/renderer_matrix_submit.text.o .text 0x298
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_matrix_submit.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/renderer_matrix_submit.o

build/us/model_file_relocate.o: src/game/model_file_relocate.c tools/owned_sections.py config/owned_sections.json include/debug_output.h include/object_recovery.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_file_relocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_file_relocate.raw.o build/us/model_file_relocate.text.o .text 0x294
	$(PYTHON) tools/owned_sections.py $< build/us/model_file_relocate.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/model_file_relocate.o

build/us/audio_voice_defaults.o: src/game/audio_voice_defaults.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_voice_defaults.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_voice_defaults.raw.o $@ .text 0x2cc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_voice_defaults.o

build/us/audio_memory_size.o: src/game/audio_memory_size.c include/audio_backend_internal.h include/audio_bank_layout_internal.h include/audio_callbacks.h include/audio_control.h include/audio_file_services_internal.h include/audio_host_internal.h include/audio_io.h include/audio_loader_internal.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h tools/owned_sections.py config/owned_sections.json $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_memory_size.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_memory_size.raw.o build/us/audio_memory_size.text.o .text 0x2cc
	$(PYTHON) tools/owned_sections.py $< build/us/audio_memory_size.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/audio_memory_size.o

build/us/collision_dispatch_initialize.o: src/game/collision_dispatch_initialize.c tools/owned_sections.py config/owned_sections.json include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_helpers.h include/early_game_medium.h include/early_game_more.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/collision_dispatch_initialize.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/collision_dispatch_initialize.raw.o build/us/collision_dispatch_initialize.text.o .text 0x328
	$(PYTHON) tools/owned_sections.py $< build/us/collision_dispatch_initialize.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/collision_dispatch_initialize.o

build/us/renderer_projection_highlight.o: src/game/renderer_projection_highlight.c tools/owned_sections.py config/owned_sections.json include/debug_output.h include/early_game_helpers.h include/early_render_internal.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object_recovery.h include/renderer_geometry_internal.h include/rom_files.h include/runtime_angle.h include/scalar_math.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/renderer_projection_internal.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_projection_highlight.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_projection_highlight.raw.o build/us/renderer_projection_highlight.text.o .text 0x2b8
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_projection_highlight.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/renderer_projection_highlight.o

build/us/actor_pool_allocate.o: src/game/actor_pool_allocate.c tools/owned_sections.py config/owned_sections.json include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_pool_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_pool_allocate.raw.o build/us/actor_pool_allocate.text.o .text 0x314
	$(PYTHON) tools/owned_sections.py $< build/us/actor_pool_allocate.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += \
    build/us/actor_pool_allocate.o

build/us/game_string_append.o: src/game/game_string_append.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_string_append.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_string_append.raw.o $@ .text 0x34
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/game_string_append.o

build/us/early_player_sequence.o: src/game/early_player_sequence.c include/destination_format.h include/early_input_internal.h include/save_game.h include/pak_file.h include/scene_definition.h include/controller_input.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_player_sequence.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_player_sequence.raw.o $@ .text 0x118
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_player_sequence.o

build/us/early_player_input_sample.o: src/game/early_player_input_sample.c include/destination_format.h include/early_input_internal.h include/save_game.h include/pak_file.h include/scene_definition.h include/controller_input.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/menu_label_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_player_input_sample.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_player_input_sample.raw.o $@ .text 0xD4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_player_input_sample.o

build/us/early_relative_position.o: src/game/early_relative_position.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/fixed_math.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/sdk_matrix.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_relative_position.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_relative_position.raw.o $@ .text 0xe4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_relative_position.o

build/us/actor_contact_gate.o: src/game/actor_contact_gate.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h include/actor_collision_separation_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_contact_gate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_contact_gate.raw.o $@ .text 0x278
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_contact_gate.o

build/us/sound_request_dispatch.o: src/game/sound_request_dispatch.c include/destination_format.h tools/owned_sections.py config/owned_sections.json include/actor.h include/game_memory.h include/object.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/sound_request_dispatch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/sound_request_dispatch.raw.o build/us/sound_request_dispatch.text.o .text 0xb0
	$(PYTHON) tools/owned_sections.py $< build/us/sound_request_dispatch.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/sound_request_dispatch.o

build/us/actor_chain_reset.o: src/game/actor_chain_reset.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_chain_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_chain_reset.raw.o $@ .text 0x3c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_chain_reset.o

build/us/model_hierarchy_transform.o: src/game/model_hierarchy_transform.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/model_hierarchy_transform.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/model_hierarchy_transform.raw.o $@ .text 0x16c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/model_hierarchy_transform.o

build/us/actor_history_projectile.o: src/game/actor_history_projectile.c include/actor.h include/actor_history_internal.h include/actor_projectile_internal.h include/game_memory.h include/object.h include/object_recovery.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_history_projectile.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_history_projectile.raw.o $@ .text 0x1a4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_history_projectile.o

build/us/actor_history_data.o: src/game/actor_history_data.c include/actor.h include/actor_history_internal.h include/actor_projectile_internal.h include/game_memory.h include/object.h include/object_recovery.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_history_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_history_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_history_data.o

build/us/actor_history_tick.o: src/game/actor_history_tick.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_history_internal.h include/actor_projectile_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_history_tick.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_history_tick.raw.o build/us/actor_history_tick.text.o .text 0x288
	$(PYTHON) tools/owned_sections.py $< build/us/actor_history_tick.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_history_tick.o

build/us/object_camera_angles.o: src/game/object_camera_angles.c include/frame.h include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_camera_angles.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_camera_angles.raw.o build/us/object_camera_angles.text.o .text 0xa4
	$(PYTHON) tools/owned_sections.py $< build/us/object_camera_angles.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/object_camera_angles.o

build/us/object_camera_angles_alt.o: src/game/object_camera_angles_alt.c include/frame.h include/object_helpers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_camera_angles_alt.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/object_camera_angles_alt.raw.o build/us/object_camera_angles_alt.text.o .text 0xa0
	$(PYTHON) tools/owned_sections.py $< build/us/object_camera_angles_alt.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/object_camera_angles_alt.o

build/us/camera_state_data.o: src/game/camera_state_data.c include/frame.h include/object_helpers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/camera_state_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/camera_state_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/camera_state_data.o

build/us/camera_matrix_data.o: src/game/camera_matrix_data.c include/fixed_math.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/camera_matrix_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/camera_matrix_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/camera_matrix_data.o

build/us/controller_input.o: src/game/controller_input.c include/controller_input.h include/scalar_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_input.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_input.raw.o $@ .text 0x320
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_input.o

build/us/game_float_parse.o: src/game/game_float_parse.c include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_float_parse.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_float_parse.raw.o $@ .text 0x174
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/game_float_parse.o

build/us/controller_pad_state.o: src/game/controller_pad_state.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pad_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_pad_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_pad_state.o

build/us/actor_position_submit.o: src/game/actor_position_submit.c include/actor.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_position_submit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_position_submit.raw.o build/us/actor_position_submit.text.o .text 0xa4
	$(PYTHON) tools/owned_sections.py $< build/us/actor_position_submit.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_position_submit.o

build/us/save_menu_score_step.o: src/game/save_menu_score_step.c include/destination_format.h include/pak_file.h include/save_game.h include/save_menu_internal.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/menu_label_internal.h include/front_menu_internal.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_menu_score_step.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/save_menu_score_step.raw.o build/us/save_menu_score_step.text.o .text 0xec
	$(PYTHON) tools/owned_sections.py $< build/us/save_menu_score_step.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/save_menu_score_step.o

build/us/audio_variable_length_size.o: src/game/audio_variable_length_size.c include/audio_properties_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_variable_length_size.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_variable_length_size.raw.o $@ .text 0x80
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_variable_length_size.o

build/us/early_input_cursor_data.o: src/game/early_input_cursor_data.c include/destination_format.h include/controller_input.h include/early_input_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_input_cursor_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_input_cursor_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_input_cursor_data.o

build/us/early_input_button_data.o: src/game/early_input_button_data.c include/destination_format.h include/controller_input.h include/early_input_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_input_button_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_input_button_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_input_button_data.o

build/us/early_input_counter_data.o: src/game/early_input_counter_data.c include/destination_format.h include/controller_input.h include/early_input_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_input_counter_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_input_counter_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_input_counter_data.o

build/us/early_input_sequence_data.o: src/game/early_input_sequence_data.c include/destination_format.h include/controller_input.h include/early_input_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_input_sequence_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_input_sequence_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_input_sequence_data.o

build/us/early_input_fixed_data.o: src/game/early_input_fixed_data.c include/destination_format.h include/controller_input.h include/early_input_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_input_fixed_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_input_fixed_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_input_fixed_data.o

build/us/audio_timing_data.o: src/game/audio_timing_data.c include/audio_host_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_timing_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_timing_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_timing_data.o

build/us/early_render_quad.o: src/game/early_render_quad.c include/debug_output.h include/early_game_helpers.h include/early_render_internal.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_quad.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_render_quad.raw.o $@ .text 0x178
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_render_quad.o

build/us/renderer_vertex_arena_data.o: src/game/renderer_vertex_arena_data.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_vertex_arena_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_vertex_arena_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_vertex_arena_data.o

build/us/early_render_color_data.o: src/game/early_render_color_data.c include/debug_output.h include/early_game_helpers.h include/early_render_internal.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_color_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_render_color_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_render_color_data.o

build/us/early_render_tube_data.o: src/game/early_render_tube_data.c include/actor.h include/actor_behavior_internal.h include/debug_output.h include/early_game_helpers.h include/early_game_state.h include/early_render_effects_internal.h include/early_render_internal.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/game_memory.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/object_recovery.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/scalar_math.h include/sdk_matrix.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_tube_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_render_tube_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_render_tube_data.o

build/us/early_render_coordinate_data.o: src/game/early_render_coordinate_data.c include/actor.h include/actor_behavior_internal.h include/debug_output.h include/early_game_helpers.h include/early_game_state.h include/early_render_effects_internal.h include/early_render_internal.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/game_memory.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/object_recovery.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/scalar_math.h include/sdk_matrix.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_render_coordinate_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_render_coordinate_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_render_coordinate_data.o

build/us/renderer_image_placement_data.o: src/game/renderer_image_placement_data.c include/debug_output.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_image_setup_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_image_placement_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_image_placement_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_image_placement_data.o

build/us/graphics_buffer_select_data.o: src/boot/graphics_buffer_select_data.c include/fixed_math.h include/frame.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_buffer_select_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_buffer_select_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/graphics_buffer_select_data.o

build/us/graphics_rsp_stack_data.o: src/boot/graphics_rsp_stack_data.c include/graphics_tasks.h include/scheduler.h include/scheduler_task.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_rsp_stack_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_rsp_stack_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/graphics_rsp_stack_data.o

build/us/graphics_rsp_yield_data.o: src/boot/graphics_rsp_yield_data.c include/graphics_tasks.h include/scheduler.h include/scheduler_task.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/graphics_rsp_yield_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/graphics_rsp_yield_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/graphics_rsp_yield_data.o

build/us/renderer_matrix_arena_data.o: src/game/renderer_matrix_arena_data.c include/fixed_math.h include/frame.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_matrix_arena_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_matrix_arena_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_matrix_arena_data.o

build/us/renderer_matrix_cursor_data.o: src/game/renderer_matrix_cursor_data.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_matrix_cursor_data.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_matrix_cursor_data.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_matrix_cursor_data.o

build/us/renderer_matrix_transform.o: src/game/renderer_matrix_transform.c include/debug_output.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_matrix_transform.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_matrix_transform.raw.o build/us/renderer_matrix_transform.text.o .text 0x498
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_matrix_transform.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_matrix_transform.o

build/us/renderer_diagnostic_messages.o: src/game/renderer_diagnostics/messages.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_messages.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_messages.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_messages.o

build/us/renderer_diagnostic_version.o: src/game/renderer_diagnostics/version.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_version.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_version.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_version.o

build/us/renderer_diagnostic_frame_count.o: src/game/renderer_diagnostics/frame_count.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_frame_count.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_frame_count.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_frame_count.o

build/us/renderer_diagnostic_asset_lengths.o: src/game/renderer_diagnostics/asset_lengths.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_asset_lengths.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_asset_lengths.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_asset_lengths.o

build/us/renderer_diagnostic_instance_pool.o: src/game/renderer_diagnostics/instance_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_instance_pool.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_instance_pool.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_instance_pool.o

build/us/renderer_diagnostic_object_pool.o: src/game/renderer_diagnostics/object_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_object_pool.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_object_pool.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_object_pool.o

build/us/renderer_diagnostic_movie_pool.o: src/game/renderer_diagnostics/movie_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_movie_pool.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_movie_pool.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_movie_pool.o

build/us/renderer_diagnostic_path_pool.o: src/game/renderer_diagnostics/path_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_path_pool.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_path_pool.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_path_pool.o

build/us/renderer_diagnostic_vertex_pool.o: src/game/renderer_diagnostics/vertex_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_vertex_pool.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_vertex_pool.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_vertex_pool.o

build/us/renderer_diagnostic_matrix_pool.o: src/game/renderer_diagnostics/matrix_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_matrix_pool.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_matrix_pool.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_matrix_pool.o

build/us/renderer_diagnostic_hierarchy_pool.o: src/game/renderer_diagnostics/hierarchy_pool.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_hierarchy_pool.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_hierarchy_pool.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_hierarchy_pool.o

build/us/renderer_diagnostic_frame_metrics.o: src/game/renderer_diagnostics/frame_metrics.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/rom_files.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/resource_arena.h include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_frame_metrics.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_diagnostic_frame_metrics.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_frame_metrics.o

build/us/controller_motor_duty.o: src/game/controller/motor_duty.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_motor_duty.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_motor_duty.raw.o $@ .text 0x110
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_motor_duty.o

build/us/controller_connection_masks.o: src/game/controller/connection_masks.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_connection_masks.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_connection_masks.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_connection_masks.o

build/us/controller_paks.o: src/game/controller/paks.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_paks.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_paks.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_paks.o

build/us/controller_file_index.o: src/game/controller/file_index.c include/controller_input.h include/controller_services.h include/pak_file.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_file_index.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_file_index.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_file_index.o

build/us/controller_motor_command.o: src/game/controller/motor_command.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_motor_command.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_motor_command.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_motor_command.o

build/us/controller_access_queue.o: src/game/controller/access_queue.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_access_queue.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_access_queue.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_access_queue.o



build/us/controller_pak_directory_state.o: src/game/controller/pak_directory.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_pak_directory_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_pak_directory_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_pak_directory_state.o

build/us/controller_access_guard.o: src/game/controller/access_guard.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_access_guard.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_access_guard.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_access_guard.o

build/us/controller_motor_strength.o: src/game/controller/motor_strength.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_motor_strength.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_motor_strength.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_motor_strength.o

build/us/controller_motor_initialize_message.o: src/game/controller/motor_initialize_message.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_motor_initialize_message.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_motor_initialize_message.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_motor_initialize_message.o

build/us/controller_motor_refresh_message.o: src/game/controller/motor_refresh_message.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_motor_refresh_message.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_motor_refresh_message.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_motor_refresh_message.o

build/us/controller_access_message.o: src/game/controller/access_message.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_access_message.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/controller_access_message.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_access_message.o

build/us/renderer_opaque_quad.o: src/game/renderer_primitives/opaque_quad.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_polygon_messages.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_opaque_quad.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_opaque_quad.raw.o $@ .text 0x1c4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_opaque_quad.o

build/us/renderer_alpha_quad.o: src/game/renderer_primitives/alpha_quad.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_polygon_messages.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_alpha_quad.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_alpha_quad.raw.o $@ .text 0x1c4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_alpha_quad.o

build/us/renderer_expanded_quad_messages.o: src/game/renderer_primitives/expanded_quad_messages.c include/renderer_polygon_messages.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_expanded_quad_messages.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_expanded_quad_messages.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_expanded_quad_messages.o

build/us/renderer_polygon_messages.o: src/game/renderer_primitives/polygon_messages.c include/renderer_polygon_messages.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_polygon_messages.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_polygon_messages.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_polygon_messages.o

build/us/renderer_mesh_submit.o: src/game/renderer_primitives/mesh_submit.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_geometry_internal.h include/renderer_polygon_messages.h include/renderer_primitives_internal.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_mesh_submit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_mesh_submit.raw.o $@ .text 0x400
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_mesh_submit.o

build/us/renderer_resource_messages.o: src/game/renderer_resources/messages.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_recovery.h include/object_runtime.h include/renderer_resource_loader.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_resource_messages.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_resource_messages.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_resource_messages.o

build/us/destination_format.o: src/game/formatting/destination.c include/destination_format.h include/game_memory.h include/game_stdarg.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/destination_format.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/destination_format.raw.o build/us/destination_format.text.o .text 0x298
	$(PYTHON) tools/owned_sections.py $< build/us/destination_format.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/destination_format.o

build/us/renderer_model_cache_storage.o: src/game/renderer_resources/model_storage.c include/object_recovery.h include/renderer_resource_storage.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_model_cache_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_model_cache_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_model_cache_storage.o

build/us/renderer_animation_cache_storage.o: src/game/renderer_resources/animation_storage.c include/object_recovery.h include/renderer_resource_storage.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_animation_cache_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_animation_cache_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_animation_cache_storage.o

build/us/renderer_resource_map_reset.o: src/game/renderer_resources/map_reset_flags.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_resource_map_reset.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_resource_map_reset.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_resource_map_reset.o

build/us/renderer_resource_counters.o: src/game/renderer_resources/counters.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_resource_counters.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_resource_counters.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_resource_counters.o

build/us/renderer_resource_identifier_maps.o: src/game/renderer_resources/identifier_maps.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/object_runtime.h include/resource_bridge_internal.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_resource_identifier_maps.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_resource_identifier_maps.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_resource_identifier_maps.o

build/us/renderer_resource_arena_state.o: src/game/renderer_resources/arena_state.c include/resource_arena.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_resource_arena_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_resource_arena_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_resource_arena_state.o

build/us/heap_state.o: src/game/heap/state.c include/heap.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/heap_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/heap_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/heap_state.o

build/us/renderer_diagnostic_report.o: src/game/renderer_diagnostics/report.c include/debug_output.h include/frame.h include/graphics_state_internal.h include/heap.h include/renderer_diagnostic_internal.h include/renderer_peak_metrics.h include/resource_arena.h include/rom_files.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_diagnostic_report.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_diagnostic_report.raw.o $@ .text 0x5c4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_diagnostic_report.o

build/us/renderer_projection_constants.o: src/game/renderer_projection/constants.c include/renderer_projection_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_projection_constants.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_projection_constants.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_projection_constants.o

build/us/renderer_projection_state.o: src/game/renderer_projection/state.c include/renderer_projection_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_projection_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_projection_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_projection_state.o

build/us/renderer_grid_commands.o: src/game/renderer_setup/grid_commands.c include/frame.h include/renderer_setup_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_grid_commands.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_grid_commands.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_grid_commands.o

build/us/renderer_setup_viewport.o: src/game/renderer_setup/viewport.c include/frame.h include/renderer_setup_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_setup_viewport.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_setup_viewport.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_setup_viewport.o

build/us/renderer_setup_lighting.o: src/game/renderer_setup/lighting.c include/frame.h include/renderer_setup_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_setup_lighting.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_setup_lighting.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_setup_lighting.o

build/us/renderer_frame_geometry_commands.o: src/game/renderer_setup/frame_geometry_commands.c include/frame.h include/renderer_setup_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_frame_geometry_commands.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_frame_geometry_commands.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_frame_geometry_commands.o

build/us/renderer_frame_rdp_commands.o: src/game/renderer_setup/frame_rdp_commands.c include/frame.h include/renderer_setup_internal.h include/sdk_camera.h include/sdk_float_math.h include/sdk_matrix.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_frame_rdp_commands.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_frame_rdp_commands.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_frame_rdp_commands.o

build/us/tweak_variables.o: src/game/tweaks/variables.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_variables.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/tweak_variables.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/tweak_variables.o

build/us/tweak_pages.o: src/game/tweaks/pages.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_pages.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/tweak_pages.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/tweak_pages.o

build/us/tweak_difficulties.o: src/game/tweaks/difficulties.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_difficulties.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/tweak_difficulties.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/tweak_difficulties.o

build/us/tweak_counters.o: src/game/tweaks/counters.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_counters.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/tweak_counters.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/tweak_counters.o

build/us/tweak_display_state.o: src/game/tweaks/display_state.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_display_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/tweak_display_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/tweak_display_state.o

build/us/tweak_messages.o: src/game/tweaks/messages.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_messages.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/tweak_messages.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/tweak_messages.o

build/us/tweak_difficulty_define.o: src/game/tweak_difficulty_define.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_difficulty_define.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_difficulty_define.raw.o $@ .text 0xd4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/tweak_difficulty_define.o

build/us/tweak_scene_define.o: src/game/tweak_scene_define.c include/actor.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h include/tweak_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/tweak_scene_define.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/tweak_scene_define.raw.o $@ .text 0xd0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/tweak_scene_define.o

build/us/actor_behavior_duration.o: src/game/actor_behaviors/duration.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_duration_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_duration.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_duration.raw.o $@ .text 0x3f0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_duration.o

build/us/actor_behavior_brain.o: src/game/actor_behaviors/brain.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_brain_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_brain.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_brain.raw.o $@ .text 0x3dc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_brain.o

build/us/actor_behavior_hulk.o: src/game/actor_behaviors/hulk.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_hulk_internal.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_hulk.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_hulk.raw.o build/us/actor_behavior_hulk.text.o .text 0x400
	$(PYTHON) tools/owned_sections.py $< build/us/actor_behavior_hulk.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_hulk.o

build/us/actor_behavior_diagnostic.o: src/game/actor_behaviors/diagnostics.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_hulk_internal.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_diagnostic.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_behavior_diagnostic.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_diagnostic.o

build/us/actor_behavior_spawn_state.o: src/game/actor_behaviors/spawn.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_spawn_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_spawn_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_spawn_state.raw.o $@ .text 0x544
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_spawn_state.o

build/us/actor_behavior_spawn_callback.o: src/game/actor_behaviors/spawn_callback.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_spawn_callback_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_spawn_callback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_spawn_callback.raw.o $@ .text 0x3c0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_spawn_callback.o

build/us/actor_create.o: src/game/actor_lifecycle/create.c include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_lifecycle_internal.h include/actor_motion_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/destination_format.h include/early_pool_tick.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_create.raw.o build/us/actor_create.text.o .text 0x3e0
	$(PYTHON) tools/owned_sections.py $< build/us/actor_create.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_create.o

build/us/actor_behavior_pursuit.o: src/game/actor_behaviors/pursuit.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_motion_internal.h include/actor_pursuit_internal.h include/actor_spawn_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_pursuit.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_pursuit.raw.o build/us/actor_behavior_pursuit.text.o .text 0x4b0
	$(PYTHON) tools/owned_sections.py $< build/us/actor_behavior_pursuit.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_pursuit.o

build/us/actor_behavior_enforcer.o: src/game/actor_behaviors/enforcer.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_enforcer_internal.h include/actor_spawn_callback_internal.h include/actor_spawn_internal.h include/early_game_helpers.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_enforcer.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_enforcer.raw.o build/us/actor_behavior_enforcer.text.o .text 0x69c
	$(PYTHON) tools/owned_sections.py $< build/us/actor_behavior_enforcer.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_enforcer.o

build/us/actor_brain_diagnostic.o: src/game/actor_behaviors/brain_diagnostic.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_motion_internal.h include/actor_pursuit_internal.h include/actor_spawn_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_brain_diagnostic.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_brain_diagnostic.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_brain_diagnostic.o

build/us/actor_behavior_human.o: src/game/actor_behaviors/human.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_human_internal.h include/actor_motion_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_history_internal.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_human.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_human.raw.o build/us/actor_behavior_human.text.o .text 0x724
	$(PYTHON) tools/owned_sections.py $< build/us/actor_behavior_human.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_human.o

build/us/actor_human_diagnostic.o: src/game/actor_behaviors/human_diagnostic.c include/actor.h include/actor_behavior_extra_internal.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_human_internal.h include/actor_motion_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_history_internal.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_human_diagnostic.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_human_diagnostic.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_human_diagnostic.o

build/us/actor_behavior_stride.o: src/game/actor_behaviors/stride.c include/actor.h include/actor_behavior_internal.h include/actor_behavior_more_internal.h include/actor_motion_internal.h include/actor_stride_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_behavior_stride.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_behavior_stride.raw.o build/us/actor_behavior_stride.text.o .text 0x7cc
	$(PYTHON) tools/owned_sections.py $< build/us/actor_behavior_stride.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_behavior_stride.o

build/us/actor_retirement.o: src/game/actor_retirement.c include/actor.h include/actor_behavior_internal.h include/actor_motion_internal.h include/destination_format.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_retirement.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_retirement.raw.o build/us/actor_retirement.text.o .text 0x800
	$(PYTHON) tools/owned_sections.py $< build/us/actor_retirement.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_retirement.o

build/us/actor_manual_motion.o: src/game/actor_manual_motion.c include/actor.h include/actor_behavior_internal.h include/controller_input.h include/debug_output.h include/destination_format.h include/early_input_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/sound_bridge_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_manual_motion.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_manual_motion.raw.o build/us/actor_manual_motion.text.o .text 0x228
	$(PYTHON) tools/owned_sections.py $< build/us/actor_manual_motion.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_manual_motion.o

build/us/actor_manual_motion_diagnostic.o: src/game/actor_manual_motion_diagnostic.c $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_manual_motion_diagnostic.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_manual_motion_diagnostic.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_manual_motion_diagnostic.o

build/us/actor_fragment_spawn.o: src/game/actor_effects/fragment_spawn.c include/actor.h include/actor_behavior_internal.h include/actor_motion_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_fragment_spawn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_fragment_spawn.raw.o build/us/actor_fragment_spawn.text.o .text 0x2c8
	$(PYTHON) tools/owned_sections.py $< build/us/actor_fragment_spawn.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_fragment_spawn.o

build/us/actor_scatter_spawn.o: src/game/actor_effects/scatter_spawn.c include/actor.h include/actor_behavior_internal.h include/actor_motion_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_scatter_spawn.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_scatter_spawn.raw.o build/us/actor_scatter_spawn.text.o .text 0x300
	$(PYTHON) tools/owned_sections.py $< build/us/actor_scatter_spawn.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_scatter_spawn.o

build/us/command_script_execute.o: src/game/command_scripts/execute.c include/command_script.h include/game_memory.h include/object.h include/platform_services.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/command_script_execute.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/command_script_execute.raw.o build/us/command_script_execute.text.o .text 0x160
	$(PYTHON) tools/owned_sections.py $< build/us/command_script_execute.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/command_script_execute.o

build/us/effect_draw_config.o: src/game/actor_effects/draw_config.c include/actor.h include/actor_behavior_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/early_game_state.h include/effect_draw_config_internal.h include/game_memory.h include/object.h include/object_recovery.h include/palette.h include/scalar_math.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/effect_draw_config.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/effect_draw_config.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/effect_draw_config.o

build/us/command_script_diagnostics.o: src/game/command_scripts/diagnostics.c $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/command_script_diagnostics.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/command_script_diagnostics.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/command_script_diagnostics.o

build/us/palette_fade_update.o: src/game/palette_effects/fade_update.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_fade_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette_fade_update.raw.o build/us/palette_fade_update.text.o .text 0x47c
	$(PYTHON) tools/owned_sections.py $< build/us/palette_fade_update.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_fade_update.o

build/us/palette_base_storage.o: src/game/palette_effects/base_storage.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_base_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/palette_base_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_base_storage.o

build/us/palette_transition_storage.o: src/game/palette_effects/transition_storage.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_transition_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/palette_transition_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_transition_storage.o

build/us/palette_fade_color.o: src/game/palette_effects/fade_color.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_fade_color.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/palette_fade_color.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_fade_color.o

build/us/palette_fade_progress.o: src/game/palette_effects/fade_progress.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_fade_progress.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/palette_fade_progress.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_fade_progress.o

build/us/palette_fade_step.o: src/game/palette_effects/fade_step.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_fade_step.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/palette_fade_step.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_fade_step.o

build/us/actor_group_setup.o: src/game/actor_groups/setup.c include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/destination_format.h include/early_game_more.h include/early_game_state.h include/early_parameter_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_group_setup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_group_setup.raw.o $@ .text 0x220
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_group_setup.o

build/us/actor_direction_table.o: src/game/actor_groups/direction_table.c $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_direction_table.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_direction_table.raw.o $@
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += build/us/actor_direction_table.o

build/us/actor_child_resources.o: src/game/actor_groups/child_resources.c include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/game_memory.h include/object.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_child_resources.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_child_resources.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_child_counts.o: src/game/actor_groups/child_counts.c $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_child_counts.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_child_counts.raw.o $@
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += build/us/actor_child_resources.o build/us/actor_child_counts.o

build/us/actor_effect_draw.o: src/game/actor_effects/draw.c include/actor.h include/actor_behavior_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/debug_output.h include/early_game_state.h include/effect_draw_config_internal.h include/fixed_math.h include/frame.h include/game_memory.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/object_recovery.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_texture_index.h include/rom_files.h include/scalar_math.h include/sdk_matrix.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_effect_draw.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_effect_draw.raw.o $@ .text 0x2b4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_effect_draw.o

build/us/object_record_storage.o: src/game/object_storage/records.c include/object.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_record_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/object_record_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/object_record_storage.o

build/us/object_slot_storage.o: src/game/object_storage/slots.c include/object_helpers.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/object_slot_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/object_slot_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/object_slot_storage.o

build/us/renderer_matrix_scale.o: src/game/renderer_matrix_scale.c include/debug_output.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_matrix_scale.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_matrix_scale.raw.o $@ .text 0x380
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_matrix_scale.o

build/us/renderer_supplied_matrix_diagnostics.o: src/game/renderer_diagnostics/supplied_matrix.c  $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_supplied_matrix_diagnostics.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_supplied_matrix_diagnostics.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_supplied_matrix_diagnostics.o

build/us/renderer_image_setup_ci.o: src/game/renderer_images/setup_ci.c include/debug_output.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_image_setup_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_image_setup_ci.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_image_setup_ci.raw.o $@ .text 0xc0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_image_setup_ci.o

build/us/renderer_image_setup_rgba.o: src/game/renderer_images/setup_rgba.c include/debug_output.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_image_setup_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_image_setup_rgba.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_image_setup_rgba.raw.o $@ .text 0xf4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_image_setup_rgba.o

build/us/renderer_object_glyph.o: src/game/renderer_text/object_glyph.c include/debug_output.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/object.h include/object_draw.h include/renderer_draw_state_internal.h include/renderer_geometry_internal.h include/renderer_image_setup_internal.h include/renderer_object_glyph_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_object_glyph.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_object_glyph.raw.o $@ .text 0x400
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_object_glyph.o

build/us/menu_options_define.o: src/game/save_menus/define_options.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_options_define.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/menu_options_define.raw.o $@ .text 0x1d8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_options_define.o

build/us/menu_options_records.o: src/game/save_menus/option_records.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_options_records.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_options_records.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_options_records.o

build/us/menu_options_page.o: src/game/save_menus/option_page.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_options_page.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_options_page.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_options_page.o

build/us/scene_action_dispatch.o: src/game/scene_actions/dispatch.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_action_internal.h include/scene_player_runtime_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json include/destination_format.h include/front_menu_internal.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h include/static_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_action_dispatch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/scene_action_dispatch.raw.o build/us/scene_action_dispatch.text.o .text 0x2d4
	$(PYTHON) tools/owned_sections.py $< build/us/scene_action_dispatch.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/scene_action_dispatch.o

build/us/scene_action_pickup_count.o: src/game/scene_actions/pickup_count.c $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/scene_action_pickup_count.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/scene_action_pickup_count.raw.o $@
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += build/us/scene_action_pickup_count.o

build/us/early_boss_create.o: src/game/actor_groups/boss_create.c include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/destination_format.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_boss_create.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_boss_create.raw.o build/us/early_boss_create.text.o .text 0x304
	$(PYTHON) tools/owned_sections.py $< build/us/early_boss_create.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_boss_create.o

build/us/early_boss_timestamps.o: src/game/actor_groups/boss_timestamps.c $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_boss_timestamps.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_boss_timestamps.raw.o $@
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += build/us/early_boss_timestamps.o

build/us/early_boss_trigger.o: src/game/actor_groups/trigger.c include/actor.h include/actor_behavior_internal.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/destination_format.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/platform_services.h include/save_game.h include/scalar_math.h include/scene_audio.h include/scene_commands_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_boss_trigger.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_boss_trigger.raw.o $@ .text 0x3ac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_boss_trigger.o

build/us/early_boss_trigger_records.o: src/game/actor_groups/trigger_records.c include/actor.h include/actor_dynamic_pool_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor_setup_internal.h include/game_memory.h include/object.h include/scene_definition.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_boss_trigger_records.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_boss_trigger_records.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_boss_trigger_records.o

build/us/early_boss_trigger_state.o: src/game/actor_groups/trigger_state.c  $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_boss_trigger_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/early_boss_trigger_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_boss_trigger_state.o

build/us/early_actor_decision.o: src/game/actor_groups/decision.c include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/destination_format.h include/early_bonus_internal.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_decision.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_decision.raw.o $@ .text 0x8a0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_actor_decision.o

build/us/early_actor_movement.o: src/game/actor_groups/movement.c include/actor.h include/actor_behavior_internal.h include/destination_format.h include/early_game_state.h include/early_session_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_actor_movement.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_actor_movement.raw.o build/us/early_actor_movement.text.o .text 0x5ec
	$(PYTHON) tools/owned_sections.py $< build/us/early_actor_movement.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_actor_movement.o

build/us/actor_collision_response_gate.o: src/game/collisions/response_gate.c include/actor_damage_internal.h include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_counter_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_response_gate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_response_gate.raw.o build/us/actor_collision_response_gate.text.o .text 0x308
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_response_gate.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_collision_response_gate.o

build/us/actor_collision_pickup_response.o: src/game/collisions/pickup_response.c include/actor_damage_internal.h include/actor.h include/actor_behavior_internal.h include/destination_format.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json tools/owned_sections.py
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_pickup_response.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_pickup_response.raw.o $@ .text 0x3ac
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_collision_pickup_response.o

build/us/actor_collision_pickup_order.o: src/game/collisions/pickup_order.c $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_pickup_order.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_pickup_order.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_collision_pickup_order.o

build/us/actor_collision_retire.o: src/game/collisions/retire.c include/actor.h include/actor_behavior_internal.h include/early_game_state.h include/early_pool_tick.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_retire.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_retire.raw.o build/us/actor_collision_retire.text.o .text 0x2d8
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_retire.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_collision_retire.o

build/us/actor_collision_rebound.o: src/game/collisions/rebound.c include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/scene_counter_internal.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_rebound.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_rebound.raw.o build/us/actor_collision_rebound.text.o .text 0x2fc
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_rebound.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_collision_rebound.o

build/us/actor_collision_retirement_message.o: src/game/collisions/retirement_message.c $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_retirement_message.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_retirement_message.raw.o $@
	$(PYTHON) tools/provenance.py $< $@

RUNTIME_OBJECTS += build/us/actor_collision_retirement_message.o

build/us/actor_group_rotate.o: src/game/actor_groups/rotate.c include/object_recovery.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_group_rotate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_group_rotate.raw.o $@ .text 0x174
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_group_rotate.o

build/us/actor_collision_impact.o: src/game/collisions/impact.c include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/actor_dynamic_pool_internal.h include/actor_resource_5c_internal.h include/actor_resource_internal.h include/actor_setup_internal.h include/destination_format.h include/early_game_more.h include/early_game_state.h include/early_parameter_internal.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_counter_internal.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_impact.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_impact.raw.o build/us/actor_collision_impact.text.o .text 0x748
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_impact.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_collision_impact.o

build/us/actor_collision_palette.o: src/game/collisions/palette.c include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_palette.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_collision_palette.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_collision_palette.o

build/us/audio_instance_allocate.o: src/game/audio_instance_allocate.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_instance_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_instance_allocate.raw.o $@ .text 0x2e4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_command_lengths.o: src/game/audio_command_lengths.c include/audio_engine_tables_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_command_lengths.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_command_lengths.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_engine_command_table.o: src/game/audio_engine_command_table.c include/audio_engine_tables_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_engine_command_table.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_engine_command_table.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_instance_allocate.o build/us/audio_command_lengths.o build/us/audio_engine_command_table.o

build/us/audio_sequence_data_load.o: src/game/audio_sequence_data_load.c include/audio_file_services_internal.h include/audio_host_internal.h include/audio_properties_internal.h include/audio_sequence_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_data_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_sequence_data_load.raw.o $@ .text 0x414
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_sequence_data_load.o

build/us/model_framebuffer_strip.o: src/game/model_framebuffer_strip.c include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/frame.h include/graphics_state_internal.h include/heap.h include/model_geometry_internal.h include/renderer_geometry_internal.h include/renderer_primitives_internal.h include/rom_files.h include/sdk_matrix.h $(IDO) Makefile tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o $@ $<
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/model_framebuffer_strip.o

build/us/boundary_dispatch.o: src/game/actor_groups/boundary_dispatch.c include/actor.h include/actor_behavior_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json tools/owned_sections.py config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/boundary_dispatch.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/boundary_dispatch.raw.o build/us/boundary_dispatch.text.o .text 0x3e4
	$(PYTHON) tools/owned_sections.py $< build/us/boundary_dispatch.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/boundary_dispatch.o


# Fatal and warning formatter strings, including complete alignment bytes.
build/us/error_messages.o: src/game/diagnostics/messages.c include/error_formatters.h $(IDO) Makefile tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/error_messages.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/error_messages.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ include/error_formatters.h

RUNTIME_OBJECTS += build/us/error_messages.o

# Buffered diagnostic formatter and its complete generated dispatch table.
build/us/error_formatted.o: src/game/diagnostics/formatted.c include/error_formatters.h include/game_memory.h include/game_stdarg.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/error_formatted.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/error_formatted.raw.o build/us/error_formatted.text.o .text 0x298
	$(PYTHON) tools/owned_sections.py $< build/us/error_formatted.text.o $@
	$(PYTHON) tools/provenance.py $< $@ include/error_formatters.h include/game_memory.h include/game_stdarg.h

RUNTIME_OBJECTS += build/us/error_formatted.o


# Audio playback setup and complete callback dispatch tables.
build/us/audio_backend_playback.o: src/game/audio/backend/playback.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_playback.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_backend_playback.raw.o build/us/audio_backend_playback.text.o .text 0x344
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_playback.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_backend_playback.o

build/us/audio_dispatch.o: src/game/audio/dispatch.c include/audio_engine_tables_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_dispatch.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_dispatch.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_dispatch.o

build/us/audio_backend_commands.o: src/game/audio/backend/commands.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_commands.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_commands.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_backend_commands.o

# Audio synthesis configuration and custom-effect delay conversion.
build/us/audio_synthesis_startup.o: src/game/audio/startup/synthesis.c include/audio_synthesis_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synthesis_startup.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_synthesis_startup.raw.o $@ .text 0x1f4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_synthesis_startup.o

build/us/audio_synthesis_storage.o: src/game/audio/startup/storage.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_synthesis_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synthesis_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_synthesis_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_synthesis_storage.o

build/us/audio_synthesis_rate_constant.o: src/game/audio/startup/rate_constant.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_synthesis_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synthesis_rate_constant.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_synthesis_rate_constant.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_synthesis_rate_constant.o

build/us/audio_synthesis_driver.o: src/game/audio/startup/driver.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_synthesis_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synthesis_driver.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_synthesis_driver.raw.o $@ .text 0x51c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_synthesis_driver.o

build/us/audio_synthesis_buffer_pointers.o: src/game/audio/startup/buffer_pointers.c include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synthesis_buffer_pointers.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_synthesis_buffer_pointers.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_synthesis_buffer_pointers.o

build/us/audio_synthesis_synth_state.o: src/game/audio/startup/synth_state.c include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_synthesis_synth_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_synthesis_synth_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_synthesis_synth_state.o


# SN64 bank loading and complete configuration/control storage.
build/us/audio_bank_load.o: src/game/audio/startup/bank_load.c include/audio_backend_internal.h include/audio_bank_layout_internal.h include/audio_callbacks.h include/audio_control.h include/audio_file_services_internal.h include/audio_host_internal.h include/audio_io.h include/audio_loader_internal.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_bank_load.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_bank_load.raw.o build/us/audio_bank_load.text.o .text 0x5f0
	$(PYTHON) tools/owned_sections.py $< build/us/audio_bank_load.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_bank_load.o

build/us/audio_bank_allocation_state.o: src/game/audio/startup/allocation_state.c include/audio_backend_internal.h include/audio_bank_layout_internal.h include/audio_callbacks.h include/audio_control.h include/audio_file_services_internal.h include/audio_host_internal.h include/audio_io.h include/audio_loader_internal.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_bank_allocation_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_bank_allocation_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_bank_allocation_state.o

build/us/audio_bank_loader_storage.o: src/game/audio/startup/loader_storage.c include/audio_backend_internal.h include/audio_bank_layout_internal.h include/audio_callbacks.h include/audio_control.h include/audio_file_services_internal.h include/audio_host_internal.h include/audio_io.h include/audio_loader_internal.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_bank_loader_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_bank_loader_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_bank_loader_storage.o

build/us/audio_bank_state.o: src/game/audio/startup/bank_state.c include/audio_backend_internal.h include/audio_bank_layout_internal.h include/audio_callbacks.h include/audio_control.h include/audio_file_services_internal.h include/audio_host_internal.h include/audio_io.h include/audio_loader_internal.h include/audio_patch_table_internal.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_bank_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_bank_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_bank_state.o

# Complete fatal/warning formatters and their measured stack storage.
build/us/error_fatal_format.o: src/game/diagnostics/fatal.c include/error_formatters.h include/error_message_storage_internal.h include/game_memory.h include/game_stdarg.h include/debug_output.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/error_fatal_format.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/error_fatal_format.raw.o $@ .text 0x1f4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/error_fatal_format.o

build/us/error_warning_format.o: src/game/diagnostics/warning.c include/error_formatters.h include/error_message_storage_internal.h include/game_memory.h include/game_stdarg.h include/debug_output.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/error_warning_format.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/error_warning_format.raw.o $@ .text 0x1d8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/error_warning_format.o


# Controller Pak directory menu and verified strings/storage.
build/us/pak_menu_directory.o: src/game/save_menus/pak_directory.c include/controller_input.h include/controller_pak_menu_internal.h include/controller_services.h include/destination_format.h include/game_memory.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/save_menu_legacy_internal.h include/scene_definition.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/trim_padding.py tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/static_menu_internal.h include/front_menu_internal.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_menu_directory.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/pak_menu_directory.raw.o $@ .text 0x254
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/pak_menu_directory.o

build/us/pak_directory_storage.o: src/game/save_menus/pak_directory_storage.c include/controller_pak_menu_internal.h $(IDO) Makefile tools/trim_padding.py tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_directory_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/pak_directory_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/pak_directory_storage.o

build/us/pak_directory_strings.o: src/game/save_menus/pak_directory_strings.c include/controller_pak_menu_internal.h $(IDO) Makefile tools/trim_padding.py tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/pak_directory_strings.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/pak_directory_strings.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/pak_directory_strings.o


# Boss update and retained aggregate initializers.
build/us/boss_update.o: src/game/actor_groups/boss_update.c include/actor.h include/actor_animation_state.h include/actor_behavior_internal.h include/actor_resource_5c_internal.h include/actor_resource_internal.h include/debug_output.h include/destination_format.h include/early_bonus_internal.h include/early_game_more.h include/early_game_state.h include/early_session_state.h include/frame.h include/game_memory.h include/graphics_state_internal.h include/heap.h include/object.h include/object_recovery.h include/pak_file.h include/rom_files.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/boss_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/boss_update.raw.o build/us/boss_update.text.o .text 0x29c
	$(PYTHON) tools/owned_sections.py $< build/us/boss_update.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/boss_update.o

# Random spawn position with the complete retail retry and spacing behavior.
build/us/actor_spawn_position.o: src/game/actor_spawn_position.c include/actor.h include/actor_motion_internal.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_spawn_position.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_spawn_position.raw.o $@ .text 0x2b8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_spawn_position.o

build/us/controller_poll.o: src/game/controller/poll.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_poll.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_poll.raw.o build/us/controller_poll.text.o .text 0x1a8
	$(PYTHON) tools/owned_sections.py $< build/us/controller_poll.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_poll.o

build/us/controller_legacy_poll.o: src/game/controller/legacy_poll.c include/controller_input.h include/controller_services.h include/scheduler.h include/sdk_controller.h include/sdk_pfs.h include/sdk_pfs_internal.h include/sdk_si.h include/sdk_time.h include/sdk_timers.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/controller_legacy_poll.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/controller_legacy_poll.raw.o build/us/controller_legacy_poll.text.o .text 0x198
	$(PYTHON) tools/owned_sections.py $< build/us/controller_legacy_poll.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/controller_legacy_poll.o


build/us/audio_seek_forward.o: src/game/audio/seek_forward.c include/audio_properties_internal.h include/audio_engine_tables_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_seek_forward.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_seek_forward.raw.o $@ .text 0x234
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_seek_restart.o: src/game/audio/seek_restart.c include/audio_properties_internal.h include/audio_engine_tables_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_seek_restart.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_seek_restart.raw.o $@ .text 0x234
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_seek_forward.o build/us/audio_seek_restart.o

build/us/audio_timing_tick.o: src/game/audio/timing_tick.c include/audio_host_internal.h include/audio_properties_internal.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_timing_tick.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/audio_timing_tick.raw.o $@ .text 0x84
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_sequence_tick.o: src/game/audio/sequence_tick.c src/game/audio_stream_variable_read.c include/audio_host_internal.h include/audio_properties_internal.h include/audio_engine_tables_internal.h include/audio_property_pipeline_internal.h $(IDO) Makefile tools/partition_text.py tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_sequence_tick.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_sequence_tick.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) src/game/audio_stream_variable_read.c tools/partition_text.py

RUNTIME_OBJECTS += build/us/audio_timing_tick.o build/us/audio_sequence_tick.o

build/us/audio_backend_voice_release_all.o: src/game/audio/backend/voice_release_all.c src/game/audio_voice_capture_append.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/partition_text.py tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_voice_release_all.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_voice_release_all.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) src/game/audio_voice_capture_append.c tools/partition_text.py

RUNTIME_OBJECTS += build/us/audio_backend_voice_release_all.o

build/us/audio_backend_pitch_command.o: src/game/audio/backend/pitch_command.c src/game/audio_pitch_scale.c include/audio_backend_internal.h include/audio_callbacks.h include/audio_control.h include/audio_io.h include/audio_properties_internal.h include/audio_runtime.h include/audio_voice_capture_internal.h include/scheduler.h include/scheduler_runtime.h include/scheduler_task.h include/sdk_audio.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/partition_text.py tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_backend_pitch_command.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_backend_pitch_command.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^) src/game/audio_pitch_scale.c tools/partition_text.py

RUNTIME_OBJECTS += build/us/audio_backend_pitch_command.o

build/us/audio_pitch_factors.o: src/game/audio/pitch_factors.c $(IDO) Makefile tools/partition_text.py tools/owned_sections.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_pitch_factors.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_pitch_factors.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/audio_pitch_factors.o



build/us/compression_huffman.o: src/game/compression/huffman.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_huffman.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_huffman.raw.o $@ .text 0x7c4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_codes.o: src/game/compression/codes.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_codes.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_codes.raw.o $@ .text 0x7e4
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/compression_dynamic.o: src/game/compression/dynamic.c include/audio_io.h include/compression_internal.h include/scheduler.h include/sdk_device_manager.h include/sdk_pi_device.h include/sdk_pi_dma.h include/sdk_pi_transfer.h include/sdk_pi_word.h include/sdk_time.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/compression_dynamic.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/compression_dynamic.raw.o $@ .text 0x83c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/compression_huffman.o build/us/compression_codes.o build/us/compression_dynamic.o

build/us/actor_damage.o: src/game/collisions/damage.c include/actor_damage_internal.h include/actor_behavior_internal.h include/actor.h include/actor_position_pairs.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_damage.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_damage.raw.o $@ .text 0x11c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_damage.o

build/us/actor_collision_separation.o: src/game/collisions/separation.c include/actor_collision_separation_internal.h include/actor_behavior_internal.h include/actor_motion_internal.h include/actor.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_separation.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_separation.raw.o $@ .text 0x2dc
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_collision_separation.o

build/us/renderer_color_gradient.o: src/game/renderer_surfaces/color_gradient.c include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_color_gradient.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_color_gradient.raw.o $@ .text 0x224
	$(PYTHON) tools/provenance.py $< $@ include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h include/palette.h

RUNTIME_OBJECTS += build/us/renderer_color_gradient.o

build/us/renderer_gradient_extents.o: src/game/renderer_surfaces/gradient_extents.c include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_gradient_extents.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_gradient_extents.raw.o $@ .data 0x8
	$(PYTHON) tools/provenance.py $< $@ include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h include/palette.h

RUNTIME_OBJECTS += build/us/renderer_gradient_extents.o

build/us/renderer_border_gradient.o: src/game/renderer_surfaces/border_gradient.c include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_border_gradient.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_border_gradient.raw.o $@ .text 0x344
	$(PYTHON) tools/provenance.py $< $@ include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h include/palette.h

RUNTIME_OBJECTS += build/us/renderer_border_gradient.o

build/us/actor_collision_kind_response.o: src/game/collisions/kind_response.c include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_collision_kind_response.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/actor_collision_kind_response.raw.o $@ .text 0x2cc
	$(PYTHON) tools/provenance.py $< $@ include/actor.h include/actor_behavior_internal.h include/actor_collision_services.h include/early_game_state.h include/game_memory.h include/object.h include/object_recovery.h include/scalar_math.h include/text.h

RUNTIME_OBJECTS += build/us/actor_collision_kind_response.o

build/us/palette_transition_allocate.o: src/game/palette_effects/transition_allocate.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_transition_allocate.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette_transition_allocate.raw.o $@ .text 0xe8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_transition_allocate.o

build/us/palette_command_storage.o: src/game/palette_effects/command_storage.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_command_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/palette_command_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_command_storage.o

build/us/palette_transition_order.o: src/game/palette_effects/transition_order.c include/palette.h include/palette_effects.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_transition_order.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/palette_transition_order.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_transition_order.o

build/us/renderer_color_wave_storage.o: src/game/renderer_surfaces/color_wave_storage.c include/renderer_color_wave_internal.h include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/palette.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_color_wave_storage.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_color_wave_storage.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ include/renderer_color_wave_internal.h include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h include/palette.h

RUNTIME_OBJECTS += build/us/renderer_color_wave_storage.o

build/us/renderer_background_dispatch.o: src/game/renderer_surfaces/background_dispatch.c include/fixed_math.h include/sdk_matrix.h include/scalar_math.h include/game_memory.h include/palette.h include/palette_effects.h include/renderer_color_wave_internal.h include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h include/scene_background_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_background_dispatch.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_background_dispatch.raw.o build/us/renderer_background_dispatch.owned.o
	$(PYTHON) tools/trim_padding.py build/us/renderer_background_dispatch.owned.o $@ .text 0x424
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_background_dispatch.o

build/us/renderer_background_color_mode.o: src/game/renderer_surfaces/background_color_mode.c include/fixed_math.h include/sdk_matrix.h include/scalar_math.h include/game_memory.h include/palette.h include/palette_effects.h include/renderer_color_wave_internal.h include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h include/scene_background_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_background_color_mode.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_background_color_mode.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_background_color_mode.o

build/us/renderer_material_cache_reset.o: src/game/renderer_resources/material_reset.c include/renderer_material_internal.h include/graphics_state_internal.h include/resource_bridge_internal.h include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/object_runtime.h include/text.h include/object.h include/game_memory.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_cache_reset.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_cache_reset.raw.o $@ .text 0x778
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_material_cache_reset.o

build/us/palette_transition_update.o: src/game/palette_effects/transition_update.c include/palette.h include/palette_effects.h include/game_memory.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_transition_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/palette_transition_update.raw.o $@ .text 0x4b0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_transition_update.o


build/us/renderer_rotating_rings.o: src/game/renderer_surfaces/rotating_rings.c include/renderer_color_wave_internal.h include/renderer_color_gradient_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h include/fixed_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_rotating_rings.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_rotating_rings.raw.o $@ .text 0x238
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_rotating_rings.o

.PHONY: check-renderer-rotating-rings
check-renderer-rotating-rings:
	$(PYTHON) tools/check_renderer_rotating_rings.py

.PHONY: audit-object-projection
audit-object-projection:
	$(PYTHON) tools/check_object_projection.py

.PHONY: audit-inverse-camera
audit-inverse-camera:
	$(PYTHON) tools/check_inverse_camera.py


build/us/renderer_depth_blend_origin.o: src/game/renderer_setup/depth_blend_origin.c include/model_geometry_internal.h include/renderer_primitives_internal.h include/renderer_geometry_internal.h include/graphics_state_internal.h include/frame.h include/heap.h include/rom_files.h include/debug_output.h include/fixed_geometry.h include/fixed_math.h include/sdk_matrix.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json include/palette.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_depth_blend_origin.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_depth_blend_origin.raw.o $@ .data 0x8
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_depth_blend_origin.o

build/us/renderer_material_presets.o: src/game/renderer_setup/material_presets.c include/renderer_setup_internal.h include/frame.h include/sdk_camera.h include/sdk_math.h include/sdk_matrix.h include/sdk_float_math.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_material_presets.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_material_presets.raw.o $@ .rodata 0x1b0
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_material_presets.o


build/us/palette_color_tables.o: src/game/palette_effects/color_tables.c include/palette.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/palette_color_tables.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/palette_color_tables.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/palette_color_tables.o

build/us/game_number_digits.o: src/game/formatting/digits.c include/game_memory.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_number_digits.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/game_number_digits.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/game_number_digits.o

build/us/renderer_fatal_message.o: src/game/renderer_diagnostics/fatal_message.c include/debug_output.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_fatal_message.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_fatal_message.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_fatal_message.o

build/us/early_input_sequence_define.o: src/game/input_sequences/define.c include/controller_input.h include/destination_format.h include/early_input_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/early_input_sequence_define.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/early_input_sequence_define.raw.o $@ .text 0x11C
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/early_input_sequence_define.o

.PHONY: check-input-sequence-definition
check-input-sequence-definition:
	$(PYTHON) tools/check_input_sequence_definition.py


build/us/input_sequence_limit_message.o: src/game/input_sequences/limit_message.c include/controller_input.h include/destination_format.h include/early_input_internal.h include/pak_file.h include/save_game.h include/scene_definition.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/input_sequence_limit_message.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/input_sequence_limit_message.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/input_sequence_limit_message.o



build/us/menu_static_confirmation_labels.o: src/game/save_menus/static_confirmation/labels.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h include/static_menu_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_static_confirmation_labels.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_static_confirmation_labels.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_static_confirmation_labels.o

build/us/menu_static_pause_labels.o: src/game/save_menus/static_pause/labels.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h include/static_menu_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_static_pause_labels.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_static_pause_labels.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_static_pause_labels.o

build/us/menu_static_confirmation_page.o: src/game/save_menus/static_confirmation/page.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h include/static_menu_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_static_confirmation_page.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_static_confirmation_page.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_static_confirmation_page.o

build/us/menu_static_pause_page.o: src/game/save_menus/static_pause/page.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h include/static_menu_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_static_pause_page.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_static_pause_page.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_static_pause_page.o

build/us/menu_static_confirmation_text.o: src/game/save_menus/static_confirmation/text.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h include/static_menu_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_static_confirmation_text.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_static_confirmation_text.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_static_confirmation_text.o

build/us/menu_static_pause_text.o: src/game/save_menus/static_pause/text.c include/destination_format.h include/menu_label_internal.h include/pak_file.h include/save_game.h include/scene_definition.h include/static_menu_internal.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_static_pause_text.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_static_pause_text.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_static_pause_text.o

.PHONY: check-static-menu-records
check-static-menu-records:
	$(PYTHON) tools/check_static_menu_records.py

build/us/menu_display.o: src/game/save_menus/display/submit.c include/actor.h include/destination_format.h include/game_memory.h include/menu_display_internal.h include/menu_label_internal.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/static_menu_internal.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/front_menu_internal.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_display.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/menu_display.raw.o $@ .text 1168
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_display.o

build/us/menu_display_choices.o: src/game/save_menus/display/choices.c include/actor.h include/destination_format.h include/game_memory.h include/menu_display_internal.h include/menu_label_internal.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/static_menu_internal.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/front_menu_internal.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_display_choices.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_display_choices.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_display_choices.o

build/us/menu_display_text.o: src/game/save_menus/display/text.c include/actor.h include/destination_format.h include/game_memory.h include/menu_display_internal.h include/menu_label_internal.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/static_menu_internal.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/front_menu_internal.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_display_text.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_display_text.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_display_text.o

build/us/menu_display_never.o: src/game/save_menus/display/never.c include/actor.h include/destination_format.h include/game_memory.h include/menu_display_internal.h include/menu_label_internal.h include/object.h include/object_helpers.h include/pak_file.h include/save_game.h include/save_menu_nav_internal.h include/scene_definition.h include/static_menu_internal.h include/text.h $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json include/front_menu_internal.h
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_display_never.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_display_never.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_display_never.o


build/us/menu_control_setup_choices.o: src/game/save_menus/control_setup/choices.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_control_setup_choices.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_control_setup_choices.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_control_setup_choices.o

build/us/menu_control_setup_labels.o: src/game/save_menus/control_setup/labels.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_control_setup_labels.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_control_setup_labels.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_control_setup_labels.o

build/us/menu_control_setup_page.o: src/game/save_menus/control_setup/page.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_control_setup_page.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_control_setup_page.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_control_setup_page.o

build/us/menu_control_setup_text.o: src/game/save_menus/control_setup/text.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_control_setup_text.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_control_setup_text.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_control_setup_text.o

.PHONY: check-control-setup-records
check-control-setup-records:
	$(PYTHON) tools/check_control_setup_records.py

.PHONY: check-platform-empty
check-platform-empty:
	$(PYTHON) tools/check_platform_empty.py


build/us/menu_pak_confirmation_labels.o: src/game/save_menus/pak_confirmation/labels.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_pak_confirmation_labels.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_pak_confirmation_labels.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_pak_confirmation_labels.o

build/us/menu_pak_confirmation_page.o: src/game/save_menus/pak_confirmation/page.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_pak_confirmation_page.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_pak_confirmation_page.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_pak_confirmation_page.o

build/us/menu_pak_confirmation_text.o: src/game/save_menus/pak_confirmation/text.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_pak_confirmation_text.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_pak_confirmation_text.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_pak_confirmation_text.o

build/us/menu_pak_confirmation_title.o: src/game/save_menus/pak_confirmation/title.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_pak_confirmation_title.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_pak_confirmation_title.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_pak_confirmation_title.o

build/us/menu_pak_confirmation_format.o: src/game/save_menus/pak_confirmation/format.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_pak_confirmation_format.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_pak_confirmation_format.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_pak_confirmation_format.o

.PHONY: check-pak-confirmation-records
check-pak-confirmation-records:
	$(PYTHON) tools/check_pak_confirmation_records.py

build/us/renderer_mesh_commands.o: src/game/renderer_primitives/mesh_commands.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/renderer_mesh_commands.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/renderer_mesh_commands.raw.o build/us/renderer_mesh_commands.text.o .text 0x538
	$(PYTHON) tools/owned_sections.py $< build/us/renderer_mesh_commands.text.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/renderer_mesh_commands.o

.PHONY: check-mesh-commands
check-mesh-commands:
	$(PYTHON) tools/check_mesh_commands.py

build/us/menu_front_load_labels.o: src/game/save_menus/front_pages/load_labels.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_front_load_labels.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_front_load_labels.raw.o $@
	$(PYTHON) tools/provenance.py $< build/us/menu_front_load_labels.o $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_front_load_labels.o

build/us/menu_front_load_page.o: src/game/save_menus/front_pages/load_page.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_front_load_page.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_front_load_page.raw.o $@
	$(PYTHON) tools/provenance.py $< build/us/menu_front_load_page.o $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_front_load_page.o

build/us/menu_front_main_labels.o: src/game/save_menus/front_pages/main_labels.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_front_main_labels.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_front_main_labels.raw.o $@
	$(PYTHON) tools/provenance.py $< build/us/menu_front_main_labels.o $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_front_main_labels.o

build/us/menu_front_main_page.o: src/game/save_menus/front_pages/main_page.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_front_main_page.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_front_main_page.raw.o $@
	$(PYTHON) tools/provenance.py $< build/us/menu_front_main_page.o $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_front_main_page.o

build/us/menu_front_audio_labels.o: src/game/save_menus/front_pages/audio_labels.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_front_audio_labels.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_front_audio_labels.raw.o $@
	$(PYTHON) tools/provenance.py $< build/us/menu_front_audio_labels.o $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_front_audio_labels.o

build/us/menu_front_audio_page.o: src/game/save_menus/front_pages/audio_page.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_front_audio_page.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_front_audio_page.raw.o $@
	$(PYTHON) tools/provenance.py $< build/us/menu_front_audio_page.o $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_front_audio_page.o

build/us/menu_front_text.o: src/game/save_menus/front_pages/text.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json config/owned_sections.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/menu_front_text.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/menu_front_text.raw.o $@
	$(PYTHON) tools/provenance.py $< build/us/menu_front_text.o $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/menu_front_text.o

.PHONY: check-front-menu-records
check-front-menu-records:
	$(PYTHON) tools/check_front_menu_records.py

build/us/text_records.o: src/game/text_records.c include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_records.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/text_records.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_width_lowercase.o: src/game/text_widths/lowercase.c include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_width_lowercase.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/text_width_lowercase.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/text_width_digits.o: src/game/text_widths/digits.c include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/text_width_digits.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/text_width_digits.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/text_records.o build/us/text_width_lowercase.o build/us/text_width_digits.o

.PHONY: audit-text-storage
audit-text-storage:
	$(PYTHON) tools/check_text_storage.py

build/us/actor_resources_primary.o: src/game/actor_resources/primary.c include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resources_primary.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_resources_primary.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resources_enemies.o: src/game/actor_resources/enemies.c include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resources_enemies.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_resources_enemies.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resources_child_variants.o: src/game/actor_resources/child_variants.c include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resources_child_variants.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_resources_child_variants.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resources_secondary.o: src/game/actor_resources/secondary.c include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resources_secondary.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_resources_secondary.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resources_small.o: src/game/actor_resources/small.c include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resources_small.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_resources_small.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resources_player.o: src/game/actor_resources/player.c include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resources_player.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_resources_player.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/actor_resources_early.o: src/game/actor_resources/early.c include/actor_resource_internal.h include/actor_resource_5c_internal.h include/actor.h include/text.h include/game_memory.h include/object.h $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/actor_resources_early.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/actor_resources_early.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

RUNTIME_OBJECTS += build/us/actor_resources_primary.o build/us/actor_resources_enemies.o build/us/actor_resources_child_variants.o build/us/actor_resources_secondary.o build/us/actor_resources_small.o build/us/actor_resources_player.o build/us/actor_resources_early.o


RUNTIME_OBJECTS += build/us/save_storage_players.o build/us/save_storage_configuration.o build/us/save_storage_image.o

RUNTIME_OBJECTS += build/us/script_storage_files.o build/us/script_storage_strings.o build/us/script_storage_scenes.o

RUNTIME_OBJECTS += build/us/movie_storage_tracks.o build/us/movie_storage_configuration.o

RUNTIME_OBJECTS += build/us/audio_startup_temporary_allocation.o build/us/audio_startup_task_records.o build/us/audio_startup_scheduler_records.o build/us/audio_startup_synthesis_heap.o build/us/audio_startup_thread_stack.o build/us/audio_startup_message_queues.o build/us/audio_startup_thread_state.o build/us/audio_startup_bank_cursor.o build/us/audio_startup_heap_state.o build/us/audio_startup_generation_mode.o

build/us/robotron64.elf: build/us/fallback.o build/us/text.o build/us/text_wrapper.o build/us/text_edit.o build/us/text_properties.o build/us/text_conversion.o build/us/object_transforms.o build/us/entry.o build/us/startup.o build/us/scheduler.o $(RUNTIME_OBJECTS) linker_scripts/us.ld config/startup_symbols.ld config/runtime_symbols.ld
	$(CROSS)ld -EB -T linker_scripts/us.ld -Map build/us/robotron64.map -o $@

build/us/robotron64.z64: build/us/robotron64.elf
	$(CROSS)objcopy -O binary $< $@

verify: all
	$(PYTHON) tools/verify.py "$(BASEROM)" build/us/robotron64.z64

progress: verify
	$(PYTHON) tools/progress.py

remaining:
	$(PYTHON) tools/remaining.py

test:
	$(PYTHON) -m unittest discover -s tests -v
	$(PYTHON) tools/manifest.py
	$(PYTHON) tools/remaining.py --limit 0

analysis-setup:
	$(PYTHON) -m venv .venv
	.venv/bin/python -m pip install -r requirements-analysis.txt

analyze:
	.venv/bin/python tools/analyze.py

clean:
	$(PYTHON) -c 'import shutil; shutil.rmtree("build", ignore_errors=True)'

.PHONY: check-menu-display
check-menu-display:
	$(PYTHON) tools/check_menu_display.py

.PHONY: audit-actor-resource-storage
audit-actor-resource-storage: toolchain
	$(PYTHON) tools/check_actor_resource_storage.py

build/us/save_storage_players.o: src/game/save_storage/players.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_storage_players.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/save_storage_players.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_storage_configuration.o: src/game/save_storage/configuration.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_storage_configuration.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/save_storage_configuration.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/save_storage_image.o: src/game/save_storage/image.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/save_storage_image.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/save_storage_image.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

.PHONY: audit-save-state-storage
audit-save-state-storage: toolchain
	$(PYTHON) tools/check_save_state_storage.py

build/us/script_storage_files.o: src/game/script_storage/files.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_storage_files.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/script_storage_files.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_storage_strings.o: src/game/script_storage/strings.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_storage_strings.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/script_storage_strings.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/script_storage_scenes.o: src/game/script_storage/scenes.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/script_storage_scenes.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/script_storage_scenes.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

.PHONY: audit-script-resource-storage
audit-script-resource-storage: toolchain
	$(PYTHON) tools/check_script_resource_storage.py

build/us/movie_storage_tracks.o: src/game/movie_storage/tracks.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_storage_tracks.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/movie_storage_tracks.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/movie_storage_configuration.o: src/game/movie_storage/configuration.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_storage_configuration.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/movie_storage_configuration.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

.PHONY: audit-movie-storage
audit-movie-storage: toolchain
	$(PYTHON) tools/check_movie_storage.py

build/us/movie_update.o: src/game/movie_update.c include/actor.h include/game_memory.h include/movie.h include/object.h include/palette.h include/palette_effects.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/movie_update.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/movie_update.raw.o $@ .text 0x718
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

.PHONY: audit-movie-playback
audit-movie-playback: toolchain
	$(PYTHON) tools/check_movie_playback.py --mutations

build/us/audio_startup_temporary_allocation.o: src/game/audio/startup/temporary_allocation.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_temporary_allocation.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_temporary_allocation.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_task_records.o: src/game/audio/startup/task_records.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_task_records.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_task_records.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_scheduler_records.o: src/game/audio/startup/scheduler_records.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_scheduler_records.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_scheduler_records.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_synthesis_heap.o: src/game/audio/startup/synthesis_heap.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_synthesis_heap.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_synthesis_heap.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_thread_stack.o: src/game/audio/startup/thread_stack.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_thread_stack.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_thread_stack.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_message_queues.o: src/game/audio/startup/message_queues.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_message_queues.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_message_queues.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_thread_state.o: src/game/audio/startup/thread_state.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_thread_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_thread_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_bank_cursor.o: src/game/audio/startup/bank_cursor.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_bank_cursor.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_bank_cursor.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_heap_state.o: src/game/audio/startup/heap_state.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_heap_state.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_heap_state.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

build/us/audio_startup_generation_mode.o: src/game/audio/startup/generation_mode.c $(wildcard include/*.h) $(IDO) Makefile tools/owned_sections.py config/owned_sections.json tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	@mkdir -p build/us
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/audio_startup_generation_mode.raw.o $<
	$(PYTHON) tools/owned_sections.py $< build/us/audio_startup_generation_mode.raw.o $@
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

.PHONY: audit-audio-startup-storage
audit-audio-startup-storage: toolchain
	$(PYTHON) tools/check_audio_startup_storage.py

build/us/game_hud_state.o: src/game/game_hud_state.c include/actor.h include/actor_behavior_internal.h include/destination_format.h include/early_game_state.h include/game_hud_state.h include/game_memory.h include/object.h include/object_recovery.h include/pak_file.h include/save_game.h include/scalar_math.h include/scene_definition.h include/text.h $(IDO) Makefile tools/trim_padding.py tools/provenance.py tools/compiler.py tools/toolchain.py config/toolchain_files.json
	mkdir -p $(@D)
	$(PYTHON) tools/compiler.py --cc $(IDO) -o build/us/game_hud_state.raw.o $<
	$(PYTHON) tools/trim_padding.py build/us/game_hud_state.raw.o $@ .text 0x20c
	$(PYTHON) tools/provenance.py $< $@ $(filter include/%,$^)

.PHONY: audit-game-hud-state
audit-game-hud-state: toolchain
	$(PYTHON) tools/check_game_hud_state.py
