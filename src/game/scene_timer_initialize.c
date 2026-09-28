extern int D_800781D0;
extern int D_8009EFA4;
extern int D_8009EF94;
extern void func_8003BFC4(int value);
extern int func_8003BFA4(void);
extern void func_8003BFCC(void);

void func_800387C8(void)
{
    func_8003BFC4(1000);
    D_8009EFA4 = func_8003BFA4();
    D_8009EF94 = 1;
    D_800781D0 = 0;
    func_8003BFCC();
}
