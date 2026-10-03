/* Retail supplies only the selection for actions 0, 12 and 13.
 * These actions never inspect the player argument. */
void func_8001B8D8();

void func_800338F0(int *selection)
{
    int first;
    int second;
    int third;

    first = 12, second = 13, third = 0;
    switch (*selection) {
    case 10:
        func_8001B8D8(&third);
        break;
    case 8:
        func_8001B8D8(&first);
        break;
    case 9:
        func_8001B8D8(&second);
        break;
    }
    *selection = 0;
}
