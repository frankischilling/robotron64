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
func_8003921C = 0x8003921C;
func_8003947C = 0x8003947C;

D_8008F64C = 0x8008F64C;

func_800392F4 = 0x800392F4;

D_8009EFA4 = 0x8009EFA4;

func_80000F48 = 0x80000F48;
func_8003B7FC = 0x8003B7FC;


D_800BF918 = 0x800BF918;
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
    .cpu_fallback 0x8000177C : AT(0x237C) { build/us/fallback.o(.rom_cpu_fallback) }
    .movie_reset 0x80002EE0 : AT(0x3AE0) SUBALIGN(4) { build/us/movie_reset.o(.text) }
    .movie_parameters 0x80002F28 : AT(0x3B28) SUBALIGN(4) { build/us/movie_parameters.o(.text) }
    .movie_commands 0x80003040 : AT(0x3C40) SUBALIGN(4) { build/us/movie_commands.o(.text) }
    .movie_channels 0x800037F8 : AT(0x43F8) SUBALIGN(4) { build/us/movie_channels.o(.text) }
    .movie_files 0x80003A7C : AT(0x467C) SUBALIGN(4) { build/us/movie_files.o(.text) }
    .movie_track_release 0x80003D74 : AT(0x4974) SUBALIGN(4) { build/us/movie_track_release.o(.text) }
    .cpu_after_movie_track_release 0x80003ECC : AT(0x4ACC) { build/us/fallback.o(.rom_cpu_after_movie_track_release) }
    .movie_sample 0x80004098 : AT(0x4C98) SUBALIGN(4) { build/us/movie_sample.o(.text) }
    .cpu_after_movie_sample 0x80004258 : AT(0x4E58) { build/us/fallback.o(.rom_cpu_after_movie_sample) }
    .movie_callback 0x8000440C : AT(0x500C) SUBALIGN(4) { build/us/movie_callback.o(.text) }
    .movie_prepare 0x800044AC : AT(0x50AC) SUBALIGN(4) { build/us/movie_prepare.o(.text) }
    .movie_start 0x800045E4 : AT(0x51E4) SUBALIGN(4) { build/us/movie_start.o(.text) }
    .cpu_after_movie_start 0x80004C3C : AT(0x583C) { build/us/fallback.o(.rom_cpu_after_movie_start) }
    .movie_status 0x80005354 : AT(0x5F54) SUBALIGN(4) { build/us/movie_status.o(.text) }
    .movie_cleanup 0x8000544C : AT(0x604C) SUBALIGN(4) { build/us/movie_cleanup.o(.text) }
    .cpu_after_movie_cleanup 0x80005560 : AT(0x6160) { build/us/fallback.o(.rom_cpu_after_movie_cleanup) }
    .script_service_cache_reset 0x8001C740 : AT(0x1D340) SUBALIGN(4) { build/us/script_service_cache_reset.o(.text) }
    .script_service_files 0x8001C790 : AT(0x1D390) SUBALIGN(4) { build/us/script_service_files.o(.text) }
    .script_service_cache_access 0x8001C8C4 : AT(0x1D4C4) SUBALIGN(4) { build/us/script_service_cache_access.o(.text) }
    .cpu_after_script_service_cache_access 0x8001CB48 : AT(0x1D748) { build/us/fallback.o(.rom_cpu_after_script_service_cache_access) }
    .script_service_commands 0x8001CB50 : AT(0x1D750) SUBALIGN(4) { build/us/script_service_commands.o(.text) }
    .cpu_after_script_service_commands 0x8001CD94 : AT(0x1D994) { build/us/fallback.o(.rom_cpu_after_script_service_commands) }
    .script_service_platform_stub 0x8001CE68 : AT(0x1DA68) SUBALIGN(4) { build/us/script_service_platform_stub.o(.text) }
    .cpu_after_script_service_platform_stub 0x8001CE70 : AT(0x1DA70) { build/us/fallback.o(.rom_cpu_after_script_service_platform_stub) }
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
    .cpu_after_scene_background 0x8001FCE4 : AT(0x208E4) { build/us/fallback.o(.rom_cpu_after_scene_background) }
    .actor_motion_mode 0x80027B9C : AT(0x2879C) SUBALIGN(4) { build/us/actor_motion_mode.o(.text) }
    .cpu_after_actor_motion_mode 0x80027CE4 : AT(0x288E4) { build/us/fallback.o(.rom_cpu_after_actor_motion_mode) }
    .actor_pool_reset 0x8002818C : AT(0x28D8C) SUBALIGN(4) { build/us/actor_pool_reset.o(.text) }
    .actor_cleanup 0x800281C4 : AT(0x28DC4) SUBALIGN(4) { build/us/actor_cleanup.o(.text) }
    .actor_remove 0x80028274 : AT(0x28E74) SUBALIGN(4) { build/us/actor_remove.o(.text) }
    .actor_sweep 0x8002836C : AT(0x28F6C) SUBALIGN(4) { build/us/actor_sweep.o(.text) }
    .cpu_after_actor_sweep 0x800283D4 : AT(0x28FD4) { build/us/fallback.o(.rom_cpu_after_actor_sweep) }
    .actor_behavior_state 0x8002A3E8 : AT(0x2AFE8) SUBALIGN(4) { build/us/actor_behavior_state.o(.text) }
    .actor_behavior_blend_velocity 0x8002A414 : AT(0x2B014) SUBALIGN(4) { build/us/actor_behavior_blend_velocity.o(.text) }
    .actor_behavior_blend_motion 0x8002A5DC : AT(0x2B1DC) SUBALIGN(4) { build/us/actor_behavior_blend_motion.o(.text) }
    .cpu_after_actor_behavior_blend_motion 0x8002A808 : AT(0x2B408) { build/us/fallback.o(.rom_cpu_after_actor_behavior_blend_motion) }
    .actor_behavior_height 0x8002B31C : AT(0x2BF1C) SUBALIGN(4) { build/us/actor_behavior_height.o(.text) }
    .actor_behavior_extra_b32c 0x8002B32C : AT(0x2BF2C) SUBALIGN(4) { build/us/actor_behavior_extra_b32c.o(.text) }
    .actor_behavior_noop_b570 0x8002B570 : AT(0x2C170) SUBALIGN(4) { build/us/actor_behavior_noop_b570.o(.text) }
    .actor_behavior_extra_b57c 0x8002B57C : AT(0x2C17C) SUBALIGN(4) { build/us/actor_behavior_extra_b57c.o(.text) }
    .actor_behavior_noop_b7a4 0x8002B7A4 : AT(0x2C3A4) SUBALIGN(4) { build/us/actor_behavior_noop_b7a4.o(.text) }
    .actor_behavior_noop_b7b0 0x8002B7B0 : AT(0x2C3B0) SUBALIGN(4) { build/us/actor_behavior_noop_b7b0.o(.text) }
    .cpu_after_actor_behavior_noop_b7b0 0x8002B7BC : AT(0x2C3BC) { build/us/fallback.o(.rom_cpu_after_actor_behavior_noop_b7b0) }
    .actor_behavior_repeat 0x8002BF88 : AT(0x2CB88) SUBALIGN(4) { build/us/actor_behavior_repeat.o(.text) }
    .cpu_after_actor_behavior_repeat 0x8002C0AC : AT(0x2CCAC) { build/us/fallback.o(.rom_cpu_after_actor_behavior_repeat) }
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
    .cpu_after_session_setup_bitmap 0x8002F29C : AT(0x2FE9C) { build/us/fallback.o(.rom_cpu_after_session_setup_bitmap) }
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
    .cpu_after_save_file_write 0x800305F8 : AT(0x311F8) { build/us/fallback.o(.rom_cpu_after_save_file_write) }
    .save_menu_slot_write 0x80030798 : AT(0x31398) SUBALIGN(4) { build/us/save_menu_slot_write.o(.text) }
    .save_menu_cancel 0x800308AC : AT(0x314AC) SUBALIGN(4) { build/us/save_menu_cancel.o(.text) }
    .save_menu_slot_prompt 0x800308E8 : AT(0x314E8) SUBALIGN(4) { build/us/save_menu_slot_prompt.o(.text) }
    .save_menu_slot_callback 0x800309D0 : AT(0x315D0) SUBALIGN(4) { build/us/save_menu_slot_callback.o(.text) }
    .save_menu_open 0x80030A3C : AT(0x3163C) SUBALIGN(4) { build/us/save_menu_open.o(.text) }
    .save_menu_status 0x80030A80 : AT(0x31680) SUBALIGN(4) { build/us/save_menu_status.o(.text) }
    .cpu_after_save_menu_status 0x80030DC0 : AT(0x319C0) { build/us/fallback.o(.rom_cpu_after_save_menu_status) }
    .save_menu_audio_index 0x80030EAC : AT(0x31AAC) SUBALIGN(4) { build/us/save_menu_audio_index.o(.text) }
    .save_menu_sound_preview 0x80030F20 : AT(0x31B20) SUBALIGN(4) { build/us/save_menu_sound_preview.o(.text) }
    .save_menu_audio_apply 0x80030F50 : AT(0x31B50) SUBALIGN(4) { build/us/save_menu_audio_apply.o(.text) }
    .save_menu_audio_secondary 0x80030F94 : AT(0x31B94) SUBALIGN(4) { build/us/save_menu_audio_secondary.o(.text) }
    .save_menu_write_return 0x80030FB8 : AT(0x31BB8) SUBALIGN(4) { build/us/save_menu_write_return.o(.text) }
    .cpu_after_save_menu_write_return 0x80030FEC : AT(0x31BEC) { build/us/fallback.o(.rom_cpu_after_save_menu_write_return) }
    .save_menu_palette_index 0x80031420 : AT(0x32020) SUBALIGN(4) { build/us/save_menu_palette_index.o(.text) }
    .scene_palette_load 0x800314FC : AT(0x320FC) SUBALIGN(4) { build/us/scene_palette_load.o(.text) }
    .palette_fade_controls 0x80031564 : AT(0x32164) SUBALIGN(4) { build/us/palette_fade_controls.o(.text) }
    .cpu_after_palette_fade_controls 0x800316AC : AT(0x322AC) { build/us/fallback.o(.rom_cpu_after_palette_fade_controls) }
    .palette_transition_reset 0x80031C10 : AT(0x32810) SUBALIGN(4) { build/us/palette_transition_reset.o(.text) }
    .palette_transition_range 0x80031C44 : AT(0x32844) SUBALIGN(4) { build/us/palette_transition_range.o(.text) }
    .cpu_after_palette_transition_range 0x80031ECC : AT(0x32ACC) { build/us/fallback.o(.rom_cpu_after_palette_transition_range) }
    .palette_commands 0x8003237C : AT(0x32F7C) SUBALIGN(4) { build/us/palette_commands.o(.text) }
    .cpu_after_palette_commands 0x80032534 : AT(0x33134) { build/us/fallback.o(.rom_cpu_after_palette_commands) }
    .command_enable 0x80032540 : AT(0x33140) SUBALIGN(4) { build/us/command_enable.o(.text) }
    .game_number_convert 0x80032550 : AT(0x33150) SUBALIGN(4) { build/us/game_number_convert.o(.text) }
    .cpu_after_game_number_convert 0x8003264C : AT(0x3324C) { build/us/fallback.o(.rom_cpu_after_game_number_convert) }
    .command_machine 0x800327AC : AT(0x333AC) SUBALIGN(4) { build/us/command_machine.o(.text) }
    .cpu_after_command_machine 0x8003282C : AT(0x3342C) { build/us/fallback.o(.rom_cpu_after_command_machine) }
    .sound_bridge_core 0x80036064 : AT(0x36C64) SUBALIGN(4) { build/us/sound_bridge_core.o(.text) }
    .cpu_after_sound_bridge_core 0x800360E8 : AT(0x36CE8) { build/us/fallback.o(.rom_cpu_after_sound_bridge_core) }
    .sound_bridge_definitions 0x800360F0 : AT(0x36CF0) SUBALIGN(4) { build/us/sound_bridge_definitions.o(.text) }
    .cpu_after_sound_bridge_definitions 0x8003614C : AT(0x36D4C) { build/us/fallback.o(.rom_cpu_after_sound_bridge_definitions) }
    .sound_bridge_future_reset 0x800361FC : AT(0x36DFC) SUBALIGN(4) { build/us/sound_bridge_future_reset.o(.text) }
    .sound_bridge_future_queue 0x80036288 : AT(0x36E88) SUBALIGN(4) { build/us/sound_bridge_future_queue.o(.text) }
    .sound_bridge_future_update 0x80036318 : AT(0x36F18) SUBALIGN(4) { build/us/sound_bridge_future_update.o(.text) }
    .cpu_after_sound_bridge_future_update 0x800363D0 : AT(0x36FD0) { build/us/fallback.o(.rom_cpu_after_sound_bridge_future_update) }
    .debug_context_set 0x80037408 : AT(0x38008) SUBALIGN(4) { build/us/debug_context_set.o(.text) }
    .cpu_after_debug_context_set 0x80037418 : AT(0x38018) { build/us/fallback.o(.rom_cpu_after_debug_context_set) }
    .debug_text_draw 0x80037420 : AT(0x38020) SUBALIGN(4) { build/us/debug_text_draw.o(.text) }
    .cpu_after_debug_text_draw 0x800374C8 : AT(0x380C8) { build/us/fallback.o(.rom_cpu_after_debug_text_draw) }
    .tweak_reset 0x800374D0 : AT(0x380D0) SUBALIGN(4) { build/us/tweak_reset.o(.text) }
    .tweak_page 0x80037508 : AT(0x38108) SUBALIGN(4) { build/us/tweak_page.o(.text) }
    .tweak_define 0x80037588 : AT(0x38188) SUBALIGN(4) { build/us/tweak_define.o(.text) }
    .cpu_after_tweak_define 0x8003762C : AT(0x3822C) { build/us/fallback.o(.rom_cpu_after_tweak_define) }
    .tweak_difficulty_apply 0x80037700 : AT(0x38300) SUBALIGN(4) { build/us/tweak_difficulty_apply.o(.text) }
    .cpu_after_tweak_difficulty_apply 0x800377E4 : AT(0x383E4) { build/us/fallback.o(.rom_cpu_after_tweak_difficulty_apply) }
    .tweak_bind 0x8003799C : AT(0x3859C) SUBALIGN(4) { build/us/tweak_bind.o(.text) }
    .tweak_bind_all 0x80037A20 : AT(0x38620) SUBALIGN(4) { build/us/tweak_bind_all.o(.text) }
    .tweak_scale_enemy_speeds 0x80038228 : AT(0x38E28) SUBALIGN(4) { build/us/tweak_scale_enemy_speeds.o(.text) }
    .resource_string_reset 0x80038390 : AT(0x38F90) SUBALIGN(4) { build/us/resource_string_reset.o(.text) }
    .string_resource 0x800383C4 : AT(0x38FC4) SUBALIGN(4) { build/us/string_resource.o(.text) }
    .resource_string_find 0x800383F8 : AT(0x38FF8) SUBALIGN(4) { build/us/resource_string_find.o(.text) }
    .resource_string_load 0x80038498 : AT(0x39098) SUBALIGN(4) { build/us/resource_string_load.o(.text) }
    .cpu_after_resource_string_load 0x8003856C : AT(0x3916C) { build/us/fallback.o(.rom_cpu_after_resource_string_load) }
    .object_transforms 0x800394C0 : AT(0x3A0C0) { build/us/object_transforms.o(.text) }
    .object_helpers 0x80039C78 : AT(0x3A878) SUBALIGN(4) { build/us/object_helpers.o(.text) }
    .object_helpers_index_limit 0x80039CD0 : AT(0x3A8D0) SUBALIGN(4) { build/us/object_helpers_index_limit.o(.text) }
    .object_helpers_index_set 0x80039D4C : AT(0x3A94C) SUBALIGN(4) { build/us/object_helpers_index_set.o(.text) }
    .object_helpers_properties 0x80039DAC : AT(0x3A9AC) SUBALIGN(4) { build/us/object_helpers_properties.o(.text) }
    .object_helpers_camera_state 0x80039EA0 : AT(0x3AAA0) SUBALIGN(4) { build/us/object_helpers_camera_state.o(.text) }
    .object_helpers_camera_position 0x80039F10 : AT(0x3AB10) SUBALIGN(4) { build/us/object_helpers_camera_position.o(.text) }
    .cpu_after_object_helpers_camera_position 0x80039FCC : AT(0x3ABCC) { build/us/fallback.o(.rom_cpu_after_object_helpers_camera_position) }
    .object_helpers_camera_position_alt 0x8003A070 : AT(0x3AC70) SUBALIGN(4) { build/us/object_helpers_camera_position_alt.o(.text) }
    .cpu_after_object_helpers_camera_position_alt 0x8003A128 : AT(0x3AD28) { build/us/fallback.o(.rom_cpu_after_object_helpers_camera_position_alt) }
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
    .cpu_after_game_memory 0x8003B734 : AT(0x3C334) { build/us/fallback.o(.rom_cpu_after_game_memory) }
    .game_string_case_compare 0x8003B768 : AT(0x3C368) SUBALIGN(4) { build/us/game_string_case_compare.o(.text) }
    .cpu_after_game_string_case_compare 0x8003B7FC : AT(0x3C3FC) { build/us/fallback.o(.rom_cpu_after_game_string_case_compare) }
    .game_number_format 0x8003B928 : AT(0x3C528) SUBALIGN(4) { build/us/game_number_format.o(.text) }
    .game_character 0x8003BBAC : AT(0x3C7AC) SUBALIGN(4) { build/us/game_character.o(.text) }
    .game_integer_parse 0x8003BD4C : AT(0x3C94C) SUBALIGN(4) { build/us/game_integer_parse.o(.text) }
    .cpu_after_game_integer_parse 0x8003BDE8 : AT(0x3C9E8) { build/us/fallback.o(.rom_cpu_after_game_integer_parse) }
    .platform_empty 0x8003BF5C : AT(0x3CB5C) SUBALIGN(4) { build/us/platform_empty.o(.text) }
    .palette 0x8003BFEC : AT(0x3CBEC) SUBALIGN(4) { build/us/palette.o(.text) }
    .controller_button 0x8003C180 : AT(0x3CD80) SUBALIGN(4) { build/us/controller_button.o(.text) }
    .cpu_after_controller_button 0x8003C1A8 : AT(0x3CDA8) { build/us/fallback.o(.rom_cpu_after_controller_button) }
    .controller_axes 0x8003C4C8 : AT(0x3D0C8) SUBALIGN(4) { build/us/controller_axes.o(.text) }
    .platform_io 0x8003C5C4 : AT(0x3D1C4) SUBALIGN(4) { build/us/platform_io.o(.text) }
    .cpu_after_platform_io 0x8003C6B8 : AT(0x3D2B8) { build/us/fallback.o(.rom_cpu_after_platform_io) }
    .object_recovery_path_extension 0x8003CBEC : AT(0x3D7EC) SUBALIGN(4) { build/us/object_recovery_path_extension.o(.text) }
    .geometry_debug_bridge 0x8003CC30 : AT(0x3D830) SUBALIGN(4) { build/us/geometry_debug_bridge.o(.text) }
    .object_recovery_fixed_trig 0x8003CC58 : AT(0x3D858) SUBALIGN(4) { build/us/object_recovery_fixed_trig.o(.text) }
    .object_recovery_integer_sqrt 0x8003CCE8 : AT(0x3D8E8) SUBALIGN(4) { build/us/object_recovery_integer_sqrt.o(.text) }
    .object_recovery_angle_scale 0x8003CD4C : AT(0x3D94C) SUBALIGN(4) { build/us/object_recovery_angle_scale.o(.text) }
    .object_recovery_direction_angle 0x8003CD70 : AT(0x3D970) SUBALIGN(4) { build/us/object_recovery_direction_angle.o(.text) }
    .object_recovery_angle_table 0x8003CEF4 : AT(0x3DAF4) SUBALIGN(4) { build/us/object_recovery_angle_table.o(.text) }
    .cpu_after_object_recovery_angle_table 0x8003CF88 : AT(0x3DB88) { build/us/fallback.o(.rom_cpu_after_object_recovery_angle_table) }
    .geometry_bridge_apply 0x8003D170 : AT(0x3DD70) SUBALIGN(4) { build/us/geometry_bridge_apply.o(.text) }
    .geometry_bridge_rotate 0x8003D20C : AT(0x3DE0C) SUBALIGN(4) { build/us/geometry_bridge_rotate.o(.text) }
    .cpu_after_geometry_bridge_rotate 0x8003D2C0 : AT(0x3DEC0) { build/us/fallback.o(.rom_cpu_after_geometry_bridge_rotate) }
    .renderer_vertex_attributes 0x80043930 : AT(0x44530) SUBALIGN(4) { build/us/renderer_vertex_attributes.o(.text) }
    .renderer_material_texture 0x80043D68 : AT(0x44968) SUBALIGN(4) { build/us/renderer_material_texture.o(.text) }
    .renderer_material_light 0x80043E80 : AT(0x44A80) SUBALIGN(4) { build/us/renderer_material_light.o(.text) }
    .renderer_material_combined 0x80043EEC : AT(0x44AEC) SUBALIGN(4) { build/us/renderer_material_combined.o(.text) }
    .renderer_light_select 0x8004417C : AT(0x44D7C) SUBALIGN(4) { build/us/renderer_light_select.o(.text) }
    .renderer_material_untextured 0x800441D0 : AT(0x44DD0) SUBALIGN(4) { build/us/renderer_material_untextured.o(.text) }
    .cpu_after_renderer_material_untextured 0x80044270 : AT(0x44E70) { build/us/fallback.o(.rom_cpu_after_renderer_material_untextured) }
    .renderer_material_reset 0x80045514 : AT(0x46114) SUBALIGN(4) { build/us/renderer_material_reset.o(.text) }
    .cpu_after_renderer_material_reset 0x80045534 : AT(0x46134) { build/us/fallback.o(.rom_cpu_after_renderer_material_reset) }
    .renderer_vertex_copy 0x80045F40 : AT(0x46B40) SUBALIGN(4) { build/us/renderer_vertex_copy.o(.text) }
    .renderer_texture_load 0x800462DC : AT(0x46EDC) SUBALIGN(4) { build/us/renderer_texture_load.o(.text) }
    .graphics_display_list 0x800464F4 : AT(0x470F4) SUBALIGN(4) { build/us/graphics_display_list.o(.text) }
    .graphics_resource 0x8004653C : AT(0x4713C) SUBALIGN(4) { build/us/graphics_resource.o(.text) }
    .cpu_after_graphics_resource 0x800465AC : AT(0x471AC) { build/us/fallback.o(.rom_cpu_after_graphics_resource) }
    .palette_tint 0x800465B0 : AT(0x471B0) SUBALIGN(4) { build/us/palette_tint.o(.text) }
    .graphics_modes 0x80046608 : AT(0x47208) SUBALIGN(4) { build/us/graphics_modes.o(.text) }
    .cpu_after_graphics_modes 0x80046C2C : AT(0x4782C) { build/us/fallback.o(.rom_cpu_after_graphics_modes) }
    .graphics_lights 0x80046CF8 : AT(0x478F8) SUBALIGN(4) { build/us/graphics_lights.o(.text) }
    .graphics_pool 0x80046F50 : AT(0x47B50) SUBALIGN(4) { build/us/graphics_pool.o(.text) }
    .cpu_after_graphics_pool 0x800470F4 : AT(0x47CF4) { build/us/fallback.o(.rom_cpu_after_graphics_pool) }
    .graphics_frame_reset 0x8004717C : AT(0x47D7C) SUBALIGN(4) { build/us/graphics_frame_reset.o(.text) }
    .graphics_mode_dispatch 0x8004729C : AT(0x47E9C) SUBALIGN(4) { build/us/graphics_mode_dispatch.o(.text) }
    .graphics_environment 0x800474B8 : AT(0x480B8) SUBALIGN(4) { build/us/graphics_environment.o(.text) }
    .cpu_after_graphics_environment 0x80047568 : AT(0x48168) { build/us/fallback.o(.rom_cpu_after_graphics_environment) }
    .startup 0x80048170 : AT(0x48D70) SUBALIGN(16) { build/us/startup.o(.text) }
    .cpu_after_startup 0x80048510 : AT(0x49110) { build/us/fallback.o(.rom_cpu_after_startup) }
    .frame_render 0x800489F4 : AT(0x495F4) SUBALIGN(4) { build/us/frame_render.o(.text) }
    .frame_helpers 0x80048B8C : AT(0x4978C) SUBALIGN(4) { build/us/frame_helpers.o(.text) }
    .debug_noop 0x80048DC0 : AT(0x499C0) SUBALIGN(4) { build/us/debug_noop.o(.text) }
    .cpu_after_debug_noop 0x80048DDC : AT(0x499DC) { build/us/fallback.o(.rom_cpu_after_debug_noop) }
    .frame_matrices 0x80049514 : AT(0x4A114) SUBALIGN(4) { build/us/frame_matrices.o(.text) }
    .frame_timing 0x800495BC : AT(0x4A1BC) SUBALIGN(4) { build/us/frame_timing.o(.text) }
    .cpu_after_frame_timing 0x800496E0 : AT(0x4A2E0) { build/us/fallback.o(.rom_cpu_after_frame_timing) }
    .graphics_ucode 0x800498E0 : AT(0x4A4E0) SUBALIGN(4) { build/us/graphics_ucode.o(.text) }
    .cpu_after_graphics_ucode 0x800498EC : AT(0x4A4EC) { build/us/fallback.o(.rom_cpu_after_graphics_ucode) }
    .controller_legacy_initialize 0x8004C090 : AT(0x4CC90) SUBALIGN(4) { build/us/controller_legacy_initialize.o(.text) }
    .cpu_after_controller_legacy_initialize 0x8004C0D4 : AT(0x4CCD4) { build/us/fallback.o(.rom_cpu_after_controller_legacy_initialize) }
    .controller_legacy_present 0x8004C1C8 : AT(0x4CDC8) SUBALIGN(4) { build/us/controller_legacy_present.o(.text) }
    .cpu_after_controller_legacy_present 0x8004C1E0 : AT(0x4CDE0) { build/us/fallback.o(.rom_cpu_after_controller_legacy_present) }
    .pak_file_status 0x8004C378 : AT(0x4CF78) SUBALIGN(4) { build/us/pak_file_status.o(.text) }
    .pak_file_open 0x8004C3AC : AT(0x4CFAC) SUBALIGN(4) { build/us/pak_file_open.o(.text) }
    .pak_file_read 0x8004C564 : AT(0x4D164) SUBALIGN(4) { build/us/pak_file_read.o(.text) }
    .pak_file_write 0x8004C5DC : AT(0x4D1DC) SUBALIGN(4) { build/us/pak_file_write.o(.text) }
    .pak_file_close 0x8004C648 : AT(0x4D248) SUBALIGN(4) { build/us/pak_file_close.o(.text) }
    .pak_file_encode_name 0x8004C65C : AT(0x4D25C) SUBALIGN(4) { build/us/pak_file_encode_name.o(.text) }
    .cpu_after_pak_file_encode_name 0x8004C6DC : AT(0x4D2DC) { build/us/fallback.o(.rom_cpu_after_pak_file_encode_name) }
    .fixed_geometry_setup 0x8004CED0 : AT(0x4DAD0) SUBALIGN(4) { build/us/fixed_geometry_setup.o(.text) }
    .frame_transform 0x8004D4B4 : AT(0x4E0B4) SUBALIGN(4) { build/us/frame_transform.o(.text) }
    .fixed_geometry 0x8004D59C : AT(0x4E19C) SUBALIGN(4) { build/us/fixed_geometry.o(.text) }
    .fixed_math 0x8004DB34 : AT(0x4E734) SUBALIGN(4) { build/us/fixed_math.o(.text) }
    .cpu_after_fixed_math 0x8004DC68 : AT(0x4E868) { build/us/fallback.o(.rom_cpu_after_fixed_math) }
    .heap 0x8004DC70 : AT(0x4E870) SUBALIGN(4) { build/us/heap.o(.text) }
    .cpu_after_heap 0x8004DE8C : AT(0x4EA8C) { build/us/fallback.o(.rom_cpu_after_heap) }
    .heap_empty 0x8004DED8 : AT(0x4EAD8) SUBALIGN(4) { build/us/heap_empty.o(.text) }
    .cpu_after_heap_empty 0x8004DEE0 : AT(0x4EAE0) { build/us/fallback.o(.rom_cpu_after_heap_empty) }
    .object_history 0x8004E168 : AT(0x4ED68) SUBALIGN(4) { build/us/object_history.o(.text) }
    .cpu_after_object_history 0x8004E1C0 : AT(0x4EDC0) { build/us/fallback.o(.rom_cpu_after_object_history) }
    .rom_directory 0x8004EB80 : AT(0x4F780) SUBALIGN(4) { build/us/rom_directory.o(.text) }
    .rom_file_error 0x8004ED14 : AT(0x4F914) SUBALIGN(4) { build/us/rom_file_error.o(.text) }
    .rom_files 0x8004ED78 : AT(0x4F978) SUBALIGN(4) { build/us/rom_files.o(.text) }
    .cpu_after_rom_files 0x8004EFA8 : AT(0x4FBA8) { build/us/fallback.o(.rom_cpu_after_rom_files) }
    .controller_access 0x8004EFB0 : AT(0x4FBB0) SUBALIGN(4) { build/us/controller_access.o(.text) }
    .cpu_after_controller_access 0x8004F06C : AT(0x4FC6C) { build/us/fallback.o(.rom_cpu_after_controller_access) }
    .controller_motor_commands 0x8004F178 : AT(0x4FD78) SUBALIGN(4) { build/us/controller_motor_commands.o(.text) }
    .controller_scan 0x8004F1EC : AT(0x4FDEC) SUBALIGN(4) { build/us/controller_scan.o(.text) }
    .cpu_after_controller_scan 0x8004F330 : AT(0x4FF30) { build/us/fallback.o(.rom_cpu_after_controller_scan) }
    .controller_pak_info 0x8004F990 : AT(0x50590) SUBALIGN(4) { build/us/controller_pak_info.o(.text) }
    .controller_pak_delete 0x8004FA14 : AT(0x50614) SUBALIGN(4) { build/us/controller_pak_delete.o(.text) }
    .controller_pak_name 0x8004FAC0 : AT(0x506C0) SUBALIGN(4) { build/us/controller_pak_name.o(.text) }
    .cpu_after_controller_pak_name 0x8004FB48 : AT(0x50748) { build/us/fallback.o(.rom_cpu_after_controller_pak_name) }
    .controller_pak_directory 0x8004FC98 : AT(0x50898) SUBALIGN(4) { build/us/controller_pak_directory.o(.text) }
    .cpu_after_controller_pak_directory 0x8004FE04 : AT(0x50A04) { build/us/fallback.o(.rom_cpu_after_controller_pak_directory) }
    .graphics_setup 0x8004FE10 : AT(0x50A10) SUBALIGN(4) { build/us/graphics_setup.o(.text) }
    .graphics_pacing 0x8004FEA8 : AT(0x50AA8) { build/us/fallback.o(.rom_graphics_pacing) }
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
    .cpu_after_audio_task_build 0x80052378 : AT(0x52F78) { build/us/fallback.o(.rom_cpu_after_audio_task_build) }
    .audio_pool_callback 0x8005254C : AT(0x5314C) SUBALIGN(4) { build/us/audio_pool_callback.o(.text) }
    .cpu_after_audio_pool_callback 0x80052580 : AT(0x53180) { build/us/fallback.o(.rom_cpu_after_audio_pool_callback) }
    .audio_shutdown 0x800526D0 : AT(0x532D0) SUBALIGN(4) { build/us/audio_shutdown.o(.text) }
    .cpu_after_audio_shutdown 0x800526FC : AT(0x532FC) { build/us/fallback.o(.rom_cpu_after_audio_shutdown) }
    .audio_callback_registration 0x80052700 : AT(0x53300) SUBALIGN(4) { build/us/audio_callback_registration.o(.text) }
    .audio_callback_return 0x80052754 : AT(0x53354) SUBALIGN(4) { build/us/audio_callback_return.o(.text) }
    .cpu_after_audio_callback_return 0x80052774 : AT(0x53374) { build/us/fallback.o(.rom_cpu_after_audio_callback_return) }
    .audio_config 0x80052780 : AT(0x53380) SUBALIGN(4) { build/us/audio_config.o(.text) }
    .audio_control 0x80052A00 : AT(0x53600) SUBALIGN(4) { build/us/audio_control.o(.text) }
    .cpu_after_audio_control 0x80052D70 : AT(0x53970) { build/us/fallback.o(.rom_cpu_after_audio_control) }
    .audio_play 0x80053C50 : AT(0x54850) SUBALIGN(4) { build/us/audio_play.o(.text) }
    .cpu_after_audio_play 0x80053CC0 : AT(0x548C0) { build/us/fallback.o(.rom_cpu_after_audio_play) }
    .audio_instance_stop 0x80053DAC : AT(0x549AC) SUBALIGN(4) { build/us/audio_instance_stop.o(.text) }
    .audio_stop_commands 0x80053EBC : AT(0x54ABC) SUBALIGN(4) { build/us/audio_stop_commands.o(.text) }
    .audio_voice_stop 0x80053F78 : AT(0x54B78) SUBALIGN(4) { build/us/audio_voice_stop.o(.text) }
    .audio_instance_stop_all 0x80054178 : AT(0x54D78) SUBALIGN(4) { build/us/audio_instance_stop_all.o(.text) }
    .audio_stop_all_commands 0x80054268 : AT(0x54E68) SUBALIGN(4) { build/us/audio_stop_all_commands.o(.text) }
    .audio_voice_stop_all 0x80054304 : AT(0x54F04) SUBALIGN(4) { build/us/audio_voice_stop_all.o(.text) }
    .cpu_after_audio_voice_stop_all 0x800544F0 : AT(0x550F0) { build/us/fallback.o(.rom_cpu_after_audio_voice_stop_all) }
    .audio_level_commands 0x80054720 : AT(0x55320) SUBALIGN(4) { build/us/audio_level_commands.o(.text) }
    .audio_level_update 0x800547FC : AT(0x553FC) SUBALIGN(4) { build/us/audio_level_update.o(.text) }
    .audio_level_commands_alt 0x800549DC : AT(0x555DC) SUBALIGN(4) { build/us/audio_level_commands_alt.o(.text) }
    .audio_level_update_alt 0x80054A48 : AT(0x55648) SUBALIGN(4) { build/us/audio_level_update_alt.o(.text) }
    .audio_mode 0x80054C24 : AT(0x55824) SUBALIGN(4) { build/us/audio_mode.o(.text) }
    .cpu_after_audio_mode 0x80054C44 : AT(0x55844) { build/us/fallback.o(.rom_cpu_after_audio_mode) }
    .audio_play_arguments 0x80055760 : AT(0x56360) SUBALIGN(4) { build/us/audio_play_arguments.o(.text) }
    .cpu_after_audio_play_arguments 0x800557FC : AT(0x563FC) { build/us/fallback.o(.rom_cpu_after_audio_play_arguments) }
    .audio_command_lock 0x8005895C : AT(0x5955C) SUBALIGN(4) { build/us/audio_command_lock.o(.text) }
    .cpu_after_audio_command_lock 0x800589DC : AT(0x595DC) { build/us/fallback.o(.rom_cpu_after_audio_command_lock) }
    .audio_command_queue 0x800592C0 : AT(0x59EC0) SUBALIGN(4) { build/us/audio_command_queue.o(.text) }
    .cpu_after_audio_command_queue 0x80059500 : AT(0x5A100) { build/us/fallback.o(.rom_cpu_after_audio_command_queue) }
    .gu_sine 0x8005FBB0 : AT(0x607B0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_sine) }
    .gu_cosine 0x8005FC20 : AT(0x60820) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_cosine) }
    .cpu_after_gu_cosine 0x8005FC50 : AT(0x60850) { build/us/fallback.o(.rom_cpu_after_gu_cosine) }
    .pi_raw_read 0x8005FEE0 : AT(0x60AE0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pi_raw_read) }
    .cpu_after_pi_raw_read 0x8005FF34 : AT(0x60B34) { build/us/fallback.o(.rom_cpu_after_pi_raw_read) }
    .thread_create 0x8005FF40 : AT(0x60B40) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_thread_create) }
    .cpu_after_thread_create 0x80060084 : AT(0x60C84) { build/us/fallback.o(.rom_cpu_after_thread_create) }
    .thread_start 0x80060090 : AT(0x60C90) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_thread_start) }
    .pi_manager_create 0x800601E0 : AT(0x60DE0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pi_manager_create) }
    .cpu_after_pi_manager_create 0x80060368 : AT(0x60F68) { build/us/fallback.o(.rom_cpu_after_pi_manager_create) }
    .thread_priority 0x80060370 : AT(0x60F70) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_thread_priority) }
    .message_queue_create 0x80060450 : AT(0x61050) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_message_queue_create) }
    .cpu_after_message_queue_create 0x8006047C : AT(0x6107C) { build/us/fallback.o(.rom_cpu_after_message_queue_create) }
    .vi_features 0x800604E0 : AT(0x610E0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_vi_features) }
    .cpu_after_vi_features 0x80060698 : AT(0x61298) { build/us/fallback.o(.rom_cpu_after_vi_features) }
    .virtual_to_physical 0x800606A0 : AT(0x612A0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_virtual_to_physical) }
    .cpu_after_virtual_to_physical 0x8006071C : AT(0x6131C) { build/us/fallback.o(.rom_cpu_after_virtual_to_physical) }
    .gu_perspective 0x80060750 : AT(0x61350) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_perspective) }
    .cpu_after_gu_perspective 0x800609D8 : AT(0x615D8) { build/us/fallback.o(.rom_cpu_after_gu_perspective) }
    .gu_lookathilite 0x800609E0 : AT(0x615E0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_lookathilite) }
    .cpu_after_gu_lookathilite 0x80061204 : AT(0x61E04) { build/us/fallback.o(.rom_cpu_after_gu_lookathilite) }
    .gu_translate 0x80061210 : AT(0x61E10) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_translate) }
    .cpu_after_gu_translate 0x800612AC : AT(0x61EAC) { build/us/fallback.o(.rom_cpu_after_gu_translate) }
    .gu_rotate_rpy 0x800612B0 : AT(0x61EB0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_rotate_rpy) }
    .cpu_after_gu_rotate_rpy 0x80061444 : AT(0x62044) { build/us/fallback.o(.rom_cpu_after_gu_rotate_rpy) }
    .time_get 0x80061450 : AT(0x62050) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_time_get) }
    .cpu_after_time_get 0x800614D4 : AT(0x620D4) { build/us/fallback.o(.rom_cpu_after_time_get) }
    .compiler_arithmetic 0x800614E0 : AT(0x620E0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_compiler_arithmetic) }
    .cpu_after_compiler_arithmetic 0x800617A0 : AT(0x623A0) { build/us/fallback.o(.rom_cpu_after_compiler_arithmetic) }
    .pfs_is_plug 0x80061A00 : AT(0x62600) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_is_plug) }
    .cpu_after_pfs_is_plug 0x80061D6C : AT(0x6296C) { build/us/fallback.o(.rom_cpu_after_pfs_is_plug) }
    .pfs_init_pak 0x80061D70 : AT(0x62970) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_init_pak) }
    .cpu_after_pfs_init_pak 0x80061FD4 : AT(0x62BD4) { build/us/fallback.o(.rom_cpu_after_pfs_init_pak) }
    .controller_read 0x80061FE0 : AT(0x62BE0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_controller_read) }
    .cpu_after_controller_read 0x80062238 : AT(0x62E38) { build/us/fallback.o(.rom_cpu_after_controller_read) }
    .message_receive 0x80062240 : AT(0x62E40) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_message_receive) }
    .cpu_after_message_receive 0x80062378 : AT(0x62F78) { build/us/fallback.o(.rom_cpu_after_message_receive) }
    .pfs_search_file 0x80062380 : AT(0x62F80) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_search_file) }
    .cpu_after_pfs_search_file 0x80062534 : AT(0x63134) { build/us/fallback.o(.rom_cpu_after_pfs_search_file) }
    .pfs_allocate_file 0x80062540 : AT(0x63140) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_allocate_file) }
    .cpu_after_pfs_allocate_file 0x80062CE8 : AT(0x638E8) { build/us/fallback.o(.rom_cpu_after_pfs_allocate_file) }
    .pfs_read_write_file 0x80062CF0 : AT(0x638F0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_read_write_file) }
    .cpu_after_pfs_read_write_file 0x800631EC : AT(0x63DEC) { build/us/fallback.o(.rom_cpu_after_pfs_read_write_file) }
    .gu_random 0x800631F0 : AT(0x63DF0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_random) }
    .cpu_after_gu_random 0x8006321C : AT(0x63E1C) { build/us/fallback.o(.rom_cpu_after_gu_random) }
    .gu_sine_float 0x80063230 : AT(0x63E30) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_sine_float) }
    .gu_cosine_float 0x800633F0 : AT(0x63FF0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_cosine_float) }
    .cpu_after_gu_cosine_float 0x80063558 : AT(0x64158) { build/us/fallback.o(.rom_cpu_after_gu_cosine_float) }
    .pi_read 0x80063560 : AT(0x64160) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pi_read) }
    .message_send 0x800635A0 : AT(0x641A0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_message_send) }
    .cpu_after_message_send 0x800636EC : AT(0x642EC) { build/us/fallback.o(.rom_cpu_after_message_send) }
    .pfs_motor 0x800636F0 : AT(0x642F0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_motor) }
    .cpu_after_pfs_motor 0x80063D04 : AT(0x64904) { build/us/fallback.o(.rom_cpu_after_pfs_motor) }
    .controller_init 0x80063D10 : AT(0x64910) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_controller_init) }
    .cpu_after_controller_init 0x800640CC : AT(0x64CCC) { build/us/fallback.o(.rom_cpu_after_controller_init) }
    .event_message 0x800640D0 : AT(0x64CD0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_event_message) }
    .cpu_after_event_message 0x80064138 : AT(0x64D38) { build/us/fallback.o(.rom_cpu_after_event_message) }
    .pfs_free_blocks 0x80064140 : AT(0x64D40) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_free_blocks) }
    .cpu_after_pfs_free_blocks 0x8006428C : AT(0x64E8C) { build/us/fallback.o(.rom_cpu_after_pfs_free_blocks) }
    .pfs_num_files 0x80064290 : AT(0x64E90) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_num_files) }
    .cpu_after_pfs_num_files 0x800643D4 : AT(0x64FD4) { build/us/fallback.o(.rom_cpu_after_pfs_num_files) }
    .pfs_delete_file 0x800643E0 : AT(0x64FE0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_delete_file) }
    .cpu_after_pfs_delete_file 0x800649E8 : AT(0x655E8) { build/us/fallback.o(.rom_cpu_after_pfs_delete_file) }
    .pfs_file_state 0x800649F0 : AT(0x655F0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_file_state) }
    .vi_vertical_scale 0x80064CE0 : AT(0x658E0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_vi_vertical_scale) }
    .cpu_after_vi_vertical_scale 0x80064D38 : AT(0x65938) { build/us/fallback.o(.rom_cpu_after_vi_vertical_scale) }
    .vi_manager 0x80064D40 : AT(0x65940) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_vi_manager) }
    .cpu_after_vi_manager 0x80065094 : AT(0x65C94) { build/us/fallback.o(.rom_cpu_after_vi_manager) }
    .vi_mode 0x800650A0 : AT(0x65CA0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_vi_mode) }
    .cpu_after_vi_mode 0x80065108 : AT(0x65D08) { build/us/fallback.o(.rom_cpu_after_vi_mode) }
    .vi_black 0x80065110 : AT(0x65D10) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_vi_black) }
    .vi_event 0x80065180 : AT(0x65D80) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_vi_event) }
    .cpu_after_vi_event 0x800651EC : AT(0x65DEC) { build/us/fallback.o(.rom_cpu_after_vi_event) }
    .sp_yield 0x80065290 : AT(0x65E90) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sp_yield) }
    .sp_yielded 0x800652B0 : AT(0x65EB0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sp_yielded) }
    .sp_task 0x80065330 : AT(0x65F30) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sp_task) }
    .audio_sp 0x800655DC : AT(0x661DC) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_sp) }
    .cpu_after_audio_sp 0x8006561C : AT(0x6621C) { build/us/fallback.o(.rom_cpu_after_audio_sp) }
    .audio_vi 0x80065620 : AT(0x66220) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_vi) }
    .audio_heap_init 0x800656F0 : AT(0x662F0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_heap_init) }
    .cpu_after_audio_heap_init 0x80065724 : AT(0x66324) { build/us/fallback.o(.rom_cpu_after_audio_heap_init) }
    .audio_heap_alloc 0x80065730 : AT(0x66330) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_heap_alloc) }
    .cpu_after_audio_heap_alloc 0x80065784 : AT(0x66384) { build/us/fallback.o(.rom_cpu_after_audio_heap_alloc) }
    .pi_start_dma 0x80065840 : AT(0x66440) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pi_start_dma) }
    .cpu_after_pi_start_dma 0x8006594C : AT(0x6654C) { build/us/fallback.o(.rom_cpu_after_pi_start_dma) }
    .ai_frequency 0x80065950 : AT(0x66550) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_ai_frequency) }
    .audio_globals 0x80065AB0 : AT(0x666B0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_globals) }
    .ai_buffer 0x80065B70 : AT(0x66770) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_ai_buffer) }
    .cpu_after_ai_buffer 0x80065C18 : AT(0x66818) { build/us/fallback.o(.rom_cpu_after_ai_buffer) }
    .ai_length 0x80065C20 : AT(0x66820) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_ai_length) }
    .cpu_after_ai_length 0x80065C2C : AT(0x6682C) { build/us/fallback.o(.rom_cpu_after_ai_length) }
    .audio_synthesizer 0x80065C30 : AT(0x66830) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synthesizer) }
    .audio_synth_player 0x80066310 : AT(0x66F10) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_player) }
    .audio_synth_allocate 0x80066360 : AT(0x66F60) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_allocate) }
    .cpu_after_audio_synth_allocate 0x80066588 : AT(0x67188) { build/us/fallback.o(.rom_cpu_after_audio_synth_allocate) }
    .audio_synth_start 0x80066590 : AT(0x67190) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_start) }
    .cpu_after_audio_synth_start 0x80066674 : AT(0x67274) { build/us/fallback.o(.rom_cpu_after_audio_synth_start) }
    .audio_synth_pitch 0x80066680 : AT(0x67280) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_pitch) }
    .cpu_after_audio_synth_pitch 0x80066704 : AT(0x67304) { build/us/fallback.o(.rom_cpu_after_audio_synth_pitch) }
    .audio_synth_volume 0x80066710 : AT(0x67310) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_volume) }
    .cpu_after_audio_synth_volume 0x800667AC : AT(0x673AC) { build/us/fallback.o(.rom_cpu_after_audio_synth_volume) }
    .audio_synth_pan 0x800667B0 : AT(0x673B0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_pan) }
    .cpu_after_audio_synth_pan 0x80066834 : AT(0x67434) { build/us/fallback.o(.rom_cpu_after_audio_synth_pan) }
    .audio_synth_stop 0x80066840 : AT(0x67440) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_stop) }
    .cpu_after_audio_synth_stop 0x800668B8 : AT(0x674B8) { build/us/fallback.o(.rom_cpu_after_audio_synth_stop) }
    .audio_synth_free_voice 0x800668C0 : AT(0x674C0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_free_voice) }
    .audio_synth_priority 0x80066970 : AT(0x67570) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_priority) }
    .cpu_after_audio_synth_priority 0x80066980 : AT(0x67580) { build/us/fallback.o(.rom_cpu_after_audio_synth_priority) }
    .si_raw_read 0x800669B0 : AT(0x675B0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_si_raw_read) }
    .si_raw_write 0x80066A00 : AT(0x67600) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_si_raw_write) }
    .cpu_after_si_raw_write 0x80066A4C : AT(0x6764C) { build/us/fallback.o(.rom_cpu_after_si_raw_write) }
    .pi_access 0x800677D0 : AT(0x683D0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pi_access) }
    .thread_get_priority 0x80067890 : AT(0x68490) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_thread_get_priority) }
    .cpu_after_thread_get_priority 0x800678A8 : AT(0x684A8) { build/us/fallback.o(.rom_cpu_after_thread_get_priority) }
    .pi_raw_dma 0x800678B0 : AT(0x684B0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pi_raw_dma) }
    .epi_dma 0x80067990 : AT(0x68590) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_epi_dma) }
    .cpu_after_epi_dma 0x80067BB4 : AT(0x687B4) { build/us/fallback.o(.rom_cpu_after_epi_dma) }
    .gu_mtxutil 0x80068250 : AT(0x68E50) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_gu_mtxutil) }
    .cpu_after_gu_mtxutil 0x800684BC : AT(0x690BC) { build/us/fallback.o(.rom_cpu_after_gu_mtxutil) }
    .timer_init 0x800684D0 : AT(0x690D0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_timer_init) }
    .timer_interrupt 0x8006855C : AT(0x6915C) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_timer_interrupt) }
    .timer_compare 0x800686D4 : AT(0x692D4) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_timer_compare) }
    .timer_insert 0x80068748 : AT(0x69348) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_timer_insert) }
    .pfs_contpfs 0x800688D0 : AT(0x694D0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_contpfs) }
    .cpu_after_pfs_contpfs 0x80069628 : AT(0x6A228) { build/us/fallback.o(.rom_cpu_after_pfs_contpfs) }
    .pfs_cont_ram_read 0x80069630 : AT(0x6A230) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_cont_ram_read) }
    .cpu_after_pfs_cont_ram_read 0x800699B4 : AT(0x6A5B4) { build/us/fallback.o(.rom_cpu_after_pfs_cont_ram_read) }
    .si_access 0x800699C0 : AT(0x6A5C0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_si_access) }
    .si_dma 0x80069A80 : AT(0x6A680) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_si_dma) }
    .cpu_after_si_dma 0x80069B2C : AT(0x6A72C) { build/us/fallback.o(.rom_cpu_after_si_dma) }
    .pfs_get_status 0x80069B30 : AT(0x6A730) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_get_status) }
    .cpu_after_pfs_get_status 0x80069C3C : AT(0x6A83C) { build/us/fallback.o(.rom_cpu_after_pfs_get_status) }
    .pfs_checker 0x80069C40 : AT(0x6A840) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_checker) }
    .pfs_cont_ram_write 0x8006A6A0 : AT(0x6B2A0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pfs_cont_ram_write) }
    .controller_crc 0x8006AA20 : AT(0x6B620) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_controller_crc) }
    .timer_set 0x8006ABA0 : AT(0x6B7A0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_timer_set) }
    .cpu_after_timer_set 0x8006AC74 : AT(0x6B874) { build/us/fallback.o(.rom_cpu_after_timer_set) }
    .vi_context 0x8006AC80 : AT(0x6B880) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_vi_context) }
    .cpu_after_vi_context 0x8006AC8C : AT(0x6B88C) { build/us/fallback.o(.rom_cpu_after_vi_context) }
    .sp_set_status 0x8006AFF0 : AT(0x6BBF0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sp_set_status) }
    .cpu_after_sp_set_status 0x8006AFFC : AT(0x6BBFC) { build/us/fallback.o(.rom_cpu_after_sp_set_status) }
    .sp_get_status 0x8006B000 : AT(0x6BC00) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sp_get_status) }
    .cpu_after_sp_get_status 0x8006B00C : AT(0x6BC0C) { build/us/fallback.o(.rom_cpu_after_sp_get_status) }
    .sp_set_pc 0x8006B320 : AT(0x6BF20) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sp_set_pc) }
    .cpu_after_sp_set_pc 0x8006B354 : AT(0x6BF54) { build/us/fallback.o(.rom_cpu_after_sp_set_pc) }
    .sp_dma 0x8006B360 : AT(0x6BF60) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sp_dma) }
    .cpu_after_sp_dma 0x8006B3EC : AT(0x6BFEC) { build/us/fallback.o(.rom_cpu_after_sp_dma) }
    .sp_busy 0x8006B3F0 : AT(0x6BFF0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sp_busy) }
    .cpu_after_sp_busy 0x8006B41C : AT(0x6C01C) { build/us/fallback.o(.rom_cpu_after_sp_busy) }
    .message_jam 0x8006B420 : AT(0x6C020) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_message_jam) }
    .pi_get_queue 0x8006B570 : AT(0x6C170) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pi_get_queue) }
    .cpu_after_pi_get_queue 0x8006B598 : AT(0x6C198) { build/us/fallback.o(.rom_cpu_after_pi_get_queue) }
    .audio_synth_delete 0x8006B5A0 : AT(0x6C1A0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_synth_delete) }
    .cpu_after_audio_synth_delete 0x8006B5A8 : AT(0x6C1A8) { build/us/fallback.o(.rom_cpu_after_audio_synth_delete) }
    .ai_busy 0x8006B5B0 : AT(0x6C1B0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_ai_busy) }
    .audio_filter_constructors 0x8006B5E0 : AT(0x6C1E0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_filter_constructors) }
    .audio_effect_init 0x8006B940 : AT(0x6C540) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_effect_init) }
    .cpu_after_audio_effect_init 0x8006BD7C : AT(0x6C97C) { build/us/fallback.o(.rom_cpu_after_audio_effect_init) }
    .audio_effect_allocate 0x8006BD80 : AT(0x6C980) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_effect_allocate) }
    .cpu_after_audio_effect_allocate 0x8006BE18 : AT(0x6CA18) { build/us/fallback.o(.rom_cpu_after_audio_effect_allocate) }
    .audio_main_bus 0x8006BE20 : AT(0x6CA20) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_main_bus) }
    .audio_decoder 0x8006BF70 : AT(0x6CB70) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_decoder) }
    .cpu_after_audio_decoder 0x8006CABC : AT(0x6D6BC) { build/us/fallback.o(.rom_cpu_after_audio_decoder) }
    .audio_resample 0x8006CAC0 : AT(0x6D6C0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_resample) }
    .cpu_after_audio_resample 0x8006CDB4 : AT(0x6D9B4) { build/us/fallback.o(.rom_cpu_after_audio_resample) }
    .audio_envelope 0x8006CDC0 : AT(0x6D9C0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_envelope) }
    .cpu_after_audio_envelope 0x8006DA14 : AT(0x6E614) { build/us/fallback.o(.rom_cpu_after_audio_envelope) }
    .audio_aux_bus 0x8006DA20 : AT(0x6E620) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_aux_bus) }
    .cpu_after_audio_aux_bus 0x8006DB28 : AT(0x6E728) { build/us/fallback.o(.rom_cpu_after_audio_aux_bus) }
    .audio_save 0x8006DB30 : AT(0x6E730) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_save) }
    .si_busy 0x8006DBF0 : AT(0x6E7F0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_si_busy) }
    .cpu_after_si_busy 0x8006DC1C : AT(0x6E81C) { build/us/fallback.o(.rom_cpu_after_si_busy) }
    .pi_event 0x8006E3AC : AT(0x6EFAC) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_pi_event) }
    .cpu_after_pi_event 0x8006E498 : AT(0x6F098) { build/us/fallback.o(.rom_cpu_after_pi_event) }
    .thread_destroy 0x8006E4A0 : AT(0x6F0A0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_thread_destroy) }
    .cpu_after_thread_destroy 0x8006E598 : AT(0x6F198) { build/us/fallback.o(.rom_cpu_after_thread_destroy) }
    .interrupt_global_clear 0x8006E5A0 : AT(0x6F1A0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_interrupt_global_clear) }
    .cpu_after_interrupt_global_clear 0x8006E5F8 : AT(0x6F1F8) { build/us/fallback.o(.rom_cpu_after_interrupt_global_clear) }
    .epi_raw_write 0x8006E600 : AT(0x6F200) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_epi_raw_write) }
    .cpu_after_epi_raw_write 0x8006E64C : AT(0x6F24C) { build/us/fallback.o(.rom_cpu_after_epi_raw_write) }
    .epi_raw_read 0x8006E650 : AT(0x6F250) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_epi_raw_read) }
    .interrupt_global_set 0x8006E6A0 : AT(0x6F2A0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_interrupt_global_set) }
    .cpu_after_interrupt_global_set 0x8006E6EC : AT(0x6F2EC) { build/us/fallback.o(.rom_cpu_after_interrupt_global_set) }
    .thread_yield 0x8006E6F0 : AT(0x6F2F0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_thread_yield) }
    .cpu_after_thread_yield 0x8006E73C : AT(0x6F33C) { build/us/fallback.o(.rom_cpu_after_thread_yield) }
    .audio_filter_init 0x8006E750 : AT(0x6F350) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_filter_init) }
    .cpu_after_audio_filter_init 0x8006E76C : AT(0x6F36C) { build/us/fallback.o(.rom_cpu_after_audio_filter_init) }
    .audio_effect_modulation 0x8006E770 : AT(0x6F370) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_effect_modulation) }
    .audio_effect_buffers 0x8006E818 : AT(0x6F418) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_effect_buffers) }
    .audio_effect_parameters 0x8006EE08 : AT(0x6FA08) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_effect_parameters) }
    .audio_effect_source 0x8006F064 : AT(0x6FC64) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_effect_source) }
    .audio_effect_pull 0x8006F07C : AT(0x6FC7C) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_effect_pull) }
    .cpu_after_audio_effect_pull 0x8006F3BC : AT(0x6FFBC) { build/us/fallback.o(.rom_cpu_after_audio_effect_pull) }
    .audio_copy 0x8006F3C0 : AT(0x6FFC0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_audio_copy) }
    .cpu_after_audio_copy 0x8006F434 : AT(0x70034) { build/us/fallback.o(.rom_cpu_after_audio_copy) }
    /* CPU-visible storage address. The RSP executes this at 0x04001000. */
    .rsp_boot 0x8006F440 : AT(0x70040) { build/us/fallback.o(.rom_rsp_boot) }
    /* Unmapped fallback uses a synthetic VMA, not a claim about RAM layout. */
    .data_before_text_table 0x90000000 : AT(0x70110) { build/us/fallback.o(.rom_data_before_text_table) }
    .movie_commands_data 0x80078150 : AT(0x78D50) SUBALIGN(4) { build/us/movie_prepare.o(.data) }
    .data_after_movie_commands_data 0x90008CA8 : AT(0x78DB8) { build/us/fallback.o(.rom_data_after_movie_commands_data) }
    .sdk_pi_manager_data 0x8008E3D0 : AT(0x8EFD0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_pi_manager_data) }
    .data_after_sdk_pi_manager_data 0x9001EEDC : AT(0x8EFEC) { build/us/fallback.o(.rom_data_after_sdk_pi_manager_data) }
    .sdk_random_data 0x8008F120 : AT(0x8FD20) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_random_data) }
    .data_after_sdk_random_data 0x9001FC14 : AT(0x8FD24) { build/us/fallback.o(.rom_data_after_sdk_random_data) }
    .sdk_controller_init_data 0x8008F130 : AT(0x8FD30) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_controller_init_data) }
    .data_after_sdk_controller_init_data 0x9001FC24 : AT(0x8FD34) { build/us/fallback.o(.rom_data_after_sdk_controller_init_data) }
    .sdk_vi_manager_data 0x8008F140 : AT(0x8FD40) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_vi_manager_data) }
    .data_after_sdk_vi_manager_data 0x9001FC4C : AT(0x8FD5C) { build/us/fallback.o(.rom_data_after_sdk_vi_manager_data) }
    .sdk_audio_globals_data 0x8008F160 : AT(0x8FD60) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_audio_globals_data) }
    .data_after_sdk_audio_globals_data 0x9001FC54 : AT(0x8FD64) { build/us/fallback.o(.rom_data_after_sdk_audio_globals_data) }
    .sdk_audio_effect_init_data 0x8008F260 : AT(0x8FE60) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_audio_effect_init_data) }
    .sdk_audio_envelope_data 0x8008F3F0 : AT(0x8FFF0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_audio_envelope_data) }
    .data_after_sdk_audio_envelope_data 0x90020020 : AT(0x90130) { build/us/fallback.o(.rom_data_after_sdk_audio_envelope_data) }
    .text_table 0x8008F678 : AT(0x90278) SUBALIGN(4) { build/us/text.o(.rodata) }
    .remainder 0x91000000 : AT(0x903A0) { build/us/fallback.o(.rom_remainder) }
    .scene_background_constants 0x80091958 : AT(0x92558) SUBALIGN(4) { build/us/scene_background.o(.rodata) }
    .data_after_scene_background_constants 0x910021C0 : AT(0x92560) { build/us/fallback.o(.rom_data_after_scene_background_constants) }
    .save_menu_status_tables 0x80094084 : AT(0x94C84) SUBALIGN(4) { build/us/save_menu_status.o(.rodata) }
    .data_after_save_menu_status_tables 0x91004914 : AT(0x94CB4) { build/us/fallback.o(.rom_data_after_save_menu_status_tables) }
    .command_machine_table 0x8009416C : AT(0x94D6C) SUBALIGN(4) { build/us/command_machine.o(.rodata) }
    .data_after_command_machine_table 0x910049EC : AT(0x94D8C) { build/us/fallback.o(.rom_data_after_command_machine_table) }
    .sound_bridge_future_queue_strings 0x800942E0 : AT(0x94EE0) SUBALIGN(4) { build/us/sound_bridge_future_queue.o(.rodata) }
    .data_after_sound_bridge_future_queue_strings 0x91004B60 : AT(0x94F00) { build/us/fallback.o(.rom_data_after_sound_bridge_future_queue_strings) }
    .renderer_vertex_attributes_strings 0x80094F20 : AT(0x95B20) SUBALIGN(4) { build/us/renderer_vertex_attributes.o(.rodata) }
    .data_after_renderer_vertex_attributes_strings 0x91005870 : AT(0x95C10) { build/us/fallback.o(.rom_data_after_renderer_vertex_attributes_strings) }
    .graphics_resource_strings 0x800951C8 : AT(0x95DC8) SUBALIGN(4) { build/us/graphics_resource.o(.rodata) }
    .data_after_graphics_resource_strings 0x91005A3C : AT(0x95DDC) { build/us/fallback.o(.rom_data_after_graphics_resource_strings) }
    .graphics_pool_strings 0x80095220 : AT(0x95E20) SUBALIGN(4) { build/us/graphics_pool.o(.rodata) }
    .graphics_mode_dispatch_table 0x80095300 : AT(0x95F00) SUBALIGN(4) { build/us/graphics_mode_dispatch.o(.rodata) }
    .data_after_graphics_mode_dispatch_table 0x91005BC0 : AT(0x95F60) { build/us/fallback.o(.rom_data_after_graphics_mode_dispatch_table) }
    .sdk_gu_perspective_constants 0x80095CF0 : AT(0x968F0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_gu_perspective_constants) }
    .sdk_gu_lookathilite_constants 0x80095D00 : AT(0x96900) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_gu_lookathilite_constants) }
    .sdk_gu_rotate_rpy_constants 0x80095D20 : AT(0x96920) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_gu_rotate_rpy_constants) }
    .data_after_sdk_gu_rotate_rpy_constants 0x91006590 : AT(0x96930) { build/us/fallback.o(.rom_data_after_sdk_gu_rotate_rpy_constants) }
    .sdk_audio_synthesizer_constants 0x80095E50 : AT(0x96A50) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_audio_synthesizer_constants) }
    .data_after_sdk_audio_synthesizer_constants 0x910066C0 : AT(0x96A60) { build/us/fallback.o(.rom_data_after_sdk_audio_synthesizer_constants) }
    .sdk_audio_effect_init_constants 0x80095EE0 : AT(0x96AE0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_audio_effect_init_constants) }
    .sdk_audio_resample_constants 0x80095F00 : AT(0x96B00) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_audio_resample_constants) }
    .data_after_sdk_audio_resample_constants 0x91006794 : AT(0x96B34) { build/us/fallback.o(.rom_data_after_sdk_audio_resample_constants) }
    .sdk_audio_envelope_constants 0x80095F40 : AT(0x96B40) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_audio_envelope_constants) }
    .sdk_audio_effect_constants 0x80095FA0 : AT(0x96BA0) SUBALIGN(4) { build/us/fallback.o(.rom_sdk_fallback_sdk_audio_effect_constants) }
    .data_after_sdk_audio_effect_constants 0x91006828 : AT(0x96BC8) { build/us/fallback.o(.rom_data_after_sdk_audio_effect_constants) }
    /DISCARD/ : {
        *(.reginfo .MIPS.abiflags .mdebug .mdebug.* .pdr .comment .note.GNU-stack)
    }
    .unexpected 0 : { *(.text .data .rodata .bss .sdata .sbss COMMON) }
}

ASSERT(SIZEOF(.header) == 0x40, "header size changed")
ASSERT(SIZEOF(.ipl3) == 0xfc0, "IPL3 size changed")
ASSERT(SIZEOF(.entry) == 0x50, "entry size changed")
ASSERT(SIZEOF(.text_start) == 0xaf8, "initial text functions size changed")
ASSERT(SIZEOF(.cpu_fallback) == 0x1764, "cpu_fallback size changed")
ASSERT(SIZEOF(.movie_reset) == 0x48, "movie_reset size changed")
ASSERT(SIZEOF(.movie_parameters) == 0x118, "movie_parameters size changed")
ASSERT(SIZEOF(.movie_commands) == 0x7b8, "movie_commands size changed")
ASSERT(SIZEOF(.movie_channels) == 0x284, "movie_channels size changed")
ASSERT(SIZEOF(.movie_files) == 0x2f8, "movie_files size changed")
ASSERT(SIZEOF(.movie_track_release) == 0x158, "movie_track_release size changed")
ASSERT(SIZEOF(.cpu_after_movie_track_release) == 0x1cc, "cpu_after_movie_track_release size changed")
ASSERT(SIZEOF(.movie_sample) == 0x1c0, "movie_sample size changed")
ASSERT(SIZEOF(.cpu_after_movie_sample) == 0x1b4, "cpu_after_movie_sample size changed")
ASSERT(SIZEOF(.movie_callback) == 0xa0, "movie_callback size changed")
ASSERT(SIZEOF(.movie_prepare) == 0x138, "movie_prepare size changed")
ASSERT(SIZEOF(.movie_start) == 0x658, "movie_start size changed")
ASSERT(SIZEOF(.cpu_after_movie_start) == 0x718, "cpu_after_movie_start size changed")
ASSERT(SIZEOF(.movie_status) == 0xf8, "movie_status size changed")
ASSERT(SIZEOF(.movie_cleanup) == 0x114, "movie_cleanup size changed")
ASSERT(SIZEOF(.cpu_after_movie_cleanup) == 0x171e0, "cpu_after_movie_cleanup size changed")
ASSERT(SIZEOF(.script_service_cache_reset) == 0x50, "script_service_cache_reset size changed")
ASSERT(SIZEOF(.script_service_files) == 0x134, "script_service_files size changed")
ASSERT(SIZEOF(.script_service_cache_access) == 0x284, "script_service_cache_access size changed")
ASSERT(SIZEOF(.cpu_after_script_service_cache_access) == 0x8, "cpu_after_script_service_cache_access size changed")
ASSERT(SIZEOF(.script_service_commands) == 0x244, "script_service_commands size changed")
ASSERT(SIZEOF(.cpu_after_script_service_commands) == 0xd4, "cpu_after_script_service_commands size changed")
ASSERT(SIZEOF(.script_service_platform_stub) == 0x8, "script_service_platform_stub size changed")
ASSERT(SIZEOF(.cpu_after_script_service_platform_stub) == 0xf8, "cpu_after_script_service_platform_stub size changed")
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
ASSERT(SIZEOF(.cpu_after_scene_background) == 0x7eb8, "cpu_after_scene_background size changed")
ASSERT(SIZEOF(.actor_motion_mode) == 0x148, "actor_motion_mode size changed")
ASSERT(SIZEOF(.cpu_after_actor_motion_mode) == 0x4a8, "cpu_after_actor_motion_mode size changed")
ASSERT(SIZEOF(.actor_pool_reset) == 0x38, "actor_pool_reset size changed")
ASSERT(SIZEOF(.actor_cleanup) == 0xb0, "actor_cleanup size changed")
ASSERT(SIZEOF(.actor_remove) == 0xf8, "actor_remove size changed")
ASSERT(SIZEOF(.actor_sweep) == 0x68, "actor_sweep size changed")
ASSERT(SIZEOF(.cpu_after_actor_sweep) == 0x2014, "cpu_after_actor_sweep size changed")
ASSERT(SIZEOF(.actor_behavior_state) == 0x2c, "actor_behavior_state size changed")
ASSERT(SIZEOF(.actor_behavior_blend_velocity) == 0x1c8, "actor_behavior_blend_velocity size changed")
ASSERT(SIZEOF(.actor_behavior_blend_motion) == 0x22c, "actor_behavior_blend_motion size changed")
ASSERT(SIZEOF(.cpu_after_actor_behavior_blend_motion) == 0xb14, "cpu_after_actor_behavior_blend_motion size changed")
ASSERT(SIZEOF(.actor_behavior_height) == 0x10, "actor_behavior_height size changed")
ASSERT(SIZEOF(.actor_behavior_extra_b32c) == 0x244, "actor_behavior_extra_b32c size changed")
ASSERT(SIZEOF(.actor_behavior_noop_b570) == 0xc, "actor_behavior_noop_b570 size changed")
ASSERT(SIZEOF(.actor_behavior_extra_b57c) == 0x228, "actor_behavior_extra_b57c size changed")
ASSERT(SIZEOF(.actor_behavior_noop_b7a4) == 0xc, "actor_behavior_noop_b7a4 size changed")
ASSERT(SIZEOF(.actor_behavior_noop_b7b0) == 0xc, "actor_behavior_noop_b7b0 size changed")
ASSERT(SIZEOF(.cpu_after_actor_behavior_noop_b7b0) == 0x7cc, "cpu_after_actor_behavior_noop_b7b0 size changed")
ASSERT(SIZEOF(.actor_behavior_repeat) == 0x124, "actor_behavior_repeat size changed")
ASSERT(SIZEOF(.cpu_after_actor_behavior_repeat) == 0x186c, "cpu_after_actor_behavior_repeat size changed")
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
ASSERT(SIZEOF(.cpu_after_session_setup_bitmap) == 0x178, "cpu_after_session_setup_bitmap size changed")
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
ASSERT(SIZEOF(.cpu_after_save_file_write) == 0x1a0, "cpu_after_save_file_write size changed")
ASSERT(SIZEOF(.save_menu_slot_write) == 0x114, "save_menu_slot_write size changed")
ASSERT(SIZEOF(.save_menu_cancel) == 0x3c, "save_menu_cancel size changed")
ASSERT(SIZEOF(.save_menu_slot_prompt) == 0xe8, "save_menu_slot_prompt size changed")
ASSERT(SIZEOF(.save_menu_slot_callback) == 0x6c, "save_menu_slot_callback size changed")
ASSERT(SIZEOF(.save_menu_open) == 0x44, "save_menu_open size changed")
ASSERT(SIZEOF(.save_menu_status) == 0x340, "save_menu_status size changed")
ASSERT(SIZEOF(.cpu_after_save_menu_status) == 0xec, "cpu_after_save_menu_status size changed")
ASSERT(SIZEOF(.save_menu_audio_index) == 0x74, "save_menu_audio_index size changed")
ASSERT(SIZEOF(.save_menu_sound_preview) == 0x30, "save_menu_sound_preview size changed")
ASSERT(SIZEOF(.save_menu_audio_apply) == 0x44, "save_menu_audio_apply size changed")
ASSERT(SIZEOF(.save_menu_audio_secondary) == 0x24, "save_menu_audio_secondary size changed")
ASSERT(SIZEOF(.save_menu_write_return) == 0x34, "save_menu_write_return size changed")
ASSERT(SIZEOF(.cpu_after_save_menu_write_return) == 0x434, "cpu_after_save_menu_write_return size changed")
ASSERT(SIZEOF(.save_menu_palette_index) == 0xdc, "save_menu_palette_index size changed")
ASSERT(SIZEOF(.scene_palette_load) == 0x68, "scene_palette_load size changed")
ASSERT(SIZEOF(.palette_fade_controls) == 0x148, "palette_fade_controls size changed")
ASSERT(SIZEOF(.cpu_after_palette_fade_controls) == 0x564, "cpu_after_palette_fade_controls size changed")
ASSERT(SIZEOF(.palette_transition_reset) == 0x34, "palette_transition_reset size changed")
ASSERT(SIZEOF(.palette_transition_range) == 0x288, "palette_transition_range size changed")
ASSERT(SIZEOF(.cpu_after_palette_transition_range) == 0x4b0, "cpu_after_palette_transition_range size changed")
ASSERT(SIZEOF(.palette_commands) == 0x1b8, "palette_commands size changed")
ASSERT(SIZEOF(.cpu_after_palette_commands) == 0xc, "cpu_after_palette_commands size changed")
ASSERT(SIZEOF(.command_enable) == 0x10, "command_enable size changed")
ASSERT(SIZEOF(.game_number_convert) == 0xfc, "game_number_convert size changed")
ASSERT(SIZEOF(.cpu_after_game_number_convert) == 0x160, "cpu_after_game_number_convert size changed")
ASSERT(SIZEOF(.command_machine) == 0x80, "command_machine size changed")
ASSERT(SIZEOF(.cpu_after_command_machine) == 0x3838, "cpu_after_command_machine size changed")
ASSERT(SIZEOF(.sound_bridge_core) == 0x84, "sound_bridge_core size changed")
ASSERT(SIZEOF(.cpu_after_sound_bridge_core) == 0x8, "cpu_after_sound_bridge_core size changed")
ASSERT(SIZEOF(.sound_bridge_definitions) == 0x5c, "sound_bridge_definitions size changed")
ASSERT(SIZEOF(.cpu_after_sound_bridge_definitions) == 0xb0, "cpu_after_sound_bridge_definitions size changed")
ASSERT(SIZEOF(.sound_bridge_future_reset) == 0x8c, "sound_bridge_future_reset size changed")
ASSERT(SIZEOF(.sound_bridge_future_queue) == 0x90, "sound_bridge_future_queue size changed")
ASSERT(SIZEOF(.sound_bridge_future_update) == 0xb8, "sound_bridge_future_update size changed")
ASSERT(SIZEOF(.cpu_after_sound_bridge_future_update) == 0x1038, "cpu_after_sound_bridge_future_update size changed")
ASSERT(SIZEOF(.debug_context_set) == 0x10, "debug_context_set size changed")
ASSERT(SIZEOF(.cpu_after_debug_context_set) == 0x8, "cpu_after_debug_context_set size changed")
ASSERT(SIZEOF(.debug_text_draw) == 0xa8, "debug_text_draw size changed")
ASSERT(SIZEOF(.cpu_after_debug_text_draw) == 0x8, "cpu_after_debug_text_draw size changed")
ASSERT(SIZEOF(.tweak_reset) == 0x38, "tweak_reset size changed")
ASSERT(SIZEOF(.tweak_page) == 0x80, "tweak_page size changed")
ASSERT(SIZEOF(.tweak_define) == 0xa4, "tweak_define size changed")
ASSERT(SIZEOF(.cpu_after_tweak_define) == 0xd4, "cpu_after_tweak_define size changed")
ASSERT(SIZEOF(.tweak_difficulty_apply) == 0xe4, "tweak_difficulty_apply size changed")
ASSERT(SIZEOF(.cpu_after_tweak_difficulty_apply) == 0x1b8, "cpu_after_tweak_difficulty_apply size changed")
ASSERT(SIZEOF(.tweak_bind) == 0x84, "tweak_bind size changed")
ASSERT(SIZEOF(.tweak_bind_all) == 0x808, "tweak_bind_all size changed")
ASSERT(SIZEOF(.tweak_scale_enemy_speeds) == 0x168, "tweak_scale_enemy_speeds size changed")
ASSERT(SIZEOF(.resource_string_reset) == 0x34, "resource_string_reset size changed")
ASSERT(SIZEOF(.string_resource) == 0x34, "string_resource size changed")
ASSERT(SIZEOF(.resource_string_find) == 0xa0, "resource_string_find size changed")
ASSERT(SIZEOF(.resource_string_load) == 0xd4, "resource_string_load size changed")
ASSERT(SIZEOF(.cpu_after_resource_string_load) == 0xf54, "cpu_after_resource_string_load size changed")
ASSERT(SIZEOF(.rsp_boot) == 0xd0, "RSP boot size changed")
ASSERT(SIZEOF(.remainder) == 0x21b8, "remainder size changed")
ASSERT(SIZEOF(.scene_background_constants) == 0x8, "scene_background_constants size changed")
ASSERT(SIZEOF(.data_after_scene_background_constants) == 0x2724, "data_after_scene_background_constants size changed")
ASSERT(SIZEOF(.save_menu_status_tables) == 0x30, "save_menu_status_tables size changed")
ASSERT(SIZEOF(.data_after_save_menu_status_tables) == 0xb8, "data_after_save_menu_status_tables size changed")
ASSERT(SIZEOF(.command_machine_table) == 0x20, "command_machine_table size changed")
ASSERT(SIZEOF(.data_after_command_machine_table) == 0x154, "data_after_command_machine_table size changed")
ASSERT(SIZEOF(.sound_bridge_future_queue_strings) == 0x20, "sound_bridge_future_queue_strings size changed")
ASSERT(SIZEOF(.data_after_sound_bridge_future_queue_strings) == 0xc20, "data_after_sound_bridge_future_queue_strings size changed")
ASSERT(SIZEOF(.renderer_vertex_attributes_strings) == 0xf0, "renderer_vertex_attributes_strings size changed")
ASSERT(SIZEOF(.data_after_renderer_vertex_attributes_strings) == 0x1b8, "data_after_renderer_vertex_attributes_strings size changed")
ASSERT(SIZEOF(.graphics_resource_strings) == 0x14, "graphics_resource_strings size changed")
ASSERT(SIZEOF(.data_after_graphics_resource_strings) == 0x44, "data_after_graphics_resource_strings size changed")
ASSERT(SIZEOF(.graphics_pool_strings) == 0xe0, "graphics_pool_strings size changed")
ASSERT(SIZEOF(.graphics_mode_dispatch_table) == 0x60, "graphics_mode_dispatch_table size changed")
ASSERT(SIZEOF(.data_after_graphics_mode_dispatch_table) == 0x990, "data_after_graphics_mode_dispatch_table size changed")
ASSERT(SIZEOF(.sdk_gu_perspective_constants) == 0x10, "sdk_gu_perspective_constants size changed")
ASSERT(SIZEOF(.sdk_gu_lookathilite_constants) == 0x20, "sdk_gu_lookathilite_constants size changed")
ASSERT(SIZEOF(.sdk_gu_rotate_rpy_constants) == 0x10, "sdk_gu_rotate_rpy_constants size changed")
ASSERT(SIZEOF(.data_after_sdk_gu_rotate_rpy_constants) == 0x120, "data_after_sdk_gu_rotate_rpy_constants size changed")
ASSERT(SIZEOF(.sdk_audio_synthesizer_constants) == 0x10, "sdk_audio_synthesizer_constants size changed")
ASSERT(SIZEOF(.data_after_sdk_audio_synthesizer_constants) == 0x80, "data_after_sdk_audio_synthesizer_constants size changed")
ASSERT(SIZEOF(.sdk_audio_effect_init_constants) == 0x20, "sdk_audio_effect_init_constants size changed")
ASSERT(SIZEOF(.sdk_audio_resample_constants) == 0x34, "sdk_audio_resample_constants size changed")
ASSERT(SIZEOF(.data_after_sdk_audio_resample_constants) == 0xc, "data_after_sdk_audio_resample_constants size changed")
ASSERT(SIZEOF(.sdk_audio_envelope_constants) == 0x60, "sdk_audio_envelope_constants size changed")
ASSERT(SIZEOF(.sdk_audio_effect_constants) == 0x28, "sdk_audio_effect_constants size changed")
ASSERT(SIZEOF(.data_after_sdk_audio_effect_constants) == 0x769438, "data_after_sdk_audio_effect_constants size changed")
ASSERT(SIZEOF(.unexpected) == 0, "unmapped input data")

ASSERT(SIZEOF(.text_table) == 0x128, "text jump tables size changed")
ASSERT(SIZEOF(.data_before_text_table) == 0x8c40, "data_before_text_table size changed")
ASSERT(SIZEOF(.movie_commands_data) == 0x68, "movie_commands_data size changed")
ASSERT(SIZEOF(.data_after_movie_commands_data) == 0x16218, "data_after_movie_commands_data size changed")
ASSERT(SIZEOF(.sdk_pi_manager_data) == 0x1c, "sdk_pi_manager_data size changed")
ASSERT(SIZEOF(.data_after_sdk_pi_manager_data) == 0xd34, "data_after_sdk_pi_manager_data size changed")
ASSERT(SIZEOF(.sdk_random_data) == 0x4, "sdk_random_data size changed")
ASSERT(SIZEOF(.data_after_sdk_random_data) == 0xc, "data_after_sdk_random_data size changed")
ASSERT(SIZEOF(.sdk_controller_init_data) == 0x4, "sdk_controller_init_data size changed")
ASSERT(SIZEOF(.data_after_sdk_controller_init_data) == 0xc, "data_after_sdk_controller_init_data size changed")
ASSERT(SIZEOF(.sdk_vi_manager_data) == 0x1c, "sdk_vi_manager_data size changed")
ASSERT(SIZEOF(.data_after_sdk_vi_manager_data) == 0x4, "data_after_sdk_vi_manager_data size changed")
ASSERT(SIZEOF(.sdk_audio_globals_data) == 0x4, "sdk_audio_globals_data size changed")
ASSERT(SIZEOF(.data_after_sdk_audio_globals_data) == 0xfc, "data_after_sdk_audio_globals_data size changed")
ASSERT(SIZEOF(.sdk_audio_effect_init_data) == 0x190, "sdk_audio_effect_init_data size changed")
ASSERT(SIZEOF(.sdk_audio_envelope_data) == 0x140, "sdk_audio_envelope_data size changed")
ASSERT(SIZEOF(.data_after_sdk_audio_envelope_data) == 0x148, "data_after_sdk_audio_envelope_data size changed")

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
ASSERT(SIZEOF(.cpu_after_object_helpers_camera_position) == 0xa4, "cpu_after_object_helpers_camera_position size changed")
ASSERT(SIZEOF(.object_helpers_camera_position_alt) == 0xb8, "object_helpers_camera_position_alt size changed")
ASSERT(SIZEOF(.cpu_after_object_helpers_camera_position_alt) == 0xa0, "cpu_after_object_helpers_camera_position_alt size changed")
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
ASSERT(SIZEOF(.cpu_after_game_memory) == 0x34, "cpu_after_game_memory size changed")
ASSERT(SIZEOF(.game_string_case_compare) == 0x94, "game_string_case_compare size changed")
ASSERT(SIZEOF(.cpu_after_game_string_case_compare) == 0x12c, "cpu_after_game_string_case_compare size changed")
ASSERT(SIZEOF(.game_number_format) == 0x284, "game_number_format size changed")
ASSERT(SIZEOF(.game_character) == 0x1a0, "game_character size changed")
ASSERT(SIZEOF(.game_integer_parse) == 0x9c, "game_integer_parse size changed")
ASSERT(SIZEOF(.cpu_after_game_integer_parse) == 0x174, "cpu_after_game_integer_parse size changed")
ASSERT(SIZEOF(.platform_empty) == 0x90, "platform_empty size changed")
ASSERT(SIZEOF(.palette) == 0x194, "palette size changed")
ASSERT(SIZEOF(.controller_button) == 0x28, "controller_button size changed")
ASSERT(SIZEOF(.cpu_after_controller_button) == 0x320, "cpu_after_controller_button size changed")
ASSERT(SIZEOF(.controller_axes) == 0xfc, "controller_axes size changed")
ASSERT(SIZEOF(.platform_io) == 0xf4, "platform_io size changed")
ASSERT(SIZEOF(.cpu_after_platform_io) == 0x534, "cpu_after_platform_io size changed")
ASSERT(SIZEOF(.object_recovery_path_extension) == 0x44, "object_recovery_path_extension size changed")
ASSERT(SIZEOF(.geometry_debug_bridge) == 0x28, "geometry_debug_bridge size changed")
ASSERT(SIZEOF(.object_recovery_fixed_trig) == 0x90, "object_recovery_fixed_trig size changed")
ASSERT(SIZEOF(.object_recovery_integer_sqrt) == 0x64, "object_recovery_integer_sqrt size changed")
ASSERT(SIZEOF(.object_recovery_angle_scale) == 0x24, "object_recovery_angle_scale size changed")
ASSERT(SIZEOF(.object_recovery_direction_angle) == 0x184, "object_recovery_direction_angle size changed")
ASSERT(SIZEOF(.object_recovery_angle_table) == 0x94, "object_recovery_angle_table size changed")
ASSERT(SIZEOF(.cpu_after_object_recovery_angle_table) == 0x1e8, "cpu_after_object_recovery_angle_table size changed")
ASSERT(SIZEOF(.geometry_bridge_apply) == 0x9c, "geometry_bridge_apply size changed")
ASSERT(SIZEOF(.geometry_bridge_rotate) == 0xb4, "geometry_bridge_rotate size changed")
ASSERT(SIZEOF(.cpu_after_geometry_bridge_rotate) == 0x6670, "cpu_after_geometry_bridge_rotate size changed")
ASSERT(SIZEOF(.renderer_vertex_attributes) == 0x438, "renderer_vertex_attributes size changed")
ASSERT(SIZEOF(.renderer_material_texture) == 0x118, "renderer_material_texture size changed")
ASSERT(SIZEOF(.renderer_material_light) == 0x6c, "renderer_material_light size changed")
ASSERT(SIZEOF(.renderer_material_combined) == 0x290, "renderer_material_combined size changed")
ASSERT(SIZEOF(.renderer_light_select) == 0x54, "renderer_light_select size changed")
ASSERT(SIZEOF(.renderer_material_untextured) == 0xa0, "renderer_material_untextured size changed")
ASSERT(SIZEOF(.cpu_after_renderer_material_untextured) == 0x12a4, "cpu_after_renderer_material_untextured size changed")
ASSERT(SIZEOF(.renderer_material_reset) == 0x20, "renderer_material_reset size changed")
ASSERT(SIZEOF(.cpu_after_renderer_material_reset) == 0xa0c, "cpu_after_renderer_material_reset size changed")
ASSERT(SIZEOF(.renderer_vertex_copy) == 0x39c, "renderer_vertex_copy size changed")
ASSERT(SIZEOF(.renderer_texture_load) == 0x218, "renderer_texture_load size changed")
ASSERT(SIZEOF(.graphics_display_list) == 0x48, "graphics_display_list size changed")
ASSERT(SIZEOF(.graphics_resource) == 0x70, "graphics_resource size changed")
ASSERT(SIZEOF(.cpu_after_graphics_resource) == 0x4, "cpu_after_graphics_resource size changed")
ASSERT(SIZEOF(.palette_tint) == 0x58, "palette_tint size changed")
ASSERT(SIZEOF(.graphics_modes) == 0x624, "graphics_modes size changed")
ASSERT(SIZEOF(.cpu_after_graphics_modes) == 0xcc, "cpu_after_graphics_modes size changed")
ASSERT(SIZEOF(.graphics_lights) == 0x258, "graphics_lights size changed")
ASSERT(SIZEOF(.graphics_pool) == 0x1a4, "graphics_pool size changed")
ASSERT(SIZEOF(.cpu_after_graphics_pool) == 0x88, "cpu_after_graphics_pool size changed")
ASSERT(SIZEOF(.graphics_frame_reset) == 0x120, "graphics_frame_reset size changed")
ASSERT(SIZEOF(.graphics_mode_dispatch) == 0x21c, "graphics_mode_dispatch size changed")
ASSERT(SIZEOF(.graphics_environment) == 0xb0, "graphics_environment size changed")
ASSERT(SIZEOF(.cpu_after_graphics_environment) == 0xc08, "cpu_after_graphics_environment size changed")
ASSERT(SIZEOF(.startup) == 0x3a0, "startup functions size changed")
ASSERT(SIZEOF(.cpu_after_startup) == 0x4e4, "CPU fallback after startup size changed")
ASSERT(SIZEOF(.frame_render) == 0x198, "frame submission size changed")
ASSERT(SIZEOF(.frame_helpers) == 0x234, "frame helpers size changed")
ASSERT(SIZEOF(.debug_noop) == 0x1c, "debug_noop size changed")
ASSERT(SIZEOF(.cpu_after_debug_noop) == 0x738, "cpu_after_debug_noop size changed")
ASSERT(SIZEOF(.frame_matrices) == 0xa8, "frame matrix commands size changed")
ASSERT(SIZEOF(.frame_timing) == 0x124, "frame timing size changed")
ASSERT(SIZEOF(.cpu_after_frame_timing) == 0x200, "CPU fallback after frame timing size changed")
ASSERT(SIZEOF(.graphics_ucode) == 0xc, "graphics microcode selector size changed")
ASSERT(SIZEOF(.cpu_after_graphics_ucode) == 0x27a4, "cpu_after_graphics_ucode size changed")
ASSERT(SIZEOF(.controller_legacy_initialize) == 0x44, "controller_legacy_initialize size changed")
ASSERT(SIZEOF(.cpu_after_controller_legacy_initialize) == 0xf4, "cpu_after_controller_legacy_initialize size changed")
ASSERT(SIZEOF(.controller_legacy_present) == 0x18, "controller_legacy_present size changed")
ASSERT(SIZEOF(.cpu_after_controller_legacy_present) == 0x198, "cpu_after_controller_legacy_present size changed")
ASSERT(SIZEOF(.pak_file_status) == 0x34, "pak_file_status size changed")
ASSERT(SIZEOF(.pak_file_open) == 0x1b8, "pak_file_open size changed")
ASSERT(SIZEOF(.pak_file_read) == 0x78, "pak_file_read size changed")
ASSERT(SIZEOF(.pak_file_write) == 0x6c, "pak_file_write size changed")
ASSERT(SIZEOF(.pak_file_close) == 0x14, "pak_file_close size changed")
ASSERT(SIZEOF(.pak_file_encode_name) == 0x80, "pak_file_encode_name size changed")
ASSERT(SIZEOF(.cpu_after_pak_file_encode_name) == 0x7f4, "cpu_after_pak_file_encode_name size changed")
ASSERT(SIZEOF(.fixed_geometry_setup) == 0x5e4, "fixed_geometry_setup size changed")
ASSERT(SIZEOF(.frame_transform) == 0xe8, "frame transform size changed")
ASSERT(SIZEOF(.fixed_geometry) == 0x598, "fixed-point geometry size changed")
ASSERT(SIZEOF(.fixed_math) == 0x134, "fixed-point math size changed")
ASSERT(SIZEOF(.cpu_after_fixed_math) == 0x8, "cpu_after_fixed_math size changed")
ASSERT(SIZEOF(.heap) == 0x21c, "heap size changed")
ASSERT(SIZEOF(.cpu_after_heap) == 0x4c, "cpu_after_heap size changed")
ASSERT(SIZEOF(.heap_empty) == 0x8, "heap_empty size changed")
ASSERT(SIZEOF(.cpu_after_heap_empty) == 0x288, "cpu_after_heap_empty size changed")
ASSERT(SIZEOF(.object_history) == 0x58, "object_history size changed")
ASSERT(SIZEOF(.cpu_after_object_history) == 0x9c0, "cpu_after_object_history size changed")
ASSERT(SIZEOF(.rom_directory) == 0x194, "rom_directory size changed")
ASSERT(SIZEOF(.rom_file_error) == 0x64, "rom_file_error size changed")
ASSERT(SIZEOF(.rom_files) == 0x230, "rom_files size changed")
ASSERT(SIZEOF(.cpu_after_rom_files) == 0x8, "cpu_after_rom_files size changed")
ASSERT(SIZEOF(.controller_access) == 0xbc, "controller_access size changed")
ASSERT(SIZEOF(.cpu_after_controller_access) == 0x10c, "cpu_after_controller_access size changed")
ASSERT(SIZEOF(.controller_motor_commands) == 0x74, "controller_motor_commands size changed")
ASSERT(SIZEOF(.controller_scan) == 0x144, "controller_scan size changed")
ASSERT(SIZEOF(.cpu_after_controller_scan) == 0x660, "cpu_after_controller_scan size changed")
ASSERT(SIZEOF(.controller_pak_info) == 0x84, "controller_pak_info size changed")
ASSERT(SIZEOF(.controller_pak_delete) == 0xac, "controller_pak_delete size changed")
ASSERT(SIZEOF(.controller_pak_name) == 0x88, "controller_pak_name size changed")
ASSERT(SIZEOF(.cpu_after_controller_pak_name) == 0x150, "cpu_after_controller_pak_name size changed")
ASSERT(SIZEOF(.controller_pak_directory) == 0x16c, "controller_pak_directory size changed")
ASSERT(SIZEOF(.cpu_after_controller_pak_directory) == 0xc, "cpu_after_controller_pak_directory size changed")
ASSERT(SIZEOF(.graphics_setup) == 0x98, "graphics setup size changed")
ASSERT(SIZEOF(.graphics_pacing) == 0x1dc, "graphics pacing fallback size changed")
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
ASSERT(SIZEOF(.cpu_after_audio_task_build) == 0x1d4, "cpu_after_audio_task_build size changed")
ASSERT(SIZEOF(.audio_pool_callback) == 0x34, "audio_pool_callback size changed")
ASSERT(SIZEOF(.cpu_after_audio_pool_callback) == 0x150, "cpu_after_audio_pool_callback size changed")
ASSERT(SIZEOF(.audio_shutdown) == 0x2c, "audio_shutdown size changed")
ASSERT(SIZEOF(.cpu_after_audio_shutdown) == 0x4, "cpu_after_audio_shutdown size changed")
ASSERT(SIZEOF(.audio_callback_registration) == 0x54, "audio_callback_registration size changed")
ASSERT(SIZEOF(.audio_callback_return) == 0x20, "audio_callback_return size changed")
ASSERT(SIZEOF(.cpu_after_audio_callback_return) == 0xc, "cpu_after_audio_callback_return size changed")
ASSERT(SIZEOF(.audio_config) == 0x280, "audio_config size changed")
ASSERT(SIZEOF(.audio_control) == 0x370, "audio control size changed")
ASSERT(SIZEOF(.cpu_after_audio_control) == 0xee0, "cpu_after_audio_control size changed")
ASSERT(SIZEOF(.audio_play) == 0x70, "audio_play size changed")
ASSERT(SIZEOF(.cpu_after_audio_play) == 0xec, "cpu_after_audio_play size changed")
ASSERT(SIZEOF(.audio_instance_stop) == 0x110, "audio_instance_stop size changed")
ASSERT(SIZEOF(.audio_stop_commands) == 0xbc, "audio_stop_commands size changed")
ASSERT(SIZEOF(.audio_voice_stop) == 0x200, "audio_voice_stop size changed")
ASSERT(SIZEOF(.audio_instance_stop_all) == 0xf0, "audio_instance_stop_all size changed")
ASSERT(SIZEOF(.audio_stop_all_commands) == 0x9c, "audio_stop_all_commands size changed")
ASSERT(SIZEOF(.audio_voice_stop_all) == 0x1ec, "audio_voice_stop_all size changed")
ASSERT(SIZEOF(.cpu_after_audio_voice_stop_all) == 0x230, "cpu_after_audio_voice_stop_all size changed")
ASSERT(SIZEOF(.audio_level_commands) == 0xdc, "audio_level_commands size changed")
ASSERT(SIZEOF(.audio_level_update) == 0x1e0, "audio_level_update size changed")
ASSERT(SIZEOF(.audio_level_commands_alt) == 0x6c, "audio_level_commands_alt size changed")
ASSERT(SIZEOF(.audio_level_update_alt) == 0x1dc, "audio_level_update_alt size changed")
ASSERT(SIZEOF(.audio_mode) == 0x20, "audio_mode size changed")
ASSERT(SIZEOF(.cpu_after_audio_mode) == 0xb1c, "cpu_after_audio_mode size changed")
ASSERT(SIZEOF(.audio_play_arguments) == 0x9c, "audio_play_arguments size changed")
ASSERT(SIZEOF(.cpu_after_audio_play_arguments) == 0x3160, "cpu_after_audio_play_arguments size changed")
ASSERT(SIZEOF(.audio_command_lock) == 0x80, "audio_command_lock size changed")
ASSERT(SIZEOF(.cpu_after_audio_command_lock) == 0x8e4, "cpu_after_audio_command_lock size changed")
ASSERT(SIZEOF(.audio_command_queue) == 0x240, "audio_command_queue size changed")
ASSERT(SIZEOF(.cpu_after_audio_command_queue) == 0x66b0, "cpu_after_audio_command_queue size changed")
ASSERT(SIZEOF(.gu_sine) == 0x70, "gu_sine size changed")
ASSERT(SIZEOF(.gu_cosine) == 0x30, "gu_cosine size changed")
ASSERT(SIZEOF(.cpu_after_gu_cosine) == 0x290, "cpu_after_gu_cosine size changed")
ASSERT(SIZEOF(.pi_raw_read) == 0x54, "pi_raw_read size changed")
ASSERT(SIZEOF(.cpu_after_pi_raw_read) == 0xc, "cpu_after_pi_raw_read size changed")
ASSERT(SIZEOF(.thread_create) == 0x144, "thread_create size changed")
ASSERT(SIZEOF(.cpu_after_thread_create) == 0xc, "cpu_after_thread_create size changed")
ASSERT(SIZEOF(.thread_start) == 0x150, "thread_start size changed")
ASSERT(SIZEOF(.pi_manager_create) == 0x188, "pi_manager_create size changed")
ASSERT(SIZEOF(.cpu_after_pi_manager_create) == 0x8, "cpu_after_pi_manager_create size changed")
ASSERT(SIZEOF(.thread_priority) == 0xe0, "thread_priority size changed")
ASSERT(SIZEOF(.message_queue_create) == 0x2c, "message_queue_create size changed")
ASSERT(SIZEOF(.cpu_after_message_queue_create) == 0x64, "cpu_after_message_queue_create size changed")
ASSERT(SIZEOF(.vi_features) == 0x1b8, "vi_features size changed")
ASSERT(SIZEOF(.cpu_after_vi_features) == 0x8, "cpu_after_vi_features size changed")
ASSERT(SIZEOF(.virtual_to_physical) == 0x7c, "virtual_to_physical size changed")
ASSERT(SIZEOF(.cpu_after_virtual_to_physical) == 0x34, "cpu_after_virtual_to_physical size changed")
ASSERT(SIZEOF(.gu_perspective) == 0x288, "gu_perspective size changed")
ASSERT(SIZEOF(.cpu_after_gu_perspective) == 0x8, "cpu_after_gu_perspective size changed")
ASSERT(SIZEOF(.gu_lookathilite) == 0x824, "gu_lookathilite size changed")
ASSERT(SIZEOF(.cpu_after_gu_lookathilite) == 0xc, "cpu_after_gu_lookathilite size changed")
ASSERT(SIZEOF(.gu_translate) == 0x9c, "gu_translate size changed")
ASSERT(SIZEOF(.cpu_after_gu_translate) == 0x4, "cpu_after_gu_translate size changed")
ASSERT(SIZEOF(.gu_rotate_rpy) == 0x194, "gu_rotate_rpy size changed")
ASSERT(SIZEOF(.cpu_after_gu_rotate_rpy) == 0xc, "cpu_after_gu_rotate_rpy size changed")
ASSERT(SIZEOF(.time_get) == 0x84, "time_get size changed")
ASSERT(SIZEOF(.cpu_after_time_get) == 0xc, "cpu_after_time_get size changed")
ASSERT(SIZEOF(.compiler_arithmetic) == 0x2c0, "compiler_arithmetic size changed")
ASSERT(SIZEOF(.cpu_after_compiler_arithmetic) == 0x260, "cpu_after_compiler_arithmetic size changed")
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
ASSERT(SIZEOF(.cpu_after_gu_random) == 0x14, "cpu_after_gu_random size changed")
ASSERT(SIZEOF(.gu_sine_float) == 0x1c0, "gu_sine_float size changed")
ASSERT(SIZEOF(.gu_cosine_float) == 0x168, "gu_cosine_float size changed")
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
ASSERT(SIZEOF(.vi_vertical_scale) == 0x58, "vi_vertical_scale size changed")
ASSERT(SIZEOF(.cpu_after_vi_vertical_scale) == 0x8, "cpu_after_vi_vertical_scale size changed")
ASSERT(SIZEOF(.vi_manager) == 0x354, "vi_manager size changed")
ASSERT(SIZEOF(.cpu_after_vi_manager) == 0xc, "cpu_after_vi_manager size changed")
ASSERT(SIZEOF(.vi_mode) == 0x68, "vi_mode size changed")
ASSERT(SIZEOF(.cpu_after_vi_mode) == 0x8, "cpu_after_vi_mode size changed")
ASSERT(SIZEOF(.vi_black) == 0x70, "vi_black size changed")
ASSERT(SIZEOF(.vi_event) == 0x6c, "vi_event size changed")
ASSERT(SIZEOF(.cpu_after_vi_event) == 0xa4, "cpu_after_vi_event size changed")
ASSERT(SIZEOF(.sp_yield) == 0x20, "sp_yield size changed")
ASSERT(SIZEOF(.sp_yielded) == 0x80, "sp_yielded size changed")
ASSERT(SIZEOF(.sp_task) == 0x2ac, "sp_task size changed")
ASSERT(SIZEOF(.audio_sp) == 0x40, "audio_sp size changed")
ASSERT(SIZEOF(.cpu_after_audio_sp) == 0x4, "cpu_after_audio_sp size changed")
ASSERT(SIZEOF(.audio_vi) == 0xd0, "audio_vi size changed")
ASSERT(SIZEOF(.audio_heap_init) == 0x34, "audio_heap_init size changed")
ASSERT(SIZEOF(.cpu_after_audio_heap_init) == 0xc, "cpu_after_audio_heap_init size changed")
ASSERT(SIZEOF(.audio_heap_alloc) == 0x54, "audio_heap_alloc size changed")
ASSERT(SIZEOF(.cpu_after_audio_heap_alloc) == 0xbc, "cpu_after_audio_heap_alloc size changed")
ASSERT(SIZEOF(.pi_start_dma) == 0x10c, "pi_start_dma size changed")
ASSERT(SIZEOF(.cpu_after_pi_start_dma) == 0x4, "cpu_after_pi_start_dma size changed")
ASSERT(SIZEOF(.ai_frequency) == 0x160, "ai_frequency size changed")
ASSERT(SIZEOF(.audio_globals) == 0xc0, "audio_globals size changed")
ASSERT(SIZEOF(.ai_buffer) == 0xa8, "ai_buffer size changed")
ASSERT(SIZEOF(.cpu_after_ai_buffer) == 0x8, "cpu_after_ai_buffer size changed")
ASSERT(SIZEOF(.ai_length) == 0xc, "ai_length size changed")
ASSERT(SIZEOF(.cpu_after_ai_length) == 0x4, "cpu_after_ai_length size changed")
ASSERT(SIZEOF(.audio_synthesizer) == 0x6e0, "audio_synthesizer size changed")
ASSERT(SIZEOF(.audio_synth_player) == 0x50, "audio_synth_player size changed")
ASSERT(SIZEOF(.audio_synth_allocate) == 0x228, "audio_synth_allocate size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_allocate) == 0x8, "cpu_after_audio_synth_allocate size changed")
ASSERT(SIZEOF(.audio_synth_start) == 0xe4, "audio_synth_start size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_start) == 0xc, "cpu_after_audio_synth_start size changed")
ASSERT(SIZEOF(.audio_synth_pitch) == 0x84, "audio_synth_pitch size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_pitch) == 0xc, "cpu_after_audio_synth_pitch size changed")
ASSERT(SIZEOF(.audio_synth_volume) == 0x9c, "audio_synth_volume size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_volume) == 0x4, "cpu_after_audio_synth_volume size changed")
ASSERT(SIZEOF(.audio_synth_pan) == 0x84, "audio_synth_pan size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_pan) == 0xc, "cpu_after_audio_synth_pan size changed")
ASSERT(SIZEOF(.audio_synth_stop) == 0x78, "audio_synth_stop size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_stop) == 0x8, "cpu_after_audio_synth_stop size changed")
ASSERT(SIZEOF(.audio_synth_free_voice) == 0xb0, "audio_synth_free_voice size changed")
ASSERT(SIZEOF(.audio_synth_priority) == 0x10, "audio_synth_priority size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_priority) == 0x30, "cpu_after_audio_synth_priority size changed")
ASSERT(SIZEOF(.si_raw_read) == 0x50, "si_raw_read size changed")
ASSERT(SIZEOF(.si_raw_write) == 0x4c, "si_raw_write size changed")
ASSERT(SIZEOF(.cpu_after_si_raw_write) == 0xd84, "cpu_after_si_raw_write size changed")
ASSERT(SIZEOF(.pi_access) == 0xc0, "pi_access size changed")
ASSERT(SIZEOF(.thread_get_priority) == 0x18, "thread_get_priority size changed")
ASSERT(SIZEOF(.cpu_after_thread_get_priority) == 0x8, "cpu_after_thread_get_priority size changed")
ASSERT(SIZEOF(.pi_raw_dma) == 0xe0, "pi_raw_dma size changed")
ASSERT(SIZEOF(.epi_dma) == 0x224, "epi_dma size changed")
ASSERT(SIZEOF(.cpu_after_epi_dma) == 0x69c, "cpu_after_epi_dma size changed")
ASSERT(SIZEOF(.gu_mtxutil) == 0x26c, "gu_mtxutil size changed")
ASSERT(SIZEOF(.cpu_after_gu_mtxutil) == 0x14, "cpu_after_gu_mtxutil size changed")
ASSERT(SIZEOF(.timer_init) == 0x8c, "timer_init size changed")
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
ASSERT(SIZEOF(.timer_set) == 0xd4, "timer_set size changed")
ASSERT(SIZEOF(.cpu_after_timer_set) == 0xc, "cpu_after_timer_set size changed")
ASSERT(SIZEOF(.vi_context) == 0xc, "vi_context size changed")
ASSERT(SIZEOF(.cpu_after_vi_context) == 0x364, "cpu_after_vi_context size changed")
ASSERT(SIZEOF(.sp_set_status) == 0xc, "sp_set_status size changed")
ASSERT(SIZEOF(.cpu_after_sp_set_status) == 0x4, "cpu_after_sp_set_status size changed")
ASSERT(SIZEOF(.sp_get_status) == 0xc, "sp_get_status size changed")
ASSERT(SIZEOF(.cpu_after_sp_get_status) == 0x314, "cpu_after_sp_get_status size changed")
ASSERT(SIZEOF(.sp_set_pc) == 0x34, "sp_set_pc size changed")
ASSERT(SIZEOF(.cpu_after_sp_set_pc) == 0xc, "cpu_after_sp_set_pc size changed")
ASSERT(SIZEOF(.sp_dma) == 0x8c, "sp_dma size changed")
ASSERT(SIZEOF(.cpu_after_sp_dma) == 0x4, "cpu_after_sp_dma size changed")
ASSERT(SIZEOF(.sp_busy) == 0x2c, "sp_busy size changed")
ASSERT(SIZEOF(.cpu_after_sp_busy) == 0x4, "cpu_after_sp_busy size changed")
ASSERT(SIZEOF(.message_jam) == 0x150, "message_jam size changed")
ASSERT(SIZEOF(.pi_get_queue) == 0x28, "pi_get_queue size changed")
ASSERT(SIZEOF(.cpu_after_pi_get_queue) == 0x8, "cpu_after_pi_get_queue size changed")
ASSERT(SIZEOF(.audio_synth_delete) == 0x8, "audio_synth_delete size changed")
ASSERT(SIZEOF(.cpu_after_audio_synth_delete) == 0x8, "cpu_after_audio_synth_delete size changed")
ASSERT(SIZEOF(.ai_busy) == 0x30, "ai_busy size changed")
ASSERT(SIZEOF(.audio_filter_constructors) == 0x360, "audio_filter_constructors size changed")
ASSERT(SIZEOF(.audio_effect_init) == 0x43c, "audio_effect_init size changed")
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
ASSERT(SIZEOF(.audio_aux_bus) == 0x108, "audio_aux_bus size changed")
ASSERT(SIZEOF(.cpu_after_audio_aux_bus) == 0x8, "cpu_after_audio_aux_bus size changed")
ASSERT(SIZEOF(.audio_save) == 0xc0, "audio_save size changed")
ASSERT(SIZEOF(.si_busy) == 0x2c, "si_busy size changed")
ASSERT(SIZEOF(.cpu_after_si_busy) == 0x790, "cpu_after_si_busy size changed")
ASSERT(SIZEOF(.pi_event) == 0xec, "pi_event size changed")
ASSERT(SIZEOF(.cpu_after_pi_event) == 0x8, "cpu_after_pi_event size changed")
ASSERT(SIZEOF(.thread_destroy) == 0xf8, "thread_destroy size changed")
ASSERT(SIZEOF(.cpu_after_thread_destroy) == 0x8, "cpu_after_thread_destroy size changed")
ASSERT(SIZEOF(.interrupt_global_clear) == 0x58, "interrupt_global_clear size changed")
ASSERT(SIZEOF(.cpu_after_interrupt_global_clear) == 0x8, "cpu_after_interrupt_global_clear size changed")
ASSERT(SIZEOF(.epi_raw_write) == 0x4c, "epi_raw_write size changed")
ASSERT(SIZEOF(.cpu_after_epi_raw_write) == 0x4, "cpu_after_epi_raw_write size changed")
ASSERT(SIZEOF(.epi_raw_read) == 0x50, "epi_raw_read size changed")
ASSERT(SIZEOF(.interrupt_global_set) == 0x4c, "interrupt_global_set size changed")
ASSERT(SIZEOF(.cpu_after_interrupt_global_set) == 0x4, "cpu_after_interrupt_global_set size changed")
ASSERT(SIZEOF(.thread_yield) == 0x4c, "thread_yield size changed")
ASSERT(SIZEOF(.cpu_after_thread_yield) == 0x14, "cpu_after_thread_yield size changed")
ASSERT(SIZEOF(.audio_filter_init) == 0x1c, "audio_filter_init size changed")
ASSERT(SIZEOF(.cpu_after_audio_filter_init) == 0x4, "cpu_after_audio_filter_init size changed")
ASSERT(SIZEOF(.audio_effect_modulation) == 0xa8, "audio_effect_modulation size changed")
ASSERT(SIZEOF(.audio_effect_buffers) == 0x5f0, "audio_effect_buffers size changed")
ASSERT(SIZEOF(.audio_effect_parameters) == 0x25c, "audio_effect_parameters size changed")
ASSERT(SIZEOF(.audio_effect_source) == 0x18, "audio_effect_source size changed")
ASSERT(SIZEOF(.audio_effect_pull) == 0x340, "audio_effect_pull size changed")
ASSERT(SIZEOF(.cpu_after_audio_effect_pull) == 0x4, "cpu_after_audio_effect_pull size changed")
ASSERT(SIZEOF(.audio_copy) == 0x74, "audio_copy size changed")
ASSERT(SIZEOF(.cpu_after_audio_copy) == 0xc, "cpu_after_audio_copy size changed")
