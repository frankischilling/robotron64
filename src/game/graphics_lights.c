#include "../../include/graphics_state_internal.h"

void func_80046CF8(int unused, int index)
{
    int color = D_8007BF34[index];
    int red = (color >> 24) & 0xFF;
    int green = (color >> 16) & 0xFF;
    int blue = (color >> 8) & 0xFF;
    GraphicsLight *light = &D_80123B28[index];

    red = (red * 380) >> 8;
    if (red > 255) red = 255;
    green = (green * 380) >> 8;
    if (green > 255) green = 255;
    blue = (blue * 380) >> 8;
    if (blue > 255) blue = 255;
    light->values.color[0] = light->values.colorCopy[0] = red;
    light->values.color[1] = light->values.colorCopy[1] = green;
    light->values.color[2] = light->values.colorCopy[2] = blue;
    light->values.direction[0] = D_8007D5DC;
    light->values.direction[1] = D_8007D5E0;
    light->values.direction[2] = D_8007D5E4;
}

void func_80046DD0(int index)
{
    int color = D_8007BF34[index];
    int red = (color >> 24) & 0xFF;
    int green = (color >> 16) & 0xFF;
    int blue = (color >> 8) & 0xFF;
    GraphicsLight *light = &D_80123B28[index];

    red = (red * 380) >> 8;
    if (red > 255) red = 255;
    green = (green * 380) >> 8;
    if (green > 255) green = 255;
    blue = (blue * 380) >> 8;
    if (blue > 255) blue = 255;
    light->values.color[0] = light->values.colorCopy[0] = red;
    light->values.color[1] = light->values.colorCopy[1] = green;
    light->values.color[2] = light->values.colorCopy[2] = blue;
    light->values.direction[0] = D_8007D5DC;
    light->values.direction[1] = D_8007D5E0;
    light->values.direction[2] = D_8007D5E4;
}

void func_80046EA8(int index, int red, int green, int blue)
{
    GraphicsLight *light = &D_80123B28[index];

    red = (red * 380) >> 8;
    if (red > 255) red = 255;
    green = (green * 380) >> 8;
    if (green > 255) green = 255;
    blue = (blue * 380) >> 8;
    if (blue > 255) blue = 255;
    light->values.color[0] = light->values.colorCopy[0] = red;
    light->values.color[1] = light->values.colorCopy[1] = green;
    light->values.color[2] = light->values.colorCopy[2] = blue;
    light->values.direction[0] = D_8007D5DC;
    light->values.direction[1] = D_8007D5E0;
    light->values.direction[2] = D_8007D5E4;
}
