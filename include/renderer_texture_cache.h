#ifndef ROBOTRON_RENDERER_TEXTURE_CACHE_H
#define ROBOTRON_RENDERER_TEXTURE_CACHE_H

typedef unsigned short RendererTextureCacheImage[32][32];

typedef char RendererTextureCacheImageMustBe2048Bytes[
    sizeof(RendererTextureCacheImage) == 0x800 ? 1 : -1];

extern RendererTextureCacheImage D_800CD3C0;
extern int D_800CDBC0;
extern int D_8007CD8C;
extern int D_8007CD90;
extern unsigned char *D_8007CCC0[];

void func_80042830(int unused);

#endif
