# Save menu navigation recovery

Eight earlier helpers in the same subsystem are now source-owned. `func_80021B20` looks up a level label in `D_800BA7A8`, `func_80021C14` conditionally copies one source byte into a caller-selected word, `func_80022050` updates the menu/runtime flag at `D_80075950`, and `func_80022CF8` resets the menu status words before the main state machine runs. The four functions at `0x800226E8..0x80022858` call the text flag service on the four slots stored at `D_80076000..D_8007600C` or on movie string slots beginning at offset `0x66C` of the active movie configuration. Together these eight functions total 488 code bytes and are linked independently inside the surrounding fallback so all intervening procedures remain untouched.

The legacy callback block from `0x80025688` through `0x80025C40` now has twenty complete matching functions totaling 1,448 code bytes. Two eight-byte regions at `0x800256B8..0x800256C0` and `0x80025708..0x80025710` remain ROM fallback because the function catalog does not identify them as procedures. The recovered functions own no initialized data or BSS.

`func_80025688` resets the legacy menu state, followed by the empty `func_800256C0` callback and two heap forwarding wrappers. The callbacks from `func_80025710` through `func_80025870`, plus `func_800259DC` and the three tail callbacks at `0x80025BBC..0x80025C40`, either refresh controller state before forwarding a value or open one of the existing menu-page definitions through `func_80026178`.

`func_8002589C` and `func_80025A08` establish the session/menu state, refresh the controller-pak service, map its return codes to `D_80075FC4`, inspect directory capacity, and honor bit `0x100` in the session flag word at offset `0x1C`. Naming that word as `SavedSessionState.flags1C` preserves the previously asserted `0x4C` session layout. The two routines differ in their filename/mode data and in whether controller state is refreshed before setup. `func_80025B44` tears down the current menu, selects state 12, starts the existing transition movie, and advances the session service.

The navigation block from `0x80025C40` through the boundary at `0x80026178` contains twelve complete matching functions totaling 1,336 code bytes. The recovered sources keep each function separate so their code and transitive inputs can be compared independently with the US ROM. These functions own no initialized data or BSS.

`func_80025C40` refreshes a save-level selection. Negative values become `1`; otherwise an invalid level advances by `D_800761F0`. It formats the resolved level name into the existing menu text buffer and submits that buffer to the text system. The declaration for `func_80021B20` comes from `save_game.h`, which also carries the recovered `GameSessionState` and `SceneDefinition` layouts used by the surrounding save and scene code.

`func_80025CD0`, `func_80025CFC`, and `func_80025D28` open the two menu definitions used by this path. `func_80025D54` is an empty callback. `func_80025D5C` clears the 0x64-byte navigation state, and `func_80025D88` marks an actor for removal while clearing the associated activity word.

The preview actor uses the same packed actor fields seen elsewhere in the game: object index at `0x0C`, the signed 16-bit timer/value at `0x0E`, flags at `0x14`, state byte at `0x21`, resource pointer at `0x24`, and callback at `0x44`. `func_80025D9C` and `func_80025E68` alternate that callback while switching animation state. `func_80025EF0` creates the preview actor, applies the resource scale, installs the callback, clears flag `0x20`, and records the preview in the navigation state. `func_80026044` releases that preview.

`func_8002606C` tears down the active menu. It releases the primary text slot, walks the linked child nodes and releases their text slots, optionally removes the preview actor, optionally restores the saved camera position and angles, marks the secondary actor for removal, and clears the active menu pointer.

Four controller-pak callbacks after the navigation block are also exact. `func_800265B8` closes the active menu state, refreshes the pak directory through `func_800267BC`, and returns to the common status-3 menu state when that refresh does not report success. `func_80026620` performs the same status reset without refreshing. `func_80026674` optionally deletes the currently selected pak slot before refreshing and dispatching the result, while `func_8002674C` clears the pak-page flag, reopens the normal page when the status word is zero, and otherwise returns to the shared status-3 state. These four functions total 372 bytes; the 144-byte `func_800266BC` and 596-byte `func_800267BC` between them remain fallback.

The menu node has a 48-byte layout, and the navigation state is 100 bytes. Size assertions cover both. The twelve functions preserve the established field offsets as later menu-activation work gives names to previously unknown fields.

The first exact comparisons live under `.local/recovery59-menu`, with preserved snapshots under `.local/recovery61-menu/frozen_exact`. Those older proofs include the header version used for their original compilation. Independent integration comparisons under `.local/recovery61-integration` recompile all twelve sources against the current expanded header. The four text-flag helpers also have a complete linked comparison over their contiguous 368-byte range; the current build records source and transitive-header hashes through the standard provenance step.

The legacy prelude was reconstructed from the US target function catalog and the frozen local disassemblies in `recovery38-session` and `recovery58-menu`; no external source tree was used for these twenty functions. The six source units were then linked at their final addresses against the current project symbol layout, including the two retained fallback fragments, before integration.

The comparison runner uses IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`, checks each complete procedure and any allocated data, and records current source, transitive-header, compiler, and symbol-layout identities. The larger menu-activation routine at `0x80026178` and the pak directory builder at `0x800267BC` remain separate candidates until their complete comparisons pass.

[Menu option construction](save-menu-options.md) now completes the 472-byte
initializer at `800263E0` and owns its seventeen 40-byte option records and
48-byte page. The 616-byte activation routine immediately before it remains
fallback; constructor execution tests use an ABI stub for that call.
