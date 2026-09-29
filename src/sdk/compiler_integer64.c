unsigned long long func_800614E0(unsigned long long value, unsigned long long shift)
{
    return value >> shift;
}

unsigned long long func_8006150C(unsigned long long dividend, unsigned long long divisor)
{
    return dividend % divisor;
}

unsigned long long func_80061548(unsigned long long dividend, unsigned long long divisor)
{
    return dividend / divisor;
}

unsigned long long func_80061584(unsigned long long value, unsigned long long shift)
{
    return value << shift;
}

unsigned long long func_800615B0(unsigned long long dividend, unsigned long long divisor)
{
    return dividend % divisor;
}

long long func_800615EC(long long dividend, long long divisor)
{
    return dividend / divisor;
}

unsigned long long func_80061648(unsigned long long first, unsigned long long second)
{
    return first * second;
}

void func_80061678(unsigned long long *quotient, unsigned long long *remainder,
                   unsigned long long dividend, unsigned short divisor)
{
    *quotient = dividend / divisor;
    *remainder = dividend % divisor;
}

long long func_800616D8(long long dividend, long long divisor)
{
    long long remainder;

    remainder = dividend % divisor;
    if ((remainder < 0 && divisor > 0) || (remainder > 0 && divisor < 0)) {
        remainder += divisor;
    }
    return remainder;
}

long long func_80061774(long long value, unsigned long long shift)
{
    return value >> shift;
}
