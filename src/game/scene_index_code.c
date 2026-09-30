int func_80030FEC(int index)
{
    if (index > 10) {
        index += 4;
    } else if (index > 5) {
        index += 3;
    } else if (index > 2) {
        index += 2;
    } else {
        index++;
    }
    return index + 97;
}
