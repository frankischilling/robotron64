int func_800498F0(unsigned char value)
{
    unsigned char result = 0;

    if (value >= 'A' && value <= 'Z') {
        result = value - 'A';
    }
    if (value >= 'a' && value <= 'z') {
        result = value - 'a';
    }
    if (value == '_') result = 26;
    if (value == '?') result = 27;
    if (value == '=') result = 28;
    if (value == '+') result = 29;
    if (value == '/') result = 30;
    if (value == '-') result = 31;
    if (value == '.') result = 32;
    if (value == '%') result = 33;
    if (value == '!') result = 34;
    if (value == '*') result = 35;
    if (value >= '0' && value <= '9') result = value - 12;
    if (value >= 170 && value <= 179) result = value - 134;
    if (value == 31) result = 46;
    if (value == 11) result = 47;
    if (value == 12) result = 48;
    if (value == 13) result = 49;
    if (value == '^') result = 50;
    if (value == ',') result = 51;
    if (value == '#') result = 53;
    if (value == '"') result = 54;
    if (value == ':') result = 55;
    if (value == '@') result = 56;
    if (value == '\'') result = 57;

    return result;
}
