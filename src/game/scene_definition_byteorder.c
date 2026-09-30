#include "../../include/scene_definition.h"
#include "../../include/rom_files.h"

void func_80021B38(SceneDefinition *scene)
{
    int i;

    for (i = 0; i < 256; i++) {
        func_8004EB80((unsigned int *)&scene->arrivals[i].delay);
        func_8004EB80((unsigned int *)&scene->arrivals[i].x);
        func_8004EBC0(&scene->arrivals[i].delay);
        func_8004EBC0(&scene->arrivals[i].count);
        func_8004EBC0(&scene->arrivals[i].x);
        func_8004EBC0(&scene->arrivals[i].y);
    }
    for (i = 0; i < 25; i++) {
        func_8004EB80((unsigned int *)&scene->tweaks[i]);
        func_8004EBC0(&scene->tweaks[i].variable);
        func_8004EBC0(&scene->tweaks[i].value);
    }
}
