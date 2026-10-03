#ifndef ROBOTRON_RENDERER_OBJECT_GLYPH_INTERNAL_H
#define ROBOTRON_RENDERER_OBJECT_GLYPH_INTERNAL_H

#include "renderer_draw_state_internal.h"

/* The matching callee has no explicit C return; its matching object callback
 * consumes the surviving allocator result in v0. These provisional module
 * views reproduce the N64 ABI but are not compatible ISO C function types.
 * See docs/renderer-object-glyph.md and issue #61 before changing either view.
 * The byte formal and promoted caller argument also retain their retail views.
 */
#ifdef ROBOTRON_OBJECT_GLYPH_IMPLEMENTATION
void func_8004A2B4(RendererDrawState *draw, unsigned char character, int mode);
#else
int func_8004A2B4(RendererDrawState *draw, int character, int mode);
#endif

#endif
