D_8008FDC8 = 0x8008FDC8;
D_8009D118 = 0x8009D118;
D_8009B0E0 = 0x8009B0E0;
D_800B4B00 = 0x800B4B00;
D_80097350 = 0x80097350;
D_80073574 = 0x80073574;
D_80073588 = 0x80073588;
D_800AD1B8 = 0x800AD1B8;
func_80031ECC = 0x80031ECC;
D_FLT_800C8DF8 = 0x800C8DF8;
D_FLT_800C8DF4 = 0x800C8DF4;
D_800781D0 = 0x800781D0;
D_800BF120 = 0x800BF120;
D_800BF2B0 = 0x800BF2B0;
D_8009EF9C = 0x8009EF9C;
D_8009EF98 = 0x8009EF98;
D_8009EFAC = 0x8009EFAC;
D_80094064 = 0x80094064;
D_80094054 = 0x80094054;
D_8009404C = 0x8009404C;
D_8008FB70 = 0x8008FB70;
D_80073164 = 0x80073164;
D_800922FC = 0x800922FC;
D_800922DC = 0x800922DC;
D_800922C8 = 0x800922C8;
D_800922BC = 0x800922BC;
D_800922AC = 0x800922AC;
D_800BA7A0 = 0x800BA7A0;
D_80075FD0 = 0x80075FD0;
D_80075FFC = 0x80075FFC;
D_8009E57C = 0x8009E57C;
D_800925E4 = 0x800925E4;
D_80076014 = 0x80076014;
D_800B6FEC = 0x800B6FEC;
func_8000177C = 0x8000177C;
D_800925E8 = 0x800925E8;
D_8009EFB0 = 0x8009EFB0;
D_800761AC = 0x800761AC;
D_800AD19C = 0x800AD19C;
func_800077F4 = 0x800077F4;
D_800B2480 = 0x800B2480;
OUTPUT_ARCH(mips)
OUTPUT_FORMAT("elf32-tradbigmips")
ENTRY(_start)
INCLUDE config/startup_symbols.ld
INCLUDE config/runtime_symbols.ld
D_80072B40 = 0x80072B40;
D_80072BA8 = 0x80072BA8;
D_800B6FF8 = 0x800B6FF8;
__bss_start = 0x80097290;
__bss_size = 0x1003B0;
__bss_end = __bss_start + __bss_size;
__initial_stack_top = 0x8013A280;

D_800B1BE8 = 0x800B1BE8;
D_8008F620 = 0x8008F620;
func_8001C0D0 = 0x8001C0D0;

D_8008F64C = 0x8008F64C;


D_8009EFA4 = 0x8009EFA4;

func_80000F48 = 0x80000F48;


D_FLT_80094C20 = 0x80094C20;
D_FLT_80094C24 = 0x80094C24;
D_FLT_80094C28 = 0x80094C28;

D_DBL_80094C30 = 0x80094C30;
D_DBL_80094C38 = 0x80094C38;
D_DBL_80094C40 = 0x80094C40;

SECTIONS
{
    .header 0 : AT(0) { build/us/fallback.o(.rom_header) }
    .ipl3 0x40 : AT(0x40) { build/us/fallback.o(.rom_ipl3) }
    .entry 0x80000400 : AT(0x1000) {
        build/us/entry.o(.text)
    }
    .text_start 0x80000450 : AT(0x1050) { build/us/text.o(.text) }
    .text_replacement 0x80000F48 : AT(0x1B48) { build/us/fallback.o(.rom_text_replacement) }
    .text_wrapper 0x800011AC : AT(0x1DAC) SUBALIGN(4) { build/us/text_wrapper.o(.text) }
    .text_edit 0x80001270 : AT(0x1E70) { build/us/text_edit.o(.text) }
    .text_properties 0x800013D0 : AT(0x1FD0) { build/us/text_properties.o(.text) }
    .text_conversion 0x800016D8 : AT(0x22D8) SUBALIGN(4) { build/us/text_conversion.o(.text) }
    .endgame_237c_3970 0x8000177C : AT(0x237C) { build/us/fallback.o(.rom_endgame_237c_3970) }
    .movie_string_position_submit 0x80002D70 : AT(0x3970) SUBALIGN(4) { build/us/movie_string_position_submit.o(.text) }
    .movie_reset 0x80002EE0 : AT(0x3AE0) SUBALIGN(4) { build/us/movie_reset.o(.text) }
    .movie_parameters 0x80002F28 : AT(0x3B28) SUBALIGN(4) { build/us/movie_parameters.o(.text) }
    .movie_commands 0x80003040 : AT(0x3C40) SUBALIGN(4) { build/us/movie_commands.o(.text) }
    .movie_channels 0x800037F8 : AT(0x43F8) SUBALIGN(4) { build/us/movie_channels.o(.text) }
    .movie_files 0x80003A7C : AT(0x467C) SUBALIGN(4) { build/us/movie_files.o(.text) }
    .movie_track_release 0x80003D74 : AT(0x4974) SUBALIGN(4) { build/us/movie_track_release.o(.text) }
    .movie_camera 0x80003ECC : AT(0x4ACC) SUBALIGN(4) { build/us/movie_camera.o(.text) }
    .movie_sample 0x80004098 : AT(0x4C98) SUBALIGN(4) { build/us/movie_sample.o(.text) }
    .movie_actor 0x80004258 : AT(0x4E58) SUBALIGN(4) { build/us/movie_actor.o(.text) }
    .movie_callback 0x8000440C : AT(0x500C) SUBALIGN(4) { build/us/movie_callback.o(.text) }
    .movie_prepare 0x800044AC : AT(0x50AC) SUBALIGN(4) { build/us/movie_prepare.o(.text) }
    .movie_start 0x800045E4 : AT(0x51E4) SUBALIGN(4) { build/us/movie_start.o(.text) }
    .cpu_after_movie_start 0x80004C3C : AT(0x583C) { build/us/fallback.o(.rom_cpu_after_movie_start) }
    .movie_status 0x80005354 : AT(0x5F54) SUBALIGN(4) { build/us/movie_status.o(.text) }
    .movie_cleanup 0x8000544C : AT(0x604C) SUBALIGN(4) { build/us/movie_cleanup.o(.text) }
    .actor_effect_draw 0x80005560 : AT(0x6160) SUBALIGN(4) { build/us/actor_effect_draw.o(.text) }
    .renderer_texture_index_draw 0x80005814 : AT(0x6414) SUBALIGN(4) { build/us/renderer_texture_index_draw.o(.text) }
    .endgame_64f0_69ec 0x800058F0 : AT(0x64F0) { build/us/fallback.o(.rom_endgame_64f0_69ec) }
    .early_signature_gate 0x80005DEC : AT(0x69EC) SUBALIGN(4) { build/us/early_signature_gate.o(.text) }
    .endgame_6a80_ab58 0x80005E80 : AT(0x6A80) { build/us/fallback.o(.rom_endgame_6a80_ab58) }
    .early_actor_tick 0x80009F58 : AT(0xAB58) SUBALIGN(4) { build/us/early_actor_tick.o(.text) }
    .early_effect_spawn 0x80009F90 : AT(0xAB90) SUBALIGN(4) { build/us/early_effect_spawn.o(.text) }
    .early_boundary_actor_spawn 0x8000A074 : AT(0xAC74) SUBALIGN(4) { build/us/early_boundary_actor_spawn.o(.text) }
    .early_render_color 0x8000A200 : AT(0xAE00) SUBALIGN(4) { build/us/early_render_color.o(.text) }
    .random_between 0x8000A21C : AT(0xAE1C) SUBALIGN(4) { build/us/random_between.o(.text) }
    .actor_relative_geometry 0x8000A2E0 : AT(0xAEE0) SUBALIGN(4) { build/us/actor_relative_geometry.o(.text) }
    .render_stream_fallback_af88_bc6c 0x8000A388 : AT(0xAF88) { build/us/fallback.o(.rom_render_stream_fallback_af88_bc6c) }
    .early_render_quad 0x8000B06C : AT(0xBC6C) SUBALIGN(4) { build/us/early_render_quad.o(.text) }
    .render_stream_fallback_bde4_c564 0x8000B1E4 : AT(0xBDE4) { build/us/fallback.o(.rom_render_stream_fallback_bde4_c564) }
    .early_render_presets 0x8000B964 : AT(0xC564) SUBALIGN(4) { build/us/early_render_presets.o(.text) }
    .cpu_after_early_render_presets 0x8000B9D4 : AT(0xC5D4) { build/us/fallback.o(.rom_cpu_after_early_render_presets) }
    .early_render_dispatch 0x8000BE80 : AT(0xCA80) SUBALIGN(4) { build/us/early_render_dispatch.o(.text) }
    .endgame_cac0_d950 0x8000BEC0 : AT(0xCAC0) { build/us/fallback.o(.rom_endgame_cac0_d950) }
    .early_relative_position 0x8000CD50 : AT(0xD950) SUBALIGN(4) { build/us/early_relative_position.o(.text) }
    .early_render_handler_select 0x8000CE34 : AT(0xDA34) SUBALIGN(4) { build/us/early_render_handler_select.o(.text) }
    .endgame_dab8_dac0 0x8000CEB8 : AT(0xDAB8) { build/us/fallback.o(.rom_endgame_dab8_dac0) }
    .actor_dynamic_group_allocate 0x8000CEC0 : AT(0xDAC0) SUBALIGN(4) { build/us/actor_dynamic_group_allocate.o(.text) }
    .early_pool_entry_clear 0x8000CF70 : AT(0xDB70) SUBALIGN(4) { build/us/early_pool_entry_clear.o(.text) }
    .actor_dynamic_first_append 0x8000CF9C : AT(0xDB9C) SUBALIGN(4) { build/us/actor_dynamic_first_append.o(.text) }
    .early_pool_count 0x8000D034 : AT(0xDC34) SUBALIGN(4) { build/us/early_pool_count.o(.text) }
    .actor_dynamic_point_append 0x8000D090 : AT(0xDC90) SUBALIGN(4) { build/us/actor_dynamic_point_append.o(.text) }
    .actor_dynamic_pair_append 0x8000D1FC : AT(0xDDFC) SUBALIGN(4) { build/us/actor_dynamic_pair_append.o(.text) }
    .early_pool_index 0x8000D2B4 : AT(0xDEB4) SUBALIGN(4) { build/us/early_pool_index.o(.text) }
    .actor_dynamic_parameter_append 0x8000D2D4 : AT(0xDED4) SUBALIGN(4) { build/us/actor_dynamic_parameter_append.o(.text) }
    .early_pool_initialize 0x8000D38C : AT(0xDF8C) SUBALIGN(4) { build/us/early_pool_initialize.o(.text) }
    .early_pool_tick 0x8000D3E8 : AT(0xDFE8) SUBALIGN(4) { build/us/early_pool_tick.o(.text) }
    .early_pool_scene_reset 0x8000D4F8 : AT(0xE0F8) SUBALIGN(4) { build/us/early_pool_scene_reset.o(.text) }
    .early_byte_clear 0x8000D614 : AT(0xE214) SUBALIGN(4) { build/us/early_byte_clear.o(.text) }
    .cpu_after_early_byte_clear 0x8000D620 : AT(0xE220) { build/us/fallback.o(.rom_cpu_after_early_byte_clear) }
    .early_angle_normalize 0x8000DF14 : AT(0xEB14) SUBALIGN(4) { build/us/early_angle_normalize.o(.text) }
    .early_angle_step 0x8000DF30 : AT(0xEB30) SUBALIGN(4) { build/us/early_angle_step.o(.text) }
    .early_coordinate_rescale 0x8000DFB0 : AT(0xEBB0) SUBALIGN(4) { build/us/early_coordinate_rescale.o(.text) }
    .early_actor_follow_owner 0x8000DFEC : AT(0xEBEC) SUBALIGN(4) { build/us/early_actor_follow_owner.o(.text) }
    .actor_group_setup 0x8000E108 : AT(0xED08) SUBALIGN(4) { build/us/actor_group_setup.o(.text) }
    .early_transition_arrays_clear 0x8000E328 : AT(0xEF28) SUBALIGN(4) { build/us/early_transition_arrays_clear.o(.text) }
    .early_parameter_schedule 0x8000E3B4 : AT(0xEFB4) SUBALIGN(4) { build/us/early_parameter_schedule.o(.text) }
    .early_parameter_slot_tick 0x8000E4F0 : AT(0xF0F0) SUBALIGN(4) { build/us/early_parameter_slot_tick.o(.text) }
    .early_actor_scale_decay 0x8000E5C8 : AT(0xF1C8) SUBALIGN(4) { build/us/early_actor_scale_decay.o(.text) }
    .early_actor_counter_decrement 0x8000E6F0 : AT(0xF2F0) SUBALIGN(4) { build/us/early_actor_counter_decrement.o(.text) }
    .endgame_f320_f6e4 0x8000E720 : AT(0xF320) { build/us/fallback.o(.rom_endgame_f320_f6e4) }
    .early_actor_vector_clear 0x8000EAE4 : AT(0xF6E4) SUBALIGN(4) { build/us/early_actor_vector_clear.o(.text) }
    .early_parameter_complete 0x8000EAF8 : AT(0xF6F8) SUBALIGN(4) { build/us/early_parameter_complete.o(.text) }
    .endgame_f828_f830 0x8000EC28 : AT(0xF828) { build/us/fallback.o(.rom_endgame_f828_f830) }
    .early_resource_arguments 0x8000EC30 : AT(0xF830) SUBALIGN(4) { build/us/early_resource_arguments.o(.text) }
    .early_global_reset 0x8000ECD0 : AT(0xF8D0) SUBALIGN(4) { build/us/early_global_reset.o(.text) }
    .early_animation_callback 0x8000ECE4 : AT(0xF8E4) SUBALIGN(4) { build/us/early_animation_callback.o(.text) }
    .early_session_animation 0x8000EDE0 : AT(0xF9E0) SUBALIGN(4) { build/us/early_session_animation.o(.text) }
    .early_scene_animation_advance 0x8000EE48 : AT(0xFA48) SUBALIGN(4) { build/us/early_scene_animation_advance.o(.text) }
    .endgame_fc30_ff18 0x8000F030 : AT(0xFC30) { build/us/fallback.o(.rom_endgame_fc30_ff18) }
    .early_bonus_pattern 0x8000F318 : AT(0xFF18) SUBALIGN(4) { build/us/early_bonus_pattern.o(.text) }
    .early_animation_restart 0x8000F4E0 : AT(0x100E0) SUBALIGN(4) { build/us/early_animation_restart.o(.text) }
    .early_actor_pair_spawn 0x8000F564 : AT(0x10164) SUBALIGN(4) { build/us/early_actor_pair_spawn.o(.text) }
    .actor_chain_reset 0x8000F7D8 : AT(0x103D8) SUBALIGN(4) { build/us/actor_chain_reset.o(.text) }
    .endgame_10414_11060 0x8000F814 : AT(0x10414) { build/us/fallback.o(.rom_endgame_10414_11060) }
    .early_reset_parameter 0x80010460 : AT(0x11060) SUBALIGN(4) { build/us/early_reset_parameter.o(.text) }
    .endgame_1109c_13290 0x8001049C : AT(0x1109C) { build/us/fallback.o(.rom_endgame_1109c_13290) }
    .early_float_step 0x80012690 : AT(0x13290) SUBALIGN(4) { build/us/early_float_step.o(.text) }
    .session_selection_lookup 0x800126E0 : AT(0x132E0) SUBALIGN(4) { build/us/session_selection_lookup.o(.text) }
    .early_selection_state 0x8001276C : AT(0x1336C) SUBALIGN(4) { build/us/early_selection_state.o(.text) }
    .endgame_13550_15c20 0x80012950 : AT(0x13550) { build/us/fallback.o(.rom_endgame_13550_15c20) }
    .early_collision_distance 0x80015020 : AT(0x15C20) SUBALIGN(4) { build/us/early_collision_distance.o(.text) }
    .early_callbacks_true 0x80015100 : AT(0x15D00) SUBALIGN(4) { build/us/early_callbacks_true.o(.text) }
    .early_actor_pair_balance 0x80015130 : AT(0x15D30) SUBALIGN(4) { build/us/early_actor_pair_balance.o(.text) }
    .early_actor_create 0x80015184 : AT(0x15D84) SUBALIGN(4) { build/us/early_actor_create.o(.text) }
    .actor_pickup 0x800152E8 : AT(0x15EE8) SUBALIGN(4) { build/us/actor_pickup.o(.text) }
    .early_actor_state 0x80015554 : AT(0x16154) SUBALIGN(4) { build/us/early_actor_state.o(.text) }
    .endgame_1627c_1675c 0x8001567C : AT(0x1627C) { build/us/fallback.o(.rom_endgame_1627c_1675c) }
    .early_actor_forward_and_guard 0x80015B5C : AT(0x1675C) SUBALIGN(4) { build/us/early_actor_forward_and_guard.o(.text) }
    .early_actor_mode3 0x80015BD4 : AT(0x167D4) SUBALIGN(4) { build/us/early_actor_mode3.o(.text) }
    .cpu_after_early_actor_mode3 0x80015BF8 : AT(0x167F8) { build/us/fallback.o(.rom_cpu_after_early_actor_mode3) }
    .early_actor_guarded_service 0x800162AC : AT(0x16EAC) SUBALIGN(4) { build/us/early_actor_guarded_service.o(.text) }
    .early_actor_mode0 0x800162F8 : AT(0x16EF8) SUBALIGN(4) { build/us/early_actor_mode0.o(.text) }
    .endgame_16f1c_17218 0x8001631C : AT(0x16F1C) { build/us/fallback.o(.rom_endgame_16f1c_17218) }
    .actor_collision_kind_dispatch 0x80016618 : AT(0x17218) SUBALIGN(4) { build/us/actor_collision_kind_dispatch.o(.text) }
    .actor_contact_gate 0x8001669C : AT(0x1729C) SUBALIGN(4) { build/us/actor_contact_gate.o(.text) }
    .early_six_arg_forward 0x80016914 : AT(0x17514) SUBALIGN(4) { build/us/early_six_arg_forward.o(.text) }
    .cpu_after_early_six_arg_forward 0x80016950 : AT(0x17550) { build/us/fallback.o(.rom_cpu_after_early_six_arg_forward) }
    .early_callback_false 0x80017364 : AT(0x17F64) SUBALIGN(4) { build/us/early_callback_false.o(.text) }
    .endgame_17f7c_1862c 0x8001737C : AT(0x17F7C) { build/us/fallback.o(.rom_endgame_17f7c_1862c) }
    .actor_collision_animation 0x80017A2C : AT(0x1862C) SUBALIGN(4) { build/us/actor_collision_animation.o(.text) }
    .actor_collision_health_result 0x80017ACC : AT(0x186CC) SUBALIGN(4) { build/us/actor_collision_health_result.o(.text) }
    .early_actor_transition 0x80017C10 : AT(0x18810) SUBALIGN(4) { build/us/early_actor_transition.o(.text) }
    .actor_collision_death_result 0x80017CDC : AT(0x188DC) SUBALIGN(4) { build/us/actor_collision_death_result.o(.text) }
    .actor_collision_score_result 0x80017E50 : AT(0x18A50) SUBALIGN(4) { build/us/actor_collision_score_result.o(.text) }
    .endgame_18b9c_198c8 0x80017F9C : AT(0x18B9C) { build/us/fallback.o(.rom_endgame_18b9c_198c8) }
    .actor_collision_separate 0x80018CC8 : AT(0x198C8) SUBALIGN(4) { build/us/actor_collision_separate.o(.text) }
    .endgame_19a1c_1aa40 0x80018E1C : AT(0x19A1C) { build/us/fallback.o(.rom_endgame_19a1c_1aa40) }
    .collision_dispatch_initialize 0x80019E40 : AT(0x1AA40) SUBALIGN(4) { build/us/collision_dispatch_initialize.o(.text) }
    .endgame_1ad68_1ad70 0x8001A168 : AT(0x1AD68) { build/us/fallback.o(.rom_endgame_1ad68_1ad70) }
    .early_pointer_state 0x8001A170 : AT(0x1AD70) SUBALIGN(4) { build/us/early_pointer_state.o(.text) }
    .early_player_input_sample 0x8001A1F0 : AT(0x1ADF0) SUBALIGN(4) { build/us/early_player_input_sample.o(.text) }
    .session_input_initialize 0x8001A2C4 : AT(0x1AEC4) SUBALIGN(4) { build/us/session_input_initialize.o(.text) }
    .endgame_1af44_1af50 0x8001A344 : AT(0x1AF44) { build/us/fallback.o(.rom_endgame_1af44_1af50) }
    .actor_random_spawn 0x8001A350 : AT(0x1AF50) SUBALIGN(4) { build/us/actor_random_spawn.o(.text) }
    .actor_collision_turn 0x8001A410 : AT(0x1B010) SUBALIGN(4) { build/us/actor_collision_turn.o(.text) }
    .early_selection_activate 0x8001A528 : AT(0x1B128) SUBALIGN(4) { build/us/early_selection_activate.o(.text) }
    .endgame_1b148_1b9a0 0x8001A548 : AT(0x1B148) { build/us/fallback.o(.rom_endgame_1b148_1b9a0) }
    .early_resource_state 0x8001ADA0 : AT(0x1B9A0) SUBALIGN(4) { build/us/early_resource_state.o(.text) }
    .actor_create 0x8001AF44 : AT(0x1BB44) SUBALIGN(4) { build/us/actor_create.o(.text) }
    .actor_behavior_counter_expire 0x8001B324 : AT(0x1BF24) SUBALIGN(4) { build/us/actor_behavior_counter_expire.o(.text) }
    .early_actor_spawn_helper 0x8001B3DC : AT(0x1BFDC) SUBALIGN(4) { build/us/early_actor_spawn_helper.o(.text) }
    .early_simple_forward 0x8001B448 : AT(0x1C048) SUBALIGN(4) { build/us/early_simple_forward.o(.text) }
    .early_actor_callback_install 0x8001B468 : AT(0x1C068) SUBALIGN(4) { build/us/early_actor_callback_install.o(.text) }
    .endgame_1c0f8_1c3d0 0x8001B4F8 : AT(0x1C0F8) { build/us/fallback.o(.rom_endgame_1c0f8_1c3d0) }
    .name_table_lookup 0x8001B7D0 : AT(0x1C3D0) SUBALIGN(4) { build/us/name_table_lookup.o(.text) }
    .early_file_state_reset 0x8001B870 : AT(0x1C470) SUBALIGN(4) { build/us/early_file_state_reset.o(.text) }
    .cpu_after_early_file_state_reset 0x8001B8D8 : AT(0x1C4D8) { build/us/fallback.o(.rom_cpu_after_early_file_state_reset) }
    .early_name_mask_lookup 0x8001BBAC : AT(0x1C7AC) SUBALIGN(4) { build/us/early_name_mask_lookup.o(.text) }
    .early_value_lookup 0x8001BC38 : AT(0x1C838) SUBALIGN(4) { build/us/early_value_lookup.o(.text) }
    .early_name_mask_parse 0x8001BD24 : AT(0x1C924) SUBALIGN(4) { build/us/early_name_mask_parse.o(.text) }
    .endgame_1ca2c_1cb48 0x8001BE2C : AT(0x1CA2C) { build/us/fallback.o(.rom_endgame_1ca2c_1cb48) }
    .early_player_counter_reset 0x8001BF48 : AT(0x1CB48) SUBALIGN(4) { build/us/early_player_counter_reset.o(.text) }
    .early_player_sequence 0x8001BFB0 : AT(0x1CBB0) SUBALIGN(4) { build/us/early_player_sequence.o(.text) }
    .cpu_after_early_player_sequence 0x8001C0C8 : AT(0x1CCC8) { build/us/fallback.o(.rom_cpu_after_early_player_sequence) }
    .script_service_cache_reset 0x8001C740 : AT(0x1D340) SUBALIGN(4) { build/us/script_service_cache_reset.o(.text) }
    .script_service_files 0x8001C790 : AT(0x1D390) SUBALIGN(4) { build/us/script_service_files.o(.text) }
    .script_service_cache_access 0x8001C8C4 : AT(0x1D4C4) SUBALIGN(4) { build/us/script_service_cache_access.o(.text) }
    .cpu_after_script_service_cache_access 0x8001CB48 : AT(0x1D748) { build/us/fallback.o(.rom_cpu_after_script_service_cache_access) }
    .script_service_commands 0x8001CB50 : AT(0x1D750) SUBALIGN(4) { build/us/script_service_commands.o(.text) }
    .cpu_after_script_service_commands 0x8001CD94 : AT(0x1D994) { build/us/fallback.o(.rom_cpu_after_script_service_commands) }
    .script_service_platform 0x8001CDA0 : AT(0x1D9A0) SUBALIGN(4) { build/us/script_service_platform.o(.text) }
    .script_animation_resolve 0x8001CE70 : AT(0x1DA70) SUBALIGN(4) { build/us/script_animation_resolve.o(.text) }
    .actor_resource_load 0x8001CF68 : AT(0x1DB68) SUBALIGN(4) { build/us/actor_resource_load.o(.text) }
    .actor_resource_reset 0x8001D260 : AT(0x1DE60) SUBALIGN(4) { build/us/actor_resource_reset.o(.text) }
    .cpu_after_actor_resource_reset 0x8001D3F0 : AT(0x1DFF0) { build/us/fallback.o(.rom_cpu_after_actor_resource_reset) }
    .actor_setup_noop 0x8001DE54 : AT(0x1EA54) SUBALIGN(4) { build/us/actor_setup_noop.o(.text) }
    .cpu_after_actor_setup_noop 0x8001DE5C : AT(0x1EA5C) { build/us/fallback.o(.rom_cpu_after_actor_setup_noop) }
    .actor_setup_strings 0x8001DE60 : AT(0x1EA60) SUBALIGN(4) { build/us/actor_setup_strings.o(.text) }
    .actor_setup_animation_reset 0x8001DF70 : AT(0x1EB70) SUBALIGN(4) { build/us/actor_setup_animation_reset.o(.text) }
    .cpu_after_actor_setup_animation_reset 0x8001DF94 : AT(0x1EB94) { build/us/fallback.o(.rom_cpu_after_actor_setup_animation_reset) }
    .actor_setup_text_begin 0x8001EAE8 : AT(0x1F6E8) SUBALIGN(4) { build/us/actor_setup_text_begin.o(.text) }
    .cpu_after_actor_setup_text_begin 0x8001EB2C : AT(0x1F72C) { build/us/fallback.o(.rom_cpu_after_actor_setup_text_begin) }
    .actor_setup_text_reset 0x8001F1D8 : AT(0x1FDD8) SUBALIGN(4) { build/us/actor_setup_text_reset.o(.text) }
    .cpu_after_actor_setup_text_reset 0x8001F238 : AT(0x1FE38) { build/us/fallback.o(.rom_cpu_after_actor_setup_text_reset) }
    .scene_actor_create 0x8001F240 : AT(0x1FE40) SUBALIGN(4) { build/us/scene_actor_create.o(.text) }
    .scene_file_idle 0x8001F2B4 : AT(0x1FEB4) SUBALIGN(4) { build/us/scene_file_idle.o(.text) }
    .cpu_after_scene_file_idle 0x8001F2BC : AT(0x1FEBC) { build/us/fallback.o(.rom_cpu_after_scene_file_idle) }
    .scene_file_stubs 0x8001F2C0 : AT(0x1FEC0) SUBALIGN(4) { build/us/scene_file_stubs.o(.text) }
    .scene_file_select 0x8001F2D8 : AT(0x1FED8) SUBALIGN(4) { build/us/scene_file_select.o(.text) }
    .scene_resource_limits 0x8001F350 : AT(0x1FF50) SUBALIGN(4) { build/us/scene_resource_limits.o(.text) }
    .scene_display_flags 0x8001F3C4 : AT(0x1FFC4) SUBALIGN(4) { build/us/scene_display_flags.o(.text) }
    .scene_position 0x8001F3FC : AT(0x1FFFC) SUBALIGN(4) { build/us/scene_position.o(.text) }
    .scene_value_d0c 0x8001F468 : AT(0x20068) SUBALIGN(4) { build/us/scene_value_d0c.o(.text) }
    .scene_values_cd0 0x8001F478 : AT(0x20078) SUBALIGN(4) { build/us/scene_values_cd0.o(.text) }
    .scene_values_cdc 0x8001F494 : AT(0x20094) SUBALIGN(4) { build/us/scene_values_cdc.o(.text) }
    .scene_values_cf0 0x8001F4B8 : AT(0x200B8) SUBALIGN(4) { build/us/scene_values_cf0.o(.text) }
    .scene_effect_add 0x8001F4DC : AT(0x200DC) SUBALIGN(4) { build/us/scene_effect_add.o(.text) }
    .scene_value_cec 0x8001F55C : AT(0x2015C) SUBALIGN(4) { build/us/scene_value_cec.o(.text) }
    .scene_unused_commands 0x8001F56C : AT(0x2016C) SUBALIGN(4) { build/us/scene_unused_commands.o(.text) }
    .scene_resource_command 0x8001F58C : AT(0x2018C) SUBALIGN(4) { build/us/scene_resource_command.o(.text) }
    .scene_enemy_arrival 0x8001F5B4 : AT(0x201B4) SUBALIGN(4) { build/us/scene_enemy_arrival.o(.text) }
    .scene_category_arrivals 0x8001F6AC : AT(0x202AC) SUBALIGN(4) { build/us/scene_category_arrivals.o(.text) }
    .scene_unused_arrivals 0x8001F7E4 : AT(0x203E4) SUBALIGN(4) { build/us/scene_unused_arrivals.o(.text) }
    .scene_positioned_arrival 0x8001F7FC : AT(0x203FC) SUBALIGN(4) { build/us/scene_positioned_arrival.o(.text) }
    .scene_mark_dirty 0x8001F868 : AT(0x20468) SUBALIGN(4) { build/us/scene_mark_dirty.o(.text) }
    .scene_effect_apply 0x8001F87C : AT(0x2047C) SUBALIGN(4) { build/us/scene_effect_apply.o(.text) }
    .scene_audio_request 0x8001F8E8 : AT(0x204E8) SUBALIGN(4) { build/us/scene_audio_request.o(.text) }
    .scene_background 0x8001F90C : AT(0x2050C) SUBALIGN(4) { build/us/scene_background.o(.text) }
    .endgame_208e4_21b24 0x8001FCE4 : AT(0x208E4) { build/us/fallback.o(.rom_endgame_208e4_21b24) }
    .scene_arrival_reactivate 0x80020F24 : AT(0x21B24) SUBALIGN(4) { build/us/scene_arrival_reactivate.o(.text) }
    .endgame_21b8c_22720 0x80020F8C : AT(0x21B8C) { build/us/fallback.o(.rom_endgame_21b8c_22720) }
    .save_level_lookup 0x80021B20 : AT(0x22720) SUBALIGN(4) { build/us/save_level_lookup.o(.text) }
    .scene_definition_byteorder 0x80021B38 : AT(0x22738) SUBALIGN(4) { build/us/scene_definition_byteorder.o(.text) }
    .save_menu_conditional_copy 0x80021C14 : AT(0x22814) SUBALIGN(4) { build/us/save_menu_conditional_copy.o(.text) }
    .cpu_after_save_menu_conditional_copy 0x80021C3C : AT(0x2283C) { build/us/fallback.o(.rom_cpu_after_save_menu_conditional_copy) }
    .save_menu_flag_setter 0x80022050 : AT(0x22C50) SUBALIGN(4) { build/us/save_menu_flag_setter.o(.text) }
    .endgame_22c5c_23128 0x8002205C : AT(0x22C5C) { build/us/fallback.o(.rom_endgame_22c5c_23128) }
    .session_scene_start 0x80022528 : AT(0x23128) SUBALIGN(4) { build/us/session_scene_start.o(.text) }
    .save_menu_text_flags 0x800226E8 : AT(0x232E8) SUBALIGN(4) { build/us/save_menu_text_flags.o(.text) }
    .scene_menu_string_schedule 0x80022858 : AT(0x23458) SUBALIGN(4) { build/us/scene_menu_string_schedule.o(.text) }
    .scene_menu_string_refresh 0x80022A08 : AT(0x23608) SUBALIGN(4) { build/us/scene_menu_string_refresh.o(.text) }
    .session_mode_advance 0x80022B78 : AT(0x23778) SUBALIGN(4) { build/us/session_mode_advance.o(.text) }
    .session_background_select 0x80022BFC : AT(0x237FC) SUBALIGN(4) { build/us/session_background_select.o(.text) }
    .save_menu_state_reset 0x80022CF8 : AT(0x238F8) SUBALIGN(4) { build/us/save_menu_state_reset.o(.text) }
    .cpu_after_save_menu_state_reset 0x80022D24 : AT(0x23924) { build/us/fallback.o(.rom_cpu_after_save_menu_state_reset) }
    .save_menu_legacy_reset 0x80025688 : AT(0x26288) SUBALIGN(4) { build/us/save_menu_legacy_reset.o(.text) }
    .cpu_after_save_menu_legacy_reset 0x800256B8 : AT(0x262B8) { build/us/fallback.o(.rom_cpu_after_save_menu_legacy_reset) }
    .save_menu_legacy_heap 0x800256C0 : AT(0x262C0) SUBALIGN(4) { build/us/save_menu_legacy_heap.o(.text) }
    .cpu_after_save_menu_legacy_heap 0x80025708 : AT(0x26308) { build/us/fallback.o(.rom_cpu_after_save_menu_legacy_heap) }
    .save_menu_legacy_pages 0x80025710 : AT(0x26310) SUBALIGN(4) { build/us/save_menu_legacy_pages.o(.text) }
    .save_menu_legacy_pak_status 0x8002589C : AT(0x2649C) SUBALIGN(4) { build/us/save_menu_legacy_pak_status.o(.text) }
    .save_menu_legacy_exit 0x80025B44 : AT(0x26744) SUBALIGN(4) { build/us/save_menu_legacy_exit.o(.text) }
    .save_menu_legacy_pages_tail 0x80025BBC : AT(0x267BC) SUBALIGN(4) { build/us/save_menu_legacy_pages_tail.o(.text) }
    .save_menu_nav_refresh 0x80025C40 : AT(0x26840) SUBALIGN(4) { build/us/save_menu_nav_refresh.o(.text) }
    .save_menu_nav_open_primary 0x80025CD0 : AT(0x268D0) SUBALIGN(4) { build/us/save_menu_nav_open_primary.o(.text) }
    .save_menu_nav_open_secondary 0x80025CFC : AT(0x268FC) SUBALIGN(4) { build/us/save_menu_nav_open_secondary.o(.text) }
    .save_menu_nav_open_return 0x80025D28 : AT(0x26928) SUBALIGN(4) { build/us/save_menu_nav_open_return.o(.text) }
    .save_menu_nav_noop 0x80025D54 : AT(0x26954) SUBALIGN(4) { build/us/save_menu_nav_noop.o(.text) }
    .save_menu_nav_reset 0x80025D5C : AT(0x2695C) SUBALIGN(4) { build/us/save_menu_nav_reset.o(.text) }
    .save_menu_nav_actor_disable 0x80025D88 : AT(0x26988) SUBALIGN(4) { build/us/save_menu_nav_actor_disable.o(.text) }
    .save_menu_nav_actor_forward 0x80025D9C : AT(0x2699C) SUBALIGN(4) { build/us/save_menu_nav_actor_forward.o(.text) }
    .save_menu_nav_actor_back 0x80025E68 : AT(0x26A68) SUBALIGN(4) { build/us/save_menu_nav_actor_back.o(.text) }
    .save_menu_nav_preview_create 0x80025EF0 : AT(0x26AF0) SUBALIGN(4) { build/us/save_menu_nav_preview_create.o(.text) }
    .save_menu_nav_preview_release 0x80026044 : AT(0x26C44) SUBALIGN(4) { build/us/save_menu_nav_preview_release.o(.text) }
    .save_menu_nav_cleanup 0x8002606C : AT(0x26C6C) SUBALIGN(4) { build/us/save_menu_nav_cleanup.o(.text) }
    .cpu_after_save_menu_nav_cleanup 0x80026178 : AT(0x26D78) { build/us/fallback.o(.rom_cpu_after_save_menu_nav_cleanup) }
    .save_menu_pak_retry 0x800265B8 : AT(0x271B8) SUBALIGN(4) { build/us/save_menu_pak_retry.o(.text) }
    .save_menu_pak_reset 0x80026620 : AT(0x27220) SUBALIGN(4) { build/us/save_menu_pak_reset.o(.text) }
    .save_menu_pak_refresh 0x80026674 : AT(0x27274) SUBALIGN(4) { build/us/save_menu_pak_refresh.o(.text) }
    .save_menu_pak_name_select 0x800266BC : AT(0x272BC) SUBALIGN(4) { build/us/save_menu_pak_name_select.o(.text) }
    .save_menu_pak_result 0x8002674C : AT(0x2734C) SUBALIGN(4) { build/us/save_menu_pak_result.o(.text) }
    .endgame_273bc_27610 0x800267BC : AT(0x273BC) { build/us/fallback.o(.rom_endgame_273bc_27610) }
    .save_menu_pak_page_select 0x80026A10 : AT(0x27610) SUBALIGN(4) { build/us/save_menu_pak_page_select.o(.text) }
    .endgame_2770c_284ac 0x80026B0C : AT(0x2770C) { build/us/fallback.o(.rom_endgame_2770c_284ac) }
    .menu_transition_start 0x800278AC : AT(0x284AC) SUBALIGN(4) { build/us/menu_transition_start.o(.text) }
    .menu_label_assign 0x80027940 : AT(0x28540) SUBALIGN(4) { build/us/menu_label_assign.o(.text) }
    .endgame_28608_28610 0x80027A08 : AT(0x28608) { build/us/fallback.o(.rom_endgame_28608_28610) }
    .actor_position_pair_add 0x80027A10 : AT(0x28610) SUBALIGN(4) { build/us/actor_position_pair_add.o(.text) }
    .actor_animation 0x80027AB8 : AT(0x286B8) SUBALIGN(4) { build/us/actor_animation.o(.text) }
    .actor_motion_mode 0x80027B9C : AT(0x2879C) SUBALIGN(4) { build/us/actor_motion_mode.o(.text) }
    .actor_motion_facing 0x80027CE4 : AT(0x288E4) SUBALIGN(4) { build/us/actor_motion_facing.o(.text) }
    .actor_nearest_match 0x80027D8C : AT(0x2898C) SUBALIGN(4) { build/us/actor_nearest_match.o(.text) }
    .endgame_28ad4_28d8c 0x80027ED4 : AT(0x28AD4) { build/us/fallback.o(.rom_endgame_28ad4_28d8c) }
    .actor_pool_reset 0x8002818C : AT(0x28D8C) SUBALIGN(4) { build/us/actor_pool_reset.o(.text) }
    .actor_cleanup 0x800281C4 : AT(0x28DC4) SUBALIGN(4) { build/us/actor_cleanup.o(.text) }
    .actor_remove 0x80028274 : AT(0x28E74) SUBALIGN(4) { build/us/actor_remove.o(.text) }
    .actor_sweep 0x8002836C : AT(0x28F6C) SUBALIGN(4) { build/us/actor_sweep.o(.text) }
    .actor_pool_allocate 0x800283D4 : AT(0x28FD4) SUBALIGN(4) { build/us/actor_pool_allocate.o(.text) }
    .endgame_292e8_29c20 0x800286E8 : AT(0x292E8) { build/us/fallback.o(.rom_endgame_292e8_29c20) }
    .actor_position_follow 0x80029020 : AT(0x29C20) SUBALIGN(4) { build/us/actor_position_follow.o(.text) }
    .actor_position_submit 0x800290B0 : AT(0x29CB0) SUBALIGN(4) { build/us/actor_position_submit.o(.text) }
    .actor_behavior_frame_sync 0x80029154 : AT(0x29D54) SUBALIGN(4) { build/us/actor_behavior_frame_sync.o(.text) }
    .actor_animation_auxiliary 0x80029194 : AT(0x29D94) SUBALIGN(4) { build/us/actor_animation_auxiliary.o(.text) }
    .actor_behavior_motion_begin 0x80029210 : AT(0x29E10) SUBALIGN(4) { build/us/actor_behavior_motion_begin.o(.text) }
    .actor_behavior_motion_guarded 0x800292BC : AT(0x29EBC) SUBALIGN(4) { build/us/actor_behavior_motion_guarded.o(.text) }
    .actor_behavior_motion_scaled 0x8002937C : AT(0x29F7C) SUBALIGN(4) { build/us/actor_behavior_motion_scaled.o(.text) }
    .actor_behavior_animation_2945c 0x8002945C : AT(0x2A05C) SUBALIGN(4) { build/us/actor_behavior_animation_2945c.o(.text) }
    .actor_child_animation 0x800294A4 : AT(0x2A0A4) SUBALIGN(4) { build/us/actor_child_animation.o(.text) }
    .actor_behavior_callback_29544 0x80029544 : AT(0x2A144) SUBALIGN(4) { build/us/actor_behavior_callback_29544.o(.text) }
    .actor_random_fan 0x800295CC : AT(0x2A1CC) SUBALIGN(4) { build/us/actor_random_fan.o(.text) }
    .actor_behavior_spawn_callback 0x80029760 : AT(0x2A360) SUBALIGN(4) { build/us/actor_behavior_spawn_callback.o(.text) }
    .actor_behavior_spawn 0x80029B20 : AT(0x2A720) SUBALIGN(4) { build/us/actor_behavior_spawn.o(.text) }
    .actor_repeat_expire 0x80029B80 : AT(0x2A780) SUBALIGN(4) { build/us/actor_repeat_expire.o(.text) }
    .actor_repeat_delay 0x80029C48 : AT(0x2A848) SUBALIGN(4) { build/us/actor_repeat_delay.o(.text) }
    .actor_behavior_spawn_restore 0x80029CF4 : AT(0x2A8F4) SUBALIGN(4) { build/us/actor_behavior_spawn_restore.o(.text) }
    .actor_behavior_release_29d6c 0x80029D6C : AT(0x2A96C) SUBALIGN(4) { build/us/actor_behavior_release_29d6c.o(.text) }
    .actor_scene_counter_expire 0x80029D98 : AT(0x2A998) SUBALIGN(4) { build/us/actor_scene_counter_expire.o(.text) }
    .actor_child_random_motion 0x80029E5C : AT(0x2AA5C) SUBALIGN(4) { build/us/actor_child_random_motion.o(.text) }
    .actor_list_animation_tick 0x80029FD8 : AT(0x2ABD8) SUBALIGN(4) { build/us/actor_list_animation_tick.o(.text) }
    .actor_behavior_next_a244 0x8002A244 : AT(0x2AE44) SUBALIGN(4) { build/us/actor_behavior_next_a244.o(.text) }
    .actor_behavior_state 0x8002A3E8 : AT(0x2AFE8) SUBALIGN(4) { build/us/actor_behavior_state.o(.text) }
    .actor_behavior_blend_velocity 0x8002A414 : AT(0x2B014) SUBALIGN(4) { build/us/actor_behavior_blend_velocity.o(.text) }
    .actor_behavior_blend_motion 0x8002A5DC : AT(0x2B1DC) SUBALIGN(4) { build/us/actor_behavior_blend_motion.o(.text) }
    .actor_behavior_human 0x8002A808 : AT(0x2B408) SUBALIGN(4) { build/us/actor_behavior_human.o(.text) }
    .actor_behavior_duration 0x8002AF2C : AT(0x2BB2C) SUBALIGN(4) { build/us/actor_behavior_duration.o(.text) }
    .actor_behavior_height 0x8002B31C : AT(0x2BF1C) SUBALIGN(4) { build/us/actor_behavior_height.o(.text) }
    .actor_behavior_extra_b32c 0x8002B32C : AT(0x2BF2C) SUBALIGN(4) { build/us/actor_behavior_extra_b32c.o(.text) }
    .actor_behavior_noop_b570 0x8002B570 : AT(0x2C170) SUBALIGN(4) { build/us/actor_behavior_noop_b570.o(.text) }
    .actor_behavior_extra_b57c 0x8002B57C : AT(0x2C17C) SUBALIGN(4) { build/us/actor_behavior_extra_b57c.o(.text) }
    .actor_behavior_noop_b7a4 0x8002B7A4 : AT(0x2C3A4) SUBALIGN(4) { build/us/actor_behavior_noop_b7a4.o(.text) }
    .actor_behavior_noop_b7b0 0x8002B7B0 : AT(0x2C3B0) SUBALIGN(4) { build/us/actor_behavior_noop_b7b0.o(.text) }
    .actor_behavior_stride 0x8002B7BC : AT(0x2C3BC) SUBALIGN(4) { build/us/actor_behavior_stride.o(.text) }
    .actor_behavior_repeat 0x8002BF88 : AT(0x2CB88) SUBALIGN(4) { build/us/actor_behavior_repeat.o(.text) }
    .actor_behavior_hulk 0x8002C0AC : AT(0x2CCAC) SUBALIGN(4) { build/us/actor_behavior_hulk.o(.text) }
    .actor_behavior_enforcer 0x8002C4AC : AT(0x2D0AC) SUBALIGN(4) { build/us/actor_behavior_enforcer.o(.text) }
    .actor_behavior_brain 0x8002CB48 : AT(0x2D748) SUBALIGN(4) { build/us/actor_behavior_brain.o(.text) }
    .actor_behavior_pursuit 0x8002CF24 : AT(0x2DB24) SUBALIGN(4) { build/us/actor_behavior_pursuit.o(.text) }
    .actor_behavior_spawn_state 0x8002D3D4 : AT(0x2DFD4) SUBALIGN(4) { build/us/actor_behavior_spawn_state.o(.text) }
    .actor_behavior_extra_d918 0x8002D918 : AT(0x2E518) SUBALIGN(4) { build/us/actor_behavior_extra_d918.o(.text) }
    .actor_behavior_countdown 0x8002DC20 : AT(0x2E820) SUBALIGN(4) { build/us/actor_behavior_countdown.o(.text) }
    .actor_behavior_countdown_begin 0x8002DCB8 : AT(0x2E8B8) SUBALIGN(4) { build/us/actor_behavior_countdown_begin.o(.text) }
    .actor_behavior_countdown_trigger 0x8002DD40 : AT(0x2E940) SUBALIGN(4) { build/us/actor_behavior_countdown_trigger.o(.text) }
    .cpu_after_actor_behavior_countdown_trigger 0x8002DDBC : AT(0x2E9BC) { build/us/fallback.o(.rom_cpu_after_actor_behavior_countdown_trigger) }
    .session_setup_noop 0x8002E65C : AT(0x2F25C) SUBALIGN(4) { build/us/session_setup_noop.o(.text) }
    .cpu_after_session_setup_noop 0x8002E664 : AT(0x2F264) { build/us/fallback.o(.rom_cpu_after_session_setup_noop) }
    .session_setup_globals 0x8002ECC4 : AT(0x2F8C4) SUBALIGN(4) { build/us/session_setup_globals.o(.text) }
    .session_setup_value04 0x8002ECEC : AT(0x2F8EC) SUBALIGN(4) { build/us/session_setup_value04.o(.text) }
    .session_setup_value14 0x8002ED00 : AT(0x2F900) SUBALIGN(4) { build/us/session_setup_value14.o(.text) }
    .session_setup_value12 0x8002ED3C : AT(0x2F93C) SUBALIGN(4) { build/us/session_setup_value12.o(.text) }
    .session_setup_flag13 0x8002ED50 : AT(0x2F950) SUBALIGN(4) { build/us/session_setup_flag13.o(.text) }
    .session_setup_values08_10 0x8002ED78 : AT(0x2F978) SUBALIGN(4) { build/us/session_setup_values08_10.o(.text) }
    .session_setup_value1a 0x8002ED9C : AT(0x2F99C) SUBALIGN(4) { build/us/session_setup_value1a.o(.text) }
    .session_setup_playback_speed 0x8002EDB0 : AT(0x2F9B0) SUBALIGN(4) { build/us/session_setup_playback_speed.o(.text) }
    .session_setup_value16 0x8002EE24 : AT(0x2FA24) SUBALIGN(4) { build/us/session_setup_value16.o(.text) }
    .session_setup_validate 0x8002EE38 : AT(0x2FA38) SUBALIGN(4) { build/us/session_setup_validate.o(.text) }
    .session_setup_script_stop 0x8002EFC4 : AT(0x2FBC4) SUBALIGN(4) { build/us/session_setup_script_stop.o(.text) }
    .session_setup_animation_create 0x8002EFD8 : AT(0x2FBD8) SUBALIGN(4) { build/us/session_setup_animation_create.o(.text) }
    .session_setup_global_value 0x8002F088 : AT(0x2FC88) SUBALIGN(4) { build/us/session_setup_global_value.o(.text) }
    .session_setup_animation_state 0x8002F098 : AT(0x2FC98) SUBALIGN(4) { build/us/session_setup_animation_state.o(.text) }
    .session_setup_vulnerable 0x8002F100 : AT(0x2FD00) SUBALIGN(4) { build/us/session_setup_vulnerable.o(.text) }
    .session_setup_model 0x8002F128 : AT(0x2FD28) SUBALIGN(4) { build/us/session_setup_model.o(.text) }
    .session_setup_animation_file 0x8002F1A4 : AT(0x2FDA4) SUBALIGN(4) { build/us/session_setup_animation_file.o(.text) }
    .session_setup_texture_map 0x8002F1DC : AT(0x2FDDC) SUBALIGN(4) { build/us/session_setup_texture_map.o(.text) }
    .session_setup_bitmap 0x8002F23C : AT(0x2FE3C) SUBALIGN(4) { build/us/session_setup_bitmap.o(.text) }
    .session_setup_kinemation 0x8002F29C : AT(0x2FE9C) SUBALIGN(4) { build/us/session_setup_kinemation.o(.text) }
    .session_setup_extra_kinemation 0x8002F334 : AT(0x2FF34) SUBALIGN(4) { build/us/session_setup_extra_kinemation.o(.text) }
    .session_setup_pair 0x8002F414 : AT(0x30014) SUBALIGN(4) { build/us/session_setup_pair.o(.text) }
    .session_setup_value58_half 0x8002F450 : AT(0x30050) SUBALIGN(4) { build/us/session_setup_value58_half.o(.text) }
    .session_setup_value64 0x8002F464 : AT(0x30064) SUBALIGN(4) { build/us/session_setup_value64.o(.text) }
    .session_setup_value5a 0x8002F49C : AT(0x3009C) SUBALIGN(4) { build/us/session_setup_value5a.o(.text) }
    .session_setup_value58_word 0x8002F4B0 : AT(0x300B0) SUBALIGN(4) { build/us/session_setup_value58_word.o(.text) }
    .cpu_after_session_setup_value58_word 0x8002F4C4 : AT(0x300C4) { build/us/fallback.o(.rom_cpu_after_session_setup_value58_word) }
    .session_menu_selection 0x8002F4D0 : AT(0x300D0) SUBALIGN(4) { build/us/session_menu_selection.o(.text) }
    .session_menu_preview_update 0x8002F4EC : AT(0x300EC) SUBALIGN(4) { build/us/session_menu_preview_update.o(.text) }
    .session_menu_preview_create 0x8002F638 : AT(0x30238) SUBALIGN(4) { build/us/session_menu_preview_create.o(.text) }
    .session_menu_preview_accept 0x8002F79C : AT(0x3039C) SUBALIGN(4) { build/us/session_menu_preview_accept.o(.text) }
    .session_menu_preview_cancel 0x8002F7C8 : AT(0x303C8) SUBALIGN(4) { build/us/session_menu_preview_cancel.o(.text) }
    .session_menu_preview_release 0x8002F804 : AT(0x30404) SUBALIGN(4) { build/us/session_menu_preview_release.o(.text) }
    .session_setup_empty 0x8002F85C : AT(0x3045C) SUBALIGN(4) { build/us/session_setup_empty.o(.text) }
    .session_menu_exit_game 0x8002F864 : AT(0x30464) SUBALIGN(4) { build/us/session_menu_exit_game.o(.text) }
    .session_menu_start_single 0x8002F8D0 : AT(0x304D0) SUBALIGN(4) { build/us/session_menu_start_single.o(.text) }
    .session_setup_menu_reset 0x8002F980 : AT(0x30580) SUBALIGN(4) { build/us/session_setup_menu_reset.o(.text) }
    .session_menu_show_main 0x8002F9A4 : AT(0x305A4) SUBALIGN(4) { build/us/session_menu_show_main.o(.text) }
    .session_menu_start_two 0x8002F9D4 : AT(0x305D4) SUBALIGN(4) { build/us/session_menu_start_two.o(.text) }
    .session_menu_start_alternate 0x8002FA70 : AT(0x30670) SUBALIGN(4) { build/us/session_menu_start_alternate.o(.text) }
    .session_menu_return 0x8002FAE0 : AT(0x306E0) SUBALIGN(4) { build/us/session_menu_return.o(.text) }
    .session_menu_level_exit 0x8002FB30 : AT(0x30730) SUBALIGN(4) { build/us/session_menu_level_exit.o(.text) }
    .session_menu_player_choice 0x8002FB54 : AT(0x30754) SUBALIGN(4) { build/us/session_menu_player_choice.o(.text) }
    .session_menu_pages 0x8002FC08 : AT(0x30808) SUBALIGN(4) { build/us/session_menu_pages.o(.text) }
    .session_menu_shell_reset 0x8002FC9C : AT(0x3089C) SUBALIGN(4) { build/us/session_menu_shell_reset.o(.text) }
    .session_menu_defaults 0x8002FD20 : AT(0x30920) SUBALIGN(4) { build/us/session_menu_defaults.o(.text) }
    .save_options_capture 0x8002FE00 : AT(0x30A00) SUBALIGN(4) { build/us/save_options_capture.o(.text) }
    .save_slot_capture 0x8002FE68 : AT(0x30A68) SUBALIGN(4) { build/us/save_slot_capture.o(.text) }
    .save_options_restore 0x8002FF40 : AT(0x30B40) SUBALIGN(4) { build/us/save_options_restore.o(.text) }
    .save_slot_restore 0x8002FFC8 : AT(0x30BC8) SUBALIGN(4) { build/us/save_slot_restore.o(.text) }
    .save_slot_labels 0x80030054 : AT(0x30C54) SUBALIGN(4) { build/us/save_slot_labels.o(.text) }
    .save_file_read 0x800301A4 : AT(0x30DA4) SUBALIGN(4) { build/us/save_file_read.o(.text) }
    .save_file_write 0x80030420 : AT(0x31020) SUBALIGN(4) { build/us/save_file_write.o(.text) }
    .save_slot_select 0x800305F8 : AT(0x311F8) SUBALIGN(4) { build/us/save_slot_select.o(.text) }
    .save_menu_slot_write 0x80030798 : AT(0x31398) SUBALIGN(4) { build/us/save_menu_slot_write.o(.text) }
    .save_menu_cancel 0x800308AC : AT(0x314AC) SUBALIGN(4) { build/us/save_menu_cancel.o(.text) }
    .save_menu_slot_prompt 0x800308E8 : AT(0x314E8) SUBALIGN(4) { build/us/save_menu_slot_prompt.o(.text) }
    .save_menu_slot_callback 0x800309D0 : AT(0x315D0) SUBALIGN(4) { build/us/save_menu_slot_callback.o(.text) }
    .save_menu_open 0x80030A3C : AT(0x3163C) SUBALIGN(4) { build/us/save_menu_open.o(.text) }
    .save_menu_status 0x80030A80 : AT(0x31680) SUBALIGN(4) { build/us/save_menu_status.o(.text) }
    .save_menu_score_step 0x80030DC0 : AT(0x319C0) SUBALIGN(4) { build/us/save_menu_score_step.o(.text) }
    .save_menu_audio_index 0x80030EAC : AT(0x31AAC) SUBALIGN(4) { build/us/save_menu_audio_index.o(.text) }
    .save_menu_sound_preview 0x80030F20 : AT(0x31B20) SUBALIGN(4) { build/us/save_menu_sound_preview.o(.text) }
    .save_menu_audio_apply 0x80030F50 : AT(0x31B50) SUBALIGN(4) { build/us/save_menu_audio_apply.o(.text) }
    .save_menu_audio_secondary 0x80030F94 : AT(0x31B94) SUBALIGN(4) { build/us/save_menu_audio_secondary.o(.text) }
    .save_menu_write_return 0x80030FB8 : AT(0x31BB8) SUBALIGN(4) { build/us/save_menu_write_return.o(.text) }
    .scene_index_code 0x80030FEC : AT(0x31BEC) SUBALIGN(4) { build/us/scene_index_code.o(.text) }
    .save_menu_continue_character 0x80031034 : AT(0x31C34) SUBALIGN(4) { build/us/save_menu_continue_character.o(.text) }
    .save_menu_continue_decode 0x80031080 : AT(0x31C80) SUBALIGN(4) { build/us/save_menu_continue_decode.o(.text) }
    .save_menu_continue_encode 0x800312B0 : AT(0x31EB0) SUBALIGN(4) { build/us/save_menu_continue_encode.o(.text) }
    .save_menu_palette_index 0x80031420 : AT(0x32020) SUBALIGN(4) { build/us/save_menu_palette_index.o(.text) }
    .scene_palette_load 0x800314FC : AT(0x320FC) SUBALIGN(4) { build/us/scene_palette_load.o(.text) }
    .palette_fade_controls 0x80031564 : AT(0x32164) SUBALIGN(4) { build/us/palette_fade_controls.o(.text) }
    .palette_fade_update 0x800316AC : AT(0x322AC) SUBALIGN(4) { build/us/palette_fade_update.o(.text) }
    .palette_fallback_32728_32810 0x80031B28 : AT(0x32728) { build/us/fallback.o(.rom_palette_fallback_32728_32810) }
    .palette_transition_reset 0x80031C10 : AT(0x32810) SUBALIGN(4) { build/us/palette_transition_reset.o(.text) }
    .palette_transition_range 0x80031C44 : AT(0x32844) SUBALIGN(4) { build/us/palette_transition_range.o(.text) }
    .cpu_after_palette_transition_range 0x80031ECC : AT(0x32ACC) { build/us/fallback.o(.rom_cpu_after_palette_transition_range) }
    .palette_commands 0x8003237C : AT(0x32F7C) SUBALIGN(4) { build/us/palette_commands.o(.text) }
    .cpu_after_palette_commands 0x80032534 : AT(0x33134) { build/us/fallback.o(.rom_cpu_after_palette_commands) }
    .command_enable 0x80032540 : AT(0x33140) SUBALIGN(4) { build/us/command_enable.o(.text) }
    .game_number_convert 0x80032550 : AT(0x33150) SUBALIGN(4) { build/us/game_number_convert.o(.text) }
    .command_script_execute 0x8003264C : AT(0x3324C) SUBALIGN(4) { build/us/command_script_execute.o(.text) }
    .command_machine 0x800327AC : AT(0x333AC) SUBALIGN(4) { build/us/command_machine.o(.text) }
    .cpu_after_command_machine 0x8003282C : AT(0x3342C) { build/us/fallback.o(.rom_cpu_after_command_machine) }
    .scene_transition_open 0x80032830 : AT(0x33430) SUBALIGN(4) { build/us/scene_transition_open.o(.text) }
    .scene_transition_close 0x80032880 : AT(0x33480) SUBALIGN(4) { build/us/scene_transition_close.o(.text) }
    .scene_transition_draw 0x800328E0 : AT(0x334E0) SUBALIGN(4) { build/us/scene_transition_draw.o(.text) }
    .endgame_33600_33900 0x80032A00 : AT(0x33600) { build/us/fallback.o(.rom_endgame_33600_33900) }
    .player_fields_clear 0x80032D00 : AT(0x33900) SUBALIGN(4) { build/us/player_fields_clear.o(.text) }
    .scene_player_setup 0x80032D28 : AT(0x33928) SUBALIGN(4) { build/us/scene_player_setup.o(.text) }
    .scene_actor_reset_begin 0x80032F70 : AT(0x33B70) SUBALIGN(4) { build/us/scene_actor_reset_begin.o(.text) }
    .endgame_33cf8_344cc 0x800330F8 : AT(0x33CF8) { build/us/fallback.o(.rom_endgame_33cf8_344cc) }
    .scene_signed_shift 0x800338CC : AT(0x344CC) SUBALIGN(4) { build/us/scene_signed_shift.o(.text) }
    .resource_selection_clear 0x800338F0 : AT(0x344F0) SUBALIGN(4) { build/us/resource_selection_clear.o(.text) }
    .endgame_34574_35d90 0x80033974 : AT(0x34574) { build/us/fallback.o(.rom_endgame_34574_35d90) }
    .actor_value_transition 0x80035190 : AT(0x35D90) SUBALIGN(4) { build/us/actor_value_transition.o(.text) }
    .endgame_35e44_35f60 0x80035244 : AT(0x35E44) { build/us/fallback.o(.rom_endgame_35e44_35f60) }
    .actor_value_follow 0x80035360 : AT(0x35F60) SUBALIGN(4) { build/us/actor_value_follow.o(.text) }
    .scene_actor_parameter_reset 0x800354A4 : AT(0x360A4) SUBALIGN(4) { build/us/scene_actor_parameter_reset.o(.text) }
    .actor_retirement 0x800354C8 : AT(0x360C8) SUBALIGN(4) { build/us/actor_retirement.o(.text) }
    .scene_actor_mode_list 0x80035CC8 : AT(0x368C8) SUBALIGN(4) { build/us/scene_actor_mode_list.o(.text) }
    .actor_manual_motion 0x80035E3C : AT(0x36A3C) SUBALIGN(4) { build/us/actor_manual_motion.o(.text) }
    .sound_bridge_core 0x80036064 : AT(0x36C64) SUBALIGN(4) { build/us/sound_bridge_core.o(.text) }
    .cpu_after_sound_bridge_core 0x800360E8 : AT(0x36CE8) { build/us/fallback.o(.rom_cpu_after_sound_bridge_core) }
    .sound_bridge_definitions 0x800360F0 : AT(0x36CF0) SUBALIGN(4) { build/us/sound_bridge_definitions.o(.text) }
    .sound_request_dispatch 0x8003614C : AT(0x36D4C) SUBALIGN(4) { build/us/sound_request_dispatch.o(.text) }
    .sound_bridge_future_reset 0x800361FC : AT(0x36DFC) SUBALIGN(4) { build/us/sound_bridge_future_reset.o(.text) }
    .sound_bridge_future_queue 0x80036288 : AT(0x36E88) SUBALIGN(4) { build/us/sound_bridge_future_queue.o(.text) }
    .sound_bridge_future_update 0x80036318 : AT(0x36F18) SUBALIGN(4) { build/us/sound_bridge_future_update.o(.text) }
    .destination_format 0x800363D0 : AT(0x36FD0) SUBALIGN(4) { build/us/destination_format.o(.text) }
    .resource_cache_fallback_37268_37270 0x80036668 : AT(0x37268) { build/us/fallback.o(.rom_resource_cache_fallback_37268_37270) }
    .scene_glyph_release 0x80036670 : AT(0x37270) SUBALIGN(4) { build/us/scene_glyph_release.o(.text) }
    .actor_scatter_spawn 0x800366C8 : AT(0x372C8) SUBALIGN(4) { build/us/actor_scatter_spawn.o(.text) }
    .scene_actor_scale 0x800369C8 : AT(0x375C8) SUBALIGN(4) { build/us/scene_actor_scale.o(.text) }
    .actor_fragment_spawn 0x80036B00 : AT(0x37700) SUBALIGN(4) { build/us/actor_fragment_spawn.o(.text) }
    .scene_actor_motion_reset 0x80036DC8 : AT(0x379C8) SUBALIGN(4) { build/us/scene_actor_motion_reset.o(.text) }
    .scene_service_noop 0x80036ED0 : AT(0x37AD0) SUBALIGN(4) { build/us/scene_service_noop.o(.text) }
    .scene_parent_follow 0x80036ED8 : AT(0x37AD8) SUBALIGN(4) { build/us/scene_parent_follow.o(.text) }
    .scene_bonus_spawn 0x80037050 : AT(0x37C50) SUBALIGN(4) { build/us/scene_bonus_spawn.o(.text) }
    .scene_bucket_counter 0x80037144 : AT(0x37D44) SUBALIGN(4) { build/us/scene_bucket_counter.o(.text) }
    .cpu_after_scene_bucket_counter 0x800371FC : AT(0x37DFC) { build/us/fallback.o(.rom_cpu_after_scene_bucket_counter) }
    .debug_context_set 0x80037408 : AT(0x38008) SUBALIGN(4) { build/us/debug_context_set.o(.text) }
    .cpu_after_debug_context_set 0x80037418 : AT(0x38018) { build/us/fallback.o(.rom_cpu_after_debug_context_set) }
    .debug_text_draw 0x80037420 : AT(0x38020) SUBALIGN(4) { build/us/debug_text_draw.o(.text) }
    .cpu_after_debug_text_draw 0x800374C8 : AT(0x380C8) { build/us/fallback.o(.rom_cpu_after_debug_text_draw) }
    .tweak_reset 0x800374D0 : AT(0x380D0) SUBALIGN(4) { build/us/tweak_reset.o(.text) }
    .tweak_page 0x80037508 : AT(0x38108) SUBALIGN(4) { build/us/tweak_page.o(.text) }
    .tweak_define 0x80037588 : AT(0x38188) SUBALIGN(4) { build/us/tweak_define.o(.text) }
    .tweak_difficulty_define 0x8003762C : AT(0x3822C) SUBALIGN(4) { build/us/tweak_difficulty_define.o(.text) }
    .tweak_difficulty_apply 0x80037700 : AT(0x38300) SUBALIGN(4) { build/us/tweak_difficulty_apply.o(.text) }
    .tweak_scene_apply 0x800377E4 : AT(0x383E4) SUBALIGN(4) { build/us/tweak_scene_apply.o(.text) }
    .tweak_scene_define 0x800378CC : AT(0x384CC) SUBALIGN(4) { build/us/tweak_scene_define.o(.text) }
    .tweak_bind 0x8003799C : AT(0x3859C) SUBALIGN(4) { build/us/tweak_bind.o(.text) }
    .tweak_bind_all 0x80037A20 : AT(0x38620) SUBALIGN(4) { build/us/tweak_bind_all.o(.text) }
    .tweak_scale_enemy_speeds 0x80038228 : AT(0x38E28) SUBALIGN(4) { build/us/tweak_scale_enemy_speeds.o(.text) }
    .resource_string_reset 0x80038390 : AT(0x38F90) SUBALIGN(4) { build/us/resource_string_reset.o(.text) }
    .string_resource 0x800383C4 : AT(0x38FC4) SUBALIGN(4) { build/us/string_resource.o(.text) }
    .resource_string_find 0x800383F8 : AT(0x38FF8) SUBALIGN(4) { build/us/resource_string_find.o(.text) }
    .resource_string_load 0x80038498 : AT(0x39098) SUBALIGN(4) { build/us/resource_string_load.o(.text) }
    .cpu_after_resource_string_load 0x8003856C : AT(0x3916C) { build/us/fallback.o(.rom_cpu_after_resource_string_load) }
    .scene_timer_capture 0x80038570 : AT(0x39170) SUBALIGN(4) { build/us/scene_timer_capture.o(.text) }
    .scene_frame_tick 0x80038598 : AT(0x39198) SUBALIGN(4) { build/us/scene_frame_tick.o(.text) }
    .scene_timer_initialize 0x800387C8 : AT(0x393C8) SUBALIGN(4) { build/us/scene_timer_initialize.o(.text) }
    .scene_timer_service 0x80038810 : AT(0x39410) SUBALIGN(4) { build/us/scene_timer_service.o(.text) }
    .cpu_after_scene_timer_service 0x80038830 : AT(0x39430) { build/us/fallback.o(.rom_cpu_after_scene_timer_service) }
    .object_service 0x8003919C : AT(0x39D9C) SUBALIGN(4) { build/us/object_service.o(.text) }
    .cpu_after_object_service 0x800391BC : AT(0x39DBC) { build/us/fallback.o(.rom_cpu_after_object_service) }
    .object_registration 0x800391C0 : AT(0x39DC0) SUBALIGN(4) { build/us/object_registration.o(.text) }
    .object_creation 0x8003921C : AT(0x39E1C) SUBALIGN(4) { build/us/object_creation.o(.text) }
    .object_model_access 0x800393DC : AT(0x39FDC) SUBALIGN(4) { build/us/object_model_access.o(.text) }
    .object_transforms 0x800394C0 : AT(0x3A0C0) { build/us/object_transforms.o(.text) }
    .object_helpers 0x80039C78 : AT(0x3A878) SUBALIGN(4) { build/us/object_helpers.o(.text) }
    .object_helpers_index_limit 0x80039CD0 : AT(0x3A8D0) SUBALIGN(4) { build/us/object_helpers_index_limit.o(.text) }
    .object_helpers_index_set 0x80039D4C : AT(0x3A94C) SUBALIGN(4) { build/us/object_helpers_index_set.o(.text) }
    .object_helpers_properties 0x80039DAC : AT(0x3A9AC) SUBALIGN(4) { build/us/object_helpers_properties.o(.text) }
    .object_helpers_camera_state 0x80039EA0 : AT(0x3AAA0) SUBALIGN(4) { build/us/object_helpers_camera_state.o(.text) }
    .object_helpers_camera_position 0x80039F10 : AT(0x3AB10) SUBALIGN(4) { build/us/object_helpers_camera_position.o(.text) }
    .object_camera_angles 0x80039FCC : AT(0x3ABCC) SUBALIGN(4) { build/us/object_camera_angles.o(.text) }
    .object_helpers_camera_position_alt 0x8003A070 : AT(0x3AC70) SUBALIGN(4) { build/us/object_helpers_camera_position_alt.o(.text) }
    .object_camera_angles_alt 0x8003A128 : AT(0x3AD28) SUBALIGN(4) { build/us/object_camera_angles_alt.o(.text) }
    .object_helpers_camera_accessors 0x8003A1C8 : AT(0x3ADC8) SUBALIGN(4) { build/us/object_helpers_camera_accessors.o(.text) }
    .object_helpers_pool_alloc 0x8003A2F8 : AT(0x3AEF8) SUBALIGN(4) { build/us/object_helpers_pool_alloc.o(.text) }
    .object_helpers_pool_status 0x8003A3F8 : AT(0x3AFF8) SUBALIGN(4) { build/us/object_helpers_pool_status.o(.text) }
    .object_reset 0x8003A460 : AT(0x3B060) SUBALIGN(4) { build/us/object_reset.o(.text) }
    .object_helpers_draw_noop 0x8003A4EC : AT(0x3B0EC) SUBALIGN(4) { build/us/object_helpers_draw_noop.o(.text) }
    .object_helpers_draw 0x8003A4F4 : AT(0x3B0F4) SUBALIGN(4) { build/us/object_helpers_draw.o(.text) }
    .object_helpers_draw_mode 0x8003A778 : AT(0x3B378) SUBALIGN(4) { build/us/object_helpers_draw_mode.o(.text) }
    .cpu_after_object_helpers_draw_mode 0x8003A8B0 : AT(0x3B4B0) { build/us/fallback.o(.rom_cpu_after_object_helpers_draw_mode) }
    .object_runtime_service 0x8003B254 : AT(0x3BE54) SUBALIGN(4) { build/us/object_runtime_service.o(.text) }
    .cpu_after_object_runtime_service 0x8003B2B0 : AT(0x3BEB0) { build/us/fallback.o(.rom_cpu_after_object_runtime_service) }
    .object_runtime_active 0x8003B428 : AT(0x3C028) SUBALIGN(4) { build/us/object_runtime_active.o(.text) }
    .game_memory 0x8003B4C0 : AT(0x3C0C0) SUBALIGN(4) { build/us/game_memory.o(.text) }
    .game_string_append 0x8003B734 : AT(0x3C334) SUBALIGN(4) { build/us/game_string_append.o(.text) }
    .game_string_case_compare 0x8003B768 : AT(0x3C368) SUBALIGN(4) { build/us/game_string_case_compare.o(.text) }
    .game_string_compare 0x8003B7FC : AT(0x3C3FC) SUBALIGN(4) { build/us/game_string_compare.o(.text) }
    .game_string_case_compare_n 0x8003B838 : AT(0x3C438) SUBALIGN(4) { build/us/game_string_case_compare_n.o(.text) }
    .game_string_compare_n 0x8003B8E0 : AT(0x3C4E0) SUBALIGN(4) { build/us/game_string_compare_n.o(.text) }
    .game_number_format 0x8003B928 : AT(0x3C528) SUBALIGN(4) { build/us/game_number_format.o(.text) }
    .game_character 0x8003BBAC : AT(0x3C7AC) SUBALIGN(4) { build/us/game_character.o(.text) }
    .game_integer_parse 0x8003BD4C : AT(0x3C94C) SUBALIGN(4) { build/us/game_integer_parse.o(.text) }
    .game_float_parse 0x8003BDE8 : AT(0x3C9E8) SUBALIGN(4) { build/us/game_float_parse.o(.text) }
    .platform_empty 0x8003BF5C : AT(0x3CB5C) SUBALIGN(4) { build/us/platform_empty.o(.text) }
    .palette 0x8003BFEC : AT(0x3CBEC) SUBALIGN(4) { build/us/palette.o(.text) }
    .controller_button 0x8003C180 : AT(0x3CD80) SUBALIGN(4) { build/us/controller_button.o(.text) }
    .controller_input 0x8003C1A8 : AT(0x3CDA8) SUBALIGN(4) { build/us/controller_input.o(.text) }
    .controller_axes 0x8003C4C8 : AT(0x3D0C8) SUBALIGN(4) { build/us/controller_axes.o(.text) }
    .platform_io 0x8003C5C4 : AT(0x3D1C4) SUBALIGN(4) { build/us/platform_io.o(.text) }
    .model_file_relocate 0x8003C6B8 : AT(0x3D2B8) SUBALIGN(4) { build/us/model_file_relocate.o(.text) }
    .resource_bridge_model_cache 0x8003C94C : AT(0x3D54C) SUBALIGN(4) { build/us/resource_bridge_model_cache.o(.text) }
    .resource_bridge_texture_stub 0x8003CA24 : AT(0x3D624) SUBALIGN(4) { build/us/resource_bridge_texture_stub.o(.text) }
    .resource_bridge_bitmap 0x8003CA34 : AT(0x3D634) SUBALIGN(4) { build/us/resource_bridge_bitmap.o(.text) }
    .resource_bridge_animation 0x8003CB10 : AT(0x3D710) SUBALIGN(4) { build/us/resource_bridge_animation.o(.text) }
    .object_recovery_path_extension 0x8003CBEC : AT(0x3D7EC) SUBALIGN(4) { build/us/object_recovery_path_extension.o(.text) }
    .geometry_debug_bridge 0x8003CC30 : AT(0x3D830) SUBALIGN(4) { build/us/geometry_debug_bridge.o(.text) }
    .object_recovery_fixed_trig 0x8003CC58 : AT(0x3D858) SUBALIGN(4) { build/us/object_recovery_fixed_trig.o(.text) }
    .object_recovery_integer_sqrt 0x8003CCE8 : AT(0x3D8E8) SUBALIGN(4) { build/us/object_recovery_integer_sqrt.o(.text) }
    .object_recovery_angle_scale 0x8003CD4C : AT(0x3D94C) SUBALIGN(4) { build/us/object_recovery_angle_scale.o(.text) }
    .object_recovery_direction_angle 0x8003CD70 : AT(0x3D970) SUBALIGN(4) { build/us/object_recovery_direction_angle.o(.text) }
    .object_recovery_angle_table 0x8003CEF4 : AT(0x3DAF4) SUBALIGN(4) { build/us/object_recovery_angle_table.o(.text) }
    .game_debug_format 0x8003CF88 : AT(0x3DB88) SUBALIGN(4) { build/us/game_debug_format.o(.text) }
    .cpu_after_game_debug_format 0x8003D164 : AT(0x3DD64) { build/us/fallback.o(.rom_cpu_after_game_debug_format) }
    .geometry_bridge_apply 0x8003D170 : AT(0x3DD70) SUBALIGN(4) { build/us/geometry_bridge_apply.o(.text) }
    .geometry_bridge_rotate 0x8003D20C : AT(0x3DE0C) SUBALIGN(4) { build/us/geometry_bridge_rotate.o(.text) }
    .model_rotation 0x8003D2C0 : AT(0x3DEC0) SUBALIGN(4) { build/us/model_rotation.o(.text) }
    .cpu_after_model_rotation 0x8003D43C : AT(0x3E03C) { build/us/fallback.o(.rom_cpu_after_model_rotation) }
    .model_polygons_plain 0x8003EB7C : AT(0x3F77C) SUBALIGN(4) { build/us/model_polygons_plain.o(.text) }
    .model_polygons_color 0x8003EC98 : AT(0x3F898) SUBALIGN(4) { build/us/model_polygons_color.o(.text) }
    .model_normal_polygon_dispatch 0x8003EE20 : AT(0x3FA20) SUBALIGN(4) { build/us/model_normal_polygon_dispatch.o(.text) }
    .model_hierarchy_vertices 0x8003F168 : AT(0x3FD68) SUBALIGN(4) { build/us/model_hierarchy_vertices.o(.text) }
    .model_hierarchy_transform 0x8003F314 : AT(0x3FF14) SUBALIGN(4) { build/us/model_hierarchy_transform.o(.text) }
    .endgame_40080_4022c 0x8003F480 : AT(0x40080) { build/us/fallback.o(.rom_endgame_40080_4022c) }
    .model_camera_identity 0x8003F62C : AT(0x4022C) SUBALIGN(4) { build/us/model_camera_identity.o(.text) }
    .model_camera_rotation 0x8003F650 : AT(0x40250) SUBALIGN(4) { build/us/model_camera_rotation.o(.text) }
    .model_mesh_iteration 0x8003F7F4 : AT(0x403F4) SUBALIGN(4) { build/us/model_mesh_iteration.o(.text) }
    .model_normals_blend 0x8003F818 : AT(0x40418) SUBALIGN(4) { build/us/model_normals_blend.o(.text) }
    .geometry_axis_scale 0x8003FA18 : AT(0x40618) SUBALIGN(4) { build/us/geometry_axis_scale.o(.text) }
    .geometry_uniform_scale 0x8003FC14 : AT(0x40814) SUBALIGN(4) { build/us/geometry_uniform_scale.o(.text) }
    .endgame_409c4_40c0c 0x8003FDC4 : AT(0x409C4) { build/us/fallback.o(.rom_endgame_409c4_40c0c) }
    .model_vertices_scatter 0x8004000C : AT(0x40C0C) SUBALIGN(4) { build/us/model_vertices_scatter.o(.text) }
    .cpu_after_model_vertices_scatter 0x800400C4 : AT(0x40CC4) { build/us/fallback.o(.rom_cpu_after_model_vertices_scatter) }
    .model_framebuffer_copy 0x800404F4 : AT(0x410F4) SUBALIGN(4) { build/us/model_framebuffer_copy.o(.text) }
    .model_framebuffer_draw 0x80040560 : AT(0x41160) SUBALIGN(4) { build/us/model_framebuffer_draw.o(.text) }
    .cpu_after_model_framebuffer_draw 0x80040724 : AT(0x41324) { build/us/fallback.o(.rom_cpu_after_model_framebuffer_draw) }
    .model_framebuffer_texture 0x80040874 : AT(0x41474) SUBALIGN(4) { build/us/model_framebuffer_texture.o(.text) }
    .endgame_41568_43430 0x80040968 : AT(0x41568) { build/us/fallback.o(.rom_endgame_41568_43430) }
    .renderer_texture_file_cache 0x80042830 : AT(0x43430) SUBALIGN(4) { build/us/renderer_texture_file_cache.o(.text) }
    .endgame_434c0_43c70 0x800428C0 : AT(0x434C0) { build/us/fallback.o(.rom_endgame_434c0_43c70) }
    .renderer_camera_square 0x80043070 : AT(0x43C70) SUBALIGN(4) { build/us/renderer_camera_square.o(.text) }
    .endgame_43dc0_44530 0x800431C0 : AT(0x43DC0) { build/us/fallback.o(.rom_endgame_43dc0_44530) }
    .renderer_vertex_attributes 0x80043930 : AT(0x44530) SUBALIGN(4) { build/us/renderer_vertex_attributes.o(.text) }
    .renderer_material_texture 0x80043D68 : AT(0x44968) SUBALIGN(4) { build/us/renderer_material_texture.o(.text) }
    .renderer_material_light 0x80043E80 : AT(0x44A80) SUBALIGN(4) { build/us/renderer_material_light.o(.text) }
    .renderer_material_combined 0x80043EEC : AT(0x44AEC) SUBALIGN(4) { build/us/renderer_material_combined.o(.text) }
    .renderer_light_select 0x8004417C : AT(0x44D7C) SUBALIGN(4) { build/us/renderer_light_select.o(.text) }
    .renderer_material_untextured 0x800441D0 : AT(0x44DD0) SUBALIGN(4) { build/us/renderer_material_untextured.o(.text) }
    .renderer_vertex_positions 0x80044270 : AT(0x44E70) SUBALIGN(4) { build/us/renderer_vertex_positions.o(.text) }
    .renderer_expanded_triangle 0x800444F8 : AT(0x450F8) SUBALIGN(4) { build/us/renderer_expanded_triangle.o(.text) }
    .endgame_453d0_45718 0x800447D0 : AT(0x453D0) { build/us/fallback.o(.rom_endgame_453d0_45718) }
    .renderer_textured_submit 0x80044B18 : AT(0x45718) SUBALIGN(4) { build/us/renderer_textured_submit.o(.text) }
    .renderer_opaque_quad 0x80044F60 : AT(0x45B60) SUBALIGN(4) { build/us/renderer_opaque_quad.o(.text) }
    .renderer_quad_submit 0x80045124 : AT(0x45D24) SUBALIGN(4) { build/us/renderer_quad_submit.o(.text) }
    .renderer_alpha_quad 0x80045214 : AT(0x45E14) SUBALIGN(4) { build/us/renderer_alpha_quad.o(.text) }
    .polygon_fallback_45fd8_46114 0x800453D8 : AT(0x45FD8) { build/us/fallback.o(.rom_polygon_fallback_45fd8_46114) }
    .renderer_material_reset 0x80045514 : AT(0x46114) SUBALIGN(4) { build/us/renderer_material_reset.o(.text) }
    .renderer_mesh_submit 0x80045534 : AT(0x46134) SUBALIGN(4) { build/us/renderer_mesh_submit.o(.text) }
    .renderer_mesh_positions 0x80045934 : AT(0x46534) SUBALIGN(4) { build/us/renderer_mesh_positions.o(.text) }
    .cpu_after_renderer_mesh_positions 0x80045A08 : AT(0x46608) { build/us/fallback.o(.rom_cpu_after_renderer_mesh_positions) }
    .renderer_vertex_copy 0x80045F40 : AT(0x46B40) SUBALIGN(4) { build/us/renderer_vertex_copy.o(.text) }
    .renderer_texture_load 0x800462DC : AT(0x46EDC) SUBALIGN(4) { build/us/renderer_texture_load.o(.text) }
    .graphics_display_list 0x800464F4 : AT(0x470F4) SUBALIGN(4) { build/us/graphics_display_list.o(.text) }
    .graphics_resource 0x8004653C : AT(0x4713C) SUBALIGN(4) { build/us/graphics_resource.o(.text) }
    .cpu_after_graphics_resource 0x800465AC : AT(0x471AC) { build/us/fallback.o(.rom_cpu_after_graphics_resource) }
    .palette_tint 0x800465B0 : AT(0x471B0) SUBALIGN(4) { build/us/palette_tint.o(.text) }
    .graphics_modes 0x80046608 : AT(0x47208) SUBALIGN(4) { build/us/graphics_modes.o(.text) }
    .renderer_tile_origin_mode 0x80046C2C : AT(0x4782C) SUBALIGN(4) { build/us/renderer_tile_origin_mode.o(.text) }
    .graphics_lights 0x80046CF8 : AT(0x478F8) SUBALIGN(4) { build/us/graphics_lights.o(.text) }
    .graphics_pool 0x80046F50 : AT(0x47B50) SUBALIGN(4) { build/us/graphics_pool.o(.text) }
    .graphics_pool_initialize 0x800470F4 : AT(0x47CF4) SUBALIGN(4) { build/us/graphics_pool_initialize.o(.text) }
    .graphics_frame_reset 0x8004717C : AT(0x47D7C) SUBALIGN(4) { build/us/graphics_frame_reset.o(.text) }
    .graphics_mode_dispatch 0x8004729C : AT(0x47E9C) SUBALIGN(4) { build/us/graphics_mode_dispatch.o(.text) }
    .graphics_environment 0x800474B8 : AT(0x480B8) SUBALIGN(4) { build/us/graphics_environment.o(.text) }
    .matrix_transform_fallback_48168_48170 0x80047568 : AT(0x48168) { build/us/fallback.o(.rom_matrix_transform_fallback_48168_48170) }
    .renderer_matrix_transform 0x80047570 : AT(0x48170) SUBALIGN(4) { build/us/renderer_matrix_transform.o(.text) }
    .renderer_matrix_scale 0x80047A08 : AT(0x48608) SUBALIGN(4) { build/us/renderer_matrix_scale.o(.text) }
    .renderer_matrix_submit 0x80047D88 : AT(0x48988) SUBALIGN(4) { build/us/renderer_matrix_submit.o(.text) }
    .fixed_matrix_rsp 0x80048020 : AT(0x48C20) SUBALIGN(4) { build/us/fixed_matrix_rsp.o(.text) }
    .endgame_48d64_48d70 0x80048164 : AT(0x48D64) { build/us/fallback.o(.rom_endgame_48d64_48d70) }
    .startup 0x80048170 : AT(0x48D70) SUBALIGN(16) { build/us/startup.o(.text) }
    .cpu_after_startup 0x80048510 : AT(0x49110) { build/us/fallback.o(.rom_cpu_after_startup) }
    .frame_render 0x800489F4 : AT(0x495F4) SUBALIGN(4) { build/us/frame_render.o(.text) }
    .frame_helpers 0x80048B8C : AT(0x4978C) SUBALIGN(4) { build/us/frame_helpers.o(.text) }
    .debug_noop 0x80048DC0 : AT(0x499C0) SUBALIGN(4) { build/us/debug_noop.o(.text) }
    .endgame_499dc_49d3c 0x80048DDC : AT(0x499DC) { build/us/fallback.o(.rom_endgame_499dc_49d3c) }
    .renderer_projection_highlight 0x8004913C : AT(0x49D3C) SUBALIGN(4) { build/us/renderer_projection_highlight.o(.text) }
    .frame_projection 0x800493F4 : AT(0x49FF4) SUBALIGN(4) { build/us/frame_projection.o(.text) }
    .frame_matrices 0x80049514 : AT(0x4A114) SUBALIGN(4) { build/us/frame_matrices.o(.text) }
    .frame_timing 0x800495BC : AT(0x4A1BC) SUBALIGN(4) { build/us/frame_timing.o(.text) }
    .cpu_after_frame_timing 0x800496E0 : AT(0x4A2E0) { build/us/fallback.o(.rom_cpu_after_frame_timing) }
    .graphics_ucode 0x800498E0 : AT(0x4A4E0) SUBALIGN(4) { build/us/graphics_ucode.o(.text) }
    .cpu_before_renderer_platform 0x800498EC : AT(0x4A4EC) { build/us/fallback.o(.rom_cpu_before_renderer_platform) }
    .renderer_glyph_map 0x800498F0 : AT(0x4A4F0) SUBALIGN(4) { build/us/renderer_glyph_map.o(.text) }
    .renderer_platform 0x80049AD8 : AT(0x4A6D8) SUBALIGN(4) { build/us/renderer_platform.o(.text) }
    .graphics_state_helpers 0x80049DB0 : AT(0x4A9B0) SUBALIGN(4) { build/us/graphics_state_helpers.o(.text) }
    .endgame_4aa3c_4b2b4 0x80049E3C : AT(0x4AA3C) { build/us/fallback.o(.rom_endgame_4aa3c_4b2b4) }
    .renderer_texture_squares 0x8004A6B4 : AT(0x4B2B4) SUBALIGN(4) { build/us/renderer_texture_squares.o(.text) }
    .renderer_flag_set 0x8004ABBC : AT(0x4B7BC) SUBALIGN(4) { build/us/renderer_flag_set.o(.text) }
    .renderer_texture_defaults 0x8004ABC8 : AT(0x4B7C8) SUBALIGN(4) { build/us/renderer_texture_defaults.o(.text) }
    .endgame_4b8a4_4b964 0x8004ACA4 : AT(0x4B8A4) { build/us/fallback.o(.rom_endgame_4b8a4_4b964) }
    .renderer_image_quad_ci 0x8004AD64 : AT(0x4B964) SUBALIGN(4) { build/us/renderer_image_quad_ci.o(.text) }
    .endgame_4bba4_4bc98 0x8004AFA4 : AT(0x4BBA4) { build/us/fallback.o(.rom_endgame_4bba4_4bc98) }
    .renderer_image_quad_rgba 0x8004B098 : AT(0x4BC98) SUBALIGN(4) { build/us/renderer_image_quad_rgba.o(.text) }
    .endgame_4bed8_4bee0 0x8004B2D8 : AT(0x4BED8) { build/us/fallback.o(.rom_endgame_4bed8_4bee0) }
    .renderer_digit_extract 0x8004B2E0 : AT(0x4BEE0) SUBALIGN(4) { build/us/renderer_digit_extract.o(.text) }
    .renderer_status_text 0x8004B340 : AT(0x4BF40) SUBALIGN(4) { build/us/renderer_status_text.o(.text) }
    .renderer_number_forward 0x8004B45C : AT(0x4C05C) SUBALIGN(4) { build/us/renderer_number_forward.o(.text) }
    .renderer_number_reverse 0x8004B4F8 : AT(0x4C0F8) SUBALIGN(4) { build/us/renderer_number_reverse.o(.text) }
    .endgame_4c190_4c7d0 0x8004B590 : AT(0x4C190) { build/us/fallback.o(.rom_endgame_4c190_4c7d0) }
    .render_buffer_reserve 0x8004BBD0 : AT(0x4C7D0) SUBALIGN(4) { build/us/render_buffer_reserve.o(.text) }
    .render_buffer_allocate 0x8004BC44 : AT(0x4C844) SUBALIGN(4) { build/us/render_buffer_allocate.o(.text) }
    .renderer_cache_flags_clear 0x8004BC8C : AT(0x4C88C) SUBALIGN(4) { build/us/renderer_cache_flags_clear.o(.text) }
    .endgame_4c900_4cc90 0x8004BD00 : AT(0x4C900) { build/us/fallback.o(.rom_endgame_4c900_4cc90) }
    .controller_legacy_initialize 0x8004C090 : AT(0x4CC90) SUBALIGN(4) { build/us/controller_legacy_initialize.o(.text) }
    .controller_legacy_scan 0x8004C0D4 : AT(0x4CCD4) SUBALIGN(4) { build/us/controller_legacy_scan.o(.text) }
    .controller_legacy_present 0x8004C1C8 : AT(0x4CDC8) SUBALIGN(4) { build/us/controller_legacy_present.o(.text) }
    .cpu_after_controller_legacy_present 0x8004C1E0 : AT(0x4CDE0) { build/us/fallback.o(.rom_cpu_after_controller_legacy_present) }
    .pak_file_status 0x8004C378 : AT(0x4CF78) SUBALIGN(4) { build/us/pak_file_status.o(.text) }
    .pak_file_open 0x8004C3AC : AT(0x4CFAC) SUBALIGN(4) { build/us/pak_file_open.o(.text) }
    .pak_file_read 0x8004C564 : AT(0x4D164) SUBALIGN(4) { build/us/pak_file_read.o(.text) }
    .pak_file_write 0x8004C5DC : AT(0x4D1DC) SUBALIGN(4) { build/us/pak_file_write.o(.text) }
    .pak_file_close 0x8004C648 : AT(0x4D248) SUBALIGN(4) { build/us/pak_file_close.o(.text) }
    .pak_file_encode_name 0x8004C65C : AT(0x4D25C) SUBALIGN(4) { build/us/pak_file_encode_name.o(.text) }
    .projection_diagnostic_fallback_4d2dc_4d2e0 0x8004C6DC : AT(0x4D2DC) { build/us/fallback.o(.rom_projection_diagnostic_fallback_4d2dc_4d2e0) }
    .renderer_diagnostic_report 0x8004C6E0 : AT(0x4D2E0) SUBALIGN(4) { build/us/renderer_diagnostic_report.o(.text) }
    .runtime_buffer_clear 0x8004CCA4 : AT(0x4D8A4) SUBALIGN(4) { build/us/runtime_buffer_clear.o(.text) }
    .renderer_metrics_update 0x8004CCD0 : AT(0x4D8D0) SUBALIGN(4) { build/us/renderer_metrics_update.o(.text) }
    .endgame_4d9b4_4d9c0 0x8004CDB4 : AT(0x4D9B4) { build/us/fallback.o(.rom_endgame_4d9b4_4d9c0) }
    .runtime_sign 0x8004CDC0 : AT(0x4D9C0) SUBALIGN(4) { build/us/runtime_sign.o(.text) }
    .runtime_random 0x8004CDE8 : AT(0x4D9E8) SUBALIGN(4) { build/us/runtime_random.o(.text) }
    .runtime_angle 0x8004CE08 : AT(0x4DA08) SUBALIGN(4) { build/us/runtime_angle.o(.text) }
    .runtime_float_truncate 0x8004CE70 : AT(0x4DA70) SUBALIGN(4) { build/us/runtime_float_truncate.o(.text) }
    .runtime_sine 0x8004CEB0 : AT(0x4DAB0) SUBALIGN(4) { build/us/runtime_sine.o(.text) }
    .fixed_geometry_setup 0x8004CED0 : AT(0x4DAD0) SUBALIGN(4) { build/us/fixed_geometry_setup.o(.text) }
    .frame_transform 0x8004D4B4 : AT(0x4E0B4) SUBALIGN(4) { build/us/frame_transform.o(.text) }
    .fixed_geometry 0x8004D59C : AT(0x4E19C) SUBALIGN(4) { build/us/fixed_geometry.o(.text) }
    .fixed_math 0x8004DB34 : AT(0x4E734) SUBALIGN(4) { build/us/fixed_math.o(.text) }
    .cpu_after_fixed_math 0x8004DC68 : AT(0x4E868) { build/us/fallback.o(.rom_cpu_after_fixed_math) }
    .heap 0x8004DC70 : AT(0x4E870) SUBALIGN(4) { build/us/heap.o(.text) }
    .cpu_after_heap 0x8004DE8C : AT(0x4EA8C) { build/us/fallback.o(.rom_cpu_after_heap) }
    .heap_empty 0x8004DED8 : AT(0x4EAD8) SUBALIGN(4) { build/us/heap_empty.o(.text) }
    .actor_history_tick 0x8004DEE0 : AT(0x4EAE0) SUBALIGN(4) { build/us/actor_history_tick.o(.text) }
    .object_history 0x8004E168 : AT(0x4ED68) SUBALIGN(4) { build/us/object_history.o(.text) }
    .actor_history_projectile 0x8004E1C0 : AT(0x4EDC0) SUBALIGN(4) { build/us/actor_history_projectile.o(.text) }
    .endgame_4ef64_4f3d4 0x8004E364 : AT(0x4EF64) { build/us/fallback.o(.rom_endgame_4ef64_4f3d4) }
    .frame_slot_allocate 0x8004E7D4 : AT(0x4F3D4) SUBALIGN(4) { build/us/frame_slot_allocate.o(.text) }
    .object_history_write 0x8004E820 : AT(0x4F420) SUBALIGN(4) { build/us/object_history_write.o(.text) }
    .object_history_render 0x8004E968 : AT(0x4F568) SUBALIGN(4) { build/us/object_history_render.o(.text) }
    .actor_history_byte_clear 0x8004EB60 : AT(0x4F760) SUBALIGN(4) { build/us/actor_history_byte_clear.o(.text) }
    .cpu_after_actor_history_byte_clear 0x8004EB74 : AT(0x4F774) { build/us/fallback.o(.rom_cpu_after_actor_history_byte_clear) }
    .rom_directory 0x8004EB80 : AT(0x4F780) SUBALIGN(4) { build/us/rom_directory.o(.text) }
    .rom_file_error 0x8004ED14 : AT(0x4F914) SUBALIGN(4) { build/us/rom_file_error.o(.text) }
    .rom_files 0x8004ED78 : AT(0x4F978) SUBALIGN(4) { build/us/rom_files.o(.text) }
    .cpu_after_rom_files 0x8004EFA8 : AT(0x4FBA8) { build/us/fallback.o(.rom_cpu_after_rom_files) }
    .controller_access 0x8004EFB0 : AT(0x4FBB0) SUBALIGN(4) { build/us/controller_access.o(.text) }
    .controller_motor_commands 0x8004F178 : AT(0x4FD78) SUBALIGN(4) { build/us/controller_motor_commands.o(.text) }
    .controller_scan 0x8004F1EC : AT(0x4FDEC) SUBALIGN(4) { build/us/controller_scan.o(.text) }
    .endgame_4ff30_500d8 0x8004F330 : AT(0x4FF30) { build/us/fallback.o(.rom_endgame_4ff30_500d8) }
    .controller_service_setup 0x8004F4D8 : AT(0x500D8) SUBALIGN(4) { build/us/controller_service_setup.o(.text) }
    .controller_motor_duty 0x8004F850 : AT(0x50450) SUBALIGN(4) { build/us/controller_motor_duty.o(.text) }
    .frame_interval_set 0x8004F960 : AT(0x50560) SUBALIGN(4) { build/us/frame_interval_set.o(.text) }
    .endgame_50584_50590 0x8004F984 : AT(0x50584) { build/us/fallback.o(.rom_endgame_50584_50590) }
    .controller_pak_info 0x8004F990 : AT(0x50590) SUBALIGN(4) { build/us/controller_pak_info.o(.text) }
    .controller_pak_delete 0x8004FA14 : AT(0x50614) SUBALIGN(4) { build/us/controller_pak_delete.o(.text) }
    .controller_pak_name 0x8004FAC0 : AT(0x506C0) SUBALIGN(4) { build/us/controller_pak_name.o(.text) }
    .controller_pak_entry 0x8004FB48 : AT(0x50748) SUBALIGN(4) { build/us/controller_pak_entry.o(.text) }
    .controller_pak_directory 0x8004FC98 : AT(0x50898) SUBALIGN(4) { build/us/controller_pak_directory.o(.text) }
    .cpu_after_controller_pak_directory 0x8004FE04 : AT(0x50A04) { build/us/fallback.o(.rom_cpu_after_controller_pak_directory) }
    .graphics_setup 0x8004FE10 : AT(0x50A10) SUBALIGN(4) { build/us/graphics_setup.o(.text) }
    .graphics_tasks 0x80050084 : AT(0x50C84) SUBALIGN(4) { build/us/graphics_tasks.o(.text) }
    .scheduler 0x80050440 : AT(0x51040) { build/us/scheduler.o(.text) }
    .scheduler_runtime_tail 0x80050FB0 : AT(0x51BB0) SUBALIGN(4) { build/us/scheduler_runtime_tail.o(.text) }
    .audio_startup 0x8005109C : AT(0x51C9C) SUBALIGN(4) { build/us/audio_startup.o(.text) }
    .audio_thread 0x80051380 : AT(0x51F80) SUBALIGN(4) { build/us/audio_thread.o(.text) }
    .audio_generation 0x800515B0 : AT(0x521B0) SUBALIGN(4) { build/us/audio_generation.o(.text) }
    .audio_game_helpers 0x80051854 : AT(0x52454) SUBALIGN(4) { build/us/audio_game_helpers.o(.text) }
    .audio_io 0x800518E0 : AT(0x524E0) SUBALIGN(4) { build/us/audio_io.o(.text) }
    .cpu_after_audio_io 0x80051A0C : AT(0x5260C) { build/us/fallback.o(.rom_cpu_after_audio_io) }
    .audio_task_select 0x8005211C : AT(0x52D1C) SUBALIGN(4) { build/us/audio_task_select.o(.text) }
    .audio_task_build 0x800521C8 : AT(0x52DC8) SUBALIGN(4) { build/us/audio_task_build.o(.text) }
    .audio_dma_read 0x80052378 : AT(0x52F78) SUBALIGN(4) { build/us/audio_dma_read.o(.text) }
    .audio_pool_callback 0x8005254C : AT(0x5314C) SUBALIGN(4) { build/us/audio_pool_callback.o(.text) }
    .audio_dma_recycle 0x80052580 : AT(0x53180) SUBALIGN(4) { build/us/audio_dma_recycle.o(.text) }
    .audio_shutdown 0x800526D0 : AT(0x532D0) SUBALIGN(4) { build/us/audio_shutdown.o(.text) }
    .cpu_after_audio_shutdown 0x800526FC : AT(0x532FC) { build/us/fallback.o(.rom_cpu_after_audio_shutdown) }
    .audio_callback_registration 0x80052700 : AT(0x53300) SUBALIGN(4) { build/us/audio_callback_registration.o(.text) }
    .audio_callback_return 0x80052754 : AT(0x53354) SUBALIGN(4) { build/us/audio_callback_return.o(.text) }
    .cpu_after_audio_callback_return 0x80052774 : AT(0x53374) { build/us/fallback.o(.rom_cpu_after_audio_callback_return) }
    .audio_config 0x80052780 : AT(0x53380) SUBALIGN(4) { build/us/audio_config.o(.text) }
    .audio_control 0x80052A00 : AT(0x53600) SUBALIGN(4) { build/us/audio_control.o(.text) }
    .audio_memory_size 0x80052D70 : AT(0x53970) SUBALIGN(4) { build/us/audio_memory_size.o(.text) }
    .endgame_53c3c_5422c 0x8005303C : AT(0x53C3C) { build/us/fallback.o(.rom_endgame_53c3c_5422c) }
    .audio_voice_defaults 0x8005362C : AT(0x5422C) SUBALIGN(4) { build/us/audio_voice_defaults.o(.text) }
    .audio_voice_sequence_bind 0x800538F8 : AT(0x544F8) SUBALIGN(4) { build/us/audio_voice_sequence_bind.o(.text) }
    .endgame_5456c_54850 0x8005396C : AT(0x5456C) { build/us/fallback.o(.rom_endgame_5456c_54850) }
    .audio_play 0x80053C50 : AT(0x54850) SUBALIGN(4) { build/us/audio_play.o(.text) }
    .audio_instance_state_query 0x80053CC0 : AT(0x548C0) SUBALIGN(4) { build/us/audio_instance_state_query.o(.text) }
    .audio_instance_stop 0x80053DAC : AT(0x549AC) SUBALIGN(4) { build/us/audio_instance_stop.o(.text) }
    .audio_stop_commands 0x80053EBC : AT(0x54ABC) SUBALIGN(4) { build/us/audio_stop_commands.o(.text) }
    .audio_voice_stop 0x80053F78 : AT(0x54B78) SUBALIGN(4) { build/us/audio_voice_stop.o(.text) }
    .audio_instance_stop_all 0x80054178 : AT(0x54D78) SUBALIGN(4) { build/us/audio_instance_stop_all.o(.text) }
    .audio_stop_all_commands 0x80054268 : AT(0x54E68) SUBALIGN(4) { build/us/audio_stop_all_commands.o(.text) }
    .audio_voice_stop_all 0x80054304 : AT(0x54F04) SUBALIGN(4) { build/us/audio_voice_stop_all.o(.text) }
    .audio_callback_add 0x800544F0 : AT(0x550F0) SUBALIGN(4) { build/us/audio_callback_add.o(.text) }
    .audio_callback_remove 0x800545F0 : AT(0x551F0) SUBALIGN(4) { build/us/audio_callback_remove.o(.text) }
    .audio_level_commands 0x80054720 : AT(0x55320) SUBALIGN(4) { build/us/audio_level_commands.o(.text) }
    .audio_level_update 0x800547FC : AT(0x553FC) SUBALIGN(4) { build/us/audio_level_update.o(.text) }
    .audio_level_commands_alt 0x800549DC : AT(0x555DC) SUBALIGN(4) { build/us/audio_level_commands_alt.o(.text) }
    .audio_level_update_alt 0x80054A48 : AT(0x55648) SUBALIGN(4) { build/us/audio_level_update_alt.o(.text) }
    .audio_mode 0x80054C24 : AT(0x55824) SUBALIGN(4) { build/us/audio_mode.o(.text) }
    .cpu_after_audio_mode 0x80054C44 : AT(0x55844) { build/us/fallback.o(.rom_cpu_after_audio_mode) }
    .audio_voice_pause_state 0x80054C50 : AT(0x55850) SUBALIGN(4) { build/us/audio_voice_pause_state.o(.text) }
    .audio_pause_request 0x80054CF0 : AT(0x558F0) SUBALIGN(4) { build/us/audio_pause_request.o(.text) }
    .audio_pause_decode 0x80054DB8 : AT(0x559B8) SUBALIGN(4) { build/us/audio_pause_decode.o(.text) }
    .audio_pause_apply 0x80054DF8 : AT(0x559F8) SUBALIGN(4) { build/us/audio_pause_apply.o(.text) }
    .audio_resume_request 0x80054FC4 : AT(0x55BC4) SUBALIGN(4) { build/us/audio_resume_request.o(.text) }
    .audio_resume_decode 0x8005507C : AT(0x55C7C) SUBALIGN(4) { build/us/audio_resume_decode.o(.text) }
    .audio_resume_apply 0x800550AC : AT(0x55CAC) SUBALIGN(4) { build/us/audio_resume_apply.o(.text) }
    .audio_pause_all_request 0x80055214 : AT(0x55E14) SUBALIGN(4) { build/us/audio_pause_all_request.o(.text) }
    .audio_pause_all_decode 0x800552CC : AT(0x55ECC) SUBALIGN(4) { build/us/audio_pause_all_decode.o(.text) }
    .audio_pause_all_apply 0x8005530C : AT(0x55F0C) SUBALIGN(4) { build/us/audio_pause_all_apply.o(.text) }
    .audio_resume_all_request 0x800554F4 : AT(0x560F4) SUBALIGN(4) { build/us/audio_resume_all_request.o(.text) }
    .audio_resume_all_decode 0x8005559C : AT(0x5619C) SUBALIGN(4) { build/us/audio_resume_all_decode.o(.text) }
    .audio_resume_all_apply 0x800555CC : AT(0x561CC) SUBALIGN(4) { build/us/audio_resume_all_apply.o(.text) }
    .cpu_after_audio_resume_all_apply 0x80055758 : AT(0x56358) { build/us/fallback.o(.rom_cpu_after_audio_resume_all_apply) }
    .audio_play_arguments 0x80055760 : AT(0x56360) SUBALIGN(4) { build/us/audio_play_arguments.o(.text) }
    .audio_voice_properties_initial 0x800557FC : AT(0x563FC) SUBALIGN(4) { build/us/audio_voice_properties_initial.o(.text) }
    .audio_owner_properties_request 0x80055A60 : AT(0x56660) SUBALIGN(4) { build/us/audio_owner_properties_request.o(.text) }
    .audio_owner_properties_decode 0x80055AAC : AT(0x566AC) SUBALIGN(4) { build/us/audio_owner_properties_decode.o(.text) }
    .audio_owner_properties_apply 0x80055AE8 : AT(0x566E8) SUBALIGN(4) { build/us/audio_owner_properties_apply.o(.text) }
    .audio_owner_state_query 0x80055C6C : AT(0x5686C) SUBALIGN(4) { build/us/audio_owner_state_query.o(.text) }
    .audio_owner_stop_request 0x80055D58 : AT(0x56958) SUBALIGN(4) { build/us/audio_owner_stop_request.o(.text) }
    .audio_owner_stop_commands 0x80055E68 : AT(0x56A68) SUBALIGN(4) { build/us/audio_owner_stop_commands.o(.text) }
    .audio_owner_stop_apply 0x80055F24 : AT(0x56B24) SUBALIGN(4) { build/us/audio_owner_stop_apply.o(.text) }
    .cpu_after_audio_owner_stop_apply 0x80056124 : AT(0x56D24) { build/us/fallback.o(.rom_cpu_after_audio_owner_stop_apply) }
    .audio_instance_count 0x80056130 : AT(0x56D30) SUBALIGN(4) { build/us/audio_instance_count.o(.text) }
    .audio_instance_enumerate 0x800561E8 : AT(0x56DE8) SUBALIGN(4) { build/us/audio_instance_enumerate.o(.text) }
    .audio_owner_count 0x800562D4 : AT(0x56ED4) SUBALIGN(4) { build/us/audio_owner_count.o(.text) }
    .audio_owner_enumerate 0x8005638C : AT(0x56F8C) SUBALIGN(4) { build/us/audio_owner_enumerate.o(.text) }
    .after_audio_owner_enumerate 0x80056478 : AT(0x57078) { build/us/fallback.o(.rom_after_audio_owner_enumerate) }
    .audio_handle_instance 0x80056480 : AT(0x57080) SUBALIGN(4) { build/us/audio_handle_instance.o(.text) }
    .audio_handle_voice 0x800564E0 : AT(0x570E0) SUBALIGN(4) { build/us/audio_handle_voice.o(.text) }
    .audio_handle_create 0x80056580 : AT(0x57180) SUBALIGN(4) { build/us/audio_handle_create.o(.text) }
    .audio_handle_state 0x800565D8 : AT(0x571D8) SUBALIGN(4) { build/us/audio_handle_state.o(.text) }
    .audio_handle_release 0x80056648 : AT(0x57248) SUBALIGN(4) { build/us/audio_handle_release.o(.text) }
    .audio_handle_resume 0x80056780 : AT(0x57380) SUBALIGN(4) { build/us/audio_handle_resume.o(.text) }
    .audio_handle_resume_default 0x80056898 : AT(0x57498) SUBALIGN(4) { build/us/audio_handle_resume_default.o(.text) }
    .audio_handle_voice_resume 0x800568B8 : AT(0x574B8) SUBALIGN(4) { build/us/audio_handle_voice_resume.o(.text) }
    .audio_handle_voice_resume_default 0x80056944 : AT(0x57544) SUBALIGN(4) { build/us/audio_handle_voice_resume_default.o(.text) }
    .audio_handle_properties_capture 0x80056964 : AT(0x57564) SUBALIGN(4) { build/us/audio_handle_properties_capture.o(.text) }
    .audio_handle_properties_apply 0x80056A54 : AT(0x57654) SUBALIGN(4) { build/us/audio_handle_properties_apply.o(.text) }
    .audio_handle_stop 0x80056B44 : AT(0x57744) SUBALIGN(4) { build/us/audio_handle_stop.o(.text) }
    .audio_handle_rate 0x80056C58 : AT(0x57858) SUBALIGN(4) { build/us/audio_handle_rate.o(.text) }
    .audio_handle_validate_only 0x80056D88 : AT(0x57988) SUBALIGN(4) { build/us/audio_handle_validate_only.o(.text) }
    .audio_handle_rewind 0x80056DB0 : AT(0x579B0) SUBALIGN(4) { build/us/audio_handle_rewind.o(.text) }
    .cpu_after_audio_handle_rewind 0x80056EF0 : AT(0x57AF0) { build/us/fallback.o(.rom_cpu_after_audio_handle_rewind) }
    .audio_handle_seek_relative 0x80057358 : AT(0x57F58) SUBALIGN(4) { build/us/audio_handle_seek_relative.o(.text) }
    .audio_handle_seek_absolute 0x800574B8 : AT(0x580B8) SUBALIGN(4) { build/us/audio_handle_seek_absolute.o(.text) }
    .audio_handle_position 0x80057610 : AT(0x58210) SUBALIGN(4) { build/us/audio_handle_position.o(.text) }
    .audio_voice_command_parameter 0x800576E0 : AT(0x582E0) SUBALIGN(4) { build/us/audio_voice_command_parameter.o(.text) }
    .audio_voice_command_temporary 0x80057858 : AT(0x58458) SUBALIGN(4) { build/us/audio_voice_command_temporary.o(.text) }
    .audio_voice_properties_apply 0x8005789C : AT(0x5849C) SUBALIGN(4) { build/us/audio_voice_properties_apply.o(.text) }
    .audio_voice_properties_capture 0x80057B08 : AT(0x58708) SUBALIGN(4) { build/us/audio_voice_properties_capture.o(.text) }
    .cpu_after_audio_voice_properties_capture 0x80057C64 : AT(0x58864) { build/us/fallback.o(.rom_cpu_after_audio_voice_properties_capture) }
    .audio_handle_parameter_57c70 0x80057C70 : AT(0x58870) SUBALIGN(4) { build/us/audio_handle_parameter_57c70.o(.text) }
    .audio_handle_pair_request 0x80057C9C : AT(0x5889C) SUBALIGN(4) { build/us/audio_handle_pair_request.o(.text) }
    .audio_handle_pair_decode 0x80057D08 : AT(0x58908) SUBALIGN(4) { build/us/audio_handle_pair_decode.o(.text) }
    .audio_handle_pair_apply 0x80057D68 : AT(0x58968) SUBALIGN(4) { build/us/audio_handle_pair_apply.o(.text) }
    .audio_voice_command_18 0x80057E3C : AT(0x58A3C) SUBALIGN(4) { build/us/audio_voice_command_18.o(.text) }
    .audio_handle_parameter_57e94 0x80057E94 : AT(0x58A94) SUBALIGN(4) { build/us/audio_handle_parameter_57e94.o(.text) }
    .audio_handle_parameter_57ec0 0x80057EC0 : AT(0x58AC0) SUBALIGN(4) { build/us/audio_handle_parameter_57ec0.o(.text) }
    .audio_voice_command_10 0x80057EF0 : AT(0x58AF0) SUBALIGN(4) { build/us/audio_voice_command_10.o(.text) }
    .audio_handle_parameter_57f48 0x80057F48 : AT(0x58B48) SUBALIGN(4) { build/us/audio_handle_parameter_57f48.o(.text) }
    .audio_voice_command_11 0x80057F74 : AT(0x58B74) SUBALIGN(4) { build/us/audio_voice_command_11.o(.text) }
    .audio_handle_parameter_57fcc 0x80057FCC : AT(0x58BCC) SUBALIGN(4) { build/us/audio_handle_parameter_57fcc.o(.text) }
    .audio_handle_parameter_57ff8 0x80057FF8 : AT(0x58BF8) SUBALIGN(4) { build/us/audio_handle_parameter_57ff8.o(.text) }
    .audio_handle_parameter_58024 0x80058024 : AT(0x58C24) SUBALIGN(4) { build/us/audio_handle_parameter_58024.o(.text) }
    .audio_voice_command_14 0x80058050 : AT(0x58C50) SUBALIGN(4) { build/us/audio_voice_command_14.o(.text) }
    .audio_handle_parameter_580a8 0x800580A8 : AT(0x58CA8) SUBALIGN(4) { build/us/audio_handle_parameter_580a8.o(.text) }
    .audio_voice_command_15 0x800580D4 : AT(0x58CD4) SUBALIGN(4) { build/us/audio_voice_command_15.o(.text) }
    .audio_handle_parameter_5812c 0x8005812C : AT(0x58D2C) SUBALIGN(4) { build/us/audio_handle_parameter_5812c.o(.text) }
    .audio_voice_command_16 0x80058158 : AT(0x58D58) SUBALIGN(4) { build/us/audio_voice_command_16.o(.text) }
    .audio_handle_parameter_581b0 0x800581B0 : AT(0x58DB0) SUBALIGN(4) { build/us/audio_handle_parameter_581b0.o(.text) }
    .audio_handle_parameter_request 0x800581DC : AT(0x58DDC) SUBALIGN(4) { build/us/audio_handle_parameter_request.o(.text) }
    .audio_handle_parameter_decode 0x80058248 : AT(0x58E48) SUBALIGN(4) { build/us/audio_handle_parameter_decode.o(.text) }
    .audio_handle_parameter_apply 0x800582A8 : AT(0x58EA8) SUBALIGN(4) { build/us/audio_handle_parameter_apply.o(.text) }
    .cpu_after_audio_handle_parameter_apply 0x80058314 : AT(0x58F14) { build/us/fallback.o(.rom_cpu_after_audio_handle_parameter_apply) }
    .audio_stream_storage 0x80058320 : AT(0x58F20) SUBALIGN(4) { build/us/audio_stream_storage.o(.text) }
    .cpu_after_audio_stream_storage 0x800583B4 : AT(0x58FB4) { build/us/fallback.o(.rom_cpu_after_audio_stream_storage) }
    .audio_host_callbacks 0x80058890 : AT(0x59490) SUBALIGN(4) { build/us/audio_host_callbacks.o(.text) }
    .audio_host_control 0x8005891C : AT(0x5951C) SUBALIGN(4) { build/us/audio_host_control.o(.text) }
    .audio_command_lock 0x8005895C : AT(0x5955C) SUBALIGN(4) { build/us/audio_command_lock.o(.text) }
    .audio_timing_rate 0x800589DC : AT(0x595DC) SUBALIGN(4) { build/us/audio_timing_rate.o(.text) }
    .cpu_after_audio_timing_rate 0x80058A58 : AT(0x59658) { build/us/fallback.o(.rom_cpu_after_audio_timing_rate) }
    .audio_host_files 0x80058ADC : AT(0x596DC) SUBALIGN(4) { build/us/audio_host_files.o(.text) }
    .audio_diagnostics 0x80058C00 : AT(0x59800) SUBALIGN(4) { build/us/audio_diagnostics.o(.text) }
    .audio_command_queue 0x800592C0 : AT(0x59EC0) SUBALIGN(4) { build/us/audio_command_queue.o(.text) }
    .audio_handle_tests 0x80059500 : AT(0x5A100) SUBALIGN(4) { build/us/audio_handle_tests.o(.text) }
    .audio_stream_variable_read 0x80059580 : AT(0x5A180) SUBALIGN(4) { build/us/audio_stream_variable_read.o(.text) }
    .audio_stream_variable_write 0x800595D4 : AT(0x5A1D4) SUBALIGN(4) { build/us/audio_stream_variable_write.o(.text) }
    .audio_variable_length_size 0x80059644 : AT(0x5A244) SUBALIGN(4) { build/us/audio_variable_length_size.o(.text) }
    .audio_engine_setup 0x800596C4 : AT(0x5A2C4) SUBALIGN(4) { build/us/audio_engine_setup.o(.text) }
    .audio_engine_voice_stop 0x8005971C : AT(0x5A31C) SUBALIGN(4) { build/us/audio_engine_voice_stop.o(.text) }
    .audio_engine_parameters 0x80059898 : AT(0x5A498) SUBALIGN(4) { build/us/audio_engine_parameters.o(.text) }
    .audio_engine_gate 0x80059A88 : AT(0x5A688) SUBALIGN(4) { build/us/audio_engine_gate.o(.text) }
    .audio_engine_iteration 0x80059B68 : AT(0x5A768) SUBALIGN(4) { build/us/audio_engine_iteration.o(.text) }
    .audio_engine_gate_reset 0x80059C54 : AT(0x5A854) SUBALIGN(4) { build/us/audio_engine_gate_reset.o(.text) }
    .audio_engine_iteration_reset 0x80059D20 : AT(0x5A920) SUBALIGN(4) { build/us/audio_engine_iteration_reset.o(.text) }
    .audio_engine_iteration_set 0x80059DEC : AT(0x5A9EC) SUBALIGN(4) { build/us/audio_engine_iteration_set.o(.text) }
    .audio_engine_tempo 0x80059E2C : AT(0x5AA2C) SUBALIGN(4) { build/us/audio_engine_tempo.o(.text) }
    .audio_engine_sequence_call 0x80059FC8 : AT(0x5ABC8) SUBALIGN(4) { build/us/audio_engine_sequence_call.o(.text) }
    .audio_engine_sequence_jump 0x8005A180 : AT(0x5AD80) SUBALIGN(4) { build/us/audio_engine_sequence_jump.o(.text) }
    .audio_engine_sequence_return 0x8005A310 : AT(0x5AF10) SUBALIGN(4) { build/us/audio_engine_sequence_return.o(.text) }
    .audio_engine_sequence_stop 0x8005A448 : AT(0x5B048) SUBALIGN(4) { build/us/audio_engine_sequence_stop.o(.text) }
    .audio_engine_voice_tempo 0x8005A6D8 : AT(0x5B2D8) SUBALIGN(4) { build/us/audio_engine_voice_tempo.o(.text) }
    .audio_engine_voice_call 0x8005A73C : AT(0x5B33C) SUBALIGN(4) { build/us/audio_engine_voice_call.o(.text) }
    .audio_engine_voice_jump 0x8005A7C4 : AT(0x5B3C4) SUBALIGN(4) { build/us/audio_engine_voice_jump.o(.text) }
    .audio_engine_voice_return 0x8005A830 : AT(0x5B430) SUBALIGN(4) { build/us/audio_engine_voice_return.o(.text) }
    .audio_engine_voice_end 0x8005A88C : AT(0x5B48C) SUBALIGN(4) { build/us/audio_engine_voice_end.o(.text) }
    .cpu_after_audio_engine_voice_end 0x8005A9AC : AT(0x5B5AC) { build/us/fallback.o(.rom_cpu_after_audio_engine_voice_end) }
    .audio_rate_scale 0x8005AD50 : AT(0x5B950) SUBALIGN(4) { build/us/audio_rate_scale.o(.text) }
    .audio_voice_capture_control 0x8005AD88 : AT(0x5B988) SUBALIGN(4) { build/us/audio_voice_capture_control.o(.text) }
    .audio_voice_capture_resume 0x8005ADD0 : AT(0x5B9D0) SUBALIGN(4) { build/us/audio_voice_capture_resume.o(.text) }
    .audio_voice_capture_append 0x8005AEA8 : AT(0x5BAA8) SUBALIGN(4) { build/us/audio_voice_capture_append.o(.text) }
    .audio_voice_argument 0x8005AFE4 : AT(0x5BBE4) SUBALIGN(4) { build/us/audio_voice_argument.o(.text) }
    .audio_pitch_scale 0x8005B000 : AT(0x5BC00) SUBALIGN(4) { build/us/audio_pitch_scale.o(.text) }
    .after_audio_pitch_scale 0x8005B064 : AT(0x5BC64) { build/us/fallback.o(.rom_after_audio_pitch_scale) }
    .audio_backend_initialize 0x8005B3A8 : AT(0x5BFA8) SUBALIGN(4) { build/us/audio_backend_initialize.o(.text) }
    .audio_backend_update 0x8005B66C : AT(0x5C26C) SUBALIGN(4) { build/us/audio_backend_update.o(.text) }
    .audio_backend_voice_stop 0x8005B7BC : AT(0x5C3BC) SUBALIGN(4) { build/us/audio_backend_voice_stop.o(.text) }
    .after_audio_backend_voice_stop 0x8005B854 : AT(0x5C454) { build/us/fallback.o(.rom_after_audio_backend_voice_stop) }
    .audio_backend_patch 0x8005B9F8 : AT(0x5C5F8) SUBALIGN(4) { build/us/audio_backend_patch.o(.text) }
    .after_audio_backend_patch 0x8005BA24 : AT(0x5C624) { build/us/fallback.o(.rom_after_audio_backend_patch) }
    .audio_backend_volume 0x8005BCC8 : AT(0x5C8C8) SUBALIGN(4) { build/us/audio_backend_volume.o(.text) }
    .audio_backend_pan_pedal 0x8005BEFC : AT(0x5CAFC) SUBALIGN(4) { build/us/audio_backend_pan_pedal.o(.text) }
    .audio_backend_pan_command 0x8005C1D8 : AT(0x5CDD8) SUBALIGN(4) { build/us/audio_backend_pan_command.o(.text) }
    .audio_unused_command 0x8005C32C : AT(0x5CF2C) SUBALIGN(4) { build/us/audio_unused_command.o(.text) }
    .audio_backend_voice_start 0x8005C334 : AT(0x5CF34) SUBALIGN(4) { build/us/audio_backend_voice_start.o(.text) }
    .audio_backend_voice_release 0x8005C3E4 : AT(0x5CFE4) SUBALIGN(4) { build/us/audio_backend_voice_release.o(.text) }
    .audio_backend_release 0x8005C4F8 : AT(0x5D0F8) SUBALIGN(4) { build/us/audio_backend_release.o(.text) }
    .audio_backend_decay 0x8005C684 : AT(0x5D284) SUBALIGN(4) { build/us/audio_backend_decay.o(.text) }
    .audio_backend_allocate 0x8005C7F8 : AT(0x5D3F8) SUBALIGN(4) { build/us/audio_backend_allocate.o(.text) }
    .audio_backend_patch_trigger 0x8005CA34 : AT(0x5D634) SUBALIGN(4) { build/us/audio_backend_patch_trigger.o(.text) }
    .audio_backend_note_release 0x8005CBB4 : AT(0x5D7B4) SUBALIGN(4) { build/us/audio_backend_note_release.o(.text) }
    .after_audio_backend_note_release 0x8005CCBC : AT(0x5D8BC) { build/us/fallback.o(.rom_after_audio_backend_note_release) }
    .audio_file_services 0x8005CCC0 : AT(0x5D8C0) SUBALIGN(4) { build/us/audio_file_services.o(.text) }
    .after_audio_file_services 0x8005CE0C : AT(0x5DA0C) { build/us/fallback.o(.rom_after_audio_file_services) }
    .audio_sequence_table_size 0x8005D220 : AT(0x5DE20) SUBALIGN(4) { build/us/audio_sequence_table_size.o(.text) }
    .audio_sequence_table_load 0x8005D2E4 : AT(0x5DEE4) SUBALIGN(4) { build/us/audio_sequence_table_load.o(.text) }
    .audio_sequence_table_close 0x8005D4A4 : AT(0x5E0A4) SUBALIGN(4) { build/us/audio_sequence_table_close.o(.text) }
    .audio_sequence_size 0x8005D4C8 : AT(0x5E0C8) SUBALIGN(4) { build/us/audio_sequence_size.o(.text) }
    .audio_sequence_load 0x8005D584 : AT(0x5E184) SUBALIGN(4) { build/us/audio_sequence_load.o(.text) }
    .audio_sequence_release 0x8005D610 : AT(0x5E210) SUBALIGN(4) { build/us/audio_sequence_release.o(.text) }
    .audio_sequence_list_size 0x8005D690 : AT(0x5E290) SUBALIGN(4) { build/us/audio_sequence_list_size.o(.text) }
    .audio_sequence_list_load 0x8005D708 : AT(0x5E308) SUBALIGN(4) { build/us/audio_sequence_list_load.o(.text) }
    .audio_sequence_list_release 0x8005D7B4 : AT(0x5E3B4) SUBALIGN(4) { build/us/audio_sequence_list_release.o(.text) }
    .after_audio_sequence_list_release 0x8005D828 : AT(0x5E428) { build/us/fallback.o(.rom_after_audio_sequence_list_release) }
    .audio_sequence_range_size 0x8005D830 : AT(0x5E430) SUBALIGN(4) { build/us/audio_sequence_range_size.o(.text) }
    .audio_sequence_range_load 0x8005D8AC : AT(0x5E4AC) SUBALIGN(4) { build/us/audio_sequence_range_load.o(.text) }
    .audio_sequence_range_release 0x8005D95C : AT(0x5E55C) SUBALIGN(4) { build/us/audio_sequence_range_release.o(.text) }
    .after_audio_sequence_range_release 0x8005D9D8 : AT(0x5E5D8) { build/us/fallback.o(.rom_after_audio_sequence_range_release) }
    .audio_interrupt_service 0x8005D9E0 : AT(0x5E5E0) SUBALIGN(4) { build/us/audio_interrupt_service.o(.text) }
    .cpu_after_audio_interrupt_service 0x8005DA20 : AT(0x5E620) { build/us/fallback.o(.rom_cpu_after_audio_interrupt_service) }
    .compression_table_release 0x8005E1E4 : AT(0x5EDE4) SUBALIGN(4) { build/us/compression_table_release.o(.text) }
    .endgame_5edec_5f5d0 0x8005E1EC : AT(0x5EDEC) { build/us/fallback.o(.rom_endgame_5edec_5f5d0) }
    .compression_stored 0x8005E9D0 : AT(0x5F5D0) SUBALIGN(4) { build/us/compression_stored.o(.text) }
    .compression_fixed 0x8005ECA8 : AT(0x5F8A8) SUBALIGN(4) { build/us/compression_fixed.o(.text) }
    .compression_fixed_release 0x8005EE98 : AT(0x5FA98) SUBALIGN(4) { build/us/compression_fixed_release.o(.text) }
    .after_compression_fixed_release 0x8005EEE0 : AT(0x5FAE0) { build/us/fallback.o(.rom_after_compression_fixed_release) }
    .compression_workspace 0x8005F71C : AT(0x6031C) SUBALIGN(4) { build/us/compression_workspace.o(.text) }
    .compression_allocate 0x8005F7E0 : AT(0x603E0) SUBALIGN(4) { build/us/compression_allocate.o(.text) }
    .compression_refill 0x8005F804 : AT(0x60404) SUBALIGN(4) { build/us/compression_refill.o(.text) }
    .compression_decode 0x8005F878 : AT(0x60478) SUBALIGN(4) { build/us/compression_decode.o(.text) }
    .compression_memory 0x8005FAB0 : AT(0x606B0) SUBALIGN(4) { build/us/compression_memory.o(.text) }
    .compression_cartridge 0x8005FB08 : AT(0x60708) SUBALIGN(4) { build/us/compression_cartridge.o(.text) }
    .compression_cartridge_bounded 0x8005FB58 : AT(0x60758) SUBALIGN(4) { build/us/compression_cartridge_bounded.o(.text) }
    .short_sine 0x8005FBB0 : AT(0x607B0) SUBALIGN(4) { build/us/short_sine.o(.text) }
    .short_cosine 0x8005FC20 : AT(0x60820) SUBALIGN(4) { build/us/short_cosine.o(.text) }
    .initialize 0x8005FC50 : AT(0x60850) SUBALIGN(4) { build/us/initialize.o(.text) }
    .endgame_60adc_60ae0 0x8005FEDC : AT(0x60ADC) { build/us/fallback.o(.rom_endgame_60adc_60ae0) }
    .pi_cartridge_read 0x8005FEE0 : AT(0x60AE0) SUBALIGN(4) { build/us/pi_cartridge_read.o(.text) }
    .cpu_after_pi_raw_read 0x8005FF34 : AT(0x60B34) { build/us/fallback.o(.rom_cpu_after_pi_raw_read) }
    .thread_create 0x8005FF40 : AT(0x60B40) SUBALIGN(4) { build/us/thread_create.o(.text) }
    .cpu_after_thread_create 0x80060084 : AT(0x60C84) { build/us/fallback.o(.rom_cpu_after_thread_create) }
    .thread_start 0x80060090 : AT(0x60C90) SUBALIGN(4) { build/us/thread_start.o(.text) }
    .pi_manager_create 0x800601E0 : AT(0x60DE0) SUBALIGN(4) { build/us/pi_manager_create.o(.text) }
    .cpu_after_pi_manager_create 0x80060368 : AT(0x60F68) { build/us/fallback.o(.rom_cpu_after_pi_manager_create) }
    .thread_set_priority 0x80060370 : AT(0x60F70) SUBALIGN(4) { build/us/thread_set_priority.o(.text) }
    .message_queue 0x80060450 : AT(0x61050) SUBALIGN(4) { build/us/message_queue.o(.text) }
    .cpu_after_message_queue_create 0x8006047C : AT(0x6107C) { build/us/fallback.o(.rom_cpu_after_message_queue_create) }
    .vi_features 0x800604E0 : AT(0x610E0) SUBALIGN(4) { build/us/vi_features.o(.text) }
    .cpu_after_vi_features 0x80060698 : AT(0x61298) { build/us/fallback.o(.rom_cpu_after_vi_features) }
    .virtual_to_physical 0x800606A0 : AT(0x612A0) SUBALIGN(4) { build/us/virtual_to_physical.o(.text) }
    .endgame_6131c_61320 0x8006071C : AT(0x6131C) { build/us/fallback.o(.rom_endgame_6131c_61320) }
    .os_invalidate_cache_all 0x80060720 : AT(0x61320) SUBALIGN(4) { build/us/os_invalidate_cache_all.o(.text) }
    .camera_perspective 0x80060750 : AT(0x61350) SUBALIGN(4) { build/us/camera_perspective.o(.text) }
    .cpu_after_gu_perspective 0x800609D8 : AT(0x615D8) { build/us/fallback.o(.rom_cpu_after_gu_perspective) }
    .camera_highlights 0x800609E0 : AT(0x615E0) SUBALIGN(4) { build/us/camera_highlights.o(.text) }
    .cpu_after_gu_lookathilite 0x80061204 : AT(0x61E04) { build/us/fallback.o(.rom_cpu_after_gu_lookathilite) }
    .matrix_translate 0x80061210 : AT(0x61E10) SUBALIGN(4) { build/us/matrix_translate.o(.text) }
    .cpu_after_gu_translate 0x800612AC : AT(0x61EAC) { build/us/fallback.o(.rom_cpu_after_gu_translate) }
    .matrix_rotation 0x800612B0 : AT(0x61EB0) SUBALIGN(4) { build/us/matrix_rotation.o(.text) }
    .cpu_after_gu_rotate_rpy 0x80061444 : AT(0x62044) { build/us/fallback.o(.rom_cpu_after_gu_rotate_rpy) }
    .system_time 0x80061450 : AT(0x62050) SUBALIGN(4) { build/us/system_time.o(.text) }
    .cpu_after_time_get 0x800614D4 : AT(0x620D4) { build/us/fallback.o(.rom_cpu_after_time_get) }
    .compiler_integer64 0x800614E0 : AT(0x620E0) SUBALIGN(4) { build/us/compiler_integer64.o(.text) }
    .pfs_repair_id 0x800617A0 : AT(0x623A0) SUBALIGN(4) { build/us/pfs_repair_id.o(.text) }
    .endgame_625fc_62600 0x800619FC : AT(0x625FC) { build/us/fallback.o(.rom_endgame_625fc_62600) }
    .pfs_is_plug 0x80061A00 : AT(0x62600) SUBALIGN(4) { build/us/pfs_is_plug.o(.text) }
    .cpu_after_pfs_is_plug 0x80061D6C : AT(0x6296C) { build/us/fallback.o(.rom_cpu_after_pfs_is_plug) }
    .pfs_init_pak 0x80061D70 : AT(0x62970) SUBALIGN(4) { build/us/pfs_init_pak.o(.text) }
    .cpu_after_pfs_init_pak 0x80061FD4 : AT(0x62BD4) { build/us/fallback.o(.rom_cpu_after_pfs_init_pak) }
    .controller_read 0x80061FE0 : AT(0x62BE0) SUBALIGN(4) { build/us/controller_read.o(.text) }
    .cpu_after_controller_read 0x80062238 : AT(0x62E38) { build/us/fallback.o(.rom_cpu_after_controller_read) }
    .message_receive 0x80062240 : AT(0x62E40) SUBALIGN(4) { build/us/message_receive.o(.text) }
    .cpu_after_message_receive 0x80062378 : AT(0x62F78) { build/us/fallback.o(.rom_cpu_after_message_receive) }
    .pfs_search_file 0x80062380 : AT(0x62F80) SUBALIGN(4) { build/us/pfs_search_file.o(.text) }
    .cpu_after_pfs_search_file 0x80062534 : AT(0x63134) { build/us/fallback.o(.rom_cpu_after_pfs_search_file) }
    .pfs_allocate_file 0x80062540 : AT(0x63140) SUBALIGN(4) { build/us/pfs_allocate_file.o(.text) }
    .cpu_after_pfs_allocate_file 0x80062CE8 : AT(0x638E8) { build/us/fallback.o(.rom_cpu_after_pfs_allocate_file) }
    .pfs_read_write_file 0x80062CF0 : AT(0x638F0) SUBALIGN(4) { build/us/pfs_read_write_file.o(.text) }
    .cpu_after_pfs_read_write_file 0x800631EC : AT(0x63DEC) { build/us/fallback.o(.rom_cpu_after_pfs_read_write_file) }
    .gu_random 0x800631F0 : AT(0x63DF0) SUBALIGN(4) { build/us/gu_random.o(.text) }
    .endgame_63e1c_63e20 0x8006321C : AT(0x63E1C) { build/us/fallback.o(.rom_endgame_63e1c_63e20) }
    .square_root 0x80063220 : AT(0x63E20) SUBALIGN(4) { build/us/square_root.o(.text) }
    .sine_float 0x80063230 : AT(0x63E30) SUBALIGN(4) { build/us/sine_float.o(.text) }
    .cosine_float 0x800633F0 : AT(0x63FF0) SUBALIGN(4) { build/us/cosine_float.o(.text) }
    .cpu_after_gu_cosine_float 0x80063558 : AT(0x64158) { build/us/fallback.o(.rom_cpu_after_gu_cosine_float) }
    .pi_read 0x80063560 : AT(0x64160) SUBALIGN(4) { build/us/pi_read.o(.text) }
    .message_send 0x800635A0 : AT(0x641A0) SUBALIGN(4) { build/us/message_send.o(.text) }
    .cpu_after_message_send 0x800636EC : AT(0x642EC) { build/us/fallback.o(.rom_cpu_after_message_send) }
    .pfs_motor 0x800636F0 : AT(0x642F0) SUBALIGN(4) { build/us/pfs_motor.o(.text) }
    .cpu_after_pfs_motor 0x80063D04 : AT(0x64904) { build/us/fallback.o(.rom_cpu_after_pfs_motor) }
    .controller_init 0x80063D10 : AT(0x64910) SUBALIGN(4) { build/us/controller_init.o(.text) }
    .cpu_after_controller_init 0x800640CC : AT(0x64CCC) { build/us/fallback.o(.rom_cpu_after_controller_init) }
    .event_message 0x800640D0 : AT(0x64CD0) SUBALIGN(4) { build/us/event_message.o(.text) }
    .cpu_after_event_message 0x80064138 : AT(0x64D38) { build/us/fallback.o(.rom_cpu_after_event_message) }
    .pfs_free_blocks 0x80064140 : AT(0x64D40) SUBALIGN(4) { build/us/pfs_free_blocks.o(.text) }
    .cpu_after_pfs_free_blocks 0x8006428C : AT(0x64E8C) { build/us/fallback.o(.rom_cpu_after_pfs_free_blocks) }
    .pfs_num_files 0x80064290 : AT(0x64E90) SUBALIGN(4) { build/us/pfs_num_files.o(.text) }
    .cpu_after_pfs_num_files 0x800643D4 : AT(0x64FD4) { build/us/fallback.o(.rom_cpu_after_pfs_num_files) }
    .pfs_delete_file 0x800643E0 : AT(0x64FE0) SUBALIGN(4) { build/us/pfs_delete_file.o(.text) }
    .cpu_after_pfs_delete_file 0x800649E8 : AT(0x655E8) { build/us/fallback.o(.rom_cpu_after_pfs_delete_file) }
    .pfs_file_state 0x800649F0 : AT(0x655F0) SUBALIGN(4) { build/us/pfs_file_state.o(.text) }
    .video_vertical_scale 0x80064CE0 : AT(0x658E0) SUBALIGN(4) { build/us/video_vertical_scale.o(.text) }
    .cpu_after_vi_vertical_scale 0x80064D38 : AT(0x65938) { build/us/fallback.o(.rom_cpu_after_vi_vertical_scale) }
    .video_manager 0x80064D40 : AT(0x65940) SUBALIGN(4) { build/us/video_manager.o(.text) }
    .cpu_after_vi_manager 0x80065094 : AT(0x65C94) { build/us/fallback.o(.rom_cpu_after_vi_manager) }
    .vi_mode 0x800650A0 : AT(0x65CA0) SUBALIGN(4) { build/us/vi_mode.o(.text) }
    .cpu_after_vi_mode 0x80065108 : AT(0x65D08) { build/us/fallback.o(.rom_cpu_after_vi_mode) }
    .vi_black 0x80065110 : AT(0x65D10) SUBALIGN(4) { build/us/vi_black.o(.text) }
    .vi_event 0x80065180 : AT(0x65D80) SUBALIGN(4) { build/us/vi_event.o(.text) }
    .endgame_65dec_65df0 0x800651EC : AT(0x65DEC) { build/us/fallback.o(.rom_endgame_65dec_65df0) }
    .os_interrupt_mask 0x800651F0 : AT(0x65DF0) SUBALIGN(4) { build/us/os_interrupt_mask.o(.text) }
    .sp_yield 0x80065290 : AT(0x65E90) SUBALIGN(4) { build/us/sp_yield.o(.text) }
    .sp_yielded 0x800652B0 : AT(0x65EB0) SUBALIGN(4) { build/us/sp_yielded.o(.text) }
    .sp_task_physical 0x80065330 : AT(0x65F30) SUBALIGN(4) { build/us/sp_task_physical.o(.text) }
    .sp_task_load 0x8006544C : AT(0x6604C) SUBALIGN(4) { build/us/sp_task_load.o(.text) }
    .sp_start 0x800655DC : AT(0x661DC) SUBALIGN(4) { build/us/sp_start.o(.text) }
    .cpu_after_audio_sp 0x8006561C : AT(0x6621C) { build/us/fallback.o(.rom_cpu_after_audio_sp) }
    .vi_framebuffer 0x80065620 : AT(0x66220) SUBALIGN(4) { build/us/vi_framebuffer.o(.text) }
    .audio_heap_init 0x800656F0 : AT(0x662F0) SUBALIGN(4) { build/us/audio_heap_init.o(.text) }
    .cpu_after_audio_heap_init 0x80065724 : AT(0x66324) { build/us/fallback.o(.rom_cpu_after_audio_heap_init) }
    .audio_heap_allocate 0x80065730 : AT(0x66330) SUBALIGN(4) { build/us/audio_heap_allocate.o(.text) }
    .endgame_66384_66390 0x80065784 : AT(0x66384) { build/us/fallback.o(.rom_endgame_66384_66390) }
    .os_invalidate_data_cache 0x80065790 : AT(0x66390) SUBALIGN(4) { build/us/os_invalidate_data_cache.o(.text) }
    .pi_start_dma 0x80065840 : AT(0x66440) SUBALIGN(4) { build/us/pi_start_dma.o(.text) }
    .cpu_after_pi_start_dma 0x8006594C : AT(0x6654C) { build/us/fallback.o(.rom_cpu_after_pi_start_dma) }
    .ai_frequency 0x80065950 : AT(0x66550) SUBALIGN(4) { build/us/ai_frequency.o(.text) }
    .audio_link_nodes 0x80065AB0 : AT(0x666B0) SUBALIGN(4) { build/us/audio_link_nodes.o(.text) }
    .audio_synth_lifecycle 0x80065B04 : AT(0x66704) SUBALIGN(4) { build/us/audio_synth_lifecycle.o(.text) }
    .audio_buffer_submit 0x80065B70 : AT(0x66770) SUBALIGN(4) { build/us/audio_buffer_submit.o(.text) }
    .cpu_after_ai_buffer 0x80065C18 : AT(0x66818) { build/us/fallback.o(.rom_cpu_after_ai_buffer) }
    .audio_remaining_bytes 0x80065C20 : AT(0x66820) SUBALIGN(4) { build/us/audio_remaining_bytes.o(.text) }
    .cpu_after_ai_length 0x80065C2C : AT(0x6682C) { build/us/fallback.o(.rom_cpu_after_ai_length) }
    .audio_synthesizer 0x80065C30 : AT(0x66830) SUBALIGN(4) { build/us/audio_synthesizer.o(.text) }
    .audio_callback_attach 0x80066310 : AT(0x66F10) SUBALIGN(4) { build/us/audio_callback_attach.o(.text) }
    .voice_allocate 0x80066360 : AT(0x66F60) SUBALIGN(4) { build/us/voice_allocate.o(.text) }
    .cpu_after_audio_synth_allocate 0x80066588 : AT(0x67188) { build/us/fallback.o(.rom_cpu_after_audio_synth_allocate) }
    .voice_start 0x80066590 : AT(0x67190) SUBALIGN(4) { build/us/voice_start.o(.text) }
    .cpu_after_audio_synth_start 0x80066674 : AT(0x67274) { build/us/fallback.o(.rom_cpu_after_audio_synth_start) }
    .voice_pitch 0x80066680 : AT(0x67280) SUBALIGN(4) { build/us/voice_pitch.o(.text) }
    .cpu_after_audio_synth_pitch 0x80066704 : AT(0x67304) { build/us/fallback.o(.rom_cpu_after_audio_synth_pitch) }
    .voice_volume 0x80066710 : AT(0x67310) SUBALIGN(4) { build/us/voice_volume.o(.text) }
    .cpu_after_audio_synth_volume 0x800667AC : AT(0x673AC) { build/us/fallback.o(.rom_cpu_after_audio_synth_volume) }
    .voice_pan 0x800667B0 : AT(0x673B0) SUBALIGN(4) { build/us/voice_pan.o(.text) }
    .cpu_after_audio_synth_pan 0x80066834 : AT(0x67434) { build/us/fallback.o(.rom_cpu_after_audio_synth_pan) }
    .voice_stop 0x80066840 : AT(0x67440) SUBALIGN(4) { build/us/voice_stop.o(.text) }
    .cpu_after_audio_synth_stop 0x800668B8 : AT(0x674B8) { build/us/fallback.o(.rom_cpu_after_audio_synth_stop) }
    .voice_release 0x800668C0 : AT(0x674C0) SUBALIGN(4) { build/us/voice_release.o(.text) }
    .voice_priority 0x80066970 : AT(0x67570) SUBALIGN(4) { build/us/voice_priority.o(.text) }
    .os_status 0x80066980 : AT(0x67580) SUBALIGN(4) { build/us/os_status.o(.text) }
    .os_fpcsr 0x800669A0 : AT(0x675A0) SUBALIGN(4) { build/us/os_fpcsr.o(.text) }
    .si_raw_read 0x800669B0 : AT(0x675B0) SUBALIGN(4) { build/us/si_raw_read.o(.text) }
    .si_raw_write 0x80066A00 : AT(0x67600) SUBALIGN(4) { build/us/si_raw_write.o(.text) }
    .before_exception_context 0x80066A4C : AT(0x6764C) { build/us/fallback.o(.rom_before_exception_context) }
    .exception_context 0x80066A50 : AT(0x67650) SUBALIGN(4) { build/us/exception_context.o(.text) }
    .os_writeback_cache 0x80067360 : AT(0x67F60) SUBALIGN(4) { build/us/os_writeback_cache.o(.text) }
    .os_invalidate_instruction_cache 0x800673E0 : AT(0x67FE0) SUBALIGN(4) { build/us/os_invalidate_instruction_cache.o(.text) }
    .os_map_debug_tlb 0x80067460 : AT(0x68060) SUBALIGN(4) { build/us/os_map_debug_tlb.o(.text) }
    .os_block_clear 0x800674C0 : AT(0x680C0) SUBALIGN(4) { build/us/os_block_clear.o(.text) }
    .os_interrupt 0x80067560 : AT(0x68160) SUBALIGN(4) { build/us/os_interrupt.o(.text) }
    .thread_dequeue 0x800675A0 : AT(0x681A0) SUBALIGN(4) { build/us/thread_dequeue.o(.text) }
    .pi_cartridge_initialize 0x800675E0 : AT(0x681E0) SUBALIGN(4) { build/us/pi_cartridge_initialize.o(.text) }
    .endgame_682cc_682d0 0x800676CC : AT(0x682CC) { build/us/fallback.o(.rom_endgame_682cc_682d0) }
    .pi_disk_initialize 0x800676D0 : AT(0x682D0) SUBALIGN(4) { build/us/pi_disk_initialize.o(.text) }
    .endgame_683c8_683d0 0x800677C8 : AT(0x683C8) { build/us/fallback.o(.rom_endgame_683c8_683d0) }
    .pi_access 0x800677D0 : AT(0x683D0) SUBALIGN(4) { build/us/pi_access.o(.text) }
    .thread_get_priority 0x80067890 : AT(0x68490) SUBALIGN(4) { build/us/thread_get_priority.o(.text) }
    .cpu_after_thread_get_priority 0x800678A8 : AT(0x684A8) { build/us/fallback.o(.rom_cpu_after_thread_get_priority) }
    .pi_raw_dma 0x800678B0 : AT(0x684B0) SUBALIGN(4) { build/us/pi_raw_dma.o(.text) }
    .pi_extended_dma 0x80067990 : AT(0x68590) SUBALIGN(4) { build/us/pi_extended_dma.o(.text) }
    .endgame_687b4_687c0 0x80067BB4 : AT(0x687B4) { build/us/fallback.o(.rom_endgame_687b4_687c0) }
    .pi_device_manager 0x80067BC0 : AT(0x687C0) SUBALIGN(4) { build/us/pi_device_manager.o(.text) }
    .video_initialize 0x80068050 : AT(0x68C50) SUBALIGN(4) { build/us/video_initialize.o(.text) }
    .endgame_68d8c_68d90 0x8006818C : AT(0x68D8C) { build/us/fallback.o(.rom_endgame_68d8c_68d90) }
    .os_probe_tlb 0x80068190 : AT(0x68D90) SUBALIGN(4) { build/us/os_probe_tlb.o(.text) }
    .matrix_convert 0x80068250 : AT(0x68E50) SUBALIGN(4) { build/us/matrix_convert.o(.text) }
    .cpu_after_gu_mtxutil 0x800684BC : AT(0x690BC) { build/us/fallback.o(.rom_cpu_after_gu_mtxutil) }
    .os_get_count 0x800684C0 : AT(0x690C0) SUBALIGN(4) { build/us/os_get_count.o(.text) }
    .timer_initialize 0x800684D0 : AT(0x690D0) SUBALIGN(4) { build/us/timer_initialize.o(.text) }
    .timer_interrupt 0x8006855C : AT(0x6915C) SUBALIGN(4) { build/us/timer_interrupt.o(.text) }
    .timer_compare 0x800686D4 : AT(0x692D4) SUBALIGN(4) { build/us/timer_compare.o(.text) }
    .timer_insert 0x80068748 : AT(0x69348) SUBALIGN(4) { build/us/timer_insert.o(.text) }
    .pfs_contpfs 0x800688D0 : AT(0x694D0) SUBALIGN(4) { build/us/pfs_contpfs.o(.text) }
    .cpu_after_pfs_contpfs 0x80069628 : AT(0x6A228) { build/us/fallback.o(.rom_cpu_after_pfs_contpfs) }
    .pfs_cont_ram_read 0x80069630 : AT(0x6A230) SUBALIGN(4) { build/us/pfs_cont_ram_read.o(.text) }
    .cpu_after_pfs_cont_ram_read 0x800699B4 : AT(0x6A5B4) { build/us/fallback.o(.rom_cpu_after_pfs_cont_ram_read) }
    .si_access 0x800699C0 : AT(0x6A5C0) SUBALIGN(4) { build/us/si_access.o(.text) }
    .si_dma 0x80069A80 : AT(0x6A680) SUBALIGN(4) { build/us/si_dma.o(.text) }
    .cpu_after_si_dma 0x80069B2C : AT(0x6A72C) { build/us/fallback.o(.rom_cpu_after_si_dma) }
    .pfs_get_status 0x80069B30 : AT(0x6A730) SUBALIGN(4) { build/us/pfs_get_status.o(.text) }
    .cpu_after_pfs_get_status 0x80069C3C : AT(0x6A83C) { build/us/fallback.o(.rom_cpu_after_pfs_get_status) }
    .pfs_checker 0x80069C40 : AT(0x6A840) SUBALIGN(4) { build/us/pfs_checker.o(.text) }
    .pfs_cont_ram_write 0x8006A6A0 : AT(0x6B2A0) SUBALIGN(4) { build/us/pfs_cont_ram_write.o(.text) }
    .controller_crc 0x8006AA20 : AT(0x6B620) SUBALIGN(4) { build/us/controller_crc.o(.text) }
    .timer_schedule 0x8006ABA0 : AT(0x6B7A0) SUBALIGN(4) { build/us/timer_schedule.o(.text) }
    .cpu_after_timer_set 0x8006AC74 : AT(0x6B874) { build/us/fallback.o(.rom_cpu_after_timer_set) }
    .video_context_get 0x8006AC80 : AT(0x6B880) SUBALIGN(4) { build/us/video_context_get.o(.text) }
    .endgame_6b88c_6b890 0x8006AC8C : AT(0x6B88C) { build/us/fallback.o(.rom_endgame_6b88c_6b890) }
    .video_context_swap 0x8006AC90 : AT(0x6B890) SUBALIGN(4) { build/us/video_context_swap.o(.text) }
    .endgame_6bbec_6bbf0 0x8006AFEC : AT(0x6BBEC) { build/us/fallback.o(.rom_endgame_6bbec_6bbf0) }
    .sp_set_status 0x8006AFF0 : AT(0x6BBF0) SUBALIGN(4) { build/us/sp_set_status.o(.text) }
    .cpu_after_sp_set_status 0x8006AFFC : AT(0x6BBFC) { build/us/fallback.o(.rom_cpu_after_sp_set_status) }
    .sp_get_status 0x8006B000 : AT(0x6BC00) SUBALIGN(4) { build/us/sp_get_status.o(.text) }
    .endgame_6bc0c_6bc10 0x8006B00C : AT(0x6BC0C) { build/us/fallback.o(.rom_endgame_6bc0c_6bc10) }
    .os_block_copy 0x8006B010 : AT(0x6BC10) SUBALIGN(4) { build/us/os_block_copy.o(.text) }
    .sp_set_pc 0x8006B320 : AT(0x6BF20) SUBALIGN(4) { build/us/sp_set_pc.o(.text) }
    .cpu_after_sp_set_pc 0x8006B354 : AT(0x6BF54) { build/us/fallback.o(.rom_cpu_after_sp_set_pc) }
    .sp_dma 0x8006B360 : AT(0x6BF60) SUBALIGN(4) { build/us/sp_dma.o(.text) }
    .cpu_after_sp_dma 0x8006B3EC : AT(0x6BFEC) { build/us/fallback.o(.rom_cpu_after_sp_dma) }
    .sp_busy 0x8006B3F0 : AT(0x6BFF0) SUBALIGN(4) { build/us/sp_busy.o(.text) }
    .cpu_after_sp_busy 0x8006B41C : AT(0x6C01C) { build/us/fallback.o(.rom_cpu_after_sp_busy) }
    .message_prepend 0x8006B420 : AT(0x6C020) SUBALIGN(4) { build/us/message_prepend.o(.text) }
    .pi_queue_get 0x8006B570 : AT(0x6C170) SUBALIGN(4) { build/us/pi_queue_get.o(.text) }
    .cpu_after_pi_get_queue 0x8006B598 : AT(0x6C198) { build/us/fallback.o(.rom_cpu_after_pi_get_queue) }
    .audio_synth_clear 0x8006B5A0 : AT(0x6C1A0) SUBALIGN(4) { build/us/audio_synth_clear.o(.text) }
    .cpu_after_audio_synth_delete 0x8006B5A8 : AT(0x6C1A8) { build/us/fallback.o(.rom_cpu_after_audio_synth_delete) }
    .ai_busy 0x8006B5B0 : AT(0x6C1B0) SUBALIGN(4) { build/us/ai_busy.o(.text) }
    .audio_filter_create 0x8006B5E0 : AT(0x6C1E0) SUBALIGN(4) { build/us/audio_filter_create.o(.text) }
    .audio_low_pass 0x8006B8A0 : AT(0x6C4A0) SUBALIGN(4) { build/us/audio_low_pass.o(.text) }
    .audio_effect_create 0x8006B940 : AT(0x6C540) SUBALIGN(4) { build/us/audio_effect_create.o(.text) }
    .cpu_after_audio_effect_init 0x8006BD7C : AT(0x6C97C) { build/us/fallback.o(.rom_cpu_after_audio_effect_init) }
    .audio_effect_allocate 0x8006BD80 : AT(0x6C980) SUBALIGN(4) { build/us/audio_effect_allocate.o(.text) }
    .cpu_after_audio_effect_allocate 0x8006BE18 : AT(0x6CA18) { build/us/fallback.o(.rom_cpu_after_audio_effect_allocate) }
    .audio_main_bus 0x8006BE20 : AT(0x6CA20) SUBALIGN(4) { build/us/audio_main_bus.o(.text) }
    .audio_decoder 0x8006BF70 : AT(0x6CB70) SUBALIGN(4) { build/us/audio_decoder.o(.text) }
    .cpu_after_audio_decoder 0x8006CABC : AT(0x6D6BC) { build/us/fallback.o(.rom_cpu_after_audio_decoder) }
    .audio_resample 0x8006CAC0 : AT(0x6D6C0) SUBALIGN(4) { build/us/audio_resample.o(.text) }
    .cpu_after_audio_resample 0x8006CDB4 : AT(0x6D9B4) { build/us/fallback.o(.rom_cpu_after_audio_resample) }
    .audio_envelope 0x8006CDC0 : AT(0x6D9C0) SUBALIGN(4) { build/us/audio_envelope.o(.text) }
    .cpu_after_audio_envelope 0x8006DA14 : AT(0x6E614) { build/us/fallback.o(.rom_cpu_after_audio_envelope) }
    .audio_auxiliary_bus 0x8006DA20 : AT(0x6E620) SUBALIGN(4) { build/us/audio_auxiliary_bus.o(.text) }
    .cpu_after_audio_aux_bus 0x8006DB28 : AT(0x6E728) { build/us/fallback.o(.rom_cpu_after_audio_aux_bus) }
    .audio_save_filter 0x8006DB30 : AT(0x6E730) SUBALIGN(4) { build/us/audio_save_filter.o(.text) }
    .si_busy 0x8006DBF0 : AT(0x6E7F0) SUBALIGN(4) { build/us/si_busy.o(.text) }
    .endgame_6e81c_6e820 0x8006DC1C : AT(0x6E81C) { build/us/fallback.o(.rom_endgame_6e81c_6e820) }
    .pi_disk_interrupt 0x8006DC20 : AT(0x6E820) SUBALIGN(4) { build/us/pi_disk_interrupt.o(.text) }
    .pi_disk_recover 0x8006E2C4 : AT(0x6EEC4) SUBALIGN(4) { build/us/pi_disk_recover.o(.text) }
    .pi_event_notify 0x8006E3AC : AT(0x6EFAC) SUBALIGN(4) { build/us/pi_event_notify.o(.text) }
    .cpu_after_pi_event 0x8006E498 : AT(0x6F098) { build/us/fallback.o(.rom_cpu_after_pi_event) }
    .thread_destroy 0x8006E4A0 : AT(0x6F0A0) SUBALIGN(4) { build/us/thread_destroy.o(.text) }
    .cpu_after_thread_destroy 0x8006E598 : AT(0x6F198) { build/us/fallback.o(.rom_cpu_after_thread_destroy) }
    .interrupt_mask_reset 0x8006E5A0 : AT(0x6F1A0) SUBALIGN(4) { build/us/interrupt_mask_reset.o(.text) }
    .cpu_after_interrupt_global_clear 0x8006E5F8 : AT(0x6F1F8) { build/us/fallback.o(.rom_cpu_after_interrupt_global_clear) }
    .pi_extended_write 0x8006E600 : AT(0x6F200) SUBALIGN(4) { build/us/pi_extended_write.o(.text) }
    .cpu_after_epi_raw_write 0x8006E64C : AT(0x6F24C) { build/us/fallback.o(.rom_cpu_after_epi_raw_write) }
    .pi_extended_read 0x8006E650 : AT(0x6F250) SUBALIGN(4) { build/us/pi_extended_read.o(.text) }
    .interrupt_mask_set 0x8006E6A0 : AT(0x6F2A0) SUBALIGN(4) { build/us/interrupt_mask_set.o(.text) }
    .cpu_after_interrupt_global_set 0x8006E6EC : AT(0x6F2EC) { build/us/fallback.o(.rom_cpu_after_interrupt_global_set) }
    .thread_yield 0x8006E6F0 : AT(0x6F2F0) SUBALIGN(4) { build/us/thread_yield.o(.text) }
    .cpu_after_thread_yield 0x8006E73C : AT(0x6F33C) { build/us/fallback.o(.rom_cpu_after_thread_yield) }
    .os_set_compare 0x8006E740 : AT(0x6F340) SUBALIGN(4) { build/us/os_set_compare.o(.text) }
    .audio_filter_base 0x8006E750 : AT(0x6F350) SUBALIGN(4) { build/us/audio_filter_base.o(.text) }
    .cpu_after_audio_filter_init 0x8006E76C : AT(0x6F36C) { build/us/fallback.o(.rom_cpu_after_audio_filter_init) }
    .audio_effect_modulation 0x8006E770 : AT(0x6F370) SUBALIGN(4) { build/us/audio_effect_modulation.o(.text) }
    .audio_effect_buffers 0x8006E818 : AT(0x6F418) SUBALIGN(4) { build/us/audio_effect_buffers.o(.text) }
    .audio_effect_parameters 0x8006EE08 : AT(0x6FA08) SUBALIGN(4) { build/us/audio_effect_parameters.o(.text) }
    .audio_effect_source 0x8006F064 : AT(0x6FC64) SUBALIGN(4) { build/us/audio_effect_source.o(.text) }
    .audio_effect_pull 0x8006F07C : AT(0x6FC7C) SUBALIGN(4) { build/us/audio_effect_pull.o(.text) }
    .cpu_after_audio_effect_pull 0x8006F3BC : AT(0x6FFBC) { build/us/fallback.o(.rom_cpu_after_audio_effect_pull) }
    .audio_copy_bytes 0x8006F3C0 : AT(0x6FFC0) SUBALIGN(4) { build/us/audio_copy_bytes.o(.text) }
    .cpu_after_audio_copy 0x8006F434 : AT(0x70034) { build/us/fallback.o(.rom_cpu_after_audio_copy) }
    /* CPU-visible storage address. The RSP executes this at 0x04001000. */
    .rsp_boot 0x8006F440 : AT(0x70040) { build/us/fallback.o(.rom_rsp_boot) }
    /* Unmapped fallback uses a synthetic VMA, not a claim about RAM layout. */
    .diagnostic_fallback_70110_737e0 0x8006F510 : AT(0x70110) { build/us/fallback.o(.rom_diagnostic_fallback_70110_737e0) }
    .renderer_diagnostic_path_pool 0x80072BE0 : AT(0x737E0) SUBALIGN(4) { build/us/renderer_diagnostic_path_pool.o(.data) }
    .renderer_diagnostic_movie_pool 0x80072BE8 : AT(0x737E8) SUBALIGN(4) { build/us/renderer_diagnostic_movie_pool.o(.data) }
    .effect_config_fallback_737f0_73800 0x80072BF0 : AT(0x737F0) { build/us/fallback.o(.rom_effect_config_fallback_737f0_73800) }
    .effect_draw_config 0x80072C00 : AT(0x73800) SUBALIGN(4) { build/us/effect_draw_config.o(.data) }
    .early_render_tube_data 0x800730D8 : AT(0x73CD8) SUBALIGN(4) { build/us/early_render_tube_data.o(.data) }
    .early_effects_fallback_73d40_742ac 0x80073140 : AT(0x73D40) { build/us/fallback.o(.rom_early_effects_fallback_73d40_742ac) }
    .early_reset_parameter_data 0x800736AC : AT(0x742AC) SUBALIGN(4) { build/us/early_reset_parameter.o(.data) }
    .input_stream_fallback_742b8_74648 0x800736B8 : AT(0x742B8) { build/us/fallback.o(.rom_input_stream_fallback_742b8_74648) }
    .early_input_fixed_data_data 0x80073A48 : AT(0x74648) SUBALIGN(4) { build/us/early_input_fixed_data.o(.data) }
    .diagnostic_fallback_74688_786a0 0x80073A88 : AT(0x74688) { build/us/fallback.o(.rom_diagnostic_fallback_74688_786a0) }
    .renderer_diagnostic_object_pool 0x80077AA0 : AT(0x786A0) SUBALIGN(4) { build/us/renderer_diagnostic_object_pool.o(.data) }
    .diagnostic_fallback_786a8_78d50 0x80077AA8 : AT(0x786A8) { build/us/fallback.o(.rom_diagnostic_fallback_786a8_78d50) }
    .movie_commands_data 0x80078150 : AT(0x78D50) SUBALIGN(4) { build/us/movie_prepare.o(.data) }
    .diagnostic_fallback_78db8_78de4 0x800781B8 : AT(0x78DB8) { build/us/fallback.o(.rom_diagnostic_fallback_78db8_78de4) }
    .renderer_diagnostic_instance_pool 0x800781E4 : AT(0x78DE4) SUBALIGN(4) { build/us/renderer_diagnostic_instance_pool.o(.data) }
    .resource_cache_fallback_78dec_78e64 0x800781EC : AT(0x78DEC) { build/us/fallback.o(.rom_resource_cache_fallback_78dec_78e64) }
    .renderer_resource_map_reset 0x80078264 : AT(0x78E64) SUBALIGN(4) { build/us/renderer_resource_map_reset.o(.data) }
    .resource_cache_fallback_78e70_78e84 0x80078270 : AT(0x78E70) { build/us/fallback.o(.rom_resource_cache_fallback_78e70_78e84) }
    .renderer_model_cache_storage 0x80078284 : AT(0x78E84) SUBALIGN(4) { build/us/renderer_model_cache_storage.o(.data) }
    .renderer_animation_cache_storage 0x8007A1C4 : AT(0x7ADC4) SUBALIGN(4) { build/us/renderer_animation_cache_storage.o(.data) }
    .resource_cache_fallback_7c6c4_7c70c 0x8007BAC4 : AT(0x7C6C4) { build/us/fallback.o(.rom_resource_cache_fallback_7c6c4_7c70c) }
    .renderer_resource_counters 0x8007BB0C : AT(0x7C70C) SUBALIGN(4) { build/us/renderer_resource_counters.o(.data) }
    .resource_cache_fallback_7c718_7cf38 0x8007BB18 : AT(0x7C718) { build/us/fallback.o(.rom_resource_cache_fallback_7c718_7cf38) }
    .actor_direction_table 0x8007C338 : AT(0x7CF38) SUBALIGN(4) { build/us/actor_direction_table.o(.data) }
    .actor_direction_fallback_7d03c_7d148 0x8007C43C : AT(0x7D03C) { build/us/fallback.o(.rom_actor_direction_fallback_7d03c_7d148) }
    .renderer_diagnostic_hierarchy_pool 0x8007C548 : AT(0x7D148) SUBALIGN(4) { build/us/renderer_diagnostic_hierarchy_pool.o(.data) }
    .renderer_setup_fallback_7d150_7d670 0x8007C550 : AT(0x7D150) { build/us/fallback.o(.rom_renderer_setup_fallback_7d150_7d670) }
    .renderer_grid_commands 0x8007CA70 : AT(0x7D670) SUBALIGN(4) { build/us/renderer_grid_commands.o(.rodata) }
    .renderer_setup_viewport 0x8007CAC8 : AT(0x7D6C8) SUBALIGN(4) { build/us/renderer_setup_viewport.o(.rodata) }
    .renderer_setup_fallback_7d6d8_7d700 0x8007CAD8 : AT(0x7D6D8) { build/us/fallback.o(.rom_renderer_setup_fallback_7d6d8_7d700) }
    .renderer_setup_lighting 0x8007CB00 : AT(0x7D700) SUBALIGN(4) { build/us/renderer_setup_lighting.o(.rodata) }
    .renderer_frame_geometry_commands 0x8007CB18 : AT(0x7D718) SUBALIGN(4) { build/us/renderer_frame_geometry_commands.o(.data) }
    .renderer_frame_rdp_commands 0x8007CB58 : AT(0x7D758) SUBALIGN(4) { build/us/renderer_frame_rdp_commands.o(.rodata) }
    .renderer_setup_fallback_7d7d8_7d98c 0x8007CBD8 : AT(0x7D7D8) { build/us/fallback.o(.rom_renderer_setup_fallback_7d7d8_7d98c) }
    .renderer_texture_file_cache_data 0x8007CD8C : AT(0x7D98C) SUBALIGN(4) { build/us/renderer_texture_file_cache.o(.data) }
    .diagnostic_fallback_7d994_7d9a0 0x8007CD94 : AT(0x7D994) { build/us/fallback.o(.rom_diagnostic_fallback_7d994_7d9a0) }
    .renderer_diagnostic_vertex_pool 0x8007CDA0 : AT(0x7D9A0) SUBALIGN(4) { build/us/renderer_diagnostic_vertex_pool.o(.data) }
    .diagnostic_fallback_7d9a8_7d9b0 0x8007CDA8 : AT(0x7D9A8) { build/us/fallback.o(.rom_diagnostic_fallback_7d9a8_7d9b0) }
    .renderer_texture_corner_state 0x8007CDB0 : AT(0x7D9B0) SUBALIGN(4) { build/us/renderer_textured_submit.o(.data) }
    .diagnostic_fallback_7d9c0_7e2a0 0x8007CDC0 : AT(0x7D9C0) { build/us/fallback.o(.rom_diagnostic_fallback_7d9c0_7e2a0) }
    .renderer_diagnostic_matrix_pool 0x8007D6A0 : AT(0x7E2A0) SUBALIGN(4) { build/us/renderer_diagnostic_matrix_pool.o(.data) }
    .renderer_matrix_cursor_data 0x8007D6A8 : AT(0x7E2A8) SUBALIGN(4) { build/us/renderer_matrix_cursor_data.o(.data) }
    .diagnostic_fallback_7e2ac_7e2b0 0x8007D6AC : AT(0x7E2AC) { build/us/fallback.o(.rom_diagnostic_fallback_7e2ac_7e2b0) }
    .renderer_diagnostic_version 0x8007D6B0 : AT(0x7E2B0) SUBALIGN(4) { build/us/renderer_diagnostic_version.o(.rodata) }
    .diagnostic_fallback_7e2d0_7e4f0 0x8007D6D0 : AT(0x7E2D0) { build/us/fallback.o(.rom_diagnostic_fallback_7e2d0_7e4f0) }
    .renderer_diagnostic_frame_count 0x8007D8F0 : AT(0x7E4F0) SUBALIGN(4) { build/us/renderer_diagnostic_frame_count.o(.data) }
    .projection_diagnostic_fallback_7e4f4_7e504 0x8007D8F4 : AT(0x7E4F4) { build/us/fallback.o(.rom_projection_diagnostic_fallback_7e4f4_7e504) }
    .renderer_projection_light_state 0x8007D904 : AT(0x7E504) SUBALIGN(4) { build/us/renderer_projection_state.o(.data) }
    .projection_diagnostic_fallback_7e50c_7e510 0x8007D90C : AT(0x7E50C) { build/us/fallback.o(.rom_projection_diagnostic_fallback_7e50c_7e510) }
    .graphics_buffer_select_data 0x8007D910 : AT(0x7E510) SUBALIGN(4) { build/us/graphics_buffer_select_data.o(.data) }
    .matrix_transform_fallback_7e518_8d720 0x8007D918 : AT(0x7E518) { build/us/fallback.o(.rom_matrix_transform_fallback_7e518_8d720) }
    .renderer_texture_square_extent 0x8008CB20 : AT(0x8D720) SUBALIGN(4) { build/us/renderer_texture_squares.o(.data) }
    .renderer_image_placement_data 0x8008CB24 : AT(0x8D724) SUBALIGN(4) { build/us/renderer_image_placement_data.o(.data) }
    .diagnostic_fallback_8d738_8df60 0x8008CB38 : AT(0x8D738) { build/us/fallback.o(.rom_diagnostic_fallback_8d738_8df60) }
    .renderer_diagnostic_asset_lengths 0x8008D360 : AT(0x8DF60) SUBALIGN(4) { build/us/renderer_diagnostic_asset_lengths.o(.data) }
    .trail_arena_fallback_8df6c_8e080 0x8008D36C : AT(0x8DF6C) { build/us/fallback.o(.rom_trail_arena_fallback_8df6c_8e080) }
    .heap_initializer_flag 0x8008D480 : AT(0x8E080) SUBALIGN(4) { build/us/heap_state.o(.data) }
    .trail_arena_fallback_8e084_8e094 0x8008D484 : AT(0x8E084) { build/us/fallback.o(.rom_trail_arena_fallback_8e084_8e094) }
    .actor_history_flags 0x8008D494 : AT(0x8E094) SUBALIGN(4) { build/us/actor_history_data.o(.data) }
    .endgame_8e0ac_8e0e4 0x8008D4AC : AT(0x8E0AC) { build/us/fallback.o(.rom_endgame_8e0ac_8e0e4) }
    .controller_motor_state_data 0x8008D4E4 : AT(0x8E0E4) SUBALIGN(4) { build/us/controller_motor_state.o(.data) }
    .controller_access_guard_data 0x8008D504 : AT(0x8E104) SUBALIGN(4) { build/us/controller_access_guard.o(.data) }
    .controller_fallback_8e108_8e110 0x8008D508 : AT(0x8E108) { build/us/fallback.o(.rom_controller_fallback_8e108_8e110) }
    .controller_motor_strength_data 0x8008D510 : AT(0x8E110) SUBALIGN(4) { build/us/controller_motor_strength.o(.data) }
    .controller_fallback_8e114_8e468 0x8008D514 : AT(0x8E114) { build/us/fallback.o(.rom_controller_fallback_8e114_8e468) }
    .audio_timing_data_data 0x8008D868 : AT(0x8E468) SUBALIGN(4) { build/us/audio_timing_data.o(.data) }
    .input_stream_fallback_8e478_8e640 0x8008D878 : AT(0x8E478) { build/us/fallback.o(.rom_input_stream_fallback_8e478_8e640) }
    .compression_workspace_data 0x8008DA40 : AT(0x8E640) SUBALIGN(4) { build/us/compression_workspace.o(.data) }
    .short_sine_data 0x8008DBB0 : AT(0x8E7B0) SUBALIGN(4) { build/us/short_sine.o(.data) }
    .initialize_data 0x8008E3B0 : AT(0x8EFB0) SUBALIGN(4) { build/us/initialize.o(.data) }
    .after_initialize_data 0x8008E3C4 : AT(0x8EFC4) { build/us/fallback.o(.rom_after_initialize_data) }
    .pi_manager_create_data 0x8008E3D0 : AT(0x8EFD0) SUBALIGN(4) { build/us/pi_manager_create.o(.data) }
    .endgame_data_8eff8_8f000 0x8008E3F8 : AT(0x8EFF8) { build/us/fallback.o(.rom_endgame_data_8eff8_8f000) }
    .video_modes_data 0x8008E400 : AT(0x8F000) SUBALIGN(4) { build/us/video_modes.o(.data) }
    .gu_random_data 0x8008F120 : AT(0x8FD20) SUBALIGN(4) { build/us/gu_random.o(.data) }
    .data_after_sdk_random_data 0x9001FC14 : AT(0x8FD24) { build/us/fallback.o(.rom_data_after_sdk_random_data) }
    .controller_init_data 0x8008F130 : AT(0x8FD30) SUBALIGN(4) { build/us/controller_init.o(.data) }
    .data_after_sdk_controller_init_data 0x9001FC24 : AT(0x8FD34) { build/us/fallback.o(.rom_data_after_sdk_controller_init_data) }
    .video_manager_data 0x8008F140 : AT(0x8FD40) SUBALIGN(4) { build/us/video_manager.o(.data) }
    .data_after_sdk_vi_manager_data 0x9001FC4C : AT(0x8FD5C) { build/us/fallback.o(.rom_data_after_sdk_vi_manager_data) }
    .audio_synth_lifecycle_data 0x8008F160 : AT(0x8FD60) SUBALIGN(4) { build/us/audio_synth_lifecycle.o(.data) }
    .data_after_sdk_audio_globals_data 0x8008F164 : AT(0x8FD64) { build/us/fallback.o(.rom_data_after_sdk_audio_globals_data) }
    .audio_buffer_submit_data 0x8008F170 : AT(0x8FD70) SUBALIGN(4) { build/us/audio_buffer_submit.o(.data) }
    .endgame_data_8fd71_8fd80 0x8008F171 : AT(0x8FD71) { build/us/fallback.o(.rom_endgame_data_8fd71_8fd80) }
    .exception_state_data 0x8008F180 : AT(0x8FD80) SUBALIGN(4) { build/us/exception_state.o(.data) }
    .endgame_data_8fd94_8fda0 0x8008F194 : AT(0x8FD94) { build/us/fallback.o(.rom_endgame_data_8fd94_8fda0) }
    .thread_state_data 0x8008F1A0 : AT(0x8FDA0) SUBALIGN(4) { build/us/thread_state.o(.data) }
    .endgame_data_8fdb8_8fdd0 0x8008F1B8 : AT(0x8FDB8) { build/us/fallback.o(.rom_endgame_data_8fdb8_8fdd0) }
    .video_initialize_data 0x8008F1D0 : AT(0x8FDD0) SUBALIGN(4) { build/us/video_initialize.o(.data) }
    .after_video_context_data 0x8008F238 : AT(0x8FE38) { build/us/fallback.o(.rom_after_video_context_data) }
    .audio_effect_create_data 0x8008F260 : AT(0x8FE60) SUBALIGN(4) { build/us/audio_effect_create.o(.data) }
    .audio_envelope_data 0x8008F3F0 : AT(0x8FFF0) SUBALIGN(4) { build/us/audio_envelope.o(.data) }
    .video_default_modes_data 0x8008F530 : AT(0x90130) SUBALIGN(4) { build/us/video_default_modes.o(.data) }
    .after_video_default_modes_data 0x8008F620 : AT(0x90220) { build/us/fallback.o(.rom_after_video_default_modes_data) }
    .text_table 0x8008F678 : AT(0x90278) SUBALIGN(4) { build/us/text.o(.rodata) }
    .endgame_data_903a0_90428 0x8008F7A0 : AT(0x903A0) { build/us/fallback.o(.rom_endgame_data_903a0_90428) }
    .movie_string_position_submit_constants 0x8008F828 : AT(0x90428) SUBALIGN(4) { build/us/movie_string_position_submit.o(.rodata) }
    .endgame_data_90438_90530 0x8008F838 : AT(0x90438) { build/us/fallback.o(.rom_endgame_data_90438_90530) }
    .early_signature_gate_rodata 0x8008F930 : AT(0x90530) SUBALIGN(4) { build/us/early_signature_gate.o(.rodata) }
    .endgame_90540_90558 0x8008F940 : AT(0x90540) { build/us/fallback.o(.rom_endgame_90540_90558) }
    .early_effect_spawn_rodata 0x8008F958 : AT(0x90558) SUBALIGN(4) { build/us/early_effect_spawn.o(.rodata) }
    .early_render_coordinate_data 0x8008F970 : AT(0x90570) SUBALIGN(4) { build/us/early_render_coordinate_data.o(.data) }
    .early_render_handler_select_rodata 0x8008F974 : AT(0x90574) SUBALIGN(4) { build/us/early_render_handler_select.o(.rodata) }
    .endgame_data_90588_90a04 0x8008F988 : AT(0x90588) { build/us/fallback.o(.rom_endgame_data_90588_90a04) }
    .actor_pickup_dispatch 0x8008FE04 : AT(0x90A04) SUBALIGN(4) { build/us/actor_pickup.o(.rodata) }
    .endgame_data_90a44_90b08 0x8008FE44 : AT(0x90A44) { build/us/fallback.o(.rom_endgame_data_90a44_90b08) }
    .actor_collision_kind_dispatch_rodata 0x8008FF08 : AT(0x90B08) SUBALIGN(4) { build/us/actor_collision_kind_dispatch.o(.rodata) }
    .endgame_90b1c_90c98 0x8008FF1C : AT(0x90B1C) { build/us/fallback.o(.rom_endgame_90b1c_90c98) }
    .actor_collision_death_result_rodata 0x80090098 : AT(0x90C98) SUBALIGN(4) { build/us/actor_collision_death_result.o(.rodata) }
    .endgame_data_90cac_90d3c 0x800900AC : AT(0x90CAC) { build/us/fallback.o(.rom_endgame_data_90cac_90d3c) }
    .collision_dispatch_initialize_strings 0x8009013C : AT(0x90D3C) SUBALIGN(4) { build/us/collision_dispatch_initialize.o(.rodata) }
    .lifecycle_fallback_90d9c_90e1c 0x8009019C : AT(0x90D9C) { build/us/fallback.o(.rom_lifecycle_fallback_90d9c_90e1c) }
    .actor_create_switch 0x8009021C : AT(0x90E1C) SUBALIGN(4) { build/us/actor_create.o(.rodata) }
    .actor_behavior_counter_expire_rodata 0x800902A4 : AT(0x90EA4) SUBALIGN(4) { build/us/actor_behavior_counter_expire.o(.rodata) }
    .endgame_data_90ed4_90f70 0x800902D4 : AT(0x90ED4) { build/us/fallback.o(.rom_endgame_data_90ed4_90f70) }
    .name_table_lookup_data 0x80090370 : AT(0x90F70) SUBALIGN(4) { build/us/name_table_lookup.o(.data) }
    .endgame_data_90f96_92558 0x80090396 : AT(0x90F96) { build/us/fallback.o(.rom_endgame_data_90f96_92558) }
    .scene_background_constants 0x80091958 : AT(0x92558) SUBALIGN(4) { build/us/scene_background.o(.rodata) }
    .endgame_data_92560_93698 0x80091960 : AT(0x92560) { build/us/fallback.o(.rom_endgame_data_92560_93698) }
    .session_background_select_rodata 0x80092A98 : AT(0x93698) SUBALIGN(4) { build/us/session_background_select.o(.rodata) }
    .endgame_data_936c4_9450c 0x80092AC4 : AT(0x936C4) { build/us/fallback.o(.rom_endgame_data_936c4_9450c) }
    .actor_pool_allocate_strings 0x8009390C : AT(0x9450C) SUBALIGN(4) { build/us/actor_pool_allocate.o(.rodata) }
    .actor_human_diagnostic 0x8009396C : AT(0x9456C) SUBALIGN(4) { build/us/actor_human_diagnostic.o(.data) }
    .actor_behavior_diagnostic 0x80093988 : AT(0x94588) SUBALIGN(4) { build/us/actor_behavior_diagnostic.o(.data) }
    .actor_brain_diagnostic 0x800939A4 : AT(0x945A4) SUBALIGN(4) { build/us/actor_brain_diagnostic.o(.data) }
    .lifecycle_fallback_945bc_945c0 0x800939BC : AT(0x945BC) { build/us/fallback.o(.rom_lifecycle_fallback_945bc_945c0) }
    .actor_position_submit_constant 0x800939C0 : AT(0x945C0) SUBALIGN(4) { build/us/actor_position_submit.o(.rodata) }
    .actor_behavior_next_a244_rodata 0x800939C4 : AT(0x945C4) SUBALIGN(4) { build/us/actor_behavior_next_a244.o(.rodata) }
    .actor_behavior_stride_switch 0x800939F8 : AT(0x945F8) SUBALIGN(4) { build/us/actor_behavior_stride.o(.rodata) }
    .actor_behavior_hulk_switch 0x80093A1C : AT(0x9461C) SUBALIGN(4) { build/us/actor_behavior_hulk.o(.rodata) }
    .actor_behavior_enforcer_switch 0x80093A44 : AT(0x94644) SUBALIGN(4) { build/us/actor_behavior_enforcer.o(.rodata) }
    .actor_behavior_pursuit_switch 0x80093A68 : AT(0x94668) SUBALIGN(4) { build/us/actor_behavior_pursuit.o(.rodata) }
    .lifecycle_fallback_9468c_94c84 0x80093A8C : AT(0x9468C) { build/us/fallback.o(.rom_lifecycle_fallback_9468c_94c84) }
    .save_menu_status_tables 0x80094084 : AT(0x94C84) SUBALIGN(4) { build/us/save_menu_status.o(.rodata) }
    .script_diagnostic_fallback_94cb4_94d10 0x800940B4 : AT(0x94CB4) { build/us/fallback.o(.rom_script_diagnostic_fallback_94cb4_94d10) }
    .command_script_diagnostics 0x80094110 : AT(0x94D10) SUBALIGN(4) { build/us/command_script_diagnostics.o(.data) }
    .script_diagnostic_fallback_94d34_94d6c 0x80094134 : AT(0x94D34) { build/us/fallback.o(.rom_script_diagnostic_fallback_94d34_94d6c) }
    .command_machine_table 0x8009416C : AT(0x94D6C) SUBALIGN(4) { build/us/command_machine.o(.rodata) }
    .retirement_fallback_94d8c_94e44 0x8009418C : AT(0x94D8C) { build/us/fallback.o(.rom_retirement_fallback_94d8c_94e44) }
    .actor_manual_motion_diagnostic 0x80094244 : AT(0x94E44) SUBALIGN(4) { build/us/actor_manual_motion_diagnostic.o(.data) }
    .retirement_fallback_94e54_94e94 0x80094254 : AT(0x94E54) { build/us/fallback.o(.rom_retirement_fallback_94e54_94e94) }
    .actor_retirement_switch 0x80094294 : AT(0x94E94) SUBALIGN(4) { build/us/actor_retirement.o(.rodata) }
    .retirement_fallback_94eb8_94ec0 0x800942B8 : AT(0x94EB8) { build/us/fallback.o(.rom_retirement_fallback_94eb8_94ec0) }
    .sound_request_dispatch_strings 0x800942C0 : AT(0x94EC0) SUBALIGN(4) { build/us/sound_request_dispatch.o(.rodata) }
    .sound_bridge_future_queue_strings 0x800942E0 : AT(0x94EE0) SUBALIGN(4) { build/us/sound_bridge_future_queue.o(.rodata) }
    .destination_format_table 0x80094300 : AT(0x94F00) SUBALIGN(4) { build/us/destination_format.o(.rodata) }
    .tweak_messages 0x80094350 : AT(0x94F50) SUBALIGN(4) { build/us/tweak_messages.o(.data) }
    .tweak_fallback_95038_957e0 0x80094438 : AT(0x95038) { build/us/fallback.o(.rom_tweak_fallback_95038_957e0) }
    .scene_frame_tick_constants 0x80094BE0 : AT(0x957E0) SUBALIGN(4) { build/us/scene_frame_tick.o(.rodata) }
    .camera_fallback_957e8_95848 0x80094BE8 : AT(0x957E8) { build/us/fallback.o(.rom_camera_fallback_957e8_95848) }
    .object_camera_angles_constant 0x80094C48 : AT(0x95848) SUBALIGN(4) { build/us/object_camera_angles.o(.rodata) }
    .object_camera_angles_alt_constant 0x80094C4C : AT(0x9584C) SUBALIGN(4) { build/us/object_camera_angles_alt.o(.rodata) }
    .model_file_relocate_strings 0x80094C50 : AT(0x95850) SUBALIGN(4) { build/us/model_file_relocate.o(.rodata) }
    .endgame_data_95880_95b20 0x80094C80 : AT(0x95880) { build/us/fallback.o(.rom_endgame_data_95880_95b20) }
    .renderer_vertex_attributes_strings 0x80094F20 : AT(0x95B20) SUBALIGN(4) { build/us/renderer_vertex_attributes.o(.rodata) }
    .renderer_vertex_positions_strings 0x80095010 : AT(0x95C10) SUBALIGN(4) { build/us/renderer_vertex_positions.o(.rodata) }
    .renderer_expanded_triangle_strings 0x80095060 : AT(0x95C60) SUBALIGN(4) { build/us/renderer_expanded_triangle.o(.rodata) }
    .renderer_expanded_quad_messages 0x80095088 : AT(0x95C88) SUBALIGN(4) { build/us/renderer_expanded_quad_messages.o(.rodata) }
    .renderer_textured_submit_strings 0x800950B0 : AT(0x95CB0) SUBALIGN(4) { build/us/renderer_textured_submit.o(.rodata) }
    .renderer_polygon_messages 0x80095100 : AT(0x95D00) SUBALIGN(4) { build/us/renderer_polygon_messages.o(.rodata) }
    .renderer_mesh_positions_strings 0x800951A0 : AT(0x95DA0) SUBALIGN(4) { build/us/renderer_mesh_positions.o(.rodata) }
    .graphics_resource_strings 0x800951C8 : AT(0x95DC8) SUBALIGN(4) { build/us/graphics_resource.o(.rodata) }
    .data_after_graphics_resource_strings 0x91005A3C : AT(0x95DDC) { build/us/fallback.o(.rom_data_after_graphics_resource_strings) }
    .graphics_pool_strings 0x80095220 : AT(0x95E20) SUBALIGN(4) { build/us/graphics_pool.o(.rodata) }
    .graphics_mode_dispatch_table 0x80095300 : AT(0x95F00) SUBALIGN(4) { build/us/graphics_mode_dispatch.o(.rodata) }
    .renderer_matrix_transform_strings 0x80095360 : AT(0x95F60) SUBALIGN(4) { build/us/renderer_matrix_transform.o(.rodata) }
    .renderer_supplied_matrix_diagnostics 0x800953A0 : AT(0x95FA0) SUBALIGN(4) { build/us/renderer_supplied_matrix_diagnostics.o(.data) }
    .renderer_matrix_submit_strings 0x800953E0 : AT(0x95FE0) SUBALIGN(4) { build/us/renderer_matrix_submit.o(.rodata) }
    .projection_diagnostic_fallback_96020_96038 0x80095420 : AT(0x96020) { build/us/fallback.o(.rom_projection_diagnostic_fallback_96020_96038) }
    .renderer_projection_constants 0x80095438 : AT(0x96038) SUBALIGN(4) { build/us/renderer_projection_constants.o(.data) }
    .renderer_projection_highlight_constants 0x80095468 : AT(0x96068) SUBALIGN(4) { build/us/renderer_projection_highlight.o(.rodata) }
    .frame_projection_rodata 0x80095498 : AT(0x96098) SUBALIGN(4) { build/us/frame_projection.o(.rodata) }
    .endgame_data_960a4_960b0 0x800954A4 : AT(0x960A4) { build/us/fallback.o(.rom_endgame_data_960a4_960b0) }
    .renderer_status_message 0x800954B0 : AT(0x960B0) SUBALIGN(4) { build/us/renderer_status_text.o(.rodata) }
    .trail_arena_fallback_960c4_960f0 0x800954C4 : AT(0x960C4) { build/us/fallback.o(.rom_trail_arena_fallback_960c4_960f0) }
    .resource_arena_diagnostics 0x800954F0 : AT(0x960F0) SUBALIGN(4) { build/us/render_buffer_reserve.o(.rodata) }
    .renderer_resource_messages 0x80095530 : AT(0x96130) SUBALIGN(4) { build/us/renderer_resource_messages.o(.rodata) }
    .mesh_resource_fallback_961e4_96240 0x800955E4 : AT(0x961E4) { build/us/fallback.o(.rom_mesh_resource_fallback_961e4_96240) }
    .renderer_diagnostic_messages 0x80095640 : AT(0x96240) SUBALIGN(4) { build/us/renderer_diagnostic_messages.o(.rodata) }
    .actor_history_tick_constant 0x80095B30 : AT(0x96730) SUBALIGN(4) { build/us/actor_history_tick.o(.rodata) }
    .object_history_write_rodata 0x80095B34 : AT(0x96734) SUBALIGN(4) { build/us/object_history_write.o(.rodata) }
    .controller_fallback_96738_967b0 0x80095B38 : AT(0x96738) { build/us/fallback.o(.rom_controller_fallback_96738_967b0) }
    .controller_motor_initialize_message_data 0x80095BB0 : AT(0x967B0) SUBALIGN(4) { build/us/controller_motor_initialize_message.o(.data) }
    .controller_fallback_967c4_967c8 0x80095BC4 : AT(0x967C4) { build/us/fallback.o(.rom_controller_fallback_967c4_967c8) }
    .controller_motor_refresh_message_data 0x80095BC8 : AT(0x967C8) SUBALIGN(4) { build/us/controller_motor_refresh_message.o(.data) }
    .controller_fallback_967dc_967f0 0x80095BDC : AT(0x967DC) { build/us/fallback.o(.rom_controller_fallback_967dc_967f0) }
    .graphics_setup_table 0x80095BF0 : AT(0x967F0) SUBALIGN(4) { build/us/graphics_setup.o(.rodata) }
    .endgame_9686c_96890 0x80095C6C : AT(0x9686C) { build/us/fallback.o(.rom_endgame_9686c_96890) }
    .audio_dma_read_rodata 0x80095C90 : AT(0x96890) SUBALIGN(4) { build/us/audio_dma_read.o(.rodata) }
    .audio_dma_recycle_rodata 0x80095C9C : AT(0x9689C) SUBALIGN(4) { build/us/audio_dma_recycle.o(.rodata) }
    .endgame_data_968a8_968b0 0x80095CA8 : AT(0x968A8) { build/us/fallback.o(.rom_endgame_data_968a8_968b0) }
    .audio_memory_size_strings 0x80095CB0 : AT(0x968B0) SUBALIGN(4) { build/us/audio_memory_size.o(.rodata) }
    .endgame_data_968b8_968c4 0x80095CB8 : AT(0x968B8) { build/us/fallback.o(.rom_endgame_data_968b8_968c4) }
    .audio_pitch_scale_rodata 0x80095CC4 : AT(0x968C4) SUBALIGN(4) { build/us/audio_pitch_scale.o(.rodata) }
    .after_audio_pitch_scale_rodata 0x80095CCC : AT(0x968CC) { build/us/fallback.o(.rom_after_audio_pitch_scale_rodata) }
    .camera_perspective_rodata 0x80095CF0 : AT(0x968F0) SUBALIGN(4) { build/us/camera_perspective.o(.rodata) }
    .camera_highlights_rodata 0x80095D00 : AT(0x96900) SUBALIGN(4) { build/us/camera_highlights.o(.rodata) }
    .matrix_rotation_rodata 0x80095D20 : AT(0x96920) SUBALIGN(4) { build/us/matrix_rotation.o(.rodata) }
    .sine_float_rodata 0x80095D30 : AT(0x96930) SUBALIGN(4) { build/us/sine_float.o(.rodata) }
    .after_sine_float_rodata 0x80095D74 : AT(0x96974) { build/us/fallback.o(.rom_after_sine_float_rodata) }
    .cosine_float_rodata 0x80095D80 : AT(0x96980) SUBALIGN(4) { build/us/cosine_float.o(.rodata) }
    .after_cosine_float_rodata 0x80095DC4 : AT(0x969C4) { build/us/fallback.o(.rom_after_cosine_float_rodata) }
    .rcp_interrupt_masks_rodata 0x80095DD0 : AT(0x969D0) SUBALIGN(4) { build/us/rcp_interrupt_masks.o(.rodata) }
    .audio_synthesizer_rodata 0x80095E50 : AT(0x96A50) SUBALIGN(4) { build/us/audio_synthesizer.o(.rodata) }
    .cpu_interrupt_tables_rodata 0x80095E60 : AT(0x96A60) SUBALIGN(4) { build/us/cpu_interrupt_tables.o(.rodata) }
    .cpu_interrupt_tables_data 0x80095E80 : AT(0x96A80) SUBALIGN(4) { build/us/cpu_interrupt_tables.o(.data) }
    .endgame_data_96aa4_96ab0 0x80095EA4 : AT(0x96AA4) { build/us/fallback.o(.rom_endgame_data_96aa4_96ab0) }
    .pi_device_manager_rodata 0x80095EB0 : AT(0x96AB0) SUBALIGN(4) { build/us/pi_device_manager.o(.rodata) }
    .endgame_data_96acc_96ae0 0x80095ECC : AT(0x96ACC) { build/us/fallback.o(.rom_endgame_data_96acc_96ae0) }
    .audio_effect_create_rodata 0x80095EE0 : AT(0x96AE0) SUBALIGN(4) { build/us/audio_effect_create.o(.rodata) }
    .audio_resample_rodata 0x80095F00 : AT(0x96B00) SUBALIGN(4) { build/us/audio_resample.o(.rodata) }
    .data_after_sdk_audio_resample_constants 0x91006794 : AT(0x96B34) { build/us/fallback.o(.rom_data_after_sdk_audio_resample_constants) }
    .audio_envelope_rodata 0x80095F40 : AT(0x96B40) SUBALIGN(4) { build/us/audio_envelope.o(.rodata) }
    .audio_effect_parameters_rodata 0x80095FA0 : AT(0x96BA0) SUBALIGN(4) { build/us/audio_effect_parameters.o(.rodata) }
    .data_after_sdk_audio_effect_constants 0x91006828 : AT(0x96BC8) { build/us/fallback.o(.rom_data_after_sdk_audio_effect_constants) }
    .audio_engine_voice_stop_bss 0x80192758 (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_voice_stop.o(.bss) }
    .actor_child_resources 0x800AC998 (NOLOAD) : SUBALIGN(4) { build/us/actor_child_resources.o(.bss) }
    .actor_child_counts 0x800ACD90 (NOLOAD) : SUBALIGN(4) { build/us/actor_child_counts.o(.bss) }
    .audio_engine_tempo_bss 0x8019279C (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_tempo.o(.bss) }
    .audio_engine_sequence_call_bss 0x801927AC (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_sequence_call.o(.bss) }
    .audio_engine_sequence_jump_bss 0x801927C4 (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_sequence_jump.o(.bss) }
    .audio_engine_sequence_return_bss 0x801927DC (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_sequence_return.o(.bss) }
    .audio_engine_sequence_stop_bss 0x801927EC (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_sequence_stop.o(.bss) }
    .audio_backend_update_bss 0x80192AC0 (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_update.o(.bss) }
    .audio_backend_voice_stop_bss 0x80192ACC (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_voice_stop.o(.bss) }
    .audio_backend_patch_bss 0x80192AE0 (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_patch.o(.bss) }
    .audio_backend_decay_bss 0x80192B3C (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_decay.o(.bss) }
    .audio_backend_allocate_bss 0x80192B44 (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_allocate.o(.bss) }
    .compression_workspace_bss 0x80192BD0 (NOLOAD) : SUBALIGN(4) { build/us/compression_workspace.o(.bss) }
    .audio_backend_initialize_bss 0x80192ABC (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_initialize.o(.bss) }
    .audio_backend_volume_bss 0x80192AFC (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_volume.o(.bss) }
    .audio_backend_pan_pedal_bss 0x80192B10 (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_pan_pedal.o(.bss) }
    .audio_engine_gate_reset_bss 0x80192788 (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_gate_reset.o(.bss) }
    .audio_engine_iteration_reset_bss 0x80192790 (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_iteration_reset.o(.bss) }
    .audio_engine_iteration_set_bss 0x80192798 (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_iteration_set.o(.bss) }
    .audio_engine_gate_bss 0x80192770 (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_gate.o(.bss) }
    .audio_engine_iteration_bss 0x8019277C (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_iteration.o(.bss) }
    .audio_backend_note_release_bss 0x80192B70 (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_note_release.o(.bss) }
    .timer_initialize_bss 0x80196450 (NOLOAD) : SUBALIGN(4) { build/us/timer_initialize.o(.bss) }
    .matrix_rotation_bss 0x80194D10 (NOLOAD) : SUBALIGN(4) { build/us/matrix_rotation.o(.bss) }
    .pfs_is_plug_bss 0x80194D20 (NOLOAD) : SUBALIGN(4) { build/us/pfs_is_plug.o(.bss) }
    .controller_read_bss 0x80194FA0 (NOLOAD) : SUBALIGN(4) { build/us/controller_read.o(.bss) }
    .pfs_motor_bss 0x80194D60 (NOLOAD) : SUBALIGN(4) { build/us/pfs_motor.o(.bss) }
    .controller_init_bss 0x80194FE0 (NOLOAD) : SUBALIGN(4) { build/us/controller_init.o(.bss) }
    .video_manager_bss 0x801950B0 (NOLOAD) : SUBALIGN(4) { build/us/video_manager.o(.bss) }
    .pi_cartridge_initialize_bss 0x80196310 (NOLOAD) : SUBALIGN(4) { build/us/pi_cartridge_initialize.o(.bss) }
    .pi_disk_initialize_bss 0x80196390 (NOLOAD) : SUBALIGN(4) { build/us/pi_disk_initialize.o(.bss) }
    .pi_manager_create_bss 0x80193B40 (NOLOAD) : SUBALIGN(4) { build/us/pi_manager_create.o(.bss) }
    .initialize_bss 0x80193B30 (NOLOAD) : SUBALIGN(4) { build/us/initialize.o(.bss) }
    .exception_state_bss 0x80196490 (NOLOAD) : SUBALIGN(4) { build/us/exception_state.o(.bss) }
    .menu_transition_start_bss 0x800AEE98 (NOLOAD) : SUBALIGN(4) { build/us/menu_transition_start.o(.bss) }
    .renderer_texture_file_cache_bss 0x800CD3C0 (NOLOAD) : SUBALIGN(4) { build/us/renderer_texture_file_cache.o(.bss) }
    .actor_position_pair_add_bss 0x800A4580 (NOLOAD) : SUBALIGN(4) { build/us/actor_position_pair_add.o(.bss) }
    .actor_random_spawn_bss 0x800AD138 (NOLOAD) : SUBALIGN(4) { build/us/actor_random_spawn.o(.bss) }
    .audio_callback_add_bss 0x801902F0 (NOLOAD) : SUBALIGN(4) { build/us/audio_callback_add.o(.bss) }
    .audio_callback_remove_bss 0x801902F8 (NOLOAD) : SUBALIGN(4) { build/us/audio_callback_remove.o(.bss) }
    .audio_backend_voice_release_bss 0x80192B38 (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_voice_release.o(.bss) }
    .audio_backend_pan_command_bss 0x80192B28 (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_pan_command.o(.bss) }
    .audio_backend_patch_trigger_bss 0x80192B5C (NOLOAD) : SUBALIGN(4) { build/us/audio_backend_patch_trigger.o(.bss) }
    .controller_thread_state_bss 0x80141210 (NOLOAD) : SUBALIGN(4) { build/us/controller_thread_state.o(.bss) }
    .audio_engine_parameter_callback_state 0x80192764 (NOLOAD) : SUBALIGN(4) { build/us/audio_engine_parameters.o(.bss) }
    .collision_dispatch_initialize_bss 0x800974A0 (NOLOAD) : SUBALIGN(4) { build/us/collision_dispatch_initialize.o(.bss) }
    .actor_pool_allocate_bss 0x800A4628 (NOLOAD) : SUBALIGN(4) { build/us/actor_pool_allocate.o(.bss) }
    .actor_history_points_bss 0x8013EC00 (NOLOAD) : SUBALIGN(4) { build/us/actor_history_data.o(.bss) }
    /DISCARD/ : {
        *(.reginfo .MIPS.abiflags .mdebug .mdebug.* .pdr .comment .note.GNU-stack)
    }
    .camera_state_data_bss 0x800C8B88 (NOLOAD) : SUBALIGN(4) { build/us/camera_state_data.o(.bss) }
    .camera_matrix_data_bss 0x800CD250 (NOLOAD) : SUBALIGN(4) { build/us/camera_matrix_data.o(.bss) }
    .controller_pad_state_bss 0x8013DBA0 (NOLOAD) : SUBALIGN(4) { build/us/controller_pad_state.o(.bss) }
    .early_input_cursor_data_bss 0x8009E588 (NOLOAD) : SUBALIGN(4) { build/us/early_input_cursor_data.o(.bss) }
    .early_input_button_data_bss 0x8009E590 (NOLOAD) : SUBALIGN(4) { build/us/early_input_button_data.o(.bss) }
    .early_input_counter_data_bss 0x8009E9E0 (NOLOAD) : SUBALIGN(4) { build/us/early_input_counter_data.o(.bss) }
    .early_input_sequence_data_bss 0x8009EE08 (NOLOAD) : SUBALIGN(4) { build/us/early_input_sequence_data.o(.bss) }
    .renderer_vertex_arena_data_bss 0x800CDBD0 (NOLOAD) : SUBALIGN(4) { build/us/renderer_vertex_arena_data.o(.bss) }
    .early_render_color_data_bss 0x80138268 (NOLOAD) : SUBALIGN(4) { build/us/early_render_color_data.o(.bss) }
    .renderer_image_placement_data_bss 0x8013D9A0 (NOLOAD) : SUBALIGN(4) { build/us/renderer_image_placement_data.o(.bss) }
    .renderer_matrix_arena_data_bss 0x80126B90 (NOLOAD) : SUBALIGN(8) { build/us/renderer_matrix_arena_data.o(.bss) }
    .graphics_rsp_stack_data_bss 0x8012E890 (NOLOAD) : SUBALIGN(8) { build/us/graphics_rsp_stack_data.o(.bss) }
    .graphics_rsp_yield_data_bss 0x80136CD0 (NOLOAD) : SUBALIGN(8) { build/us/graphics_rsp_yield_data.o(.bss) }
    .renderer_diagnostic_frame_metrics_bss 0x80126B30 (NOLOAD) : SUBALIGN(4) { build/us/renderer_diagnostic_frame_metrics.o(.bss) }
    .controller_connection_masks_bss 0x8013D9D0 (NOLOAD) : SUBALIGN(4) { build/us/controller_connection_masks.o(.bss) }
    .controller_paks_bss 0x8013D9D8 (NOLOAD) : SUBALIGN(4) { build/us/controller_paks.o(.bss) }
    .controller_file_index_bss 0x8013DB78 (NOLOAD) : SUBALIGN(4) { build/us/controller_file_index.o(.bss) }
    .controller_motor_command_bss 0x80143418 (NOLOAD) : SUBALIGN(4) { build/us/controller_motor_command.o(.bss) }
    .controller_access_queue_bss 0x80143428 (NOLOAD) : SUBALIGN(4) { build/us/controller_access_queue.o(.bss) }
    .controller_polled_buttons_bss 0x80143440 (NOLOAD) : SUBALIGN(4) { build/us/controller_polled_buttons.o(.bss) }
    .controller_pak_directory_state_bss 0x80143450 (NOLOAD) : SUBALIGN(4) { build/us/controller_pak_directory_state.o(.bss) }
    .controller_access_message_bss 0x80143424 (NOLOAD) : SUBALIGN(4) { build/us/controller_access_message.o(.bss) }
    .renderer_resource_identifier_maps_bss 0x800C8E00 (NOLOAD) : SUBALIGN(4) { build/us/renderer_resource_identifier_maps.o(.bss) }
    .renderer_resource_arena_state 0x8013D9C0 (NOLOAD) : SUBALIGN(4) { build/us/renderer_resource_arena_state.o(.bss) }
    .heap_first_block 0x8013EBF0 (NOLOAD) : SUBALIGN(4) { build/us/heap_state.o(.bss) }
    .renderer_projection_normalization 0x8013D950 (NOLOAD) : SUBALIGN(4) { build/us/renderer_projection_state.o(.bss) }
    .tweak_variables 0x8009F030 (NOLOAD) : SUBALIGN(4) { build/us/tweak_variables.o(.bss) }
    .tweak_pages 0x8009F4E0 (NOLOAD) : SUBALIGN(4) { build/us/tweak_pages.o(.bss) }
    .tweak_difficulties 0x8009FAE0 (NOLOAD) : SUBALIGN(4) { build/us/tweak_difficulties.o(.bss) }
    .tweak_counters 0x8009F024 (NOLOAD) : SUBALIGN(4) { build/us/tweak_counters.o(.bss) }
    .tweak_display_state 0x8009F558 (NOLOAD) : SUBALIGN(4) { build/us/tweak_display_state.o(.bss) }
    .palette_base_storage 0x8009CD18 (NOLOAD) : SUBALIGN(4) { build/us/palette_base_storage.o(.bss) }
    .palette_transition_storage 0x8009D120 (NOLOAD) : SUBALIGN(4) { build/us/palette_transition_storage.o(.bss) }
    .palette_fade_color 0x8009E570 (NOLOAD) : SUBALIGN(4) { build/us/palette_fade_color.o(.bss) }
    .palette_fade_progress 0x8009E578 (NOLOAD) : SUBALIGN(4) { build/us/palette_fade_progress.o(.bss) }
    .palette_fade_step 0x8009E580 (NOLOAD) : SUBALIGN(4) { build/us/palette_fade_step.o(.bss) }
    .object_record_storage 0x800BF918 (NOLOAD) : SUBALIGN(4) { build/us/object_record_storage.o(.bss) }
    .object_slot_storage 0x800C86C0 (NOLOAD) : SUBALIGN(4) { build/us/object_slot_storage.o(.bss) }
    .unexpected 0 : { *(.text .data .rodata .bss .sdata .sbss COMMON) }
}

ASSERT(SIZEOF(.header) == 0x40, "header size changed")
ASSERT(SIZEOF(.ipl3) == 0xfc0, "IPL3 size changed")
ASSERT(SIZEOF(.entry) == 0x50, "entry size changed")
ASSERT(SIZEOF(.text_start) == 0xaf8, "initial text functions size changed")
ASSERT(SIZEOF(.movie_reset) == 0x48, "movie_reset size changed")
ASSERT(SIZEOF(.movie_parameters) == 0x118, "movie_parameters size changed")
ASSERT(SIZEOF(.movie_commands) == 0x7b8, "movie_commands size changed")
ASSERT(SIZEOF(.movie_channels) == 0x284, "movie_channels size changed")
ASSERT(SIZEOF(.movie_files) == 0x2f8, "movie_files size changed")
ASSERT(SIZEOF(.movie_track_release) == 0x158, "movie_track_release size changed")
ASSERT(SIZEOF(.movie_camera) == 0x1cc, "movie_camera size changed")
ASSERT(SIZEOF(.movie_sample) == 0x1c0, "movie_sample size changed")
ASSERT(SIZEOF(.movie_actor) == 0x1b4, "movie_actor size changed")
ASSERT(SIZEOF(.movie_callback) == 0xa0, "movie_callback size changed")
ASSERT(SIZEOF(.movie_prepare) == 0x138, "movie_prepare size changed")
ASSERT(SIZEOF(.movie_start) == 0x658, "movie_start size changed")
ASSERT(SIZEOF(.cpu_after_movie_start) == 0x718, "cpu_after_movie_start size changed")
ASSERT(SIZEOF(.movie_status) == 0xf8, "movie_status size changed")
ASSERT(SIZEOF(.movie_cleanup) == 0x114, "movie_cleanup size changed")
ASSERT(SIZEOF(.early_actor_tick) == 0x38, "early_actor_tick size changed")
ASSERT(SIZEOF(.early_render_color) == 0x1c, "early_render_color size changed")
ASSERT(SIZEOF(.early_render_presets) == 0x70, "early_render_presets size changed")
ASSERT(SIZEOF(.cpu_after_early_render_presets) == 0x4ac, "cpu_after_early_render_presets size changed")
ASSERT(SIZEOF(.early_render_dispatch) == 0x40, "early_render_dispatch size changed")
ASSERT(SIZEOF(.early_pool_entry_clear) == 0x2c, "early_pool_entry_clear size changed")
ASSERT(SIZEOF(.early_pool_count) == 0x5c, "early_pool_count size changed")
ASSERT(SIZEOF(.early_pool_index) == 0x20, "early_pool_index size changed")
ASSERT(SIZEOF(.early_byte_clear) == 0xc, "early_byte_clear size changed")
ASSERT(SIZEOF(.cpu_after_early_byte_clear) == 0x8f4, "cpu_after_early_byte_clear size changed")
ASSERT(SIZEOF(.early_angle_normalize) == 0x1c, "early_angle_normalize size changed")
ASSERT(SIZEOF(.early_actor_vector_clear) == 0x14, "early_actor_vector_clear size changed")
ASSERT(SIZEOF(.early_global_reset) == 0x14, "early_global_reset size changed")
ASSERT(SIZEOF(.early_float_step) == 0x50, "early_float_step size changed")
ASSERT(SIZEOF(.early_selection_state) == 0x1e4, "early_selection_state size changed")
ASSERT(SIZEOF(.early_callbacks_true) == 0x30, "early_callbacks_true size changed")
ASSERT(SIZEOF(.early_actor_pair_balance) == 0x54, "early_actor_pair_balance size changed")
ASSERT(SIZEOF(.early_actor_create) == 0x164, "early_actor_create size changed")
ASSERT(SIZEOF(.early_actor_state) == 0x128, "early_actor_state size changed")
ASSERT(SIZEOF(.early_actor_mode3) == 0x24, "early_actor_mode3 size changed")
ASSERT(SIZEOF(.cpu_after_early_actor_mode3) == 0x6b4, "cpu_after_early_actor_mode3 size changed")
ASSERT(SIZEOF(.early_actor_guarded_service) == 0x4c, "early_actor_guarded_service size changed")
ASSERT(SIZEOF(.early_actor_mode0) == 0x24, "early_actor_mode0 size changed")
ASSERT(SIZEOF(.early_six_arg_forward) == 0x3c, "early_six_arg_forward size changed")
ASSERT(SIZEOF(.cpu_after_early_six_arg_forward) == 0xa14, "cpu_after_early_six_arg_forward size changed")
ASSERT(SIZEOF(.early_callback_false) == 0x18, "early_callback_false size changed")
ASSERT(SIZEOF(.early_actor_transition) == 0xcc, "early_actor_transition size changed")
ASSERT(SIZEOF(.early_pointer_state) == 0x80, "early_pointer_state size changed")
ASSERT(SIZEOF(.early_resource_state) == 0x1a4, "early_resource_state size changed")
ASSERT(SIZEOF(.early_actor_spawn_helper) == 0x6c, "early_actor_spawn_helper size changed")
ASSERT(SIZEOF(.early_simple_forward) == 0x20, "early_simple_forward size changed")
ASSERT(SIZEOF(.early_actor_callback_install) == 0x90, "early_actor_callback_install size changed")
ASSERT(SIZEOF(.early_file_state_reset) == 0x68, "early_file_state_reset size changed")
ASSERT(SIZEOF(.cpu_after_early_file_state_reset) == 0x2d4, "cpu_after_early_file_state_reset size changed")
ASSERT(SIZEOF(.early_name_mask_lookup) == 0x8c, "early_name_mask_lookup size changed")
ASSERT(SIZEOF(.early_value_lookup) == 0xec, "early_value_lookup size changed")
ASSERT(SIZEOF(.early_name_mask_parse) == 0x108, "early_name_mask_parse size changed")
ASSERT(SIZEOF(.script_service_cache_reset) == 0x50, "script_service_cache_reset size changed")
ASSERT(SIZEOF(.script_service_files) == 0x134, "script_service_files size changed")
ASSERT(SIZEOF(.script_service_cache_access) == 0x284, "script_service_cache_access size changed")
ASSERT(SIZEOF(.cpu_after_script_service_cache_access) == 0x8, "cpu_after_script_service_cache_access size changed")
ASSERT(SIZEOF(.script_service_commands) == 0x244, "script_service_commands size changed")
ASSERT(SIZEOF(.cpu_after_script_service_commands) == 0xc, "cpu_after_script_service_commands size changed")
ASSERT(SIZEOF(.script_service_platform) == 0xd0, "script_service_platform size changed")
ASSERT(SIZEOF(.script_animation_resolve) == 0xf8, "script_animation_resolve size changed")
ASSERT(SIZEOF(.actor_resource_load) == 0x2f8, "actor_resource_load size changed")
ASSERT(SIZEOF(.actor_resource_reset) == 0x190, "actor_resource_reset size changed")
ASSERT(SIZEOF(.cpu_after_actor_resource_reset) == 0xa64, "cpu_after_actor_resource_reset size changed")
ASSERT(SIZEOF(.actor_setup_noop) == 0x8, "actor_setup_noop size changed")
ASSERT(SIZEOF(.cpu_after_actor_setup_noop) == 0x4, "cpu_after_actor_setup_noop size changed")
ASSERT(SIZEOF(.actor_setup_strings) == 0x110, "actor_setup_strings size changed")
ASSERT(SIZEOF(.actor_setup_animation_reset) == 0x24, "actor_setup_animation_reset size changed")
ASSERT(SIZEOF(.cpu_after_actor_setup_animation_reset) == 0xb54, "cpu_after_actor_setup_animation_reset size changed")
ASSERT(SIZEOF(.actor_setup_text_begin) == 0x44, "actor_setup_text_begin size changed")
ASSERT(SIZEOF(.cpu_after_actor_setup_text_begin) == 0x6ac, "cpu_after_actor_setup_text_begin size changed")
ASSERT(SIZEOF(.actor_setup_text_reset) == 0x60, "actor_setup_text_reset size changed")
ASSERT(SIZEOF(.cpu_after_actor_setup_text_reset) == 0x8, "cpu_after_actor_setup_text_reset size changed")
ASSERT(SIZEOF(.scene_actor_create) == 0x74, "scene_actor_create size changed")
ASSERT(SIZEOF(.scene_file_idle) == 0x8, "scene_file_idle size changed")
ASSERT(SIZEOF(.cpu_after_scene_file_idle) == 0x4, "cpu_after_scene_file_idle size changed")
ASSERT(SIZEOF(.scene_file_stubs) == 0x18, "scene_file_stubs size changed")
ASSERT(SIZEOF(.scene_file_select) == 0x78, "scene_file_select size changed")
ASSERT(SIZEOF(.scene_resource_limits) == 0x74, "scene_resource_limits size changed")
ASSERT(SIZEOF(.scene_display_flags) == 0x38, "scene_display_flags size changed")
ASSERT(SIZEOF(.scene_position) == 0x6c, "scene_position size changed")
ASSERT(SIZEOF(.scene_value_d0c) == 0x10, "scene_value_d0c size changed")
ASSERT(SIZEOF(.scene_values_cd0) == 0x1c, "scene_values_cd0 size changed")
ASSERT(SIZEOF(.scene_values_cdc) == 0x24, "scene_values_cdc size changed")
ASSERT(SIZEOF(.scene_values_cf0) == 0x24, "scene_values_cf0 size changed")
ASSERT(SIZEOF(.scene_effect_add) == 0x80, "scene_effect_add size changed")
ASSERT(SIZEOF(.scene_value_cec) == 0x10, "scene_value_cec size changed")
ASSERT(SIZEOF(.scene_unused_commands) == 0x20, "scene_unused_commands size changed")
ASSERT(SIZEOF(.scene_resource_command) == 0x28, "scene_resource_command size changed")
ASSERT(SIZEOF(.scene_enemy_arrival) == 0xf8, "scene_enemy_arrival size changed")
ASSERT(SIZEOF(.scene_category_arrivals) == 0x138, "scene_category_arrivals size changed")
ASSERT(SIZEOF(.scene_unused_arrivals) == 0x18, "scene_unused_arrivals size changed")
ASSERT(SIZEOF(.scene_positioned_arrival) == 0x6c, "scene_positioned_arrival size changed")
ASSERT(SIZEOF(.scene_mark_dirty) == 0x14, "scene_mark_dirty size changed")
ASSERT(SIZEOF(.scene_effect_apply) == 0x6c, "scene_effect_apply size changed")
ASSERT(SIZEOF(.scene_audio_request) == 0x24, "scene_audio_request size changed")
ASSERT(SIZEOF(.scene_background) == 0x3d8, "scene_background size changed")
ASSERT(SIZEOF(.save_level_lookup) == 0x18, "save_level_lookup size changed")
ASSERT(SIZEOF(.save_menu_conditional_copy) == 0x28, "save_menu_conditional_copy size changed")
ASSERT(SIZEOF(.cpu_after_save_menu_conditional_copy) == 0x414, "cpu_after_save_menu_conditional_copy size changed")
ASSERT(SIZEOF(.save_menu_flag_setter) == 0xc, "save_menu_flag_setter size changed")
ASSERT(SIZEOF(.save_menu_text_flags) == 0x170, "save_menu_text_flags size changed")
ASSERT(SIZEOF(.save_menu_state_reset) == 0x2c, "save_menu_state_reset size changed")
ASSERT(SIZEOF(.cpu_after_save_menu_state_reset) == 0x2964, "cpu_after_save_menu_state_reset size changed")
ASSERT(SIZEOF(.save_menu_legacy_reset) == 0x30, "save_menu_legacy_reset size changed")
ASSERT(SIZEOF(.cpu_after_save_menu_legacy_reset) == 0x8, "cpu_after_save_menu_legacy_reset size changed")
ASSERT(SIZEOF(.save_menu_legacy_heap) == 0x48, "save_menu_legacy_heap size changed")
ASSERT(SIZEOF(.cpu_after_save_menu_legacy_heap) == 0x8, "cpu_after_save_menu_legacy_heap size changed")
ASSERT(SIZEOF(.save_menu_legacy_pages) == 0x18c, "save_menu_legacy_pages size changed")
ASSERT(SIZEOF(.save_menu_legacy_pak_status) == 0x2a8, "save_menu_legacy_pak_status size changed")
ASSERT(SIZEOF(.save_menu_legacy_exit) == 0x78, "save_menu_legacy_exit size changed")
ASSERT(SIZEOF(.save_menu_legacy_pages_tail) == 0x84, "save_menu_legacy_pages_tail size changed")
ASSERT(SIZEOF(.save_menu_nav_refresh) == 0x90, "save_menu_nav_refresh size changed")
ASSERT(SIZEOF(.save_menu_nav_open_primary) == 0x2c, "save_menu_nav_open_primary size changed")
ASSERT(SIZEOF(.save_menu_nav_open_secondary) == 0x2c, "save_menu_nav_open_secondary size changed")
ASSERT(SIZEOF(.save_menu_nav_open_return) == 0x2c, "save_menu_nav_open_return size changed")
ASSERT(SIZEOF(.save_menu_nav_noop) == 0x8, "save_menu_nav_noop size changed")
ASSERT(SIZEOF(.save_menu_nav_reset) == 0x2c, "save_menu_nav_reset size changed")
ASSERT(SIZEOF(.save_menu_nav_actor_disable) == 0x14, "save_menu_nav_actor_disable size changed")
ASSERT(SIZEOF(.save_menu_nav_actor_forward) == 0xcc, "save_menu_nav_actor_forward size changed")
ASSERT(SIZEOF(.save_menu_nav_actor_back) == 0x88, "save_menu_nav_actor_back size changed")
ASSERT(SIZEOF(.save_menu_nav_preview_create) == 0x154, "save_menu_nav_preview_create size changed")
ASSERT(SIZEOF(.save_menu_nav_preview_release) == 0x28, "save_menu_nav_preview_release size changed")
ASSERT(SIZEOF(.save_menu_nav_cleanup) == 0x10c, "save_menu_nav_cleanup size changed")
ASSERT(SIZEOF(.cpu_after_save_menu_nav_cleanup) == 0x440, "cpu_after_save_menu_nav_cleanup size changed")
ASSERT(SIZEOF(.save_menu_pak_retry) == 0x68, "save_menu_pak_retry size changed")
ASSERT(SIZEOF(.save_menu_pak_reset) == 0x54, "save_menu_pak_reset size changed")
ASSERT(SIZEOF(.save_menu_pak_refresh) == 0x48, "save_menu_pak_refresh size changed")
ASSERT(SIZEOF(.save_menu_pak_result) == 0x70, "save_menu_pak_result size changed")
ASSERT(SIZEOF(.actor_animation) == 0xe4, "actor_animation size changed")
ASSERT(SIZEOF(.actor_motion_mode) == 0x148, "actor_motion_mode size changed")
ASSERT(SIZEOF(.actor_motion_facing) == 0xa8, "actor_motion_facing size changed")
ASSERT(SIZEOF(.actor_pool_reset) == 0x38, "actor_pool_reset size changed")
ASSERT(SIZEOF(.actor_cleanup) == 0xb0, "actor_cleanup size changed")
ASSERT(SIZEOF(.actor_remove) == 0xf8, "actor_remove size changed")
ASSERT(SIZEOF(.actor_sweep) == 0x68, "actor_sweep size changed")
ASSERT(SIZEOF(.actor_behavior_frame_sync) == 0x40, "actor_behavior_frame_sync size changed")
ASSERT(SIZEOF(.actor_behavior_motion_begin) == 0xac, "actor_behavior_motion_begin size changed")
ASSERT(SIZEOF(.actor_behavior_motion_guarded) == 0xc0, "actor_behavior_motion_guarded size changed")
ASSERT(SIZEOF(.actor_behavior_motion_scaled) == 0xe0, "actor_behavior_motion_scaled size changed")
ASSERT(SIZEOF(.actor_behavior_animation_2945c) == 0x48, "actor_behavior_animation_2945c size changed")
ASSERT(SIZEOF(.actor_behavior_callback_29544) == 0x88, "actor_behavior_callback_29544 size changed")
ASSERT(SIZEOF(.actor_behavior_spawn) == 0x60, "actor_behavior_spawn size changed")
ASSERT(SIZEOF(.actor_behavior_spawn_restore) == 0x78, "actor_behavior_spawn_restore size changed")
ASSERT(SIZEOF(.actor_behavior_release_29d6c) == 0x2c, "actor_behavior_release_29d6c size changed")
ASSERT(SIZEOF(.actor_behavior_next_a244) == 0x1a4, "actor_behavior_next_a244 size changed")
ASSERT(SIZEOF(.actor_behavior_state) == 0x2c, "actor_behavior_state size changed")
ASSERT(SIZEOF(.actor_behavior_blend_velocity) == 0x1c8, "actor_behavior_blend_velocity size changed")
ASSERT(SIZEOF(.actor_behavior_blend_motion) == 0x22c, "actor_behavior_blend_motion size changed")
ASSERT(SIZEOF(.actor_behavior_height) == 0x10, "actor_behavior_height size changed")
ASSERT(SIZEOF(.actor_behavior_extra_b32c) == 0x244, "actor_behavior_extra_b32c size changed")
ASSERT(SIZEOF(.actor_behavior_noop_b570) == 0xc, "actor_behavior_noop_b570 size changed")
ASSERT(SIZEOF(.actor_behavior_extra_b57c) == 0x228, "actor_behavior_extra_b57c size changed")
ASSERT(SIZEOF(.actor_behavior_noop_b7a4) == 0xc, "actor_behavior_noop_b7a4 size changed")
ASSERT(SIZEOF(.actor_behavior_noop_b7b0) == 0xc, "actor_behavior_noop_b7b0 size changed")
ASSERT(SIZEOF(.actor_behavior_repeat) == 0x124, "actor_behavior_repeat size changed")
ASSERT(SIZEOF(.actor_behavior_extra_d918) == 0x308, "actor_behavior_extra_d918 size changed")
ASSERT(SIZEOF(.actor_behavior_countdown) == 0x98, "actor_behavior_countdown size changed")
ASSERT(SIZEOF(.actor_behavior_countdown_begin) == 0x88, "actor_behavior_countdown_begin size changed")
ASSERT(SIZEOF(.actor_behavior_countdown_trigger) == 0x7c, "actor_behavior_countdown_trigger size changed")
ASSERT(SIZEOF(.cpu_after_actor_behavior_countdown_trigger) == 0x8a0, "cpu_after_actor_behavior_countdown_trigger size changed")
ASSERT(SIZEOF(.session_setup_noop) == 0x8, "session_setup_noop size changed")
ASSERT(SIZEOF(.cpu_after_session_setup_noop) == 0x660, "cpu_after_session_setup_noop size changed")
ASSERT(SIZEOF(.session_setup_globals) == 0x28, "session_setup_globals size changed")
ASSERT(SIZEOF(.session_setup_value04) == 0x14, "session_setup_value04 size changed")
ASSERT(SIZEOF(.session_setup_value14) == 0x3c, "session_setup_value14 size changed")
ASSERT(SIZEOF(.session_setup_value12) == 0x14, "session_setup_value12 size changed")
ASSERT(SIZEOF(.session_setup_flag13) == 0x28, "session_setup_flag13 size changed")
ASSERT(SIZEOF(.session_setup_values08_10) == 0x24, "session_setup_values08_10 size changed")
ASSERT(SIZEOF(.session_setup_value1a) == 0x14, "session_setup_value1a size changed")
ASSERT(SIZEOF(.session_setup_playback_speed) == 0x74, "session_setup_playback_speed size changed")
ASSERT(SIZEOF(.session_setup_value16) == 0x14, "session_setup_value16 size changed")
ASSERT(SIZEOF(.session_setup_validate) == 0x18c, "session_setup_validate size changed")
ASSERT(SIZEOF(.session_setup_script_stop) == 0x14, "session_setup_script_stop size changed")
ASSERT(SIZEOF(.session_setup_animation_create) == 0xb0, "session_setup_animation_create size changed")
ASSERT(SIZEOF(.session_setup_global_value) == 0x10, "session_setup_global_value size changed")
ASSERT(SIZEOF(.session_setup_animation_state) == 0x68, "session_setup_animation_state size changed")
ASSERT(SIZEOF(.session_setup_vulnerable) == 0x28, "session_setup_vulnerable size changed")
ASSERT(SIZEOF(.session_setup_model) == 0x7c, "session_setup_model size changed")
ASSERT(SIZEOF(.session_setup_animation_file) == 0x38, "session_setup_animation_file size changed")
ASSERT(SIZEOF(.session_setup_texture_map) == 0x60, "session_setup_texture_map size changed")
ASSERT(SIZEOF(.session_setup_bitmap) == 0x60, "session_setup_bitmap size changed")
ASSERT(SIZEOF(.session_setup_kinemation) == 0x98, "session_setup_kinemation size changed")
ASSERT(SIZEOF(.session_setup_extra_kinemation) == 0xe0, "session_setup_extra_kinemation size changed")
ASSERT(SIZEOF(.session_setup_pair) == 0x3c, "session_setup_pair size changed")
ASSERT(SIZEOF(.session_setup_value58_half) == 0x14, "session_setup_value58_half size changed")
ASSERT(SIZEOF(.session_setup_value64) == 0x38, "session_setup_value64 size changed")
ASSERT(SIZEOF(.session_setup_value5a) == 0x14, "session_setup_value5a size changed")
ASSERT(SIZEOF(.session_setup_value58_word) == 0x14, "session_setup_value58_word size changed")
ASSERT(SIZEOF(.cpu_after_session_setup_value58_word) == 0xc, "cpu_after_session_setup_value58_word size changed")
ASSERT(SIZEOF(.session_menu_selection) == 0x1c, "session_menu_selection size changed")
ASSERT(SIZEOF(.session_menu_preview_update) == 0x14c, "session_menu_preview_update size changed")
ASSERT(SIZEOF(.session_menu_preview_create) == 0x164, "session_menu_preview_create size changed")
ASSERT(SIZEOF(.session_menu_preview_accept) == 0x2c, "session_menu_preview_accept size changed")
ASSERT(SIZEOF(.session_menu_preview_cancel) == 0x3c, "session_menu_preview_cancel size changed")
ASSERT(SIZEOF(.session_menu_preview_release) == 0x58, "session_menu_preview_release size changed")
ASSERT(SIZEOF(.session_setup_empty) == 0x8, "session_setup_empty size changed")
ASSERT(SIZEOF(.session_menu_exit_game) == 0x6c, "session_menu_exit_game size changed")
ASSERT(SIZEOF(.session_menu_start_single) == 0xb0, "session_menu_start_single size changed")
ASSERT(SIZEOF(.session_setup_menu_reset) == 0x24, "session_setup_menu_reset size changed")
ASSERT(SIZEOF(.session_menu_show_main) == 0x30, "session_menu_show_main size changed")
ASSERT(SIZEOF(.session_menu_start_two) == 0x9c, "session_menu_start_two size changed")
ASSERT(SIZEOF(.session_menu_start_alternate) == 0x70, "session_menu_start_alternate size changed")
ASSERT(SIZEOF(.session_menu_return) == 0x50, "session_menu_return size changed")
ASSERT(SIZEOF(.session_menu_level_exit) == 0x24, "session_menu_level_exit size changed")
ASSERT(SIZEOF(.session_menu_player_choice) == 0xb4, "session_menu_player_choice size changed")
ASSERT(SIZEOF(.session_menu_pages) == 0x94, "session_menu_pages size changed")
ASSERT(SIZEOF(.session_menu_shell_reset) == 0x84, "session_menu_shell_reset size changed")
ASSERT(SIZEOF(.session_menu_defaults) == 0xe0, "session_menu_defaults size changed")
ASSERT(SIZEOF(.save_options_capture) == 0x68, "save_options_capture size changed")
ASSERT(SIZEOF(.save_slot_capture) == 0xd8, "save_slot_capture size changed")
ASSERT(SIZEOF(.save_options_restore) == 0x88, "save_options_restore size changed")
ASSERT(SIZEOF(.save_slot_restore) == 0x8c, "save_slot_restore size changed")
ASSERT(SIZEOF(.save_slot_labels) == 0x150, "save_slot_labels size changed")
ASSERT(SIZEOF(.save_file_read) == 0x27c, "save_file_read size changed")
ASSERT(SIZEOF(.save_file_write) == 0x1d8, "save_file_write size changed")
ASSERT(SIZEOF(.save_slot_select) == 0x1a0, "save_slot_select size changed")
ASSERT(SIZEOF(.save_menu_slot_write) == 0x114, "save_menu_slot_write size changed")
ASSERT(SIZEOF(.save_menu_cancel) == 0x3c, "save_menu_cancel size changed")
ASSERT(SIZEOF(.save_menu_slot_prompt) == 0xe8, "save_menu_slot_prompt size changed")
ASSERT(SIZEOF(.save_menu_slot_callback) == 0x6c, "save_menu_slot_callback size changed")
ASSERT(SIZEOF(.save_menu_open) == 0x44, "save_menu_open size changed")
ASSERT(SIZEOF(.save_menu_status) == 0x340, "save_menu_status size changed")
ASSERT(SIZEOF(.save_menu_audio_index) == 0x74, "save_menu_audio_index size changed")
ASSERT(SIZEOF(.save_menu_sound_preview) == 0x30, "save_menu_sound_preview size changed")
ASSERT(SIZEOF(.save_menu_audio_apply) == 0x44, "save_menu_audio_apply size changed")
ASSERT(SIZEOF(.save_menu_audio_secondary) == 0x24, "save_menu_audio_secondary size changed")
ASSERT(SIZEOF(.save_menu_write_return) == 0x34, "save_menu_write_return size changed")
ASSERT(SIZEOF(.save_menu_continue_encode) == 0x170, "save_menu_continue_encode size changed")
ASSERT(SIZEOF(.save_menu_palette_index) == 0xdc, "save_menu_palette_index size changed")
ASSERT(SIZEOF(.scene_palette_load) == 0x68, "scene_palette_load size changed")
ASSERT(SIZEOF(.palette_fade_controls) == 0x148, "palette_fade_controls size changed")
ASSERT(SIZEOF(.palette_transition_reset) == 0x34, "palette_transition_reset size changed")
ASSERT(SIZEOF(.palette_transition_range) == 0x288, "palette_transition_range size changed")
ASSERT(SIZEOF(.cpu_after_palette_transition_range) == 0x4b0, "cpu_after_palette_transition_range size changed")
ASSERT(SIZEOF(.palette_commands) == 0x1b8, "palette_commands size changed")
ASSERT(SIZEOF(.cpu_after_palette_commands) == 0xc, "cpu_after_palette_commands size changed")
ASSERT(SIZEOF(.command_enable) == 0x10, "command_enable size changed")
ASSERT(SIZEOF(.game_number_convert) == 0xfc, "game_number_convert size changed")
ASSERT(SIZEOF(.command_machine) == 0x80, "command_machine size changed")
ASSERT(SIZEOF(.cpu_after_command_machine) == 0x4, "cpu_after_command_machine size changed")
ASSERT(SIZEOF(.scene_transition_open) == 0x50, "scene_transition_open size changed")
ASSERT(SIZEOF(.scene_transition_close) == 0x60, "scene_transition_close size changed")
ASSERT(SIZEOF(.scene_transition_draw) == 0x120, "scene_transition_draw size changed")
ASSERT(SIZEOF(.scene_player_setup) == 0x248, "scene_player_setup size changed")
ASSERT(SIZEOF(.scene_signed_shift) == 0x24, "scene_signed_shift size changed")
ASSERT(SIZEOF(.scene_actor_parameter_reset) == 0x24, "scene_actor_parameter_reset size changed")
ASSERT(SIZEOF(.sound_bridge_core) == 0x84, "sound_bridge_core size changed")
ASSERT(SIZEOF(.cpu_after_sound_bridge_core) == 0x8, "cpu_after_sound_bridge_core size changed")
ASSERT(SIZEOF(.sound_bridge_definitions) == 0x5c, "sound_bridge_definitions size changed")
ASSERT(SIZEOF(.sound_bridge_future_reset) == 0x8c, "sound_bridge_future_reset size changed")
ASSERT(SIZEOF(.sound_bridge_future_queue) == 0x90, "sound_bridge_future_queue size changed")
ASSERT(SIZEOF(.sound_bridge_future_update) == 0xb8, "sound_bridge_future_update size changed")
ASSERT(SIZEOF(.scene_glyph_release) == 0x58, "scene_glyph_release size changed")
ASSERT(SIZEOF(.scene_actor_scale) == 0x138, "scene_actor_scale size changed")
ASSERT(SIZEOF(.scene_actor_motion_reset) == 0x108, "scene_actor_motion_reset size changed")
ASSERT(SIZEOF(.scene_service_noop) == 0x8, "scene_service_noop size changed")
ASSERT(SIZEOF(.scene_parent_follow) == 0x178, "scene_parent_follow size changed")
ASSERT(SIZEOF(.scene_bucket_counter) == 0xb8, "scene_bucket_counter size changed")
ASSERT(SIZEOF(.cpu_after_scene_bucket_counter) == 0x20c, "cpu_after_scene_bucket_counter size changed")
ASSERT(SIZEOF(.debug_context_set) == 0x10, "debug_context_set size changed")
ASSERT(SIZEOF(.cpu_after_debug_context_set) == 0x8, "cpu_after_debug_context_set size changed")
ASSERT(SIZEOF(.debug_text_draw) == 0xa8, "debug_text_draw size changed")
ASSERT(SIZEOF(.cpu_after_debug_text_draw) == 0x8, "cpu_after_debug_text_draw size changed")
ASSERT(SIZEOF(.tweak_reset) == 0x38, "tweak_reset size changed")
ASSERT(SIZEOF(.tweak_page) == 0x80, "tweak_page size changed")
ASSERT(SIZEOF(.tweak_define) == 0xa4, "tweak_define size changed")
ASSERT(SIZEOF(.tweak_difficulty_apply) == 0xe4, "tweak_difficulty_apply size changed")
ASSERT(SIZEOF(.tweak_scene_apply) == 0xe8, "tweak_scene_apply size changed")
ASSERT(SIZEOF(.tweak_bind) == 0x84, "tweak_bind size changed")
ASSERT(SIZEOF(.tweak_bind_all) == 0x808, "tweak_bind_all size changed")
ASSERT(SIZEOF(.tweak_scale_enemy_speeds) == 0x168, "tweak_scale_enemy_speeds size changed")
ASSERT(SIZEOF(.resource_string_reset) == 0x34, "resource_string_reset size changed")
ASSERT(SIZEOF(.string_resource) == 0x34, "string_resource size changed")
ASSERT(SIZEOF(.resource_string_find) == 0xa0, "resource_string_find size changed")
ASSERT(SIZEOF(.resource_string_load) == 0xd4, "resource_string_load size changed")
ASSERT(SIZEOF(.cpu_after_resource_string_load) == 0x4, "cpu_after_resource_string_load size changed")
ASSERT(SIZEOF(.scene_timer_capture) == 0x28, "scene_timer_capture size changed")
ASSERT(SIZEOF(.scene_timer_initialize) == 0x48, "scene_timer_initialize size changed")
ASSERT(SIZEOF(.scene_timer_service) == 0x20, "scene_timer_service size changed")
ASSERT(SIZEOF(.cpu_after_scene_timer_service) == 0x96c, "cpu_after_scene_timer_service size changed")
ASSERT(SIZEOF(.object_service) == 0x20, "object_service size changed")
ASSERT(SIZEOF(.cpu_after_object_service) == 0x4, "cpu_after_object_service size changed")
ASSERT(SIZEOF(.object_registration) == 0x5c, "object_registration size changed")
ASSERT(SIZEOF(.object_creation) == 0x1c0, "object_creation size changed")
ASSERT(SIZEOF(.object_model_access) == 0xe4, "object_model_access size changed")
ASSERT(SIZEOF(.rsp_boot) == 0xd0, "RSP boot size changed")
ASSERT(SIZEOF(.scene_background_constants) == 0x8, "scene_background_constants size changed")
ASSERT(SIZEOF(.actor_behavior_next_a244_rodata) == 0x34, "actor_behavior_next_a244_rodata size changed")
ASSERT(SIZEOF(.save_menu_status_tables) == 0x30, "save_menu_status_tables size changed")
ASSERT(SIZEOF(.command_machine_table) == 0x20, "command_machine_table size changed")
ASSERT(SIZEOF(.sound_bridge_future_queue_strings) == 0x20, "sound_bridge_future_queue_strings size changed")
ASSERT(SIZEOF(.renderer_vertex_attributes_strings) == 0xf0, "renderer_vertex_attributes_strings size changed")
ASSERT(SIZEOF(.renderer_vertex_positions_strings) == 0x50, "renderer_vertex_positions_strings size changed")
ASSERT(SIZEOF(.renderer_mesh_positions_strings) == 0x28, "renderer_mesh_positions_strings size changed")
ASSERT(SIZEOF(.graphics_resource_strings) == 0x14, "graphics_resource_strings size changed")
ASSERT(SIZEOF(.data_after_graphics_resource_strings) == 0x44, "data_after_graphics_resource_strings size changed")
ASSERT(SIZEOF(.graphics_pool_strings) == 0xe0, "graphics_pool_strings size changed")
ASSERT(SIZEOF(.graphics_mode_dispatch_table) == 0x60, "graphics_mode_dispatch_table size changed")
ASSERT(SIZEOF(.frame_projection_rodata) == 0xc, "frame projection rodata size changed")
ASSERT(SIZEOF(.audio_pitch_scale_rodata) == 0x8, "audio_pitch_scale_rodata size changed")
ASSERT(SIZEOF(.after_audio_pitch_scale_rodata) == 0x24, "after_audio_pitch_scale_rodata size changed")
ASSERT(SIZEOF(.camera_perspective_rodata) == 0x10, "camera_perspective_rodata size changed")
ASSERT(SIZEOF(.camera_highlights_rodata) == 0x20, "camera_highlights_rodata size changed")
ASSERT(SIZEOF(.matrix_rotation_rodata) == 0x10, "matrix_rotation_rodata size changed")
ASSERT(SIZEOF(.sine_float_rodata) == 0x44, "sine float constants size changed")
ASSERT(SIZEOF(.after_sine_float_rodata) == 0xc, "sine float alignment size changed")
ASSERT(SIZEOF(.cosine_float_rodata) == 0x44, "cosine float constants size changed")
ASSERT(SIZEOF(.after_cosine_float_rodata) == 0xc, "cosine float alignment size changed")
ASSERT(SIZEOF(.audio_synthesizer_rodata) == 0x10, "audio_synthesizer_rodata size changed")
ASSERT(SIZEOF(.audio_effect_create_rodata) == 0x20, "audio_effect_create_rodata size changed")
ASSERT(SIZEOF(.audio_resample_rodata) == 0x34, "audio_resample_rodata size changed")
ASSERT(SIZEOF(.data_after_sdk_audio_resample_constants) == 0xc, "data_after_sdk_audio_resample_constants size changed")
ASSERT(SIZEOF(.audio_envelope_rodata) == 0x60, "audio_envelope_rodata size changed")
ASSERT(SIZEOF(.audio_effect_parameters_rodata) == 0x28, "audio_effect_parameters_rodata size changed")
ASSERT(SIZEOF(.data_after_sdk_audio_effect_constants) == 0x769438, "data_after_sdk_audio_effect_constants size changed")
ASSERT(SIZEOF(.unexpected) == 0, "unmapped input data")

ASSERT(SIZEOF(.text_table) == 0x128, "text jump tables size changed")
ASSERT(SIZEOF(.movie_commands_data) == 0x68, "movie_commands_data size changed")
ASSERT(SIZEOF(.compression_workspace_data) == 0x170, "compression_workspace_data size changed")
ASSERT(SIZEOF(.gu_random_data) == 0x4, "gu_random_data size changed")
ASSERT(SIZEOF(.data_after_sdk_random_data) == 0xc, "data_after_sdk_random_data size changed")
ASSERT(SIZEOF(.controller_init_data) == 0x4, "controller_init_data size changed")
ASSERT(SIZEOF(.data_after_sdk_controller_init_data) == 0xc, "data_after_sdk_controller_init_data size changed")
ASSERT(SIZEOF(.data_after_sdk_vi_manager_data) == 0x4, "data_after_sdk_vi_manager_data size changed")
ASSERT(SIZEOF(.audio_synth_lifecycle_data) == 0x4, "audio_synth_lifecycle_data size changed")
ASSERT(SIZEOF(.data_after_sdk_audio_globals_data) == 0xc, "data_after_sdk_audio_globals_data size changed")
ASSERT(SIZEOF(.audio_buffer_submit_data) == 0x1, "audio_buffer_submit_data size changed")
ASSERT(SIZEOF(.audio_effect_create_data) == 0x190, "audio_effect_create_data size changed")
ASSERT(SIZEOF(.audio_envelope_data) == 0x140, "audio_envelope_data size changed")

ASSERT(SIZEOF(.text_replacement) == 0x264, "replacement fallback size changed")
ASSERT(SIZEOF(.text_wrapper) == 0xc4, "text wrapper size changed")

ASSERT(SIZEOF(.text_edit) == 0x160, "text edit functions size changed")

ASSERT(SIZEOF(.text_properties) == 0x308, "text property functions size changed")

ASSERT(SIZEOF(.text_conversion) == 0xa4, "text conversion function size changed")

ASSERT(SIZEOF(.object_transforms) == 0x7b8, "object transforms size changed")
ASSERT(SIZEOF(.object_helpers) == 0x58, "object_helpers size changed")
ASSERT(SIZEOF(.object_helpers_index_limit) == 0x7c, "object_helpers_index_limit size changed")
ASSERT(SIZEOF(.object_helpers_index_set) == 0x60, "object_helpers_index_set size changed")
ASSERT(SIZEOF(.object_helpers_properties) == 0xf4, "object_helpers_properties size changed")
ASSERT(SIZEOF(.object_helpers_camera_state) == 0x70, "object_helpers_camera_state size changed")
ASSERT(SIZEOF(.object_helpers_camera_position) == 0xbc, "object_helpers_camera_position size changed")
ASSERT(SIZEOF(.object_helpers_camera_position_alt) == 0xb8, "object_helpers_camera_position_alt size changed")
ASSERT(SIZEOF(.object_helpers_camera_accessors) == 0x130, "object_helpers_camera_accessors size changed")
ASSERT(SIZEOF(.object_helpers_pool_alloc) == 0x100, "object_helpers_pool_alloc size changed")
ASSERT(SIZEOF(.object_helpers_pool_status) == 0x68, "object_helpers_pool_status size changed")
ASSERT(SIZEOF(.object_reset) == 0x8c, "object_reset size changed")
ASSERT(SIZEOF(.object_helpers_draw_noop) == 0x8, "object_helpers_draw_noop size changed")
ASSERT(SIZEOF(.object_helpers_draw) == 0x284, "object_helpers_draw size changed")
ASSERT(SIZEOF(.object_helpers_draw_mode) == 0x138, "object_helpers_draw_mode size changed")
ASSERT(SIZEOF(.cpu_after_object_helpers_draw_mode) == 0x9a4, "cpu_after_object_helpers_draw_mode size changed")
ASSERT(SIZEOF(.object_runtime_service) == 0x5c, "object_runtime_service size changed")
ASSERT(SIZEOF(.cpu_after_object_runtime_service) == 0x178, "cpu_after_object_runtime_service size changed")
ASSERT(SIZEOF(.object_runtime_active) == 0x98, "object_runtime_active size changed")
ASSERT(SIZEOF(.game_memory) == 0x274, "game_memory size changed")
ASSERT(SIZEOF(.game_string_append) == 0x34, "game_string_append size changed")
ASSERT(SIZEOF(.game_string_case_compare) == 0x94, "game_string_case_compare size changed")
ASSERT(SIZEOF(.game_string_compare) == 0x3c, "game_string_compare size changed")
ASSERT(SIZEOF(.game_string_case_compare_n) == 0xa8, "game_string_case_compare_n size changed")
ASSERT(SIZEOF(.game_string_compare_n) == 0x48, "game_string_compare_n size changed")
ASSERT(SIZEOF(.game_number_format) == 0x284, "game_number_format size changed")
ASSERT(SIZEOF(.game_character) == 0x1a0, "game_character size changed")
ASSERT(SIZEOF(.game_integer_parse) == 0x9c, "game_integer_parse size changed")
ASSERT(SIZEOF(.platform_empty) == 0x90, "platform_empty size changed")
ASSERT(SIZEOF(.palette) == 0x194, "palette size changed")
ASSERT(SIZEOF(.controller_button) == 0x28, "controller_button size changed")
ASSERT(SIZEOF(.controller_axes) == 0xfc, "controller_axes size changed")
ASSERT(SIZEOF(.platform_io) == 0xf4, "platform_io size changed")
ASSERT(SIZEOF(.resource_bridge_model_cache) == 0xd8, "resource_bridge_model_cache size changed")
ASSERT(SIZEOF(.resource_bridge_texture_stub) == 0x10, "resource_bridge_texture_stub size changed")
ASSERT(SIZEOF(.resource_bridge_bitmap) == 0xdc, "resource_bridge_bitmap size changed")
ASSERT(SIZEOF(.resource_bridge_animation) == 0xdc, "resource_bridge_animation size changed")
ASSERT(SIZEOF(.object_recovery_path_extension) == 0x44, "object_recovery_path_extension size changed")
ASSERT(SIZEOF(.geometry_debug_bridge) == 0x28, "geometry_debug_bridge size changed")
ASSERT(SIZEOF(.object_recovery_fixed_trig) == 0x90, "object_recovery_fixed_trig size changed")
ASSERT(SIZEOF(.object_recovery_integer_sqrt) == 0x64, "object_recovery_integer_sqrt size changed")
ASSERT(SIZEOF(.object_recovery_angle_scale) == 0x24, "object_recovery_angle_scale size changed")
ASSERT(SIZEOF(.object_recovery_direction_angle) == 0x184, "object_recovery_direction_angle size changed")
ASSERT(SIZEOF(.object_recovery_angle_table) == 0x94, "object_recovery_angle_table size changed")
ASSERT(SIZEOF(.game_debug_format) == 0x1dc, "game_debug_format size changed")
ASSERT(SIZEOF(.cpu_after_game_debug_format) == 0xc, "cpu_after_game_debug_format size changed")
ASSERT(SIZEOF(.geometry_bridge_apply) == 0x9c, "geometry_bridge_apply size changed")
ASSERT(SIZEOF(.geometry_bridge_rotate) == 0xb4, "geometry_bridge_rotate size changed")
ASSERT(SIZEOF(.model_rotation) == 0x17c, "model_rotation size changed")
ASSERT(SIZEOF(.cpu_after_model_rotation) == 0x1740, "cpu_after_model_rotation size changed")
ASSERT(SIZEOF(.model_polygons_plain) == 0x11c, "model_polygons_plain size changed")
ASSERT(SIZEOF(.model_polygons_color) == 0x188, "model_polygons_color size changed")
ASSERT(SIZEOF(.model_hierarchy_vertices) == 0x1ac, "model_hierarchy_vertices size changed")
ASSERT(SIZEOF(.model_camera_identity) == 0x24, "model_camera_identity size changed")
ASSERT(SIZEOF(.model_camera_rotation) == 0x1a4, "model_camera_rotation size changed")
ASSERT(SIZEOF(.model_mesh_iteration) == 0x24, "model_mesh_iteration size changed")
ASSERT(SIZEOF(.model_normals_blend) == 0x200, "model_normals_blend size changed")
ASSERT(SIZEOF(.model_vertices_scatter) == 0xb8, "model_vertices_scatter size changed")
ASSERT(SIZEOF(.cpu_after_model_vertices_scatter) == 0x430, "cpu_after_model_vertices_scatter size changed")
ASSERT(SIZEOF(.model_framebuffer_copy) == 0x6c, "model_framebuffer_copy size changed")
ASSERT(SIZEOF(.model_framebuffer_draw) == 0x1c4, "model_framebuffer_draw size changed")
ASSERT(SIZEOF(.cpu_after_model_framebuffer_draw) == 0x150, "cpu_after_model_framebuffer_draw size changed")
ASSERT(SIZEOF(.model_framebuffer_texture) == 0xf4, "model_framebuffer_texture size changed")
ASSERT(SIZEOF(.renderer_vertex_attributes) == 0x438, "renderer_vertex_attributes size changed")
ASSERT(SIZEOF(.renderer_material_texture) == 0x118, "renderer_material_texture size changed")
ASSERT(SIZEOF(.renderer_material_light) == 0x6c, "renderer_material_light size changed")
ASSERT(SIZEOF(.renderer_material_combined) == 0x290, "renderer_material_combined size changed")
ASSERT(SIZEOF(.renderer_light_select) == 0x54, "renderer_light_select size changed")
ASSERT(SIZEOF(.renderer_material_untextured) == 0xa0, "renderer_material_untextured size changed")
ASSERT(SIZEOF(.renderer_vertex_positions) == 0x288, "renderer_vertex_positions size changed")
ASSERT(SIZEOF(.renderer_material_reset) == 0x20, "renderer_material_reset size changed")
ASSERT(SIZEOF(.renderer_mesh_positions) == 0xd4, "renderer_mesh_positions size changed")
ASSERT(SIZEOF(.cpu_after_renderer_mesh_positions) == 0x538, "cpu_after_renderer_mesh_positions size changed")
ASSERT(SIZEOF(.renderer_vertex_copy) == 0x39c, "renderer_vertex_copy size changed")
ASSERT(SIZEOF(.renderer_texture_load) == 0x218, "renderer_texture_load size changed")
ASSERT(SIZEOF(.graphics_display_list) == 0x48, "graphics_display_list size changed")
ASSERT(SIZEOF(.graphics_resource) == 0x70, "graphics_resource size changed")
ASSERT(SIZEOF(.cpu_after_graphics_resource) == 0x4, "cpu_after_graphics_resource size changed")
ASSERT(SIZEOF(.palette_tint) == 0x58, "palette_tint size changed")
ASSERT(SIZEOF(.graphics_modes) == 0x624, "graphics_modes size changed")
ASSERT(SIZEOF(.graphics_lights) == 0x258, "graphics_lights size changed")
ASSERT(SIZEOF(.graphics_pool) == 0x1a4, "graphics_pool size changed")
ASSERT(SIZEOF(.graphics_pool_initialize) == 0x88, "graphics_pool_initialize size changed")
ASSERT(SIZEOF(.graphics_frame_reset) == 0x120, "graphics_frame_reset size changed")
ASSERT(SIZEOF(.graphics_mode_dispatch) == 0x21c, "graphics_mode_dispatch size changed")
ASSERT(SIZEOF(.graphics_environment) == 0xb0, "graphics_environment size changed")
ASSERT(SIZEOF(.startup) == 0x3a0, "startup functions size changed")
ASSERT(SIZEOF(.cpu_after_startup) == 0x4e4, "CPU fallback after startup size changed")
ASSERT(SIZEOF(.frame_render) == 0x198, "frame submission size changed")
ASSERT(SIZEOF(.frame_helpers) == 0x234, "frame helpers size changed")
ASSERT(SIZEOF(.debug_noop) == 0x1c, "debug_noop size changed")
ASSERT(SIZEOF(.frame_projection) == 0x120, "frame projection size changed")
ASSERT(SIZEOF(.frame_matrices) == 0xa8, "frame matrix commands size changed")
ASSERT(SIZEOF(.frame_timing) == 0x124, "frame timing size changed")
ASSERT(SIZEOF(.cpu_after_frame_timing) == 0x200, "CPU fallback after frame timing size changed")
ASSERT(SIZEOF(.graphics_ucode) == 0xc, "graphics microcode selector size changed")
ASSERT(SIZEOF(.cpu_before_renderer_platform) == 0x4, "cpu_before_renderer_platform size changed")
ASSERT(SIZEOF(.renderer_glyph_map) == 0x1e8, "renderer_glyph_map size changed")
ASSERT(SIZEOF(.renderer_platform) == 0x2d8, "renderer platform size changed")
ASSERT(SIZEOF(.graphics_state_helpers) == 0x8c, "graphics_state_helpers size changed")
ASSERT(SIZEOF(.controller_legacy_initialize) == 0x44, "controller_legacy_initialize size changed")
ASSERT(SIZEOF(.controller_legacy_scan) == 0xf4, "controller_legacy_scan size changed")
ASSERT(SIZEOF(.controller_legacy_present) == 0x18, "controller_legacy_present size changed")
ASSERT(SIZEOF(.cpu_after_controller_legacy_present) == 0x198, "cpu_after_controller_legacy_present size changed")
ASSERT(SIZEOF(.pak_file_status) == 0x34, "pak_file_status size changed")
ASSERT(SIZEOF(.pak_file_open) == 0x1b8, "pak_file_open size changed")
ASSERT(SIZEOF(.pak_file_read) == 0x78, "pak_file_read size changed")
ASSERT(SIZEOF(.pak_file_write) == 0x6c, "pak_file_write size changed")
ASSERT(SIZEOF(.pak_file_close) == 0x14, "pak_file_close size changed")
ASSERT(SIZEOF(.pak_file_encode_name) == 0x80, "pak_file_encode_name size changed")
ASSERT(SIZEOF(.runtime_random) == 0x20, "runtime_random size changed")
ASSERT(SIZEOF(.runtime_angle) == 0x68, "runtime_angle size changed")
ASSERT(SIZEOF(.runtime_float_truncate) == 0x40, "runtime_float_truncate size changed")
ASSERT(SIZEOF(.fixed_geometry_setup) == 0x5e4, "fixed_geometry_setup size changed")
ASSERT(SIZEOF(.frame_transform) == 0xe8, "frame transform size changed")
ASSERT(SIZEOF(.fixed_geometry) == 0x598, "fixed-point geometry size changed")
ASSERT(SIZEOF(.fixed_math) == 0x134, "fixed-point math size changed")
ASSERT(SIZEOF(.cpu_after_fixed_math) == 0x8, "cpu_after_fixed_math size changed")
ASSERT(SIZEOF(.heap) == 0x21c, "heap size changed")
ASSERT(SIZEOF(.cpu_after_heap) == 0x4c, "cpu_after_heap size changed")
ASSERT(SIZEOF(.heap_empty) == 0x8, "heap_empty size changed")
ASSERT(SIZEOF(.object_history) == 0x58, "object_history size changed")
ASSERT(SIZEOF(.actor_history_byte_clear) == 0x14, "actor_history_byte_clear size changed")
ASSERT(SIZEOF(.cpu_after_actor_history_byte_clear) == 0xc, "cpu_after_actor_history_byte_clear size changed")
ASSERT(SIZEOF(.rom_directory) == 0x194, "rom_directory size changed")
ASSERT(SIZEOF(.rom_file_error) == 0x64, "rom_file_error size changed")
ASSERT(SIZEOF(.rom_files) == 0x230, "rom_files size changed")
ASSERT(SIZEOF(.cpu_after_rom_files) == 0x8, "cpu_after_rom_files size changed")
ASSERT(SIZEOF(.controller_access) == 0x1c8, "controller_access size changed")
ASSERT(SIZEOF(.controller_motor_commands) == 0x74, "controller_motor_commands size changed")
ASSERT(SIZEOF(.controller_scan) == 0x144, "controller_scan size changed")
ASSERT(SIZEOF(.controller_pak_info) == 0x84, "controller_pak_info size changed")
ASSERT(SIZEOF(.controller_pak_delete) == 0xac, "controller_pak_delete size changed")
ASSERT(SIZEOF(.controller_pak_name) == 0x88, "controller_pak_name size changed")
ASSERT(SIZEOF(.controller_pak_entry) == 0x150, "controller_pak_entry size changed")
ASSERT(SIZEOF(.controller_pak_directory) == 0x16c, "controller_pak_directory size changed")
ASSERT(SIZEOF(.cpu_after_controller_pak_directory) == 0xc, "cpu_after_controller_pak_directory size changed")
ASSERT(SIZEOF(.graphics_setup) == 0x274, "graphics setup size changed")
ASSERT(SIZEOF(.graphics_tasks) == 0x3bc, "graphics tasks size changed")
ASSERT(SIZEOF(.scheduler) == 0xb70, "scheduler functions size changed")
ASSERT(SIZEOF(.scheduler_runtime_tail) == 0xec, "scheduler runtime tail size changed")
ASSERT(SIZEOF(.audio_startup) == 0x2e4, "audio_startup size changed")
ASSERT(SIZEOF(.audio_thread) == 0x230, "audio_thread size changed")
ASSERT(SIZEOF(.audio_generation) == 0x2a4, "audio_generation size changed")
ASSERT(SIZEOF(.audio_game_helpers) == 0x8c, "audio_game_helpers size changed")
ASSERT(SIZEOF(.audio_io) == 0x12c, "audio_io size changed")
ASSERT(SIZEOF(.cpu_after_audio_io) == 0x710, "cpu_after_audio_io size changed")
ASSERT(SIZEOF(.audio_task_select) == 0xac, "audio_task_select size changed")
ASSERT(SIZEOF(.audio_task_build) == 0x1b0, "audio_task_build size changed")
ASSERT(SIZEOF(.audio_pool_callback) == 0x34, "audio_pool_callback size changed")
ASSERT(SIZEOF(.audio_shutdown) == 0x2c, "audio_shutdown size changed")
ASSERT(SIZEOF(.cpu_after_audio_shutdown) == 0x4, "cpu_after_audio_shutdown size changed")
ASSERT(SIZEOF(.audio_callback_registration) == 0x54, "audio_callback_registration size changed")
ASSERT(SIZEOF(.audio_callback_return) == 0x20, "audio_callback_return size changed")
ASSERT(SIZEOF(.cpu_after_audio_callback_return) == 0xc, "cpu_after_audio_callback_return size changed")
ASSERT(SIZEOF(.audio_config) == 0x280, "audio_config size changed")
ASSERT(SIZEOF(.audio_control) == 0x370, "audio control size changed")
ASSERT(SIZEOF(.audio_play) == 0x70, "audio_play size changed")
ASSERT(SIZEOF(.audio_instance_state_query) == 0xec, "audio_instance_state_query size changed")
ASSERT(SIZEOF(.audio_instance_stop) == 0x110, "audio_instance_stop size changed")
ASSERT(SIZEOF(.audio_stop_commands) == 0xbc, "audio_stop_commands size changed")
ASSERT(SIZEOF(.audio_voice_stop) == 0x200, "audio_voice_stop size changed")
ASSERT(SIZEOF(.audio_instance_stop_all) == 0xf0, "audio_instance_stop_all size changed")
ASSERT(SIZEOF(.audio_stop_all_commands) == 0x9c, "audio_stop_all_commands size changed")
ASSERT(SIZEOF(.audio_voice_stop_all) == 0x1ec, "audio_voice_stop_all size changed")
ASSERT(SIZEOF(.audio_level_commands) == 0xdc, "audio_level_commands size changed")
ASSERT(SIZEOF(.audio_level_update) == 0x1e0, "audio_level_update size changed")
ASSERT(SIZEOF(.audio_level_commands_alt) == 0x6c, "audio_level_commands_alt size changed")
ASSERT(SIZEOF(.audio_level_update_alt) == 0x1dc, "audio_level_update_alt size changed")
ASSERT(SIZEOF(.audio_mode) == 0x20, "audio_mode size changed")
ASSERT(SIZEOF(.cpu_after_audio_mode) == 0xc, "cpu_after_audio_mode size changed")
ASSERT(SIZEOF(.audio_voice_pause_state) == 0xa0, "audio_voice_pause_state size changed")
ASSERT(SIZEOF(.audio_pause_request) == 0xc8, "audio_pause_request size changed")
ASSERT(SIZEOF(.audio_pause_decode) == 0x40, "audio_pause_decode size changed")
ASSERT(SIZEOF(.audio_pause_apply) == 0x1cc, "audio_pause_apply size changed")
ASSERT(SIZEOF(.audio_resume_request) == 0xb8, "audio_resume_request size changed")
ASSERT(SIZEOF(.audio_resume_decode) == 0x30, "audio_resume_decode size changed")
ASSERT(SIZEOF(.audio_resume_apply) == 0x168, "audio_resume_apply size changed")
ASSERT(SIZEOF(.audio_pause_all_request) == 0xb8, "audio_pause_all_request size changed")
ASSERT(SIZEOF(.audio_pause_all_decode) == 0x40, "audio_pause_all_decode size changed")
ASSERT(SIZEOF(.audio_pause_all_apply) == 0x1e8, "audio_pause_all_apply size changed")
ASSERT(SIZEOF(.audio_resume_all_request) == 0xa8, "audio_resume_all_request size changed")
ASSERT(SIZEOF(.audio_resume_all_decode) == 0x30, "audio_resume_all_decode size changed")
ASSERT(SIZEOF(.audio_resume_all_apply) == 0x18c, "audio_resume_all_apply size changed")
ASSERT(SIZEOF(.cpu_after_audio_resume_all_apply) == 0x8, "cpu_after_audio_resume_all_apply size changed")
ASSERT(SIZEOF(.audio_play_arguments) == 0x9c, "audio_play_arguments size changed")
ASSERT(SIZEOF(.audio_voice_properties_initial) == 0x264, "audio_voice_properties_initial size changed")
ASSERT(SIZEOF(.audio_owner_properties_request) == 0x4c, "audio_owner_properties_request size changed")
ASSERT(SIZEOF(.audio_owner_properties_decode) == 0x3c, "audio_owner_properties_decode size changed")
ASSERT(SIZEOF(.audio_owner_properties_apply) == 0x184, "audio_owner_properties_apply size changed")
ASSERT(SIZEOF(.audio_owner_state_query) == 0xec, "audio_owner_state_query size changed")
ASSERT(SIZEOF(.audio_owner_stop_request) == 0x110, "audio_owner_stop_request size changed")
ASSERT(SIZEOF(.audio_owner_stop_commands) == 0xbc, "audio_owner_stop_commands size changed")
ASSERT(SIZEOF(.audio_owner_stop_apply) == 0x200, "audio_owner_stop_apply size changed")
ASSERT(SIZEOF(.cpu_after_audio_owner_stop_apply) == 0xc, "cpu_after_audio_owner_stop_apply size changed")
ASSERT(SIZEOF(.audio_instance_count) == 0xb8, "audio_instance_count size changed")
ASSERT(SIZEOF(.audio_instance_enumerate) == 0xec, "audio_instance_enumerate size changed")
ASSERT(SIZEOF(.audio_owner_count) == 0xb8, "audio_owner_count size changed")
ASSERT(SIZEOF(.audio_owner_enumerate) == 0xec, "audio_owner_enumerate size changed")
ASSERT(SIZEOF(.after_audio_owner_enumerate) == 0x8, "after_audio_owner_enumerate size changed")
ASSERT(SIZEOF(.audio_handle_instance) == 0x60, "audio_handle_instance size changed")
ASSERT(SIZEOF(.audio_handle_voice) == 0xa0, "audio_handle_voice size changed")
ASSERT(SIZEOF(.audio_handle_create) == 0x58, "audio_handle_create size changed")
ASSERT(SIZEOF(.audio_handle_state) == 0x70, "audio_handle_state size changed")
ASSERT(SIZEOF(.audio_handle_release) == 0x138, "audio_handle_release size changed")
ASSERT(SIZEOF(.audio_handle_resume) == 0x118, "audio_handle_resume size changed")
ASSERT(SIZEOF(.audio_handle_resume_default) == 0x20, "audio_handle_resume_default size changed")
ASSERT(SIZEOF(.audio_handle_voice_resume) == 0x8c, "audio_handle_voice_resume size changed")
ASSERT(SIZEOF(.audio_handle_voice_resume_default) == 0x20, "audio_handle_voice_resume_default size changed")
ASSERT(SIZEOF(.audio_handle_properties_capture) == 0xf0, "audio_handle_properties_capture size changed")
ASSERT(SIZEOF(.audio_handle_properties_apply) == 0xf0, "audio_handle_properties_apply size changed")
ASSERT(SIZEOF(.audio_handle_stop) == 0x114, "audio_handle_stop size changed")
ASSERT(SIZEOF(.audio_handle_rate) == 0x130, "audio_handle_rate size changed")
ASSERT(SIZEOF(.audio_handle_validate_only) == 0x28, "audio_handle_validate_only size changed")
ASSERT(SIZEOF(.audio_handle_rewind) == 0x140, "audio_handle_rewind size changed")
ASSERT(SIZEOF(.cpu_after_audio_handle_rewind) == 0x468, "cpu_after_audio_handle_rewind size changed")
ASSERT(SIZEOF(.audio_handle_seek_relative) == 0x160, "audio_handle_seek_relative size changed")
ASSERT(SIZEOF(.audio_handle_seek_absolute) == 0x158, "audio_handle_seek_absolute size changed")
ASSERT(SIZEOF(.audio_handle_position) == 0xd0, "audio_handle_position size changed")
ASSERT(SIZEOF(.audio_voice_command_parameter) == 0x178, "audio_voice_command_parameter size changed")
ASSERT(SIZEOF(.audio_voice_command_temporary) == 0x44, "audio_voice_command_temporary size changed")
ASSERT(SIZEOF(.audio_voice_properties_apply) == 0x26c, "audio_voice_properties_apply size changed")
ASSERT(SIZEOF(.audio_voice_properties_capture) == 0x15c, "audio_voice_properties_capture size changed")
ASSERT(SIZEOF(.cpu_after_audio_voice_properties_capture) == 0xc, "cpu_after_audio_voice_properties_capture size changed")
ASSERT(SIZEOF(.audio_handle_parameter_57c70) == 0x2c, "audio_handle_parameter_57c70 size changed")
ASSERT(SIZEOF(.audio_handle_pair_request) == 0x6c, "audio_handle_pair_request size changed")
ASSERT(SIZEOF(.audio_handle_pair_decode) == 0x60, "audio_handle_pair_decode size changed")
ASSERT(SIZEOF(.audio_handle_pair_apply) == 0xd4, "audio_handle_pair_apply size changed")
ASSERT(SIZEOF(.audio_voice_command_18) == 0x58, "audio_voice_command_18 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_57e94) == 0x2c, "audio_handle_parameter_57e94 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_57ec0) == 0x30, "audio_handle_parameter_57ec0 size changed")
ASSERT(SIZEOF(.audio_voice_command_10) == 0x58, "audio_voice_command_10 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_57f48) == 0x2c, "audio_handle_parameter_57f48 size changed")
ASSERT(SIZEOF(.audio_voice_command_11) == 0x58, "audio_voice_command_11 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_57fcc) == 0x2c, "audio_handle_parameter_57fcc size changed")
ASSERT(SIZEOF(.audio_handle_parameter_57ff8) == 0x2c, "audio_handle_parameter_57ff8 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_58024) == 0x2c, "audio_handle_parameter_58024 size changed")
ASSERT(SIZEOF(.audio_voice_command_14) == 0x58, "audio_voice_command_14 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_580a8) == 0x2c, "audio_handle_parameter_580a8 size changed")
ASSERT(SIZEOF(.audio_voice_command_15) == 0x58, "audio_voice_command_15 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_5812c) == 0x2c, "audio_handle_parameter_5812c size changed")
ASSERT(SIZEOF(.audio_voice_command_16) == 0x58, "audio_voice_command_16 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_581b0) == 0x2c, "audio_handle_parameter_581b0 size changed")
ASSERT(SIZEOF(.audio_handle_parameter_request) == 0x6c, "audio_handle_parameter_request size changed")
ASSERT(SIZEOF(.audio_handle_parameter_decode) == 0x60, "audio_handle_parameter_decode size changed")
ASSERT(SIZEOF(.audio_handle_parameter_apply) == 0x6c, "audio_handle_parameter_apply size changed")
ASSERT(SIZEOF(.cpu_after_audio_handle_parameter_apply) == 0xc, "cpu_after_audio_handle_parameter_apply size changed")
ASSERT(SIZEOF(.audio_stream_storage) == 0x94, "audio_stream_storage size changed")
ASSERT(SIZEOF(.cpu_after_audio_stream_storage) == 0x4dc, "cpu_after_audio_stream_storage size changed")
ASSERT(SIZEOF(.audio_host_callbacks) == 0x8c, "audio_host_callbacks size changed")
ASSERT(SIZEOF(.audio_host_control) == 0x40, "audio_host_control size changed")
ASSERT(SIZEOF(.audio_command_lock) == 0x80, "audio_command_lock size changed")
ASSERT(SIZEOF(.audio_timing_rate) == 0x7c, "audio_timing_rate size changed")
ASSERT(SIZEOF(.cpu_after_audio_timing_rate) == 0x84, "cpu_after_audio_timing_rate size changed")
ASSERT(SIZEOF(.audio_host_files) == 0x124, "audio_host_files size changed")
ASSERT(SIZEOF(.audio_diagnostics) == 0x6c0, "audio_diagnostics size changed")
ASSERT(SIZEOF(.audio_command_queue) == 0x240, "audio_command_queue size changed")
ASSERT(SIZEOF(.audio_stream_variable_read) == 0x54, "audio_stream_variable_read size changed")
ASSERT(SIZEOF(.audio_stream_variable_write) == 0x70, "audio_stream_variable_write size changed")
ASSERT(SIZEOF(.audio_engine_setup) == 0x58, "audio_engine_setup size changed")
ASSERT(SIZEOF(.audio_engine_voice_stop) == 0x17c, "audio_engine_voice_stop size changed")
ASSERT(SIZEOF(.audio_engine_parameters) == 0x1f0, "audio_engine_parameters size changed")
ASSERT(SIZEOF(.audio_engine_gate) == 0xe0, "audio_engine_gate size changed")
ASSERT(SIZEOF(.audio_engine_iteration) == 0xec, "audio_engine_iteration size changed")
ASSERT(SIZEOF(.audio_engine_gate_reset) == 0xcc, "audio_engine_gate_reset size changed")
ASSERT(SIZEOF(.audio_engine_iteration_reset) == 0xcc, "audio_engine_iteration_reset size changed")
ASSERT(SIZEOF(.audio_engine_iteration_set) == 0x40, "audio_engine_iteration_set size changed")
ASSERT(SIZEOF(.audio_engine_tempo) == 0x19c, "audio_engine_tempo size changed")
ASSERT(SIZEOF(.audio_engine_sequence_call) == 0x1b8, "audio_engine_sequence_call size changed")
ASSERT(SIZEOF(.audio_engine_sequence_jump) == 0x190, "audio_engine_sequence_jump size changed")
ASSERT(SIZEOF(.audio_engine_sequence_return) == 0x138, "audio_engine_sequence_return size changed")
ASSERT(SIZEOF(.audio_engine_sequence_stop) == 0x290, "audio_engine_sequence_stop size changed")
ASSERT(SIZEOF(.audio_engine_voice_tempo) == 0x64, "audio_engine_voice_tempo size changed")
ASSERT(SIZEOF(.audio_engine_voice_call) == 0x88, "audio_engine_voice_call size changed")
ASSERT(SIZEOF(.audio_engine_voice_jump) == 0x6c, "audio_engine_voice_jump size changed")
ASSERT(SIZEOF(.audio_engine_voice_return) == 0x5c, "audio_engine_voice_return size changed")
ASSERT(SIZEOF(.audio_engine_voice_end) == 0x120, "audio_engine_voice_end size changed")
ASSERT(SIZEOF(.cpu_after_audio_engine_voice_end) == 0x3a4, "cpu_after_audio_engine_voice_end size changed")
ASSERT(SIZEOF(.audio_rate_scale) == 0x38, "audio_rate_scale size changed")
ASSERT(SIZEOF(.audio_voice_capture_control) == 0x48, "audio_voice_capture_control size changed")
ASSERT(SIZEOF(.audio_voice_capture_resume) == 0xd8, "audio_voice_capture_resume size changed")
ASSERT(SIZEOF(.audio_voice_capture_append) == 0x13c, "audio_voice_capture_append size changed")
ASSERT(SIZEOF(.audio_voice_argument) == 0x1c, "audio_voice_argument size changed")
ASSERT(SIZEOF(.audio_pitch_scale) == 0x64, "audio_pitch_scale size changed")
ASSERT(SIZEOF(.after_audio_pitch_scale) == 0x344, "after_audio_pitch_scale size changed")
ASSERT(SIZEOF(.audio_backend_initialize) == 0x2c4, "audio_backend_initialize size changed")
ASSERT(SIZEOF(.audio_backend_update) == 0x150, "audio_backend_update size changed")
ASSERT(SIZEOF(.audio_backend_voice_stop) == 0x98, "audio_backend_voice_stop size changed")
ASSERT(SIZEOF(.after_audio_backend_voice_stop) == 0x1a4, "after_audio_backend_voice_stop size changed")
ASSERT(SIZEOF(.audio_backend_patch) == 0x2c, "audio_backend_patch size changed")
ASSERT(SIZEOF(.after_audio_backend_patch) == 0x2a4, "after_audio_backend_patch size changed")
ASSERT(SIZEOF(.audio_backend_volume) == 0x234, "audio_backend_volume size changed")
ASSERT(SIZEOF(.audio_backend_pan_pedal) == 0x2dc, "audio_backend_pan_pedal size changed")
ASSERT(SIZEOF(.audio_backend_voice_start) == 0xb0, "audio_backend_voice_start size changed")
ASSERT(SIZEOF(.audio_backend_release) == 0x18c, "audio_backend_release size changed")
ASSERT(SIZEOF(.audio_backend_decay) == 0x174, "audio_backend_decay size changed")
ASSERT(SIZEOF(.audio_backend_allocate) == 0x23c, "audio_backend_allocate size changed")
ASSERT(SIZEOF(.audio_backend_note_release) == 0x108, "audio_backend_note_release size changed")
ASSERT(SIZEOF(.after_audio_backend_note_release) == 0x4, "after_audio_backend_note_release size changed")
ASSERT(SIZEOF(.audio_file_services) == 0x14c, "audio_file_services size changed")
ASSERT(SIZEOF(.after_audio_file_services) == 0x414, "after_audio_file_services size changed")
ASSERT(SIZEOF(.audio_sequence_table_size) == 0xc4, "audio_sequence_table_size size changed")
ASSERT(SIZEOF(.audio_sequence_table_load) == 0x1c0, "audio_sequence_table_load size changed")
ASSERT(SIZEOF(.audio_sequence_table_close) == 0x24, "audio_sequence_table_close size changed")
ASSERT(SIZEOF(.audio_sequence_size) == 0xbc, "audio_sequence_size size changed")
ASSERT(SIZEOF(.audio_sequence_load) == 0x8c, "audio_sequence_load size changed")
ASSERT(SIZEOF(.audio_sequence_release) == 0x80, "audio_sequence_release size changed")
ASSERT(SIZEOF(.audio_sequence_list_size) == 0x78, "audio_sequence_list_size size changed")
ASSERT(SIZEOF(.audio_sequence_list_load) == 0xac, "audio_sequence_list_load size changed")
ASSERT(SIZEOF(.audio_sequence_list_release) == 0x74, "audio_sequence_list_release size changed")
ASSERT(SIZEOF(.after_audio_sequence_list_release) == 0x8, "after_audio_sequence_list_release size changed")
ASSERT(SIZEOF(.audio_sequence_range_size) == 0x7c, "audio_sequence_range_size size changed")
ASSERT(SIZEOF(.audio_sequence_range_load) == 0xb0, "audio_sequence_range_load size changed")
ASSERT(SIZEOF(.audio_sequence_range_release) == 0x7c, "audio_sequence_range_release size changed")
ASSERT(SIZEOF(.after_audio_sequence_range_release) == 0x8, "after_audio_sequence_range_release size changed")
ASSERT(SIZEOF(.audio_interrupt_service) == 0x40, "audio_interrupt_service size changed")
ASSERT(SIZEOF(.cpu_after_audio_interrupt_service) == 0x7c4, "cpu_after_audio_interrupt_service size changed")
ASSERT(SIZEOF(.compression_table_release) == 0x8, "compression_table_release size changed")
ASSERT(SIZEOF(.compression_fixed) == 0x1f0, "compression_fixed size changed")
ASSERT(SIZEOF(.compression_fixed_release) == 0x48, "compression_fixed_release size changed")
ASSERT(SIZEOF(.after_compression_fixed_release) == 0x83c, "after_compression_fixed_release size changed")
ASSERT(SIZEOF(.compression_workspace) == 0xc4, "compression_workspace size changed")
ASSERT(SIZEOF(.compression_allocate) == 0x24, "compression_allocate size changed")
ASSERT(SIZEOF(.compression_refill) == 0x74, "compression_refill size changed")
ASSERT(SIZEOF(.compression_decode) == 0x238, "compression_decode size changed")
ASSERT(SIZEOF(.compression_memory) == 0x58, "compression_memory size changed")
ASSERT(SIZEOF(.compression_cartridge) == 0x50, "compression_cartridge size changed")
ASSERT(SIZEOF(.compression_cartridge_bounded) == 0x58, "compression_cartridge_bounded size changed")
ASSERT(SIZEOF(.pi_cartridge_read) == 0x54, "pi_cartridge_read size changed")
ASSERT(SIZEOF(.cpu_after_pi_raw_read) == 0xc, "cpu_after_pi_raw_read size changed")
ASSERT(SIZEOF(.thread_create) == 0x144, "thread_create size changed")
ASSERT(SIZEOF(.cpu_after_thread_create) == 0xc, "cpu_after_thread_create size changed")
ASSERT(SIZEOF(.thread_start) == 0x150, "thread_start size changed")
ASSERT(SIZEOF(.pi_manager_create) == 0x188, "pi_manager_create size changed")
ASSERT(SIZEOF(.cpu_after_pi_manager_create) == 0x8, "cpu_after_pi_manager_create size changed")
ASSERT(SIZEOF(.thread_set_priority) == 0xe0, "thread_set_priority size changed")
ASSERT(SIZEOF(.message_queue) == 0x2c, "message_queue size changed")
ASSERT(SIZEOF(.cpu_after_message_queue_create) == 0x64, "cpu_after_message_queue_create size changed")
ASSERT(SIZEOF(.vi_features) == 0x1b8, "vi_features size changed")
ASSERT(SIZEOF(.cpu_after_vi_features) == 0x8, "cpu_after_vi_features size changed")
ASSERT(SIZEOF(.virtual_to_physical) == 0x7c, "virtual_to_physical size changed")
ASSERT(SIZEOF(.camera_perspective) == 0x288, "camera_perspective size changed")
ASSERT(SIZEOF(.cpu_after_gu_perspective) == 0x8, "cpu_after_gu_perspective size changed")
ASSERT(SIZEOF(.camera_highlights) == 0x824, "camera_highlights size changed")
ASSERT(SIZEOF(.cpu_after_gu_lookathilite) == 0xc, "cpu_after_gu_lookathilite size changed")
ASSERT(SIZEOF(.matrix_translate) == 0x9c, "matrix_translate size changed")
ASSERT(SIZEOF(.cpu_after_gu_translate) == 0x4, "cpu_after_gu_translate size changed")
ASSERT(SIZEOF(.matrix_rotation) == 0x194, "matrix_rotation size changed")
ASSERT(SIZEOF(.cpu_after_gu_rotate_rpy) == 0xc, "cpu_after_gu_rotate_rpy size changed")
ASSERT(SIZEOF(.system_time) == 0x84, "system_time size changed")
ASSERT(SIZEOF(.cpu_after_time_get) == 0xc, "cpu_after_time_get size changed")
ASSERT(SIZEOF(.compiler_integer64) == 0x2c0, "compiler_integer64 size changed")
ASSERT(SIZEOF(.pfs_is_plug) == 0x36c, "pfs_is_plug size changed")
ASSERT(SIZEOF(.cpu_after_pfs_is_plug) == 0x4, "cpu_after_pfs_is_plug size changed")
ASSERT(SIZEOF(.pfs_init_pak) == 0x264, "pfs_init_pak size changed")
ASSERT(SIZEOF(.cpu_after_pfs_init_pak) == 0xc, "cpu_after_pfs_init_pak size changed")
ASSERT(SIZEOF(.controller_read) == 0x258, "controller_read size changed")
ASSERT(SIZEOF(.cpu_after_controller_read) == 0x8, "cpu_after_controller_read size changed")
ASSERT(SIZEOF(.message_receive) == 0x138, "message_receive size changed")
ASSERT(SIZEOF(.cpu_after_message_receive) == 0x8, "cpu_after_message_receive size changed")
ASSERT(SIZEOF(.pfs_search_file) == 0x1b4, "pfs_search_file size changed")
ASSERT(SIZEOF(.cpu_after_pfs_search_file) == 0xc, "cpu_after_pfs_search_file size changed")
ASSERT(SIZEOF(.pfs_allocate_file) == 0x7a8, "pfs_allocate_file size changed")
ASSERT(SIZEOF(.cpu_after_pfs_allocate_file) == 0x8, "cpu_after_pfs_allocate_file size changed")
ASSERT(SIZEOF(.pfs_read_write_file) == 0x4fc, "pfs_read_write_file size changed")
ASSERT(SIZEOF(.cpu_after_pfs_read_write_file) == 0x4, "cpu_after_pfs_read_write_file size changed")
ASSERT(SIZEOF(.gu_random) == 0x2c, "gu_random size changed")
ASSERT(SIZEOF(.cpu_after_gu_cosine_float) == 0x8, "cpu_after_gu_cosine_float size changed")
ASSERT(SIZEOF(.pi_read) == 0x40, "pi_read size changed")
ASSERT(SIZEOF(.message_send) == 0x14c, "message_send size changed")
ASSERT(SIZEOF(.cpu_after_message_send) == 0x4, "cpu_after_message_send size changed")
ASSERT(SIZEOF(.pfs_motor) == 0x614, "pfs_motor size changed")
ASSERT(SIZEOF(.cpu_after_pfs_motor) == 0xc, "cpu_after_pfs_motor size changed")
ASSERT(SIZEOF(.controller_init) == 0x3bc, "controller_init size changed")
ASSERT(SIZEOF(.cpu_after_controller_init) == 0x4, "cpu_after_controller_init size changed")
ASSERT(SIZEOF(.event_message) == 0x68, "event_message size changed")
ASSERT(SIZEOF(.cpu_after_event_message) == 0x8, "cpu_after_event_message size changed")
ASSERT(SIZEOF(.pfs_free_blocks) == 0x14c, "pfs_free_blocks size changed")
ASSERT(SIZEOF(.cpu_after_pfs_free_blocks) == 0x4, "cpu_after_pfs_free_blocks size changed")
ASSERT(SIZEOF(.pfs_num_files) == 0x144, "pfs_num_files size changed")
ASSERT(SIZEOF(.cpu_after_pfs_num_files) == 0xc, "cpu_after_pfs_num_files size changed")
ASSERT(SIZEOF(.pfs_delete_file) == 0x608, "pfs_delete_file size changed")
ASSERT(SIZEOF(.cpu_after_pfs_delete_file) == 0x8, "cpu_after_pfs_delete_file size changed")
ASSERT(SIZEOF(.pfs_file_state) == 0x2f0, "pfs_file_state size changed")
ASSERT(SIZEOF(.cpu_after_vi_vertical_scale) == 0x8, "cpu_after_vi_vertical_scale size changed")
ASSERT(SIZEOF(.cpu_after_vi_manager) == 0xc, "cpu_after_vi_manager size changed")
ASSERT(SIZEOF(.vi_mode) == 0x68, "vi_mode size changed")
ASSERT(SIZEOF(.cpu_after_vi_mode) == 0x8, "cpu_after_vi_mode size changed")
ASSERT(SIZEOF(.vi_black) == 0x70, "vi_black size changed")
ASSERT(SIZEOF(.vi_event) == 0x6c, "vi_event size changed")
ASSERT(SIZEOF(.sp_yield) == 0x20, "sp_yield size changed")
ASSERT(SIZEOF(.sp_yielded) == 0x80, "sp_yielded size changed")
ASSERT(SIZEOF(.sp_start) == 0x40, "sp_start size changed")
ASSERT(SIZEOF(.cpu_after_audio_sp) == 0x4, "cpu_after_audio_sp size changed")
ASSERT(SIZEOF(.vi_framebuffer) == 0xd0, "vi_framebuffer size changed")
ASSERT(SIZEOF(.audio_heap_init) == 0x34, "audio_heap_init size changed")
ASSERT(SIZEOF(.cpu_after_audio_heap_init) == 0xc, "cpu_after_audio_heap_init size changed")
ASSERT(SIZEOF(.audio_heap_allocate) == 0x54, "audio_heap_allocate size changed")
ASSERT(SIZEOF(.pi_start_dma) == 0x10c, "pi_start_dma size changed")
ASSERT(SIZEOF(.cpu_after_pi_start_dma) == 0x4, "cpu_after_pi_start_dma size changed")
ASSERT(SIZEOF(.ai_frequency) == 0x160, "ai_frequency size changed")
ASSERT(SIZEOF(.audio_link_nodes) == 0x54, "audio_link_nodes size changed")
ASSERT(SIZEOF(.audio_synth_lifecycle) == 0x6c, "audio_synth_lifecycle size changed")
ASSERT(SIZEOF(.audio_buffer_submit) == 0xa8, "audio_buffer_submit size changed")
ASSERT(SIZEOF(.cpu_after_ai_buffer) == 0x8, "cpu_after_ai_buffer size changed")
ASSERT(SIZEOF(.audio_remaining_bytes) == 0xc, "audio_remaining_bytes size changed")
ASSERT(SIZEOF(.cpu_after_ai_length) == 0x4, "cpu_after_ai_length size changed")
ASSERT(SIZEOF(.audio_synthesizer) == 0x6e0, "audio_synthesizer size changed")
ASSERT(SIZEOF(.audio_callback_attach) == 0x50, "audio_callback_attach size changed")
ASSERT(SIZEOF(.voice_allocate) == 0x228, "voice_allocate size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_allocate) == 0x8, "cpu_after_audio_synth_allocate size changed")
ASSERT(SIZEOF(.voice_start) == 0xe4, "voice_start size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_start) == 0xc, "cpu_after_audio_synth_start size changed")
ASSERT(SIZEOF(.voice_pitch) == 0x84, "voice_pitch size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_pitch) == 0xc, "cpu_after_audio_synth_pitch size changed")
ASSERT(SIZEOF(.voice_volume) == 0x9c, "voice_volume size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_volume) == 0x4, "cpu_after_audio_synth_volume size changed")
ASSERT(SIZEOF(.voice_pan) == 0x84, "voice_pan size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_pan) == 0xc, "cpu_after_audio_synth_pan size changed")
ASSERT(SIZEOF(.voice_stop) == 0x78, "voice_stop size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_stop) == 0x8, "cpu_after_audio_synth_stop size changed")
ASSERT(SIZEOF(.voice_release) == 0xb0, "voice_release size changed")
ASSERT(SIZEOF(.voice_priority) == 0x10, "voice_priority size changed")
ASSERT(SIZEOF(.si_raw_read) == 0x50, "si_raw_read size changed")
ASSERT(SIZEOF(.si_raw_write) == 0x4c, "si_raw_write size changed")
ASSERT(SIZEOF(.os_interrupt) == 0x40, "os_interrupt size changed")
ASSERT(SIZEOF(.thread_dequeue) == 0x40, "thread_dequeue size changed")
ASSERT(SIZEOF(.pi_access) == 0xc0, "pi_access size changed")
ASSERT(SIZEOF(.thread_get_priority) == 0x18, "thread_get_priority size changed")
ASSERT(SIZEOF(.cpu_after_thread_get_priority) == 0x8, "cpu_after_thread_get_priority size changed")
ASSERT(SIZEOF(.pi_raw_dma) == 0xe0, "pi_raw_dma size changed")
ASSERT(SIZEOF(.os_probe_tlb) == 0xc0, "os_probe_tlb size changed")
ASSERT(SIZEOF(.matrix_convert) == 0x26c, "matrix_convert size changed")
ASSERT(SIZEOF(.cpu_after_gu_mtxutil) == 0x4, "cpu_after_gu_mtxutil size changed")
ASSERT(SIZEOF(.os_get_count) == 0x10, "os_get_count size changed")
ASSERT(SIZEOF(.timer_initialize) == 0x8c, "timer_initialize size changed")
ASSERT(SIZEOF(.timer_interrupt) == 0x178, "timer_interrupt size changed")
ASSERT(SIZEOF(.timer_compare) == 0x74, "timer_compare size changed")
ASSERT(SIZEOF(.timer_insert) == 0x188, "timer_insert size changed")
ASSERT(SIZEOF(.pfs_contpfs) == 0xd58, "pfs_contpfs size changed")
ASSERT(SIZEOF(.cpu_after_pfs_contpfs) == 0x8, "cpu_after_pfs_contpfs size changed")
ASSERT(SIZEOF(.pfs_cont_ram_read) == 0x384, "pfs_cont_ram_read size changed")
ASSERT(SIZEOF(.cpu_after_pfs_cont_ram_read) == 0xc, "cpu_after_pfs_cont_ram_read size changed")
ASSERT(SIZEOF(.si_access) == 0xc0, "si_access size changed")
ASSERT(SIZEOF(.si_dma) == 0xac, "si_dma size changed")
ASSERT(SIZEOF(.cpu_after_si_dma) == 0x4, "cpu_after_si_dma size changed")
ASSERT(SIZEOF(.pfs_get_status) == 0x10c, "pfs_get_status size changed")
ASSERT(SIZEOF(.cpu_after_pfs_get_status) == 0x4, "cpu_after_pfs_get_status size changed")
ASSERT(SIZEOF(.pfs_checker) == 0xa60, "pfs_checker size changed")
ASSERT(SIZEOF(.pfs_cont_ram_write) == 0x380, "pfs_cont_ram_write size changed")
ASSERT(SIZEOF(.controller_crc) == 0x180, "controller_crc size changed")
ASSERT(SIZEOF(.timer_schedule) == 0xd4, "timer_schedule size changed")
ASSERT(SIZEOF(.cpu_after_timer_set) == 0xc, "cpu_after_timer_set size changed")
ASSERT(SIZEOF(.video_context_get) == 0xc, "video_context_get size changed")
ASSERT(SIZEOF(.sp_set_status) == 0xc, "sp_set_status size changed")
ASSERT(SIZEOF(.cpu_after_sp_set_status) == 0x4, "cpu_after_sp_set_status size changed")
ASSERT(SIZEOF(.sp_get_status) == 0xc, "sp_get_status size changed")
ASSERT(SIZEOF(.sp_set_pc) == 0x34, "sp_set_pc size changed")
ASSERT(SIZEOF(.cpu_after_sp_set_pc) == 0xc, "cpu_after_sp_set_pc size changed")
ASSERT(SIZEOF(.sp_dma) == 0x8c, "sp_dma size changed")
ASSERT(SIZEOF(.cpu_after_sp_dma) == 0x4, "cpu_after_sp_dma size changed")
ASSERT(SIZEOF(.sp_busy) == 0x2c, "sp_busy size changed")
ASSERT(SIZEOF(.cpu_after_sp_busy) == 0x4, "cpu_after_sp_busy size changed")
ASSERT(SIZEOF(.message_prepend) == 0x150, "message_prepend size changed")
ASSERT(SIZEOF(.cpu_after_pi_get_queue) == 0x8, "cpu_after_pi_get_queue size changed")
ASSERT(SIZEOF(.audio_synth_clear) == 0x8, "audio_synth_clear size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_delete) == 0x8, "cpu_after_audio_synth_delete size changed")
ASSERT(SIZEOF(.ai_busy) == 0x30, "ai_busy size changed")
ASSERT(SIZEOF(.audio_filter_create) == 0x2c0, "audio_filter_create size changed")
ASSERT(SIZEOF(.audio_low_pass) == 0xa0, "audio_low_pass size changed")
ASSERT(SIZEOF(.audio_effect_create) == 0x43c, "audio_effect_create size changed")
ASSERT(SIZEOF(.cpu_after_audio_effect_init) == 0x4, "cpu_after_audio_effect_init size changed")
ASSERT(SIZEOF(.audio_effect_allocate) == 0x98, "audio_effect_allocate size changed")
ASSERT(SIZEOF(.cpu_after_audio_effect_allocate) == 0x8, "cpu_after_audio_effect_allocate size changed")
ASSERT(SIZEOF(.audio_main_bus) == 0x150, "audio_main_bus size changed")
ASSERT(SIZEOF(.audio_decoder) == 0xb4c, "audio_decoder size changed")
ASSERT(SIZEOF(.cpu_after_audio_decoder) == 0x4, "cpu_after_audio_decoder size changed")
ASSERT(SIZEOF(.audio_resample) == 0x2f4, "audio_resample size changed")
ASSERT(SIZEOF(.cpu_after_audio_resample) == 0xc, "cpu_after_audio_resample size changed")
ASSERT(SIZEOF(.audio_envelope) == 0xc54, "audio_envelope size changed")
ASSERT(SIZEOF(.cpu_after_audio_envelope) == 0xc, "cpu_after_audio_envelope size changed")
ASSERT(SIZEOF(.audio_auxiliary_bus) == 0x108, "audio_auxiliary_bus size changed")
ASSERT(SIZEOF(.cpu_after_audio_aux_bus) == 0x8, "cpu_after_audio_aux_bus size changed")
ASSERT(SIZEOF(.audio_save_filter) == 0xc0, "audio_save_filter size changed")
ASSERT(SIZEOF(.si_busy) == 0x2c, "si_busy size changed")
ASSERT(SIZEOF(.cpu_after_pi_event) == 0x8, "cpu_after_pi_event size changed")
ASSERT(SIZEOF(.thread_destroy) == 0xf8, "thread_destroy size changed")
ASSERT(SIZEOF(.cpu_after_thread_destroy) == 0x8, "cpu_after_thread_destroy size changed")
ASSERT(SIZEOF(.cpu_after_interrupt_global_clear) == 0x8, "cpu_after_interrupt_global_clear size changed")
ASSERT(SIZEOF(.cpu_after_epi_raw_write) == 0x4, "cpu_after_epi_raw_write size changed")
ASSERT(SIZEOF(.cpu_after_interrupt_global_set) == 0x4, "cpu_after_interrupt_global_set size changed")
ASSERT(SIZEOF(.thread_yield) == 0x4c, "thread_yield size changed")
ASSERT(SIZEOF(.cpu_after_thread_yield) == 0x4, "cpu_after_thread_yield size changed")
ASSERT(SIZEOF(.os_set_compare) == 0x10, "os_set_compare size changed")
ASSERT(SIZEOF(.audio_filter_base) == 0x1c, "audio_filter_base size changed")
ASSERT(SIZEOF(.cpu_after_audio_filter_init) == 0x4, "cpu_after_audio_filter_init size changed")
ASSERT(SIZEOF(.audio_effect_modulation) == 0xa8, "audio_effect_modulation size changed")
ASSERT(SIZEOF(.audio_effect_buffers) == 0x5f0, "audio_effect_buffers size changed")
ASSERT(SIZEOF(.audio_effect_parameters) == 0x25c, "audio_effect_parameters size changed")
ASSERT(SIZEOF(.audio_effect_source) == 0x18, "audio_effect_source size changed")
ASSERT(SIZEOF(.audio_effect_pull) == 0x340, "audio_effect_pull size changed")
ASSERT(SIZEOF(.cpu_after_audio_effect_pull) == 0x4, "cpu_after_audio_effect_pull size changed")
ASSERT(SIZEOF(.audio_copy_bytes) == 0x74, "audio_copy_bytes size changed")
ASSERT(SIZEOF(.cpu_after_audio_copy) == 0xc, "cpu_after_audio_copy size changed")

ASSERT(SIZEOF(.audio_engine_voice_stop_bss) == 0xc, "audio_engine_voice_stop BSS size changed")
ASSERT(SIZEOF(.audio_engine_tempo_bss) == 0x10, "audio_engine_tempo BSS size changed")
ASSERT(SIZEOF(.audio_engine_sequence_call_bss) == 0x18, "audio_engine_sequence_call BSS size changed")
ASSERT(SIZEOF(.audio_engine_sequence_jump_bss) == 0x18, "audio_engine_sequence_jump BSS size changed")
ASSERT(SIZEOF(.audio_engine_sequence_return_bss) == 0x10, "audio_engine_sequence_return BSS size changed")
ASSERT(SIZEOF(.audio_engine_sequence_stop_bss) == 0x14, "audio_engine_sequence_stop BSS size changed")

ASSERT(SIZEOF(.audio_backend_update_bss) == 0xc, "audio_backend_update BSS size changed")
ASSERT(SIZEOF(.audio_backend_voice_stop_bss) == 0x4, "audio_backend_voice_stop BSS size changed")
ASSERT(SIZEOF(.audio_backend_patch_bss) == 0x2, "audio_backend_patch BSS size changed")
ASSERT(SIZEOF(.audio_backend_decay_bss) == 0x8, "audio_backend_decay BSS size changed")
ASSERT(SIZEOF(.audio_backend_allocate_bss) == 0x18, "audio_backend_allocate BSS size changed")

ASSERT(SIZEOF(.compression_workspace_bss) == 0xf58, "compression_workspace BSS size changed")

ASSERT(SIZEOF(.audio_backend_initialize_bss) == 0x4, "audio_backend_initialize BSS size changed")

ASSERT(SIZEOF(.audio_backend_volume_bss) == 0x11, "audio_backend_volume BSS size changed")
ASSERT(SIZEOF(.audio_backend_pan_pedal_bss) == 0x18, "audio_backend_pan_pedal BSS size changed")

ASSERT(SIZEOF(.audio_engine_gate_reset_bss) == 0x8, "audio_engine_gate_reset BSS size changed")
ASSERT(SIZEOF(.audio_engine_iteration_reset_bss) == 0x8, "audio_engine_iteration_reset BSS size changed")

ASSERT(SIZEOF(.audio_engine_iteration_set_bss) == 0x4, "audio_engine_iteration_set BSS size changed")

ASSERT(SIZEOF(.audio_engine_gate_bss) == 0xc, "audio_engine_gate BSS size changed")
ASSERT(SIZEOF(.audio_engine_iteration_bss) == 0xc, "audio_engine_iteration BSS size changed")

ASSERT(SIZEOF(.audio_backend_note_release_bss) == 0x8, "audio_backend_note_release BSS size changed")

ASSERT(SIZEOF(.timer_initialize_bss) == 0x8, "timer_initialize BSS size changed")

ASSERT(SIZEOF(.matrix_rotation_bss) == 0x4, "matrix_rotation BSS size changed")

ASSERT(SIZEOF(.pfs_is_plug_bss) == 0x40, "pfs_is_plug BSS size changed")
ASSERT(SIZEOF(.controller_read_bss) == 0x40, "controller_read BSS size changed")
ASSERT(SIZEOF(.pfs_motor_bss) == 0x240, "pfs_motor BSS size changed")
ASSERT(SIZEOF(.controller_init_bss) == 0x50, "controller_init BSS size changed")

ASSERT(SIZEOF(.runtime_sign) == 0x28, "runtime_sign size changed")
ASSERT(SIZEOF(.runtime_sine) == 0x20, "runtime_sine size changed")
ASSERT(SIZEOF(.frame_interval_set) == 0x24, "frame_interval_set size changed")
ASSERT(SIZEOF(.renderer_flag_set) == 0xc, "renderer_flag_set size changed")
ASSERT(SIZEOF(.audio_unused_command) == 0x8, "audio_unused_command size changed")
ASSERT(SIZEOF(.early_pool_initialize) == 0x5c, "early_pool_initialize size changed")
ASSERT(SIZEOF(.early_coordinate_rescale) == 0x3c, "early_coordinate_rescale size changed")
ASSERT(SIZEOF(.scene_index_code) == 0x48, "scene_index_code size changed")
ASSERT(SIZEOF(.renderer_digit_extract) == 0x60, "renderer_digit_extract size changed")
ASSERT(SIZEOF(.early_selection_activate) == 0x20, "early_selection_activate size changed")
ASSERT(SIZEOF(.frame_slot_allocate) == 0x4c, "frame_slot_allocate size changed")
ASSERT(SIZEOF(.audio_handle_tests) == 0x80, "audio_handle_tests size changed")
ASSERT(SIZEOF(.early_player_counter_reset) == 0x68, "early_player_counter_reset size changed")
ASSERT(SIZEOF(.compression_stored) == 0x2d8, "compression_stored size changed")
ASSERT(SIZEOF(.video_vertical_scale) == 0x58, "video_vertical_scale size changed")
ASSERT(SIZEOF(.interrupt_mask_set) == 0x4c, "interrupt_mask_set size changed")
ASSERT(SIZEOF(.interrupt_mask_reset) == 0x58, "interrupt_mask_reset size changed")
ASSERT(SIZEOF(.pi_extended_write) == 0x4c, "pi_extended_write size changed")
ASSERT(SIZEOF(.pi_extended_read) == 0x50, "pi_extended_read size changed")
ASSERT(SIZEOF(.os_status) == 0x20, "os_status size changed")
ASSERT(SIZEOF(.os_fpcsr) == 0x10, "os_fpcsr size changed")
ASSERT(SIZEOF(.os_invalidate_cache_all) == 0x30, "os_invalidate_cache_all size changed")
ASSERT(SIZEOF(.os_map_debug_tlb) == 0x60, "os_map_debug_tlb size changed")
ASSERT(SIZEOF(.square_root) == 0x10, "square_root size changed")
ASSERT(SIZEOF(.endgame_1b148_1b9a0) == 0x858, "endgame_1b148_1b9a0 size changed")
ASSERT(SIZEOF(.endgame_1ca2c_1cb48) == 0x11c, "endgame_1ca2c_1cb48 size changed")
ASSERT(SIZEOF(.early_player_sequence) == 0x118, "early_player_sequence size changed")
ASSERT(SIZEOF(.cpu_after_early_player_sequence) == 0x678, "cpu_after_early_player_sequence size changed")
ASSERT(SIZEOF(.endgame_50584_50590) == 0xc, "endgame_50584_50590 size changed")
ASSERT(SIZEOF(.endgame_5edec_5f5d0) == 0x7e4, "endgame_5edec_5f5d0 size changed")
ASSERT(SIZEOF(.endgame_6131c_61320) == 0x4, "endgame_6131c_61320 size changed")
ASSERT(SIZEOF(.endgame_63e1c_63e20) == 0x4, "endgame_63e1c_63e20 size changed")
ASSERT(SIZEOF(.pi_queue_get) == 0x28, "pi_queue_get size changed")
ASSERT(SIZEOF(.player_fields_clear) == 0x28, "player_fields_clear size changed")
ASSERT(SIZEOF(.runtime_buffer_clear) == 0x2c, "runtime_buffer_clear size changed")
ASSERT(SIZEOF(.render_buffer_allocate) == 0x48, "render_buffer_allocate size changed")
ASSERT(SIZEOF(.scene_arrival_reactivate) == 0x68, "scene_arrival_reactivate size changed")
ASSERT(SIZEOF(.short_sine) == 0x70, "short_sine size changed")
ASSERT(SIZEOF(.short_cosine) == 0x30, "short_cosine size changed")
ASSERT(SIZEOF(.ai_frequency) == 0x160, "ai_frequency size changed")
ASSERT(SIZEOF(.thread_destroy) == 0xf8, "thread_destroy size changed")
ASSERT(SIZEOF(.pi_start_dma) == 0x10c, "pi_start_dma size changed")
ASSERT(SIZEOF(.endgame_208e4_21b24) == 0x1240, "endgame_208e4_21b24 size changed")
ASSERT(SIZEOF(.endgame_21b8c_22720) == 0xb94, "endgame_21b8c_22720 size changed")
ASSERT(SIZEOF(.endgame_33600_33900) == 0x300, "endgame_33600_33900 size changed")
ASSERT(SIZEOF(.pi_event_notify) == 0xec, "pi_event_notify size changed")
ASSERT(SIZEOF(.pi_extended_dma) == 0x224, "pi_extended_dma size changed")
ASSERT(SIZEOF(.sine_float) == 0x1c0, "sine_float size changed")
ASSERT(SIZEOF(.cosine_float) == 0x168, "cosine_float size changed")
ASSERT(SIZEOF(.audio_voice_sequence_bind) == 0x74, "audio_voice_sequence_bind size changed")
ASSERT(SIZEOF(.render_buffer_reserve) == 0x74, "render_buffer_reserve size changed")
ASSERT(SIZEOF(.os_writeback_cache) == 0x80, "os_writeback_cache size changed")
ASSERT(SIZEOF(.os_invalidate_instruction_cache) == 0x80, "os_invalidate_instruction_cache size changed")
ASSERT(SIZEOF(.os_invalidate_data_cache) == 0xb0, "os_invalidate_data_cache size changed")
ASSERT(SIZEOF(.os_block_clear) == 0xa0, "os_block_clear size changed")
ASSERT(SIZEOF(.os_interrupt_mask) == 0xa0, "os_interrupt_mask size changed")
ASSERT(SIZEOF(.endgame_5456c_54850) == 0x2e4, "endgame_5456c_54850 size changed")
ASSERT(SIZEOF(.endgame_65dec_65df0) == 0x4, "endgame_65dec_65df0 size changed")
ASSERT(SIZEOF(.endgame_66384_66390) == 0xc, "endgame_66384_66390 size changed")
ASSERT(SIZEOF(.sp_task_physical) == 0x11c, "sp_task_physical size changed")
ASSERT(SIZEOF(.sp_task_load) == 0x190, "sp_task_load size changed")
ASSERT(SIZEOF(.pi_disk_recover) == 0xe8, "pi_disk_recover size changed")
ASSERT(SIZEOF(.early_actor_forward_and_guard) == 0x78, "early_actor_forward_and_guard size changed")
ASSERT(SIZEOF(.endgame_1627c_1675c) == 0x4e0, "endgame_1627c_1675c size changed")
ASSERT(SIZEOF(.os_block_copy) == 0x310, "os_block_copy size changed")
ASSERT(SIZEOF(.endgame_6bc0c_6bc10) == 0x4, "endgame_6bc0c_6bc10 size changed")
ASSERT(SIZEOF(.short_sine_data) == 0x800, "short sine data size changed")
ASSERT(SIZEOF(.video_modes_data) == 0xd20, "video modes data size changed")
ASSERT(SIZEOF(.video_default_modes_data) == 0xf0, "default video modes data size changed")
ASSERT(SIZEOF(.after_video_default_modes_data) == 0x58, "after default video modes data size changed")
ASSERT(SIZEOF(.video_manager_data) == 0x1c, "video manager data size changed")
ASSERT(SIZEOF(.video_manager_bss) == 0x1212, "video manager BSS size changed")
ASSERT(SIZEOF(.video_initialize_data) == 0x68, "video context data size changed")
ASSERT(SIZEOF(.after_video_context_data) == 0x28, "after video context data size changed")
ASSERT(SIZEOF(.pi_cartridge_initialize_bss) == 0x74, "cartridge handle BSS size changed")
ASSERT(SIZEOF(.pi_disk_initialize_bss) == 0x78, "disk handle BSS size changed")
ASSERT(SIZEOF(.video_manager) == 0x354, "video_manager size changed")
ASSERT(SIZEOF(.video_initialize) == 0x13c, "video_initialize size changed")
ASSERT(SIZEOF(.pi_cartridge_initialize) == 0xec, "pi_cartridge_initialize size changed")
ASSERT(SIZEOF(.pi_disk_initialize) == 0xf8, "pi_disk_initialize size changed")
ASSERT(SIZEOF(.endgame_682cc_682d0) == 0x4, "endgame_682cc_682d0 size changed")
ASSERT(SIZEOF(.endgame_683c8_683d0) == 0x8, "endgame_683c8_683d0 size changed")
ASSERT(SIZEOF(.endgame_68d8c_68d90) == 0x4, "endgame_68d8c_68d90 size changed")
ASSERT(SIZEOF(.video_context_swap) == 0x35c, "video context swap size changed")
ASSERT(SIZEOF(.endgame_6b88c_6b890) == 0x4, "endgame_6b88c_6b890 size changed")
ASSERT(SIZEOF(.endgame_6bbec_6bbf0) == 0x4, "endgame_6bbec_6bbf0 size changed")
ASSERT(SIZEOF(.pi_device_manager) == 0x490, "pi_device_manager size changed")
ASSERT(SIZEOF(.pi_manager_create_data) == 0x28, "pi_manager_create_data size changed")
ASSERT(SIZEOF(.pi_manager_create_bss) == 0x11cc, "pi_manager_create_bss size changed")
ASSERT(SIZEOF(.pi_device_manager_rodata) == 0x1c, "pi_device_manager_rodata size changed")
ASSERT(SIZEOF(.endgame_687b4_687c0) == 0xc, "endgame_687b4_687c0 size changed")
ASSERT(SIZEOF(.endgame_data_8eff8_8f000) == 0x8, "endgame_data_8eff8_8f000 size changed")
ASSERT(SIZEOF(.endgame_data_96acc_96ae0) == 0x14, "endgame_data_96acc_96ae0 size changed")
ASSERT(SIZEOF(.pi_disk_interrupt) == 0x6a4, "PI disk interrupt size changed")
ASSERT(SIZEOF(.endgame_6e81c_6e820) == 0x4, "endgame_6e81c_6e820 size changed")
ASSERT(SIZEOF(.exception_context) == 0x910, "exception_context size changed")
ASSERT(SIZEOF(.initialize) == 0x28c, "initialize size changed")
ASSERT(SIZEOF(.pfs_repair_id) == 0x25c, "pfs_repair_id size changed")
ASSERT(SIZEOF(.before_exception_context) == 0x4, "before_exception_context size changed")
ASSERT(SIZEOF(.after_initialize_data) == 0xc, "after_initialize_data size changed")
ASSERT(SIZEOF(.initialize_data) == 0x14, "initialize_data size changed")
ASSERT(SIZEOF(.initialize_bss) == 0x4, "initialize_bss size changed")
ASSERT(SIZEOF(.endgame_60adc_60ae0) == 0x4, "endgame_60adc_60ae0 size changed")
ASSERT(SIZEOF(.endgame_625fc_62600) == 0x4, "endgame_625fc_62600 size changed")
ASSERT(SIZEOF(.cpu_interrupt_tables_rodata) == 0x20, "cpu_interrupt_tables_rodata size changed")
ASSERT(SIZEOF(.cpu_interrupt_tables_data) == 0x24, "cpu_interrupt_tables_data size changed")
ASSERT(SIZEOF(.exception_state_data) == 0x14, "exception_state_data size changed")
ASSERT(SIZEOF(.exception_state_bss) == 0x11b0, "exception_state_bss size changed")
ASSERT(SIZEOF(.thread_state_data) == 0x18, "thread_state_data size changed")
ASSERT(SIZEOF(.rcp_interrupt_masks_rodata) == 0x80, "rcp_interrupt_masks_rodata size changed")
ASSERT(SIZEOF(.endgame_data_8fd71_8fd80) == 0xf, "endgame_data_8fd71_8fd80 size changed")
ASSERT(SIZEOF(.endgame_data_8fd94_8fda0) == 0xc, "endgame_data_8fd94_8fda0 size changed")
ASSERT(SIZEOF(.endgame_data_8fdb8_8fdd0) == 0x18, "endgame_data_8fdb8_8fdd0 size changed")
ASSERT(SIZEOF(.endgame_data_96aa4_96ab0) == 0xc, "endgame_data_96aa4_96ab0 size changed")
ASSERT(SIZEOF(.early_actor_counter_decrement) == 0x30, "early_actor_counter_decrement size changed")
ASSERT(SIZEOF(.early_animation_callback) == 0xfc, "early_animation_callback size changed")
ASSERT(SIZEOF(.early_session_animation) == 0x68, "early_session_animation size changed")
ASSERT(SIZEOF(.early_reset_parameter) == 0x3c, "early_reset_parameter size changed")
ASSERT(SIZEOF(.early_reset_parameter_data) == 0xc, "early_reset_parameter_data size changed")
ASSERT(SIZEOF(.endgame_f320_f6e4) == 0x3c4, "endgame_f320_f6e4 size changed")
ASSERT(SIZEOF(.endgame_1109c_13290) == 0x21f4, "endgame_1109c_13290 size changed")
D_800AD1C8 = 0x800AD1C8;
func_8000FBC0 = 0x8000FBC0;
D_800972C0 = 0x800972C0;
D_800972C8 = 0x800972C8;
D_80097318 = 0x80097318;
D_80097328 = 0x80097328;
D_800972F8 = 0x800972F8;
ASSERT(SIZEOF(.early_animation_restart) == 0x84, "early_animation_restart size changed")
ASSERT(SIZEOF(.early_transition_arrays_clear) == 0x8c, "early_transition_arrays_clear size changed")
D_8009AFC0 = 0x8009AFC0;
D_8009F928 = 0x8009F928;
D_800B00A0 = 0x800B00A0;
ASSERT(SIZEOF(.actor_repeat_expire) == 0xc8, "actor_repeat_expire size changed")
ASSERT(SIZEOF(.actor_repeat_delay) == 0xac, "actor_repeat_delay size changed")
ASSERT(SIZEOF(.actor_scene_counter_expire) == 0xc4, "actor_scene_counter_expire size changed")
ASSERT(SIZEOF(.actor_animation_auxiliary) == 0x7c, "actor_animation_auxiliary size changed")
ASSERT(SIZEOF(.actor_child_animation) == 0xa0, "actor_child_animation size changed")
func_8000BEC0 = 0x8000BEC0;
func_8001B8D8 = 0x8001B8D8;
ASSERT(SIZEOF(.early_render_handler_select) == 0x84, "early_render_handler_select size changed")
ASSERT(SIZEOF(.actor_collision_kind_dispatch) == 0x84, "actor_collision_kind_dispatch size changed")
ASSERT(SIZEOF(.name_table_lookup) == 0xa0, "name_table_lookup size changed")
ASSERT(SIZEOF(.session_mode_advance) == 0x84, "session_mode_advance size changed")
ASSERT(SIZEOF(.resource_selection_clear) == 0x84, "resource_selection_clear size changed")
ASSERT(SIZEOF(.early_render_handler_select_rodata) == 0x14, "early_render_handler_select_rodata size changed")
ASSERT(SIZEOF(.actor_collision_kind_dispatch_rodata) == 0x14, "actor_collision_kind_dispatch_rodata size changed")
ASSERT(SIZEOF(.name_table_lookup_data) == 0x26, "name_table_lookup_data size changed")
ASSERT(SIZEOF(.endgame_16f1c_17218) == 0x2fc, "endgame_16f1c_17218 size changed")
ASSERT(SIZEOF(.endgame_1c0f8_1c3d0) == 0x2d8, "endgame_1c0f8_1c3d0 size changed")
ASSERT(SIZEOF(.endgame_data_90f96_92558) == 0x15c2, "endgame_data_90f96_92558 size changed")
D_8007CCC0 = 0x8007CCC0;
ASSERT(SIZEOF(.menu_transition_start) == 0x94, "menu_transition_start size changed")
ASSERT(SIZEOF(.renderer_texture_file_cache) == 0x90, "renderer_texture_file_cache size changed")
ASSERT(SIZEOF(.menu_transition_start_bss) == 0x64, "menu_transition_start_bss size changed")
ASSERT(SIZEOF(.renderer_texture_file_cache_data) == 0x8, "renderer_texture_file_cache_data size changed")
ASSERT(SIZEOF(.renderer_texture_file_cache_bss) == 0x804, "renderer_texture_file_cache_bss size changed")
ASSERT(SIZEOF(.endgame_41568_43430) == 0x1ec8, "endgame_41568_43430 size changed")
D_800AEF00 = 0x800AEF00;
D_8009B1C4 = 0x8009B1C4;
D_8009BF78 = 0x8009BF78;
func_80049E3C = 0x80049E3C;
ASSERT(SIZEOF(.renderer_number_forward) == 0x9c, "renderer_number_forward size changed")
ASSERT(SIZEOF(.renderer_number_reverse) == 0x98, "renderer_number_reverse size changed")
ASSERT(SIZEOF(.actor_position_pair_add) == 0xa8, "actor_position_pair_add size changed")
ASSERT(SIZEOF(.menu_label_assign) == 0xc8, "menu_label_assign size changed")
ASSERT(SIZEOF(.random_between) == 0xc4, "random_between size changed")
ASSERT(SIZEOF(.session_input_initialize) == 0x80, "session_input_initialize size changed")
ASSERT(SIZEOF(.actor_value_transition) == 0xb4, "actor_value_transition size changed")
ASSERT(SIZEOF(.actor_random_spawn) == 0xc0, "actor_random_spawn size changed")
ASSERT(SIZEOF(.actor_position_pair_add_bss) == 0xa0, "actor_position_pair_add_bss size changed")
ASSERT(SIZEOF(.actor_random_spawn_bss) == 0x148, "actor_random_spawn_bss size changed")
ASSERT(SIZEOF(.early_player_input_sample) == 0xd4, "early_player_input_sample size changed")
ASSERT(SIZEOF(.endgame_1af44_1af50) == 0xc, "endgame_1af44_1af50 size changed")
ASSERT(SIZEOF(.endgame_28608_28610) == 0x8, "endgame_28608_28610 size changed")
ASSERT(SIZEOF(.endgame_34574_35d90) == 0x181c, "endgame_34574_35d90 size changed")
ASSERT(SIZEOF(.endgame_4c190_4c7d0) == 0x640, "endgame_4c190_4c7d0 size changed")
D_800AE4F8 = 0x800AE4F8;
D_800BA74C = 0x800BA74C;
D_8008F990 = 0x8008F990;
D_8008F9F4 = 0x8008F9F4;
D_8008FA0C = 0x8008FA0C;
D_800C8DFC = 0x800C8DFC;
D_8007BAC4 = 0x8007BAC4;
D_80138250 = 0x80138250;
D_8013DC30 = 0x8013DC30;
ASSERT(SIZEOF(.actor_relative_geometry) == 0xa8, "actor_relative_geometry size changed")
ASSERT(SIZEOF(.renderer_quad_submit) == 0xf0, "renderer_quad_submit size changed")
ASSERT(SIZEOF(.renderer_texture_defaults) == 0xdc, "renderer_texture_defaults size changed")
ASSERT(SIZEOF(.renderer_metrics_update) == 0xe4, "renderer_metrics_update size changed")
ASSERT(SIZEOF(.actor_dynamic_group_allocate) == 0xb0, "actor_dynamic_group_allocate size changed")
ASSERT(SIZEOF(.actor_dynamic_pair_append) == 0xb8, "actor_dynamic_pair_append size changed")
ASSERT(SIZEOF(.actor_dynamic_parameter_append) == 0xb8, "actor_dynamic_parameter_append size changed")
ASSERT(SIZEOF(.renderer_texture_index_draw) == 0xdc, "renderer_texture_index_draw size changed")
ASSERT(SIZEOF(.actor_behavior_counter_expire) == 0xb8, "actor_behavior_counter_expire size changed")
ASSERT(SIZEOF(.actor_behavior_counter_expire_rodata) == 0x30, "actor_behavior_counter_expire_rodata size changed")
ASSERT(SIZEOF(.endgame_dab8_dac0) == 0x8, "endgame_dab8_dac0 size changed")
ASSERT(SIZEOF(.endgame_4d9b4_4d9c0) == 0xc, "endgame_4d9b4_4d9c0 size changed")
ASSERT(SIZEOF(.endgame_data_90ed4_90f70) == 0x9c, "endgame_data_90ed4_90f70 size changed")
D_80074C08 = 0x80074C08;
D_80074BC4 = 0x80074BC4;
D_8007BB18 = 0x8007BB18;
D_800ACE18 = 0x800ACE18;
D_800ACE1C = 0x800ACE1C;
D_800ACE24 = 0x800ACE24;
D_800ACE2C = 0x800ACE2C;
D_800ACE34 = 0x800ACE34;
D_800ACE40 = 0x800ACE40;
D_800AE2FC = 0x800AE2FC;
D_800AE300 = 0x800AE300;
D_800972BC = 0x800972BC;
D_8008FD90 = 0x8008FD90;
func_800058F0 = 0x800058F0;
func_80005E80 = 0x80005E80;
func_80006654 = 0x80006654;
func_80006C1C = 0x80006C1C;
func_80007180 = 0x80007180;
func_80006240 = 0x80006240;
ASSERT(SIZEOF(.session_background_select) == 0xfc, "session_background_select size changed")
ASSERT(SIZEOF(.scene_definition_byteorder) == 0xdc, "scene_definition_byteorder size changed")
ASSERT(SIZEOF(.early_effect_spawn) == 0xe4, "early_effect_spawn size changed")
ASSERT(SIZEOF(.scene_bonus_spawn) == 0xf4, "scene_bonus_spawn size changed")
ASSERT(SIZEOF(.early_collision_distance) == 0xe0, "early_collision_distance size changed")
ASSERT(SIZEOF(.early_pool_tick) == 0x110, "early_pool_tick size changed")
ASSERT(SIZEOF(.actor_collision_turn) == 0x118, "actor_collision_turn size changed")
ASSERT(SIZEOF(.session_background_select_rodata) == 0x2c, "session_background_select_rodata size changed")
ASSERT(SIZEOF(.early_effect_spawn_rodata) == 0x18, "early_effect_spawn_rodata size changed")
ASSERT(SIZEOF(.endgame_13550_15c20) == 0x26d0, "endgame_13550_15c20 size changed")
ASSERT(SIZEOF(.endgame_data_92560_93698) == 0x1138, "endgame_data_92560_93698 size changed")
D_800AD160 = 0x800AD160;
D_800B23D0 = 0x800B23D0;
D_800B2428 = 0x800B2428;
ASSERT(SIZEOF(.early_parameter_schedule) == 0x13c, "early_parameter_schedule size changed")
ASSERT(SIZEOF(.early_parameter_complete) == 0x130, "early_parameter_complete size changed")
ASSERT(SIZEOF(.save_menu_pak_page_select) == 0xfc, "save_menu_pak_page_select size changed")
ASSERT(SIZEOF(.renderer_tile_origin_mode) == 0xcc, "renderer_tile_origin_mode size changed")
ASSERT(SIZEOF(.fixed_matrix_rsp) == 0x144, "fixed_matrix_rsp size changed")
ASSERT(SIZEOF(.object_history_write) == 0x148, "object_history_write size changed")
ASSERT(SIZEOF(.object_history_write_rodata) == 0x4, "object_history_write_rodata size changed")
ASSERT(SIZEOF(.endgame_273bc_27610) == 0x254, "endgame_273bc_27610 size changed")
ASSERT(SIZEOF(.endgame_2770c_284ac) == 0xda0, "endgame_2770c_284ac size changed")
ASSERT(SIZEOF(.endgame_48d64_48d70) == 0xc, "endgame_48d64_48d70 size changed")
D_8007C970 = 0x8007C970;
D_8013823C = 0x8013823C;
D_80138254 = 0x80138254;
D_8013FE00 = 0x8013FE00;
D_800972D8 = 0x800972D8;
D_8009EFA0 = 0x8009EFA0;
D_800AE304 = 0x800AE304;
D_800AE4F4 = 0x800AE4F4;
D_800972B0 = 0x800972B0;
func_8000E894 = 0x8000E894;
D_80076474 = 0x80076474;
D_800767E0 = 0x800767E0;
D_80076C34 = 0x80076C34;
D_80076C68 = 0x80076C68;
D_80077A94 = 0x80077A94;
D_80077A98 = 0x80077A98;
func_80026178 = 0x80026178;
func_800267BC = 0x800267BC;
ASSERT(SIZEOF(.actor_dynamic_first_append) == 0x98, "actor_dynamic_first_append size changed")
ASSERT(SIZEOF(.early_actor_scale_decay) == 0x128, "early_actor_scale_decay size changed")
ASSERT(SIZEOF(.renderer_cache_flags_clear) == 0x74, "renderer_cache_flags_clear size changed")
ASSERT(SIZEOF(.endgame_4c900_4cc90) == 0x390, "endgame_4c900_4cc90 size changed")
D_8009EF94 = 0x8009EF94;
D_80078274 = 0x80078274;
D_8008D857 = 0x8008D857;
D_801902EC = 0x801902EC;
D_80190200 = 0x80190200;
D_80192810 = 0x80192810;
D_80192818 = 0x80192818;
D_800AD2F8 = 0x800AD2F8;
ASSERT(SIZEOF(.audio_callback_add) == 0x100, "audio_callback_add size changed")
ASSERT(SIZEOF(.audio_callback_remove) == 0x130, "audio_callback_remove size changed")
ASSERT(SIZEOF(.audio_backend_voice_release) == 0x114, "audio_backend_voice_release size changed")
ASSERT(SIZEOF(.actor_collision_health_result) == 0x144, "actor_collision_health_result size changed")
ASSERT(SIZEOF(.audio_callback_add_bss) == 0x8, "audio_callback_add_bss size changed")
ASSERT(SIZEOF(.audio_callback_remove_bss) == 0x8, "audio_callback_remove_bss size changed")
ASSERT(SIZEOF(.audio_backend_voice_release_bss) == 0x4, "audio_backend_voice_release_bss size changed")
D_8019281C = 0x8019281C;
D_80192820 = 0x80192820;
D_8019282C = 0x8019282C;
D_80192830 = 0x80192830;
D_80192834 = 0x80192834;
D_8008F9A8 = 0x8008F9A8;
D_8008F9C0 = 0x8008F9C0;
func_8001C49C = 0x8001C49C;
ASSERT(SIZEOF(.audio_backend_pan_command) == 0x154, "audio_backend_pan_command size changed")
ASSERT(SIZEOF(.audio_backend_patch_trigger) == 0x180, "audio_backend_patch_trigger size changed")
ASSERT(SIZEOF(.actor_dynamic_point_append) == 0x16c, "actor_dynamic_point_append size changed")
ASSERT(SIZEOF(.audio_backend_pan_command_bss) == 0x10, "audio_backend_pan_command_bss size changed")
ASSERT(SIZEOF(.audio_backend_patch_trigger_bss) == 0x14, "audio_backend_patch_trigger_bss size changed")
D_800761F4 = 0x800761F4;
D_8007726C = 0x8007726C;
D_80093828 = 0x80093828;
D_800BAF08 = 0x800BAF08;
D_800BB0E8 = 0x800BB0E8;
D_800BB128 = 0x800BB128;
D_8007D8FC = 0x8007D8FC;
D_800AD318 = 0x800AD318;
D_8009EA18 = 0x8009EA18;
D_8009EE04 = 0x8009EE04;
ASSERT(SIZEOF(.save_menu_pak_name_select) == 0x90, "save_menu_pak_name_select size changed")
ASSERT(SIZEOF(.early_signature_gate) == 0x94, "early_signature_gate size changed")
ASSERT(SIZEOF(.early_resource_arguments) == 0xa0, "early_resource_arguments size changed")
ASSERT(SIZEOF(.early_signature_gate_rodata) == 0x10, "early_signature_gate_rodata size changed")
ASSERT(SIZEOF(.endgame_64f0_69ec) == 0x4fc, "endgame_64f0_69ec size changed")
ASSERT(SIZEOF(.endgame_6a80_ab58) == 0x40d8, "endgame_6a80_ab58 size changed")
ASSERT(SIZEOF(.endgame_f828_f830) == 0x8, "endgame_f828_f830 size changed")
ASSERT(SIZEOF(.endgame_90540_90558) == 0x18, "endgame_90540_90558 size changed")
D_8008D790 = 0x8008D790;
D_8008D794 = 0x8008D794;
D_8008D830 = 0x8008D830;
D_801901E0 = 0x801901E0;
D_80190208 = 0x80190208;
D_80190220 = 0x80190220;
D_8008D838 = 0x8008D838;
ASSERT(SIZEOF(.audio_dma_read) == 0x1d4, "audio_dma_read size changed")
ASSERT(SIZEOF(.audio_dma_recycle) == 0x150, "audio_dma_recycle size changed")
ASSERT(SIZEOF(.audio_dma_read_rodata) == 0xc, "audio_dma_read_rodata size changed")
ASSERT(SIZEOF(.audio_dma_recycle_rodata) == 0xc, "audio_dma_recycle_rodata size changed")
func_80018E1C = 0x80018E1C;
D_800739CC = 0x800739CC;
ASSERT(SIZEOF(.actor_collision_animation) == 0xa0, "actor_collision_animation size changed")
ASSERT(SIZEOF(.actor_collision_score_result) == 0x14c, "actor_collision_score_result size changed")
D_800CD2A0 = 0x800CD2A0;
ASSERT(SIZEOF(.geometry_axis_scale) == 0x1fc, "geometry_axis_scale size changed")
ASSERT(SIZEOF(.geometry_uniform_scale) == 0x1b0, "geometry_uniform_scale size changed")
func_8003614C = 0x8003614C;
ASSERT(SIZEOF(.actor_collision_death_result) == 0x174, "actor_collision_death_result size changed")
ASSERT(SIZEOF(.actor_collision_death_result_rodata) == 0x14, "actor_collision_death_result_rodata size changed")
ASSERT(SIZEOF(.endgame_17f7c_1862c) == 0x6b0, "endgame_17f7c_1862c size changed")
ASSERT(SIZEOF(.endgame_409c4_40c0c) == 0x248, "endgame_409c4_40c0c size changed")
ASSERT(SIZEOF(.endgame_90b1c_90c98) == 0x17c, "endgame_90b1c_90c98 size changed")
D_80073850 = 0x80073850;
D_80073864 = 0x80073864;
D_8009B190 = 0x8009B190;
ASSERT(SIZEOF(.session_selection_lookup) == 0x8c, "session_selection_lookup size changed")
ASSERT(SIZEOF(.early_angle_step) == 0x80, "early_angle_step size changed")
D_800AA708 = 0x800AA708;
D_800ACE58 = 0x800ACE58;
ASSERT(SIZEOF(.scene_actor_mode_list) == 0x174, "scene_actor_mode_list size changed")
ASSERT(SIZEOF(.actor_child_random_motion) == 0x17c, "actor_child_random_motion size changed")
ASSERT(SIZEOF(.actor_collision_separate) == 0x154, "actor_collision_separate size changed")
D_800AC97C = 0x800AC97C;
ASSERT(SIZEOF(.actor_nearest_match) == 0x148, "actor_nearest_match size changed")
ASSERT(SIZEOF(.actor_random_fan) == 0x194, "actor_random_fan size changed")
D_800BB130 = 0x800BB130;
D_800BB134 = 0x800BB134;
D_80073570 = 0x80073570;
D_80097340 = 0x80097340;
D_80097344 = 0x80097344;
D_80097348 = 0x80097348;
D_8009734C = 0x8009734C;
func_8000F030 = 0x8000F030;
ASSERT(SIZEOF(.actor_list_animation_tick) == 0x26c, "actor_list_animation_tick size changed")
ASSERT(SIZEOF(.early_bonus_pattern) == 0x1c8, "early_bonus_pattern size changed")
ASSERT(SIZEOF(.graphics_setup_table) == 0x7c, "graphics_setup_table size changed")
ASSERT(SIZEOF(.endgame_9686c_96890) == 0x24, "endgame_9686c_96890 size changed")
ASSERT(SIZEOF(.actor_position_follow) == 0x90, "actor_position_follow size changed")
ASSERT(SIZEOF(.actor_value_follow) == 0x144, "actor_value_follow size changed")
D_8008D578 = 0x8008D578;
ASSERT(SIZEOF(.endgame_18b9c_198c8) == 0xd2c, "endgame_18b9c_198c8 size changed")
ASSERT(SIZEOF(.endgame_28ad4_28d8c) == 0x2b8, "endgame_28ad4_28d8c size changed")
ASSERT(SIZEOF(.endgame_35e44_35f60) == 0x11c, "endgame_35e44_35f60 size changed")
ASSERT(SIZEOF(.early_parameter_slot_tick) == 0xd8, "early_parameter_slot_tick size changed")
ASSERT(SIZEOF(.actor_group_setup) == 0x220, "actor_group_setup size changed")
func_8000E720 = 0x8000E720;
ASSERT(SIZEOF(.early_actor_follow_owner) == 0x11c, "early_actor_follow_owner size changed")
ASSERT(SIZEOF(.renderer_status_text) == 0x11c, "renderer_status_text size changed")
ASSERT(SIZEOF(.renderer_status_message) == 0x14, "renderer_status_message size changed")
ASSERT(SIZEOF(.endgame_data_960a4_960b0) == 0xc, "endgame_data_960a4_960b0 size changed")
ASSERT(SIZEOF(.early_boundary_actor_spawn) == 0x18c, "early_boundary_actor_spawn size changed")
ASSERT(SIZEOF(.controller_service_setup) == 0x378, "controller_service_setup size changed")
ASSERT(SIZEOF(.endgame_4ff30_500d8) == 0x1a8, "endgame_4ff30_500d8 size changed")
func_800640D0 = 0x800640D0;
ASSERT(SIZEOF(.controller_motor_state_data) == 0x20, "controller_motor_state_data size changed")
ASSERT(SIZEOF(.controller_thread_state_bss) == 0x2208, "controller_thread_state_bss size changed")
ASSERT(SIZEOF(.renderer_textured_submit) == 0x448, "renderer_textured_submit size changed")
ASSERT(SIZEOF(.renderer_textured_submit_strings) == 0x50, "renderer_textured_submit_strings size changed")
ASSERT(SIZEOF(.renderer_texture_corner_state) == 0x10, "renderer_texture_corner_state size changed")
ASSERT(SIZEOF(.renderer_texture_squares) == 0x508, "renderer_texture_squares size changed")
ASSERT(SIZEOF(.renderer_image_quad_ci) == 0x240, "renderer_image_quad_ci size changed")
ASSERT(SIZEOF(.renderer_image_quad_rgba) == 0x240, "renderer_image_quad_rgba size changed")
ASSERT(SIZEOF(.renderer_texture_square_extent) == 0x4, "renderer_texture_square_extent size changed")
ASSERT(SIZEOF(.endgame_4aa3c_4b2b4) == 0x878, "endgame_4aa3c_4b2b4 size changed")
ASSERT(SIZEOF(.endgame_4b8a4_4b964) == 0xc0, "endgame_4b8a4_4b964 size changed")
ASSERT(SIZEOF(.endgame_4bba4_4bc98) == 0xf4, "endgame_4bba4_4bc98 size changed")
ASSERT(SIZEOF(.endgame_4bed8_4bee0) == 0x8, "endgame_4bed8_4bee0 size changed")
ASSERT(SIZEOF(.renderer_expanded_triangle) == 0x2d8, "renderer_expanded_triangle size changed")
ASSERT(SIZEOF(.renderer_expanded_triangle_strings) == 0x28, "renderer_expanded_triangle_strings size changed")
ASSERT(SIZEOF(.endgame_453d0_45718) == 0x348, "endgame_453d0_45718 size changed")
D_800BF90C = 0x800BF90C;
ASSERT(SIZEOF(.audio_engine_parameter_callback_state) == 0xc, "audio_engine_parameter_callback_state size changed")
ASSERT(SIZEOF(.endgame_434c0_43c70) == 0x7b0, "endgame_434c0_43c70 size changed")
ASSERT(SIZEOF(.endgame_43dc0_44530) == 0x770, "endgame_43dc0_44530 size changed")
ASSERT(SIZEOF(.renderer_camera_square) == 0x150, "renderer camera square text size changed")
ASSERT(SIZEOF(.early_pool_scene_reset) == 0x11c, "early pool scene reset text size changed")
ASSERT(SIZEOF(.endgame_33cf8_344cc) == 0x7d4, "endgame_33cf8_344cc size changed")
ASSERT(SIZEOF(.scene_actor_reset_begin) == 0x188, "scene actor reset begin text size changed")
ASSERT(SIZEOF(.scene_menu_string_refresh) == 0x170, "scene menu string refresh text size changed")
ASSERT(SIZEOF(.movie_string_position_submit) == 0x170, "movie_string_position_submit size changed")
ASSERT(SIZEOF(.movie_string_position_submit_constants) == 0x10, "movie_string_position_submit_constants size changed")
ASSERT(SIZEOF(.endgame_237c_3970) == 0x15f4, "endgame_237c_3970 size changed")
ASSERT(SIZEOF(.endgame_data_903a0_90428) == 0x88, "endgame_data_903a0_90428 size changed")
ASSERT(SIZEOF(.endgame_data_90438_90530) == 0xf8, "endgame_data_90438_90530 size changed")
ASSERT(SIZEOF(.model_normal_polygon_dispatch) == 0x348, "model normal polygon dispatch text size changed")
ASSERT(SIZEOF(.scene_menu_string_schedule) == 0x1b0, "scene menu string schedule text size changed")
ASSERT(SIZEOF(.endgame_22c5c_23128) == 0x4cc, "endgame_22c5c_23128 size changed")
ASSERT(SIZEOF(.session_scene_start) == 0x1C0, "session scene start text size changed")
ASSERT(SIZEOF(.endgame_fc30_ff18) == 0x2e8, "endgame_fc30_ff18 size changed")
ASSERT(SIZEOF(.early_scene_animation_advance) == 0x1E8, "early scene animation advance text size changed")
ASSERT(SIZEOF(.save_menu_continue_decode) == 0x230, "continue decoder text size changed")
ASSERT(SIZEOF(.scene_frame_tick) == 0x230, "scene_frame_tick size changed")
ASSERT(SIZEOF(.scene_frame_tick_constants) == 0x8, "scene_frame_tick_constants size changed")
ASSERT(SIZEOF(.early_actor_pair_spawn) == 0x274, "early actor pair text size changed")
ASSERT(SIZEOF(.actor_pickup) == 0x26c, "actor_pickup size changed")
ASSERT(SIZEOF(.actor_pickup_dispatch) == 0x40, "actor_pickup_dispatch size changed")
ASSERT(SIZEOF(.endgame_data_90588_90a04) == 0x47c, "endgame_data_90588_90a04 size changed")
ASSERT(SIZEOF(.endgame_data_90a44_90b08) == 0xc4, "endgame_data_90a44_90b08 size changed")
ASSERT(SIZEOF(.save_menu_continue_character) == 0x4C, "continue character text size changed")
ASSERT(SIZEOF(.object_history_render) == 0x1F8, "object history renderer text size changed")
ASSERT(SIZEOF(.renderer_matrix_submit) == 0x298, "renderer_matrix_submit size changed")
ASSERT(SIZEOF(.renderer_matrix_submit_strings) == 0x40, "renderer_matrix_submit_strings size changed")
ASSERT(SIZEOF(.model_file_relocate) == 0x294, "model_file_relocate size changed")
ASSERT(SIZEOF(.model_file_relocate_strings) == 0x30, "model_file_relocate_strings size changed")
ASSERT(SIZEOF(.endgame_data_95880_95b20) == 0x2a0, "endgame_data_95880_95b20 size changed")
ASSERT(SIZEOF(.audio_voice_defaults) == 0x2CC, "audio voice defaults text size changed")
ASSERT(SIZEOF(.audio_memory_size) == 0x2cc, "audio_memory_size size changed")
ASSERT(SIZEOF(.audio_memory_size_strings) == 0x8, "audio_memory_size_strings size changed")
ASSERT(SIZEOF(.endgame_53c3c_5422c) == 0x5f0, "endgame_53c3c_5422c size changed")
ASSERT(SIZEOF(.endgame_data_968a8_968b0) == 0x8, "endgame_data_968a8_968b0 size changed")
ASSERT(SIZEOF(.endgame_data_968b8_968c4) == 0xc, "endgame_data_968b8_968c4 size changed")
ASSERT(SIZEOF(.collision_dispatch_initialize) == 0x328, "collision_dispatch_initialize size changed")
ASSERT(SIZEOF(.collision_dispatch_initialize_strings) == 0x60, "collision_dispatch_initialize_strings size changed")
ASSERT(SIZEOF(.endgame_19a1c_1aa40) == 0x1024, "endgame_19a1c_1aa40 size changed")
ASSERT(SIZEOF(.endgame_1ad68_1ad70) == 0x8, "endgame_1ad68_1ad70 size changed")
ASSERT(SIZEOF(.endgame_data_90cac_90d3c) == 0x90, "endgame_data_90cac_90d3c size changed")
ASSERT(SIZEOF(.collision_dispatch_initialize_bss) == 0x190, "collision callback table size changed")
func_8001567C = 0x8001567C;
func_80015BF8 = 0x80015BF8;
func_80015F00 = 0x80015F00;
func_8001631C = 0x8001631C;
func_8001669C = 0x8001669C;
func_80016950 = 0x80016950;
func_80016C1C = 0x80016C1C;
func_8001737C = 0x8001737C;
ASSERT(SIZEOF(.renderer_projection_highlight) == 0x2b8, "renderer_projection_highlight size changed")
ASSERT(SIZEOF(.renderer_projection_highlight_constants) == 0x30, "renderer_projection_highlight_constants size changed")
ASSERT(SIZEOF(.endgame_499dc_49d3c) == 0x360, "endgame_499dc_49d3c size changed")
D_8013D958 = 0x8013D958;
ASSERT(SIZEOF(.actor_pool_allocate) == 0x314, "actor_pool_allocate size changed")
ASSERT(SIZEOF(.actor_pool_allocate_strings) == 0x60, "actor_pool_allocate_strings size changed")
ASSERT(SIZEOF(.endgame_292e8_29c20) == 0x938, "endgame_292e8_29c20 size changed")
ASSERT(SIZEOF(.endgame_data_936c4_9450c) == 0xe48, "endgame_data_936c4_9450c size changed")
ASSERT(SIZEOF(.actor_pool_allocate_bss) == 0x60E0, "actor pool size changed")
D_800A4620 = 0x800A4620;
D_800759EC = 0x800759EC;
D_800AF1F0 = 0x800AF1F0;
ASSERT(SIZEOF(.endgame_cac0_d950) == 0xe90, "endgame_cac0_d950 size changed")
ASSERT(SIZEOF(.early_relative_position) == 0xe4, "early_relative_position size changed")
ASSERT(SIZEOF(.actor_contact_gate) == 0x278, "actor_contact_gate size changed")
ASSERT(SIZEOF(.sound_request_dispatch) == 0xb0, "sound_request_dispatch size changed")
ASSERT(SIZEOF(.sound_request_dispatch_strings) == 0x20, "sound_request_dispatch_strings size changed")
ASSERT(SIZEOF(.actor_chain_reset) == 0x3c, "actor_chain_reset size changed")
ASSERT(SIZEOF(.endgame_10414_11060) == 0xc4c, "endgame_10414_11060 size changed")
ASSERT(SIZEOF(.model_hierarchy_transform) == 0x16c, "model_hierarchy_transform size changed")
ASSERT(SIZEOF(.endgame_40080_4022c) == 0x1ac, "endgame_40080_4022c size changed")
ASSERT(SIZEOF(.actor_history_projectile) == 0x1a4, "actor_history_projectile size changed")
ASSERT(SIZEOF(.endgame_4ef64_4f3d4) == 0x470, "endgame_4ef64_4f3d4 size changed")
ASSERT(SIZEOF(.actor_history_flags) == 0x18, "actor_history_flags size changed")
ASSERT(SIZEOF(.endgame_8e0ac_8e0e4) == 0x38, "endgame_8e0ac_8e0e4 size changed")
ASSERT(SIZEOF(.actor_history_points_bss) == 0x1200, "actor_history_points_bss size changed")
ASSERT(SIZEOF(.actor_history_tick) == 0x288, "actor_history_tick size changed")
ASSERT(SIZEOF(.actor_history_tick_constant) == 0x4, "actor_history_tick_constant size changed")
ASSERT(SIZEOF(.object_camera_angles) == 0xa4, "object_camera_angles size changed")
ASSERT(SIZEOF(.camera_fallback_957e8_95848) == 0x60, "camera_fallback_957e8_95848 size changed")
ASSERT(SIZEOF(.object_camera_angles_constant) == 0x4, "object_camera_angles_constant size changed")
ASSERT(SIZEOF(.object_camera_angles_alt) == 0xa0, "object_camera_angles_alt size changed")
ASSERT(SIZEOF(.object_camera_angles_alt_constant) == 0x4, "object_camera_angles_alt_constant size changed")
ASSERT(SIZEOF(.camera_state_data_bss) == 0x78, "camera_state_data BSS size changed")
ASSERT(SIZEOF(.camera_matrix_data_bss) == 0x24, "camera_matrix_data BSS size changed")
ASSERT(SIZEOF(.controller_input) == 0x320, "controller_input size changed")
ASSERT(SIZEOF(.game_float_parse) == 0x174, "game_float_parse size changed")
ASSERT(SIZEOF(.controller_pad_state_bss) == 0x6a, "controller_pad_state BSS size changed")
ASSERT(SIZEOF(.actor_position_submit) == 0xa4, "actor_position_submit size changed")
ASSERT(SIZEOF(.actor_position_submit_constant) == 0x4, "actor_position_submit_constant size changed")
ASSERT(SIZEOF(.save_menu_score_step) == 0xec, "save_menu_score_step size changed")
ASSERT(SIZEOF(.audio_variable_length_size) == 0x80, "audio_variable_length_size size changed")
ASSERT(SIZEOF(.early_input_cursor_data_bss) == 0x4, "early_input_cursor_data BSS size changed")
ASSERT(SIZEOF(.early_input_button_data_bss) == 0x320, "early_input_button_data BSS size changed")
ASSERT(SIZEOF(.early_input_counter_data_bss) == 0x38, "early_input_counter_data BSS size changed")
ASSERT(SIZEOF(.early_input_sequence_data_bss) == 0x188, "early_input_sequence_data BSS size changed")
ASSERT(SIZEOF(.input_stream_fallback_742b8_74648) == 0x390, "input_stream_fallback_742b8_74648 size changed")
ASSERT(SIZEOF(.early_input_fixed_data_data) == 0x40, "early_input_fixed_data_data size changed")
ASSERT(SIZEOF(.audio_timing_data_data) == 0x10, "audio_timing_data_data size changed")
ASSERT(SIZEOF(.input_stream_fallback_8e478_8e640) == 0x1c8, "input_stream_fallback_8e478_8e640 size changed")
ASSERT(SIZEOF(.render_stream_fallback_af88_bc6c) == 0xce4, "render_stream_fallback_af88_bc6c size changed")
ASSERT(SIZEOF(.early_render_quad) == 0x178, "early_render_quad size changed")
ASSERT(SIZEOF(.render_stream_fallback_bde4_c564) == 0x780, "render_stream_fallback_bde4_c564 size changed")
ASSERT(SIZEOF(.renderer_vertex_arena_data_bss) == 0x55f00, "renderer_vertex_arena_data BSS size changed")
ASSERT(SIZEOF(.early_render_color_data_bss) == 0x10, "early_render_color_data BSS size changed")
ASSERT(SIZEOF(.early_render_tube_data) == 0x68, "early_render_tube_data size changed")
ASSERT(SIZEOF(.early_effects_fallback_73d40_742ac) == 0x56c, "early_effects_fallback_73d40_742ac size changed")
ASSERT(SIZEOF(.renderer_image_placement_data) == 0x14, "renderer_image_placement_data size changed")
ASSERT(SIZEOF(.renderer_image_placement_data_bss) == 0xc, "renderer_image_placement_data BSS size changed")
ASSERT(SIZEOF(.early_render_coordinate_data) == 0x4, "early_render_coordinate_data size changed")
ASSERT(SIZEOF(.matrix_transform_fallback_48168_48170) == 0x8, "matrix_transform_fallback_48168_48170 size changed")
ASSERT(SIZEOF(.renderer_matrix_transform) == 0x498, "renderer_matrix_transform size changed")
ASSERT(SIZEOF(.renderer_matrix_transform_strings) == 0x40, "renderer_matrix_transform_strings size changed")
ASSERT(SIZEOF(.renderer_matrix_arena_data_bss) == 0x7d00, "renderer_matrix_arena_data BSS size changed")
ASSERT(SIZEOF(.graphics_rsp_stack_data_bss) == 0x400, "graphics_rsp_stack_data BSS size changed")
ASSERT(SIZEOF(.graphics_rsp_yield_data_bss) == 0xc00, "graphics_rsp_yield_data BSS size changed")
ASSERT(SIZEOF(.renderer_matrix_cursor_data) == 0x4, "renderer_matrix_cursor_data size changed")
ASSERT(SIZEOF(.graphics_buffer_select_data) == 0x8, "graphics_buffer_select_data size changed")
ASSERT(SIZEOF(.matrix_transform_fallback_7e518_8d720) == 0xf208, "matrix_transform_fallback_7e518_8d720 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_messages) == 0x4f0, "renderer_diagnostic_messages size changed")
ASSERT(SIZEOF(.diagnostic_fallback_7e2ac_7e2b0) == 0x4, "diagnostic_fallback_7e2ac_7e2b0 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_version) == 0x20, "renderer_diagnostic_version size changed")
ASSERT(SIZEOF(.diagnostic_fallback_7e2d0_7e4f0) == 0x220, "diagnostic_fallback_7e2d0_7e4f0 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_frame_count) == 0x4, "renderer_diagnostic_frame_count size changed")
ASSERT(SIZEOF(.diagnostic_fallback_8d738_8df60) == 0x828, "diagnostic_fallback_8d738_8df60 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_asset_lengths) == 0xc, "renderer_diagnostic_asset_lengths size changed")
ASSERT(SIZEOF(.diagnostic_fallback_78db8_78de4) == 0x2c, "diagnostic_fallback_78db8_78de4 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_instance_pool) == 0x8, "renderer_diagnostic_instance_pool size changed")
ASSERT(SIZEOF(.diagnostic_fallback_74688_786a0) == 0x4018, "diagnostic_fallback_74688_786a0 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_object_pool) == 0x8, "renderer_diagnostic_object_pool size changed")
ASSERT(SIZEOF(.diagnostic_fallback_786a8_78d50) == 0x6a8, "diagnostic_fallback_786a8_78d50 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_movie_pool) == 0x8, "renderer_diagnostic_movie_pool size changed")
ASSERT(SIZEOF(.diagnostic_fallback_70110_737e0) == 0x36d0, "diagnostic_fallback_70110_737e0 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_path_pool) == 0x8, "renderer_diagnostic_path_pool size changed")
ASSERT(SIZEOF(.diagnostic_fallback_7d994_7d9a0) == 0xc, "diagnostic_fallback_7d994_7d9a0 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_vertex_pool) == 0x8, "renderer_diagnostic_vertex_pool size changed")
ASSERT(SIZEOF(.diagnostic_fallback_7d9a8_7d9b0) == 0x8, "diagnostic_fallback_7d9a8_7d9b0 size changed")
ASSERT(SIZEOF(.diagnostic_fallback_7d9c0_7e2a0) == 0x8e0, "diagnostic_fallback_7d9c0_7e2a0 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_matrix_pool) == 0x8, "renderer_diagnostic_matrix_pool size changed")
ASSERT(SIZEOF(.renderer_diagnostic_hierarchy_pool) == 0x8, "renderer_diagnostic_hierarchy_pool size changed")
ASSERT(SIZEOF(.renderer_diagnostic_frame_metrics_bss) == 0x40, "renderer_diagnostic_frame_metrics BSS size changed")
ASSERT(SIZEOF(.controller_motor_duty) == 0x110, "controller_motor_duty size changed")
ASSERT(SIZEOF(.controller_connection_masks_bss) == 0x2, "controller_connection_masks BSS size changed")
ASSERT(SIZEOF(.controller_paks_bss) == 0x1a0, "controller_paks BSS size changed")
ASSERT(SIZEOF(.controller_file_index_bss) == 0x4, "controller_file_index BSS size changed")
ASSERT(SIZEOF(.controller_motor_command_bss) == 0x8, "controller_motor_command BSS size changed")
ASSERT(SIZEOF(.controller_access_queue_bss) == 0x18, "controller_access_queue BSS size changed")
ASSERT(SIZEOF(.controller_polled_buttons_bss) == 0x2, "controller_polled_buttons BSS size changed")
ASSERT(SIZEOF(.controller_pak_directory_state_bss) == 0x350, "controller_pak_directory_state BSS size changed")
ASSERT(SIZEOF(.controller_access_guard_data) == 0x4, "controller_access_guard_data size changed")
ASSERT(SIZEOF(.controller_fallback_8e108_8e110) == 0x8, "controller_fallback_8e108_8e110 size changed")
ASSERT(SIZEOF(.controller_motor_strength_data) == 0x4, "controller_motor_strength_data size changed")
ASSERT(SIZEOF(.controller_fallback_8e114_8e468) == 0x354, "controller_fallback_8e114_8e468 size changed")
ASSERT(SIZEOF(.controller_fallback_96738_967b0) == 0x78, "controller_fallback_96738_967b0 size changed")
ASSERT(SIZEOF(.controller_motor_initialize_message_data) == 0x14, "controller_motor_initialize_message_data size changed")
ASSERT(SIZEOF(.controller_fallback_967c4_967c8) == 0x4, "controller_fallback_967c4_967c8 size changed")
ASSERT(SIZEOF(.controller_motor_refresh_message_data) == 0x14, "controller_motor_refresh_message_data size changed")
ASSERT(SIZEOF(.controller_fallback_967dc_967f0) == 0x14, "controller_fallback_967dc_967f0 size changed")
ASSERT(SIZEOF(.controller_access_message_bss) == 0x4, "controller_access_message BSS size changed")
ASSERT(SIZEOF(.renderer_opaque_quad) == 0x1c4, "renderer_opaque_quad size changed")
ASSERT(SIZEOF(.renderer_alpha_quad) == 0x1c4, "renderer_alpha_quad size changed")
ASSERT(SIZEOF(.polygon_fallback_45fd8_46114) == 0x13c, "polygon_fallback_45fd8_46114 size changed")
ASSERT(SIZEOF(.renderer_expanded_quad_messages) == 0x28, "renderer_expanded_quad_messages size changed")
ASSERT(SIZEOF(.renderer_polygon_messages) == 0xa0, "renderer_polygon_messages size changed")
ASSERT(SIZEOF(.renderer_mesh_submit) == 0x400, "renderer_mesh_submit size changed")
ASSERT(SIZEOF(.renderer_resource_messages) == 0xb4, "renderer_resource_messages size changed")
ASSERT(SIZEOF(.mesh_resource_fallback_961e4_96240) == 0x5c, "mesh_resource_fallback_961e4_96240 size changed")
ASSERT(SIZEOF(.destination_format) == 0x298, "destination_format size changed")
ASSERT(SIZEOF(.resource_cache_fallback_37268_37270) == 0x8, "resource_cache_fallback_37268_37270 size changed")
ASSERT(SIZEOF(.destination_format_table) == 0x50, "destination_format_table size changed")
ASSERT(SIZEOF(.renderer_model_cache_storage) == 0x1f40, "renderer_model_cache_storage size changed")
ASSERT(SIZEOF(.renderer_animation_cache_storage) == 0x1900, "renderer_animation_cache_storage size changed")
ASSERT(SIZEOF(.resource_cache_fallback_78dec_78e64) == 0x78, "resource_cache_fallback_78dec_78e64 size changed")
ASSERT(SIZEOF(.renderer_resource_map_reset) == 0xc, "renderer_resource_map_reset size changed")
ASSERT(SIZEOF(.resource_cache_fallback_78e70_78e84) == 0x14, "resource_cache_fallback_78e70_78e84 size changed")
ASSERT(SIZEOF(.resource_cache_fallback_7c6c4_7c70c) == 0x48, "resource_cache_fallback_7c6c4_7c70c size changed")
ASSERT(SIZEOF(.renderer_resource_counters) == 0xc, "renderer_resource_counters size changed")
ASSERT(SIZEOF(.resource_cache_fallback_7c718_7cf38) == 0x820, "resource_cache_fallback_7c718_7cf38 size changed")
ASSERT(SIZEOF(.actor_direction_table) == 0x104, "actor_direction_table size changed")
ASSERT(SIZEOF(.actor_child_resources) == 0x3F4, "actor child resources BSS size changed")
ASSERT(SIZEOF(.actor_child_counts) == 0x2C, "actor child counts BSS size changed")
ASSERT(D_800ACB08 == D_800AC998 + 4 * 0x5C, "actor child resource alias changed")
ASSERT(SIZEOF(.actor_direction_fallback_7d03c_7d148) == 0x10c, "actor_direction_fallback_7d03c_7d148 size changed")
ASSERT(SIZEOF(.renderer_resource_identifier_maps_bss) == 0x1770, "renderer identifier maps BSS size changed")
ASSERT(SIZEOF(.renderer_resource_arena_state) == 0xc, "renderer_resource_arena_state size changed")
ASSERT(SIZEOF(.heap_first_block) == 0x4, "heap_first_block size changed")
ASSERT(SIZEOF(.trail_arena_fallback_8df6c_8e080) == 0x114, "trail_arena_fallback_8df6c_8e080 size changed")
ASSERT(SIZEOF(.heap_initializer_flag) == 0x4, "heap_initializer_flag size changed")
ASSERT(SIZEOF(.trail_arena_fallback_8e084_8e094) == 0x10, "trail_arena_fallback_8e084_8e094 size changed")
ASSERT(SIZEOF(.trail_arena_fallback_960c4_960f0) == 0x2c, "trail_arena_fallback_960c4_960f0 size changed")
ASSERT(SIZEOF(.resource_arena_diagnostics) == 0x40, "resource_arena_diagnostics size changed")
ASSERT(SIZEOF(.projection_diagnostic_fallback_4d2dc_4d2e0) == 0x4, "projection_diagnostic_fallback_4d2dc_4d2e0 size changed")
ASSERT(SIZEOF(.renderer_diagnostic_report) == 0x5c4, "renderer_diagnostic_report size changed")
ASSERT(SIZEOF(.projection_diagnostic_fallback_96020_96038) == 0x18, "projection_diagnostic_fallback_96020_96038 size changed")
ASSERT(SIZEOF(.renderer_projection_constants) == 0x30, "renderer_projection_constants size changed")
ASSERT(SIZEOF(.projection_diagnostic_fallback_7e4f4_7e504) == 0x10, "projection_diagnostic_fallback_7e4f4_7e504 size changed")
ASSERT(SIZEOF(.renderer_projection_light_state) == 0x8, "renderer_projection_light_state size changed")
ASSERT(SIZEOF(.projection_diagnostic_fallback_7e50c_7e510) == 0x4, "projection_diagnostic_fallback_7e50c_7e510 size changed")
ASSERT(SIZEOF(.renderer_projection_normalization) == 0x2, "renderer_projection_normalization size changed")
ASSERT(SIZEOF(.renderer_setup_fallback_7d150_7d670) == 0x520, "renderer_setup_fallback_7d150_7d670 size changed")
ASSERT(SIZEOF(.renderer_grid_commands) == 0x58, "renderer_grid_commands size changed")
ASSERT(SIZEOF(.renderer_setup_viewport) == 0x10, "renderer_setup_viewport size changed")
ASSERT(SIZEOF(.renderer_setup_fallback_7d6d8_7d700) == 0x28, "renderer_setup_fallback_7d6d8_7d700 size changed")
ASSERT(SIZEOF(.renderer_setup_lighting) == 0x18, "renderer_setup_lighting size changed")
ASSERT(SIZEOF(.renderer_frame_geometry_commands) == 0x40, "renderer_frame_geometry_commands size changed")
ASSERT(SIZEOF(.renderer_frame_rdp_commands) == 0x80, "renderer_frame_rdp_commands size changed")
ASSERT(SIZEOF(.renderer_setup_fallback_7d7d8_7d98c) == 0x1b4, "renderer_setup_fallback_7d7d8_7d98c size changed")
ASSERT(SIZEOF(.tweak_variables) == 0x4b0, "tweak_variables size changed")
ASSERT(SIZEOF(.tweak_pages) == 0x78, "tweak_pages size changed")
ASSERT(SIZEOF(.tweak_difficulties) == 0x168, "tweak_difficulties size changed")
ASSERT(SIZEOF(.tweak_counters) == 0xa, "tweak_counters size changed")
ASSERT(SIZEOF(.tweak_display_state) == 0x4, "tweak_display_state size changed")
ASSERT(SIZEOF(.tweak_messages) == 0xe8, "tweak_messages size changed")
ASSERT(SIZEOF(.tweak_fallback_95038_957e0) == 0x7a8, "tweak_fallback_95038_957e0 size changed")
ASSERT(SIZEOF(.tweak_difficulty_define) == 0xd4, "tweak_difficulty_define size changed")
ASSERT(SIZEOF(.tweak_scene_define) == 0xd0, "tweak_scene_define size changed")
ASSERT(SIZEOF(.actor_behavior_duration) == 0x3f0, "actor_behavior_duration size changed")
ASSERT(SIZEOF(.actor_behavior_brain) == 0x3dc, "actor_behavior_brain size changed")
ASSERT(SIZEOF(.actor_behavior_hulk) == 0x400, "actor_behavior_hulk size changed")
ASSERT(SIZEOF(.actor_behavior_hulk_switch) == 0x28, "actor_behavior_hulk_switch size changed")
ASSERT(SIZEOF(.actor_behavior_diagnostic) == 0x1c, "actor_behavior_diagnostic size changed")
ASSERT(SIZEOF(.actor_behavior_spawn_state) == 0x544, "actor_behavior_spawn_state size changed")
ASSERT(SIZEOF(.actor_behavior_spawn_callback) == 0x3c0, "actor_behavior_spawn_callback size changed")
ASSERT(SIZEOF(.actor_create) == 0x3e0, "actor_create size changed")
ASSERT(SIZEOF(.lifecycle_fallback_90d9c_90e1c) == 0x80, "lifecycle_fallback_90d9c_90e1c size changed")
ASSERT(SIZEOF(.actor_create_switch) == 0x88, "actor_create_switch size changed")
ASSERT(SIZEOF(.actor_behavior_pursuit) == 0x4b0, "actor_behavior_pursuit size changed")
ASSERT(SIZEOF(.actor_behavior_pursuit_switch) == 0x24, "actor_behavior_pursuit_switch size changed")
ASSERT(SIZEOF(.lifecycle_fallback_9468c_94c84) == 0x5f8, "lifecycle_fallback_9468c_94c84 size changed")
ASSERT(SIZEOF(.actor_behavior_enforcer) == 0x69c, "actor_behavior_enforcer size changed")
ASSERT(SIZEOF(.actor_behavior_enforcer_switch) == 0x24, "actor_behavior_enforcer_switch size changed")
ASSERT(SIZEOF(.actor_brain_diagnostic) == 0x18, "actor_brain_diagnostic size changed")
ASSERT(SIZEOF(.lifecycle_fallback_945bc_945c0) == 0x4, "lifecycle_fallback_945bc_945c0 size changed")
ASSERT(SIZEOF(.actor_behavior_human) == 0x724, "actor_behavior_human size changed")
ASSERT(SIZEOF(.actor_human_diagnostic) == 0x1c, "actor_human_diagnostic size changed")
ASSERT(SIZEOF(.actor_behavior_stride) == 0x7cc, "actor_behavior_stride size changed")
ASSERT(SIZEOF(.actor_behavior_stride_switch) == 0x24, "actor_behavior_stride_switch size changed")
ASSERT(SIZEOF(.actor_retirement) == 0x800, "actor_retirement size changed")
ASSERT(SIZEOF(.actor_retirement_switch) == 0x24, "actor_retirement_switch size changed")
ASSERT(SIZEOF(.retirement_fallback_94eb8_94ec0) == 0x8, "retirement_fallback_94eb8_94ec0 size changed")
ASSERT(SIZEOF(.actor_manual_motion) == 0x228, "actor_manual_motion size changed")
ASSERT(SIZEOF(.retirement_fallback_94d8c_94e44) == 0xb8, "retirement_fallback_94d8c_94e44 size changed")
ASSERT(SIZEOF(.actor_manual_motion_diagnostic) == 0x10, "actor_manual_motion_diagnostic size changed")
ASSERT(SIZEOF(.retirement_fallback_94e54_94e94) == 0x40, "retirement_fallback_94e54_94e94 size changed")
ASSERT(SIZEOF(.actor_fragment_spawn) == 0x2c8, "actor_fragment_spawn size changed")
ASSERT(SIZEOF(.actor_scatter_spawn) == 0x300, "actor_scatter_spawn size changed")
ASSERT(SIZEOF(.command_script_execute) == 0x160, "command_script_execute size changed")
ASSERT(SIZEOF(.effect_config_fallback_737f0_73800) == 0x10, "effect_config_fallback_737f0_73800 size changed")
ASSERT(SIZEOF(.effect_draw_config) == 0x4d8, "effect_draw_config size changed")
ASSERT(SIZEOF(.script_diagnostic_fallback_94cb4_94d10) == 0x5c, "script_diagnostic_fallback_94cb4_94d10 size changed")
ASSERT(SIZEOF(.command_script_diagnostics) == 0x24, "command_script_diagnostics size changed")
ASSERT(SIZEOF(.script_diagnostic_fallback_94d34_94d6c) == 0x38, "script_diagnostic_fallback_94d34_94d6c size changed")
ASSERT(SIZEOF(.palette_fade_update) == 0x47c, "palette_fade_update size changed")
ASSERT(SIZEOF(.palette_fallback_32728_32810) == 0xe8, "palette_fallback_32728_32810 size changed")
ASSERT(SIZEOF(.palette_base_storage) == 0x400, "palette_base_storage BSS size changed")
ASSERT(SIZEOF(.palette_transition_storage) == 0x1450, "palette_transition_storage BSS size changed")
ASSERT(SIZEOF(.palette_fade_color) == 0x4, "palette_fade_color BSS size changed")
ASSERT(SIZEOF(.palette_fade_progress) == 0x4, "palette_fade_progress BSS size changed")
ASSERT(SIZEOF(.palette_fade_step) == 0x4, "palette_fade_step BSS size changed")
ASSERT(SIZEOF(.actor_effect_draw) == 0x2b4, "actor_effect_draw size changed")
ASSERT(SIZEOF(.object_record_storage) == 0x8ca0, "object_record_storage size changed")
ASSERT(SIZEOF(.object_slot_storage) == 0x4b0, "object_slot_storage size changed")
ASSERT(SIZEOF(.renderer_matrix_scale) == 0x380, "renderer_matrix_scale size changed")
ASSERT(SIZEOF(.renderer_supplied_matrix_diagnostics) == 0x40, "renderer_supplied_matrix_diagnostics size changed")
