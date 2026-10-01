"""Compile recovered C with the profile verified for that source file."""

import argparse
from pathlib import Path
import struct
import subprocess

from rom import ROOT
from toolchain import installed_identity


PROFILES = {
    "game-r4300-mul": ("-O2", "-G", "0", "-non_shared", "-mips1", "-32", "-Wab,-r4300_mul"),
    "sdk-o2-mips2-r4300-mul": ("-O2", "-G", "0", "-non_shared", "-mips2", "-32", "-Wab,-r4300_mul"),
    "sdk-o3-mips2-r4300-mul": ("-O3", "-G", "0", "-non_shared", "-mips2", "-32", "-Wab,-r4300_mul"),
    "sdk-o3-mips2": ("-O3", "-G", "0", "-non_shared", "-mips2", "-32"),
    "sdk-o1-mips3": ("-O1", "-G", "0", "-non_shared", "-mips3", "-32"),
    "sdk-o2-mips2": ("-O2", "-G", "0", "-non_shared", "-mips2", "-32"),
    "game": ("-O2", "-G", "0", "-non_shared", "-mips1", "-32"),
    "sdk-o1-mips2": ("-O1", "-G", "0", "-non_shared", "-mips2", "-32"),
}

# Add a source only after comparing its complete functions with the retail ROM.
SOURCE_PROFILES = {
    "src/game/game_float_parse.c": "game-r4300-mul",
    "src/game/renderer_projection_highlight.c": "game-r4300-mul",
    "src/sdk/cpu_interrupt_tables.c": "sdk-o1-mips2",
    "src/sdk/exception_state.c": "sdk-o1-mips2",
    "src/sdk/rcp_interrupt_masks.c": "sdk-o1-mips2",
    "src/sdk/thread_state.c": "sdk-o1-mips2",
    "src/sdk/initialize.c": "sdk-o1-mips2",
    "src/sdk/pfs_repair_id.c": "sdk-o1-mips2",
    "src/sdk/pi_disk_interrupt.c": "sdk-o1-mips2",
    "src/sdk/pi_manager_create.c": "sdk-o1-mips2",
    "src/sdk/pi_device_manager.c": "sdk-o1-mips2",
    "src/sdk/video_modes.c": "sdk-o1-mips2",
    "src/sdk/video_default_modes.c": "sdk-o1-mips2",
    "src/sdk/video_context_swap.c": "sdk-o1-mips2",
    "src/sdk/video_manager.c": "sdk-o1-mips2",
    "src/sdk/video_initialize.c": "sdk-o1-mips2",
    "src/sdk/pi_cartridge_initialize.c": "sdk-o1-mips2",
    "src/sdk/pi_disk_initialize.c": "sdk-o1-mips2",
    "src/sdk/sp_task_physical.c": "sdk-o1-mips2",
    "src/sdk/sp_task_load.c": "sdk-o1-mips2",
    "src/sdk/pi_disk_recover.c": "sdk-o1-mips2",
    "src/sdk/pi_extended_dma.c": "sdk-o1-mips2",
    "src/sdk/sine_float.c": "sdk-o2-mips2-r4300-mul",
    "src/sdk/cosine_float.c": "sdk-o2-mips2-r4300-mul",
    "src/sdk/pi_event_notify.c": "sdk-o1-mips2",
    "src/sdk/short_sine.c": "sdk-o2-mips2",
    "src/sdk/short_cosine.c": "sdk-o2-mips2",
    "src/sdk/ai_frequency.c": "sdk-o1-mips2",
    "src/sdk/thread_destroy.c": "sdk-o1-mips2",
    "src/sdk/pi_start_dma.c": "sdk-o1-mips2",
    "src/sdk/pi_queue_get.c": "sdk-o1-mips2",
    "src/sdk/video_vertical_scale.c": "sdk-o1-mips2",
    "src/sdk/thread_yield.c": "sdk-o1-mips2",
    "src/sdk/interrupt_mask_set.c": "sdk-o1-mips2",
    "src/sdk/interrupt_mask_reset.c": "sdk-o1-mips2",
    "src/sdk/pi_extended_write.c": "sdk-o1-mips2",
    "src/sdk/pi_extended_read.c": "sdk-o1-mips2",
    "src/sdk/controller_crc.c": "sdk-o1-mips2",
    "src/sdk/pfs_cont_ram_write.c": "sdk-o1-mips2",
    "src/sdk/pfs_checker.c": "sdk-o1-mips2",
    "src/sdk/pfs_get_status.c": "sdk-o1-mips2",
    "src/sdk/pfs_cont_ram_read.c": "sdk-o1-mips2",
    "src/sdk/pfs_contpfs.c": "sdk-o1-mips2",
    "src/sdk/pfs_file_state.c": "sdk-o1-mips2",
    "src/sdk/pfs_delete_file.c": "sdk-o1-mips2",
    "src/sdk/pfs_num_files.c": "sdk-o1-mips2",
    "src/sdk/pfs_free_blocks.c": "sdk-o1-mips2",
    "src/sdk/controller_init.c": "sdk-o1-mips2",
    "src/sdk/pfs_motor.c": "sdk-o1-mips2",
    "src/sdk/pfs_read_write_file.c": "sdk-o1-mips2",
    "src/sdk/pfs_allocate_file.c": "sdk-o1-mips2",
    "src/sdk/pfs_search_file.c": "sdk-o1-mips2",
    "src/sdk/controller_read.c": "sdk-o1-mips2",
    "src/sdk/pfs_init_pak.c": "sdk-o1-mips2",
    "src/sdk/pfs_is_plug.c": "sdk-o1-mips2",
    "src/sdk/matrix_rotation.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/camera_highlights.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/camera_perspective.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_effect_pull.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_effect_source.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_effect_parameters.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_effect_buffers.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_effect_modulation.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_effect_allocate.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_effect_create.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_low_pass.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_envelope.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_decoder.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_save_filter.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_auxiliary_bus.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_resample.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_main_bus.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_synthesizer.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_filter_base.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_filter_create.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/voice_priority.c": "sdk-o2-mips2",
    "src/sdk/voice_release.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/voice_stop.c": "sdk-o2-mips2",
    "src/sdk/voice_pan.c": "sdk-o2-mips2",
    "src/sdk/voice_volume.c": "sdk-o2-mips2",
    "src/sdk/voice_pitch.c": "sdk-o2-mips2",
    "src/sdk/voice_start.c": "sdk-o2-mips2",
    "src/sdk/voice_allocate.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/matrix_convert.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/audio_copy_bytes.c": "sdk-o2-mips2",
    "src/sdk/audio_synth_clear.c": "sdk-o2-mips2",
    "src/sdk/message_prepend.c": "sdk-o1-mips2",
    "src/sdk/video_context_get.c": "sdk-o1-mips2",
    "src/sdk/timer_schedule.c": "sdk-o1-mips2",
    "src/sdk/audio_callback_attach.c": "sdk-o2-mips2",
    "src/sdk/audio_remaining_bytes.c": "sdk-o1-mips2",
    "src/sdk/audio_buffer_submit.c": "sdk-o1-mips2",
    "src/sdk/audio_synth_lifecycle.c": "sdk-o2-mips2",
    "src/sdk/audio_link_nodes.c": "sdk-o2-mips2",
    "src/sdk/matrix_translate.c": "sdk-o3-mips2-r4300-mul",
    "src/sdk/timer_insert.c": "sdk-o1-mips2",
    "src/sdk/timer_compare.c": "sdk-o1-mips2",
    "src/sdk/timer_interrupt.c": "sdk-o1-mips2",
    "src/sdk/timer_initialize.c": "sdk-o1-mips2",
    "src/sdk/system_time.c": "sdk-o1-mips2",
    "src/sdk/thread_set_priority.c": "sdk-o1-mips2",
    "src/sdk/pi_cartridge_read.c": "sdk-o1-mips2",
    "src/sdk/si_busy.c": "sdk-o1-mips2",
    "src/sdk/ai_busy.c": "sdk-o1-mips2",
    "src/sdk/sp_busy.c": "sdk-o1-mips2",
    "src/sdk/sp_dma.c": "sdk-o1-mips2",
    "src/sdk/sp_set_pc.c": "sdk-o1-mips2",
    "src/sdk/sp_get_status.c": "sdk-o1-mips2",
    "src/sdk/sp_set_status.c": "sdk-o1-mips2",
    "src/sdk/si_dma.c": "sdk-o1-mips2",
    "src/sdk/si_access.c": "sdk-o1-mips2",
    "src/sdk/pi_raw_dma.c": "sdk-o1-mips2",
    "src/sdk/thread_get_priority.c": "sdk-o1-mips2",
    "src/sdk/pi_access.c": "sdk-o1-mips2",
    "src/sdk/thread_dequeue.c": "sdk-o1-mips2",
    "src/sdk/si_raw_write.c": "sdk-o1-mips2",
    "src/sdk/si_raw_read.c": "sdk-o1-mips2",
    "src/sdk/audio_heap_allocate.c": "sdk-o2-mips2",
    "src/sdk/audio_heap_init.c": "sdk-o2-mips2",
    "src/sdk/vi_framebuffer.c": "sdk-o1-mips2",
    "src/sdk/sp_start.c": "sdk-o1-mips2",
    "src/sdk/sp_yielded.c": "sdk-o1-mips2",
    "src/sdk/sp_yield.c": "sdk-o1-mips2",
    "src/sdk/vi_event.c": "sdk-o1-mips2",
    "src/sdk/vi_black.c": "sdk-o1-mips2",
    "src/sdk/vi_mode.c": "sdk-o1-mips2",
    "src/sdk/event_message.c": "sdk-o1-mips2",
    "src/sdk/message_send.c": "sdk-o1-mips2",
    "src/sdk/pi_read.c": "sdk-o1-mips2",
    "src/sdk/gu_random.c": "sdk-o2-mips2",
    "src/sdk/message_receive.c": "sdk-o1-mips2",
    "src/sdk/compiler_integer64.c": "sdk-o1-mips3",
    "src/sdk/virtual_to_physical.c": "sdk-o1-mips2",
    "src/sdk/vi_features.c": "sdk-o1-mips2",
    "src/sdk/message_queue.c": "sdk-o1-mips2",
    "src/sdk/thread_start.c": "sdk-o1-mips2",
    "src/sdk/thread_create.c": "sdk-o1-mips2",
    "src/game/audio_pitch_scale.c": "game-r4300-mul",
    "src/libultra/ai_buffer.c": "sdk-o1-mips2",
    "src/libultra/ai_busy.c": "sdk-o1-mips2",
    "src/libultra/ai_frequency.c": "sdk-o1-mips2",
    "src/libultra/ai_length.c": "sdk-o1-mips2",
    "src/libultra/audio_aux_bus.c": "sdk-o3-mips2",
    "src/libultra/audio_copy.c": "sdk-o3-mips2",
    "src/libultra/audio_decoder.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/audio_effect_allocate.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/audio_effect_buffers.c": "sdk-o3-mips2",
    "src/libultra/audio_effect_init.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/audio_effect_modulation.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/audio_effect_parameters.c": "sdk-o3-mips2",
    "src/libultra/audio_effect_pull.c": "sdk-o3-mips2",
    "src/libultra/audio_effect_source.c": "sdk-o3-mips2",
    "src/libultra/audio_envelope.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/audio_filter_constructors.c": "sdk-o3-mips2",
    "src/libultra/audio_filter_init.c": "sdk-o2-mips2",
    "src/libultra/audio_globals.c": "sdk-o2-mips2",
    "src/libultra/audio_heap_alloc.c": "sdk-o2-mips2",
    "src/libultra/audio_heap_init.c": "sdk-o2-mips2",
    "src/libultra/audio_main_bus.c": "sdk-o3-mips2",
    "src/libultra/audio_resample.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/audio_save.c": "sdk-o3-mips2",
    "src/libultra/audio_sp.c": "sdk-o1-mips2",
    "src/libultra/audio_synth_allocate.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/audio_synth_delete.c": "sdk-o2-mips2",
    "src/libultra/audio_synth_free_voice.c": "sdk-o3-mips2",
    "src/libultra/audio_synth_pan.c": "sdk-o2-mips2",
    "src/libultra/audio_synth_pitch.c": "sdk-o2-mips2",
    "src/libultra/audio_synth_player.c": "sdk-o2-mips2",
    "src/libultra/audio_synth_priority.c": "sdk-o2-mips2",
    "src/libultra/audio_synth_start.c": "sdk-o3-mips2",
    "src/libultra/audio_synth_stop.c": "sdk-o2-mips2",
    "src/libultra/audio_synth_volume.c": "sdk-o2-mips2",
    "src/libultra/audio_synthesizer.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/audio_vi.c": "sdk-o1-mips2",
    "src/libultra/compiler_arithmetic.c": "sdk-o1-mips3",
    "src/libultra/controller_crc.c": "sdk-o1-mips2",
    "src/libultra/controller_init.c": "sdk-o1-mips2",
    "src/libultra/controller_read.c": "sdk-o1-mips2",
    "src/libultra/epi_dma.c": "sdk-o1-mips2",
    "src/libultra/epi_raw_read.c": "sdk-o1-mips2",
    "src/libultra/epi_raw_write.c": "sdk-o1-mips2",
    "src/libultra/event_message.c": "sdk-o1-mips2",
    "src/libultra/gu_cosine.c": "sdk-o2-mips2",
    "src/libultra/gu_cosine_float.c": "sdk-o2-mips2-r4300-mul",
    "src/libultra/gu_lookathilite.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/gu_mtxutil.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/gu_perspective.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/gu_random.c": "sdk-o2-mips2",
    "src/libultra/gu_rotate_rpy.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/gu_sine.c": "sdk-o2-mips2",
    "src/libultra/gu_sine_float.c": "sdk-o2-mips2-r4300-mul",
    "src/libultra/gu_translate.c": "sdk-o3-mips2-r4300-mul",
    "src/libultra/interrupt_global_clear.c": "sdk-o1-mips2",
    "src/libultra/interrupt_global_set.c": "sdk-o1-mips2",
    "src/libultra/message_jam.c": "sdk-o1-mips2",
    "src/libultra/message_queue_create.c": "sdk-o1-mips2",
    "src/libultra/message_receive.c": "sdk-o1-mips2",
    "src/libultra/message_send.c": "sdk-o1-mips2",
    "src/libultra/pfs_allocate_file.c": "sdk-o1-mips2",
    "src/libultra/pfs_checker.c": "sdk-o1-mips2",
    "src/libultra/pfs_cont_ram_read.c": "sdk-o1-mips2",
    "src/libultra/pfs_cont_ram_write.c": "sdk-o1-mips2",
    "src/libultra/pfs_contpfs.c": "sdk-o1-mips2",
    "src/libultra/pfs_delete_file.c": "sdk-o1-mips2",
    "src/libultra/pfs_file_state.c": "sdk-o1-mips2",
    "src/libultra/pfs_free_blocks.c": "sdk-o1-mips2",
    "src/libultra/pfs_get_status.c": "sdk-o1-mips2",
    "src/libultra/pfs_init_pak.c": "sdk-o1-mips2",
    "src/libultra/pfs_is_plug.c": "sdk-o1-mips2",
    "src/libultra/pfs_motor.c": "sdk-o1-mips2",
    "src/libultra/pfs_num_files.c": "sdk-o1-mips2",
    "src/libultra/pfs_read_write_file.c": "sdk-o1-mips2",
    "src/libultra/pfs_search_file.c": "sdk-o1-mips2",
    "src/libultra/pi_access.c": "sdk-o1-mips2",
    "src/libultra/pi_event.c": "sdk-o1-mips2",
    "src/libultra/pi_get_queue.c": "sdk-o1-mips2",
    "src/libultra/pi_manager_create.c": "sdk-o1-mips2",
    "src/libultra/pi_raw_dma.c": "sdk-o1-mips2",
    "src/libultra/pi_raw_read.c": "sdk-o1-mips2",
    "src/libultra/pi_read.c": "sdk-o1-mips2",
    "src/libultra/pi_start_dma.c": "sdk-o1-mips2",
    "src/libultra/si_access.c": "sdk-o1-mips2",
    "src/libultra/si_busy.c": "sdk-o1-mips2",
    "src/libultra/si_dma.c": "sdk-o1-mips2",
    "src/libultra/si_raw_read.c": "sdk-o1-mips2",
    "src/libultra/si_raw_write.c": "sdk-o1-mips2",
    "src/libultra/sp_busy.c": "sdk-o1-mips2",
    "src/libultra/sp_dma.c": "sdk-o1-mips2",
    "src/libultra/sp_get_status.c": "sdk-o1-mips2",
    "src/libultra/sp_set_pc.c": "sdk-o1-mips2",
    "src/libultra/sp_set_status.c": "sdk-o1-mips2",
    "src/libultra/sp_task.c": "sdk-o1-mips2",
    "src/libultra/sp_yield.c": "sdk-o1-mips2",
    "src/libultra/sp_yielded.c": "sdk-o1-mips2",
    "src/libultra/thread_create.c": "sdk-o1-mips2",
    "src/libultra/thread_destroy.c": "sdk-o1-mips2",
    "src/libultra/thread_get_priority.c": "sdk-o1-mips2",
    "src/libultra/thread_priority.c": "sdk-o1-mips2",
    "src/libultra/thread_start.c": "sdk-o1-mips2",
    "src/libultra/thread_yield.c": "sdk-o1-mips2",
    "src/libultra/time_get.c": "sdk-o1-mips2",
    "src/libultra/timer_compare.c": "sdk-o1-mips2",
    "src/libultra/timer_init.c": "sdk-o1-mips2",
    "src/libultra/timer_insert.c": "sdk-o1-mips2",
    "src/libultra/timer_interrupt.c": "sdk-o1-mips2",
    "src/libultra/timer_set.c": "sdk-o1-mips2",
    "src/libultra/vi_black.c": "sdk-o1-mips2",
    "src/libultra/vi_context.c": "sdk-o1-mips2",
    "src/libultra/vi_event.c": "sdk-o1-mips2",
    "src/libultra/vi_features.c": "sdk-o1-mips2",
    "src/libultra/vi_manager.c": "sdk-o1-mips2",
    "src/libultra/vi_mode.c": "sdk-o1-mips2",
    "src/libultra/vi_vertical_scale.c": "sdk-o1-mips2",
    "src/libultra/virtual_to_physical.c": "sdk-o1-mips2",
}


def profile_for_source(source):
    path = Path(source)
    if not path.is_absolute():
        path = ROOT / path
    relative = path.resolve().relative_to(ROOT.resolve()).as_posix()
    name = SOURCE_PROFILES.get(relative, "game")
    return {"name": name, "version": "5.3", "flags": list(PROFILES[name])}


def compiler_command(source, output, compiler=None):
    profile = profile_for_source(source)
    executable = ROOT / ".local/toolchain" / profile["version"] / "cc"
    if compiler is not None:
        requested = Path(compiler)
        if not requested.is_absolute():
            requested = ROOT / requested
        if requested.resolve() != executable.resolve():
            raise ValueError("The compiler must be the pinned executable for the source profile")
    return [str(executable), "-c", *profile["flags"], "-o", str(output), str(source)]


def normalize_mips3_o32(data):
    """Describe IDO -mips3 -32 output's existing ABI for GNU binutils.

    IDO leaves the ABI field unset. GNU ld otherwise interprets this MIPS III
    object as 64-bit code when combining it with the game's o32 objects.
    Only EF_MIPS_ABI_O32 is added; sections and the ISA field stay unchanged.
    """
    if len(data) < 52 or data[:7] != b"\x7fELF\x01\x02\x01":
        raise ValueError("Expected an ELF32 big-endian object")
    kind, machine, version = struct.unpack_from(">HHI", data, 16)
    if (kind, machine, version) != (1, 8, 1):
        raise ValueError("Expected a relocatable MIPS object")
    flags = struct.unpack_from(">I", data, 36)[0]
    if flags & 0xF0000000 != 0x20000000:
        raise ValueError("Expected the MIPS III ISA for o32 normalization")
    if flags & 0xF000 not in (0, 0x1000) or flags & 0x220:
        raise ValueError("Object declares an incompatible ABI or FP register width")
    result = bytearray(data)
    struct.pack_into(">I", result, 36, flags | 0x1000)
    return bytes(result)


def compile_source(source, output, compiler=None):
    profile = profile_for_source(source)
    command = compiler_command(source, output, compiler)
    installed_identity(profile["version"])
    subprocess.run(command, check=True, cwd=ROOT)
    if "-mips3" in profile["flags"]:
        destination = Path(output)
        if not destination.is_absolute():
            destination = ROOT / destination
        original = destination.read_bytes()
        normalized = normalize_mips3_o32(original)
        # Retain the unmodified compiler output alongside the linker input.
        destination.with_name(destination.name + ".ido").write_bytes(original)
        destination.write_bytes(normalized)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source")
    parser.add_argument("-o", "--output", required=True)
    parser.add_argument("--cc", type=Path)
    args = parser.parse_args()
    compile_source(args.source, args.output, args.cc)


if __name__ == "__main__":
    main()
