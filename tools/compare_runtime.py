"""Recompile the recovered runtime blocks and report any instruction differences."""

import argparse
import json

from compare_startup import SymbolLayoutSnapshot, compare_block
from rom import ROOT, validate
from toolchain import install


MATCHING_BLOCKS = (
    ("movie_reset", "src/game/movie_reset.c", 0x80002EE0, 0x80002F28),
    ("movie_parameters", "src/game/movie_parameters.c", 0x80002F28, 0x80003040),
    ("movie_commands", "src/game/movie_commands.c", 0x80003040, 0x800037F8),
    ("movie_channels", "src/game/movie_channels.c", 0x800037F8, 0x80003A7C),
    ("movie_track_release", "src/game/movie_track_release.c", 0x80003D74, 0x80003ECC),
    ("movie_sample", "src/game/movie_sample.c", 0x80004098, 0x80004258),
    ("movie_callback", "src/game/movie_callback.c", 0x8000440C, 0x800044AC),
    ("movie_prepare", "src/game/movie_prepare.c", 0x800044AC, 0x800045E4),
    ("movie_start", "src/game/movie_start.c", 0x800045E4, 0x80004C3C),
    ("movie_status", "src/game/movie_status.c", 0x80005354, 0x8000544C),
    ("movie_cleanup", "src/game/movie_cleanup.c", 0x8000544C, 0x80005560),
    ("scene_audio_request", "src/game/scene_audio_request.c", 0x8001F8E8, 0x8001F90C),
    ("actor_pool_reset", "src/game/actor_pool_reset.c", 0x8002818C, 0x800281C4),
    ("actor_cleanup", "src/game/actor_cleanup.c", 0x800281C4, 0x80028274),
    ("actor_remove", "src/game/actor_remove.c", 0x80028274, 0x8002836C),
    ("actor_sweep", "src/game/actor_sweep.c", 0x8002836C, 0x800283D4),
    ("command_machine", "src/game/command_machine.c", 0x800327AC, 0x8003282C),
    ("string_resource", "src/game/string_resource.c", 0x800383C4, 0x800383F8),
    ("object_helpers", "src/game/object_helpers.c", 0x80039C78, 0x80039CD0),
    ("object_helpers_index_limit", "src/game/object_helpers_index_limit.c", 0x80039CD0, 0x80039D4C),
    ("object_helpers_index_set", "src/game/object_helpers_index_set.c", 0x80039D4C, 0x80039DAC),
    ("object_helpers_properties", "src/game/object_helpers_properties.c", 0x80039DAC, 0x80039EA0),
    ("object_helpers_camera_state", "src/game/object_helpers_camera_state.c", 0x80039EA0, 0x80039F10),
    ("object_helpers_camera_position", "src/game/object_helpers_camera_position.c", 0x80039F10, 0x80039FCC),
    ("object_helpers_camera_position_alt", "src/game/object_helpers_camera_position_alt.c", 0x8003A070, 0x8003A128),
    ("object_helpers_camera_accessors", "src/game/object_helpers_camera_accessors.c", 0x8003A1C8, 0x8003A2F8),
    ("object_helpers_pool_alloc", "src/game/object_helpers_pool_alloc.c", 0x8003A2F8, 0x8003A3F8),
    ("object_helpers_pool_status", "src/game/object_helpers_pool_status.c", 0x8003A3F8, 0x8003A460),
    ("object_reset", "src/game/object_reset.c", 0x8003A460, 0x8003A4EC),
    ("object_helpers_draw_noop", "src/game/object_helpers_draw_noop.c", 0x8003A4EC, 0x8003A4F4),
    ("object_helpers_draw", "src/game/object_helpers_draw.c", 0x8003A4F4, 0x8003A778),
    ("object_helpers_draw_mode", "src/game/object_helpers_draw_mode.c", 0x8003A778, 0x8003A8B0),
    ("object_runtime_service", "src/game/object_runtime_service.c", 0x8003B254, 0x8003B2B0),
    ("object_runtime_active", "src/game/object_runtime_active.c", 0x8003B428, 0x8003B4C0),
    ("game_memory", "src/game/game_memory.c", 0x8003B4C0, 0x8003B734),
    ("game_string_case_compare", "src/game/game_string_case_compare.c", 0x8003B768, 0x8003B7FC),
    ("game_number_format", "src/game/game_number_format.c", 0x8003B928, 0x8003BBAC),
    ("game_character", "src/game/game_character.c", 0x8003BBAC, 0x8003BD4C),
    ("game_integer_parse", "src/game/game_integer_parse.c", 0x8003BD4C, 0x8003BDE8),
    ("platform_empty", "src/game/platform_empty.c", 0x8003BF5C, 0x8003BFEC),
    ("palette", "src/game/palette.c", 0x8003BFEC, 0x8003C180),
    ("controller_button", "src/game/controller_button.c", 0x8003C180, 0x8003C1A8),
    ("controller_axes", "src/game/controller_axes.c", 0x8003C4C8, 0x8003C5C4),
    ("platform_io", "src/game/platform_io.c", 0x8003C5C4, 0x8003C6B8),
    ("object_recovery_path_extension", "src/game/object_recovery_path_extension.c", 0x8003CBEC, 0x8003CC30),
    ("object_recovery_fixed_trig", "src/game/object_recovery_fixed_trig.c", 0x8003CC58, 0x8003CCE8),
    ("object_recovery_integer_sqrt", "src/game/object_recovery_integer_sqrt.c", 0x8003CCE8, 0x8003CD4C),
    ("object_recovery_angle_scale", "src/game/object_recovery_angle_scale.c", 0x8003CD4C, 0x8003CD70),
    ("object_recovery_direction_angle", "src/game/object_recovery_direction_angle.c", 0x8003CD70, 0x8003CEF4),
    ("object_recovery_angle_table", "src/game/object_recovery_angle_table.c", 0x8003CEF4, 0x8003CF88),
    ("palette_tint", "src/game/palette_tint.c", 0x800465B0, 0x80046608),
    ("frame_render", "src/boot/frame_render.c", 0x800489F4, 0x80048B8C),
    ("frame_helpers", "src/boot/frame_helpers.c", 0x80048B8C, 0x80048DC0),
    ("debug_noop", "src/game/debug_noop.c", 0x80048DC0, 0x80048DDC),
    ("frame_matrices", "src/boot/frame_matrices.c", 0x80049514, 0x800495BC),
    ("frame_timing", "src/boot/frame_timing.c", 0x800495BC, 0x800496E0),
    ("graphics_ucode", "src/boot/graphics_ucode.c", 0x800498E0, 0x800498EC),
    ("fixed_geometry_setup", "src/game/fixed_geometry_setup.c", 0x8004CED0, 0x8004D4B4),
    ("frame_transform", "src/game/frame_transform.c", 0x8004D4B4, 0x8004D59C),
    ("fixed_geometry", "src/game/fixed_geometry.c", 0x8004D59C, 0x8004DB34),
    ("fixed_math", "src/game/fixed_math.c", 0x8004DB34, 0x8004DC68),
    ("heap", "src/game/heap.c", 0x8004DC70, 0x8004DE8C),
    ("heap_empty", "src/game/heap_empty.c", 0x8004DED8, 0x8004DEE0),
    ("object_history", "src/game/object_history.c", 0x8004E168, 0x8004E1C0),
    ("rom_directory", "src/game/rom_directory.c", 0x8004EB80, 0x8004ED14),
    ("rom_file_error", "src/game/rom_file_error.c", 0x8004ED14, 0x8004ED78),
    ("rom_files", "src/game/rom_files.c", 0x8004ED78, 0x8004EFA8),
    ("graphics_setup", "src/boot/graphics_setup.c", 0x8004FE10, 0x8004FEA8),
    ("graphics_tasks", "src/boot/graphics_tasks.c", 0x80050084, 0x80050440),
    ("scheduler", "src/boot/scheduler.c", 0x80050440, 0x80050FB0),
    ("scheduler_runtime_tail", "src/boot/scheduler_runtime_tail.c", 0x80050FB0, 0x8005109C),
    ("audio_startup", "src/game/audio_startup.c", 0x8005109C, 0x80051380),
    ("audio_thread", "src/game/audio_thread.c", 0x80051380, 0x800515B0),
    ("audio_generation", "src/game/audio_generation.c", 0x800515B0, 0x80051854),
    ("audio_game_helpers", "src/game/audio_game_helpers.c", 0x80051854, 0x800518E0),
    ("audio_io", "src/game/audio_io.c", 0x800518E0, 0x80051A0C),
    ("audio_task_select", "src/game/audio_task_select.c", 0x8005211C, 0x800521C8),
    ("audio_task_build", "src/game/audio_task_build.c", 0x800521C8, 0x80052378),
    ("audio_pool_callback", "src/game/audio_pool_callback.c", 0x8005254C, 0x80052580),
    ("audio_shutdown", "src/game/audio_shutdown.c", 0x800526D0, 0x800526FC),
    ("audio_callback_registration", "src/game/audio_callback_registration.c", 0x80052700, 0x80052754),
    ("audio_callback_return", "src/game/audio_callback_return.c", 0x80052754, 0x80052774),
    ("audio_config", "src/game/audio_config.c", 0x80052780, 0x80052A00),
    ("audio_control", "src/game/audio_control.c", 0x80052A00, 0x80052D70),
    ("audio_play", "src/game/audio_play.c", 0x80053C50, 0x80053CC0),
    ("audio_instance_stop", "src/game/audio_instance_stop.c", 0x80053DAC, 0x80053EBC),
    ("audio_stop_commands", "src/game/audio_stop_commands.c", 0x80053EBC, 0x80053F78),
    ("audio_voice_stop", "src/game/audio_voice_stop.c", 0x80053F78, 0x80054178),
    ("audio_instance_stop_all", "src/game/audio_instance_stop_all.c", 0x80054178, 0x80054268),
    ("audio_stop_all_commands", "src/game/audio_stop_all_commands.c", 0x80054268, 0x80054304),
    ("audio_voice_stop_all", "src/game/audio_voice_stop_all.c", 0x80054304, 0x800544F0),
    ("audio_level_commands", "src/game/audio_level_commands.c", 0x80054720, 0x800547FC),
    ("audio_level_update", "src/game/audio_level_update.c", 0x800547FC, 0x800549DC),
    ("audio_level_commands_alt", "src/game/audio_level_commands_alt.c", 0x800549DC, 0x80054A48),
    ("audio_level_update_alt", "src/game/audio_level_update_alt.c", 0x80054A48, 0x80054C24),
    ("audio_mode", "src/game/audio_mode.c", 0x80054C24, 0x80054C44),
    ("audio_play_arguments", "src/game/audio_play_arguments.c", 0x80055760, 0x800557FC),
    ("audio_command_lock", "src/game/audio_command_lock.c", 0x8005895C, 0x800589DC),
    ("audio_command_queue", "src/game/audio_command_queue.c", 0x800592C0, 0x80059500),
)

CANDIDATE_BLOCKS = (
    ("object_camera_angles", "src/game/object_camera_angles.c", 0x80039FCC, 0x8003A070),
    ("object_camera_angles_alt", "src/game/object_camera_angles_alt.c", 0x8003A128, 0x8003A1C8),
    ("object_runtime_update", "src/game/object_runtime_update.c", 0x8003A8B0, 0x8003B254),
    ("object_runtime_projection", "src/game/object_runtime_projection.c", 0x8003B2B0, 0x8003B428),
    ("game_string_comparisons", "src/game/game_string_comparisons.c", 0x8003B734, 0x8003B928),
    ("game_number_parse", "src/game/game_number_parse.c", 0x8003BD4C, 0x8003BF5C),
    ("controller_input", "src/game/controller_input.c", 0x8003C1A8, 0x8003C4C8),
    ("frame_begin", "src/boot/frame_begin.c", 0x80048510, 0x800489F4),
    ("graphics_pacing", "src/boot/graphics_pacing.c", 0x8004FEA8, 0x80050084),
    ("audio_instance_query", "src/game/audio_instance_query.c", 0x80053CC0, 0x80053DAC),
)


def run(candidates=False):
    install("5.3")
    target = (ROOT / "baseroms/us/baserom.z64").read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    family = "runtime-candidates" if candidates else "runtime-comparison"
    blocks = {}
    for name, source, start, end in CANDIDATE_BLOCKS if candidates else MATCHING_BLOCKS:
        result = compare_block(name, source, start, start - 0x80000000 + 0xC00,
                               end - 0x80000000 + 0xC00, target, family=family, layout=layout)
        blocks[name] = result
        print(f"{name}: {result['actual_size']} compiled bytes / "
              f"{result['expected_size']} target bytes; "
              f"{len(result['different_words'])} differing words", flush=True)
    report = {"matches": all(block["matches"] for block in blocks.values()), "blocks": blocks}
    destination = ROOT / "build" / family / "report.json"
    destination.write_text(json.dumps(report, indent=2) + "\n")
    print(f"Report: {destination.relative_to(ROOT)}")
    if not report["matches"]:
        raise SystemExit("Comparison includes nonmatching source; see the report")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--candidates", action="store_true",
                        help="compare excluded research sources; mismatches exit nonzero")
    run(parser.parse_args().candidates)
