# Legacy save menu proof ledger

The six source units recovered at `0x80025688..0x80025C40` compile with IDO 5.3 using `-O2 -G 0 -non_shared -mips1 -32`. Their linked comparison reports use the current symbol layout and the US ROM. Each report records `matches: true`, zero differing words, and no owned-data errors.

| Source | Source SHA-256 | Linked report | Report SHA-256 |
| --- | --- | --- | --- |
| `src/game/save_menu_legacy_reset.c` | `7f3c793b5feac81db494b655566e183ada1721356073b97ec5c362a78e81443f` | `.local/linked-probes/probes/save_menu_legacy_reset-5.3-O2-mips1/report.json` | `351ab0b3a754ab26d49843398df30d98e196cc525783a8010e819337b3ddafd2` |
| `src/game/save_menu_legacy_heap.c` | `6e649daa2c2a18d1cfec4c76cef9f67034f3238a7ce315754c3942863fc82a38` | `.local/linked-probes/probes/save_menu_legacy_heap-5.3-O2-mips1/report.json` | `897978d79559d54387a9973e35004d14791d9d4184801ed8aa517649b1ed7fcc` |
| `src/game/save_menu_legacy_pages.c` | `9dde0ff7ae25b35b04c8860a484a6e068d81622390740fcbd7e4994a04e0c85f` | `.local/linked-probes/probes/save_menu_legacy_pages-5.3-O2-mips1/report.json` | `c3ea43f68204daccbf904e1378d7ded6f7ccf7afdb399bd9516b8141b294898d` |
| `src/game/save_menu_legacy_pak_status.c` | `3e8fd8e8ebdcc6be3bca82678344ebffc11927088471542b7eb9554e977eb706` | `.local/linked-probes/probes/save_menu_legacy_pak_status-5.3-O2-mips1/report.json` | `c68819876241d4c0d79c3ec12bcb9ae6a803d8e5c2155a454d759349f559eebf` |
| `src/game/save_menu_legacy_exit.c` | `a38dc863047247b1b4efcc0b4f0d4e2db0b007496e12c908e136816c2d8cf45b` | `.local/linked-probes/probes/save_menu_legacy_exit-5.3-O2-mips1/report.json` | `de7c2442e9d8db8a5619c009b0145a7041173c3759f5d955773af9be6eb7600f` |
| `src/game/save_menu_legacy_pages_tail.c` | `fcb8098a3f7116baa5fbe40b56508a3611048ad3006f4e5b74534790fa199366` | `.local/linked-probes/probes/save_menu_legacy_pages_tail-5.3-O2-mips1/report.json` | `15368d55d264b0f20436e1b2176b4957940e424c5c79b6db1f5601639f3e6d8b` |

The integrated ROM verification matched all 8,388,608 bytes with SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

## Earlier save/menu helpers

| Source | Source SHA-256 | Linked report | Report SHA-256 |
| --- | --- | --- | --- |
| `src/game/save_level_lookup.c` | `039b626cca496b07a9ab2039fa89a5a6c3ec3509d82494bded97a93022942de8` | `.local/linked-probes/probes/save_level_lookup-5.3-O2-mips1/report.json` | `23d431a49591510ba4905f01184e7ee401d3148c37c3c79da6b174d17c02f2b9` |
| `src/game/save_menu_conditional_copy.c` | `da753efa6429ccc9851c8759563c06000c4915b8933c95e9b851136598b2a222` | `.local/linked-probes/probes/save_menu_conditional_copy-5.3-O2-mips1/report.json` | `6b9f11b2f77bbd0a16e5d38054a39742283c29a3fba910774b425ba60a44b25a` |
| `src/game/save_menu_flag_setter.c` | `9aaecf3fd560fdb2dde8a7cecc91f835af56d16e77bfad01f00c73da62799ee3` | `.local/linked-probes/probes/save_menu_flag_setter-5.3-O2-mips1/report.json` | `efa34348d952cf113a7309bcf3edc8dae600b38f1350e2e122b39cdf57eed3f5` |
| `src/game/save_menu_state_reset.c` | `6a55af0be752f36ccaa3c437392e505e9419480be6e84f8520375c7a72927628` | `.local/linked-probes/probes/save_menu_state_reset-5.3-O2-mips1/report.json` | `495f01bf757b63c1a0b4235251b3c2ffa28d8e0859d4ab95a48d2adad4b6004f` |

The filtered canonical `runtime-comparison` report for these four blocks is `build/runtime-comparison/helpers-report.json` with SHA-256 `4253ac655dc188f31639e3c072e6829861ba713cab41b934b268e4d5638763ca`. It records four matches and zero differing words across 120/120 target bytes.

## Pak and actor helper batch

| Source | Source SHA-256 | Linked report | Report SHA-256 |
| --- | --- | --- | --- |
| `src/game/save_menu_pak_retry.c` | `ac5d3d9af7554fb9b662995a5a1558bc9f2929f1695f7981f573f020a4319104` | `.local/linked-probes/probes/save_menu_pak_retry-5.3-O2-mips1/report.json` | `59c430000404495387b9ab1282bfbecf534afd6a9ff27a320ee7691bdbd5ee72` |
| `src/game/save_menu_pak_reset.c` | `38e026fd513a682a980c9725da78cdca449bfddbb9f7c1e9cb0fc5716ae4af21` | `.local/linked-probes/probes/save_menu_pak_reset-5.3-O2-mips1/report.json` | `c9f724626307baf78644b1b906befa4910965428ef694d061dab97719a02370c` |
| `src/game/save_menu_pak_refresh.c` | `95411733d8a8c075399b7b92ee723f13ddcd00c0b08b19887024f5d4be117804` | `.local/linked-probes/probes/save_menu_pak_refresh-5.3-O2-mips1/report.json` | `02577f3269e8410e8c86f5bacf5480e62d1311c09431ca8ed8d17b9b5f4975ed` |
| `src/game/save_menu_pak_result.c` | `acefc5dfb0647cea9144955886e36fadc8719a1592ff483fe599e857d6b29673` | `.local/linked-probes/probes/save_menu_pak_result-5.3-O2-mips1/report.json` | `5178c45c58354f43e5dbea7c8f2f5ae4f9fc7141ae65b70cfada1570a2635bbc` |
| `src/game/actor_behavior_frame_sync.c` | `a0a815a228097713bb2073b02aeea5593ec21882645a5f4bae92f81ff0539159` | `.local/linked-probes/probes/actor_behavior_frame_sync-5.3-O2-mips1/report.json` | `299e040760d178057c7421f574dd1fa6e150e031b13082fff06b1fb2710c04d3` |
| `src/game/actor_behavior_animation_2945c.c` | `53de2904acb6e60ef9c170066ac0c0eb54543a4eb36f2e480f323536ad0a3ed6` | `.local/linked-probes/probes/actor_behavior_animation_2945c-5.3-O2-mips1/report.json` | `ee9ea7ec3c7359a56357e2d276e13f225121ed1e2525aaae4668c271eb1e41d7` |
| `src/game/actor_behavior_callback_29544.c` | `d070dfe19af6cb9f2bd8e63ce7edeb1e4c92ab834350a75df619a4089fc8b1a4` | `.local/linked-probes/probes/actor_behavior_callback_29544-5.3-O2-mips1/report.json` | `5f9fd654519cbd37439404f71dd643c2655bad7f157c594b747594222402ec0e` |
| `src/game/actor_behavior_spawn.c` | `9c8a8c8b5c09cd10f18c5c156ae8598b9aca1cf6b93c9ef9603db879d956ec20` | `.local/linked-probes/probes/actor_behavior_spawn-5.3-O2-mips1/report.json` | `1dccf52c4455e49a79126a852ccd359495533daa4f8ccd7474710b6df577e1e4` |
| `src/game/actor_behavior_spawn_restore.c` | `fb6e4d7b308f068d52c6eeae2ae255670cae2ddc484a8e0e8772b6423646c293` | `.local/linked-probes/probes/actor_behavior_spawn_restore-5.3-O2-mips1/report.json` | `d6d7f9db86baef171e145d877781dc2f41f75d82fbdb82a31c9d42610e839456` |
| `src/game/actor_behavior_release_29d6c.c` | `c2df2ebb0f04c6678754f0c7b9a73aca258bfb67572061fb1ccbb90a6025fbf9` | `.local/linked-probes/probes/actor_behavior_release_29d6c-5.3-O2-mips1/report.json` | `cd16ac15a8c1835438f870ee201d9528e62dae3f5c12f2d3a43962c4616f1bac` |

The filtered canonical `runtime-comparison` report for this ten-function batch is `build/runtime-comparison/actors-menu-batch-report.json` with SHA-256 `2aa84047cb7d6973cef14437a5be36adc0659104d4c6110e90f55a7d29cf7be7`. It records ten matches and zero differing words across 904/904 target bytes.
