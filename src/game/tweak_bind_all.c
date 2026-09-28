#include "../../include/tweak_internal.h"

extern unsigned char D_80094438[];
extern unsigned char D_8009444C[];
extern unsigned char D_80094458[];
extern unsigned char D_80094464[];
extern unsigned char D_80094470[];
extern unsigned char D_8009447C[];
extern unsigned char D_80094488[];
extern unsigned char D_80094498[];
extern unsigned char D_800944A8[];
extern unsigned char D_800944B8[];
extern unsigned char D_800944C8[];
extern unsigned char D_800944D4[];
extern unsigned char D_800944E0[];
extern unsigned char D_800944EC[];
extern unsigned char D_800944FC[];
extern unsigned char D_8009450C[];
extern unsigned char D_80094518[];
extern unsigned char D_80094528[];
extern unsigned char D_80094538[];
extern unsigned char D_80094548[];
extern unsigned char D_80094558[];
extern unsigned char D_80094568[];
extern unsigned char D_80094578[];
extern unsigned char D_80094588[];
extern unsigned char D_80094598[];
extern unsigned char D_800945A8[];
extern unsigned char D_800945B8[];
extern unsigned char D_800945C8[];
extern unsigned char D_800945D4[];
extern unsigned char D_800945E4[];
extern unsigned char D_800945F4[];
extern unsigned char D_80094604[];
extern unsigned char D_80094610[];
extern unsigned char D_8009461C[];
extern unsigned char D_80094628[];
extern unsigned char D_80094634[];
extern unsigned char D_80094640[];
extern unsigned char D_8009464C[];
extern unsigned char D_8009465C[];
extern unsigned char D_8009466C[];
extern unsigned char D_8009467C[];
extern unsigned char D_800946A4[];
extern unsigned char D_800946B4[];
extern unsigned char D_800946CC[];
extern unsigned char D_800946E4[];
extern unsigned char D_80094700[];
extern unsigned char D_80094714[];
extern unsigned char D_80094728[];
extern unsigned char D_80094734[];
extern unsigned char D_80094748[];
extern unsigned char D_80094760[];
extern unsigned char D_80094778[];
extern unsigned char D_80094794[];
extern unsigned char D_800947B0[];
extern unsigned char D_800947CC[];
extern unsigned char D_800947E0[];
extern unsigned char D_800947F8[];
extern unsigned char D_80094808[];
extern unsigned char D_8009481C[];
extern unsigned char D_80094834[];
extern unsigned char D_8009484C[];
extern unsigned char D_80094864[];
extern unsigned char D_80094874[];
extern unsigned char D_8009488C[];
extern unsigned char D_800948A8[];
extern unsigned char D_800948B8[];
extern unsigned char D_800948C8[];
extern unsigned char D_800948DC[];
extern unsigned char D_800948EC[];
extern unsigned char D_80094900[];
extern unsigned char D_80094914[];
extern unsigned char D_80094934[];
extern unsigned char D_80094948[];
extern unsigned char D_8009495C[];
extern unsigned char D_80094974[];
extern unsigned char D_80094980[];
extern unsigned char D_8009499C[];
extern unsigned char D_800949BC[];
extern unsigned char D_800949D8[];
extern unsigned char D_800949EC[];
extern unsigned char D_80094A04[];
extern unsigned char D_80094A18[];
extern unsigned char D_80094A2C[];
extern unsigned char D_80094A40[];
extern unsigned char D_80094A50[];
extern unsigned char D_80094A60[];
extern unsigned char D_80094A70[];
extern unsigned char D_80094A90[];
extern unsigned char D_80094AA4[];
extern unsigned char D_80094ABC[];
extern unsigned char D_80094AD0[];
extern unsigned char D_80094AE0[];
extern unsigned char D_80094AF4[];
extern unsigned char D_80094B18[];
extern unsigned char D_80094B30[];
extern unsigned char D_80094B40[];
extern unsigned char D_80094B54[];
extern unsigned char D_80094B68[];
extern unsigned char D_80094B7C[];
extern unsigned char D_80094B8C[];
extern unsigned char D_80094B9C[];
extern unsigned char D_80094BAC[];

extern int D_8009CD0C;
extern int D_8009CD14;
extern int D_8009D118;
extern int D_8009EF90;
extern int D_8009FC48;
extern int D_800A3AD0;
extern int D_800AC974;
extern int D_800AC978;
extern int D_800AC97C;
extern int D_800AC980;
extern int D_800AC984;
extern int D_800AC988;
extern int D_800AC98C;
extern int D_800AC990;
extern int D_800ACE20;
extern int D_800ACE28;
extern int D_800ACE30;
extern int D_800ACE38;
extern int D_800ACE3C;
extern int D_800ACE44;
extern int D_800ACE48;
extern int D_800ACE4C;
extern int D_800ACE50;
extern int D_800AEE90;
extern int D_800AEE94;
extern int D_800B0094;
extern int D_800B0098;
extern int D_800B009C;
extern int D_800B00A0;
extern int D_800B00A4;
extern int D_800B00A8;
extern int D_800B00AC;
extern int D_800B00B0;
extern int D_800B00B4;
extern int D_800B14A4;
extern int D_800B14AC;
extern int D_800B1BDC;
extern int D_800B1BE4;
extern int D_800B6FD0;
extern int D_800B6FD4;
extern int D_800B6FD8;
extern int D_800B6FDC;
extern int D_800B6FE0;
extern int D_800B6FE4;
extern int D_800B6FE8;
extern int D_800B6FF0;
extern int D_800B6FF4;
extern int D_800B8F60;
extern int D_800BAE94;
extern int D_800BAE98;
extern short D_800AC9A8;

void func_80037A20(void)
{
    int laserRepeatRate;

    func_800360B8(D_80094438);
    func_8003799C(D_8009444C, &D_800AF1F0[5].speed); /* HULK_SPEED */
    func_8003799C(D_80094458, &D_800AF1F0[6].speed); /* HULK2_SPEED */
    func_8003799C(D_80094464, &D_800AF1F0[7].speed); /* HULK3_SPEED */
    func_8003799C(D_80094470, &D_800AF1F0[8].speed); /* HULK4_SPEED */
    func_8003799C(D_8009447C, &D_800AF1F0[0].speed); /* GRUNT_SPEED */
    func_8003799C(D_80094488, &D_800AF1F0[1].speed); /* GRUNT2_SPEED */
    func_8003799C(D_80094498, &D_800AF1F0[2].speed); /* GRUNT3_SPEED */
    func_8003799C(D_800944A8, &D_800AF1F0[3].speed); /* GRUNT4_SPEED */
    func_8003799C(D_800944B8, &D_800AF1F0[4].speed); /* GRUNT5_SPEED */
    func_8003799C(D_800944C8, &D_800AF1F0[29].speed); /* BEE_SPEED */
    func_8003799C(D_800944D4, &D_800AF1F0[30].speed); /* WASP_SPEED */
    func_8003799C(D_800944E0, &D_800AF1F0[31].speed); /* ANT_SPEED */
    func_8003799C(D_800944EC, &D_800AF1F0[33].speed); /* NANOBYTE_SPEED */
    func_8003799C(D_800944FC, &D_800AF1F0[32].speed); /* WEEBLE_SPEED */
    func_8003799C(D_8009450C, &D_800AF1F0[25].speed); /* BRAIN_SPEED */
    func_8003799C(D_80094518, &D_800AF1F0[26].speed); /* BRAIN2_SPEED */
    func_8003799C(D_80094528, &D_800AF1F0[27].speed); /* BRAIN3_SPEED */
    func_8003799C(D_80094538, &D_800AF1F0[28].speed); /* BRAIN4_SPEED */
    func_8003799C(D_80094548, &D_800AF1F0[13].speed); /* ENFORCER_SPEED */
    func_8003799C(D_80094558, &D_800AF1F0[14].speed); /* ENFORCER2_SPEED */
    func_8003799C(D_80094568, &D_800AF1F0[15].speed); /* ENFORCER3_SPEED */
    func_8003799C(D_80094578, &D_800AF1F0[16].speed); /* ENFORCER4_SPEED */
    func_8003799C(D_80094588, &D_800AF1F0[9].speed); /* SPHEROID_SPEED */
    func_8003799C(D_80094598, &D_800AF1F0[10].speed); /* SPHEROID2_SPEED */
    func_8003799C(D_800945A8, &D_800AF1F0[11].speed); /* SPHEROID3_SPEED */
    func_8003799C(D_800945B8, &D_800AF1F0[12].speed); /* SPHEROID4_SPEED */
    func_8003799C(D_800945C8, &D_800AF1F0[17].speed); /* QUARK_SPEED */
    func_8003799C(D_800945D4, &D_800AF1F0[18].speed); /* QUARK2_SPEED */
    func_8003799C(D_800945E4, &D_800AF1F0[19].speed); /* QUARK3_SPEED */
    func_8003799C(D_800945F4, &D_800AF1F0[20].speed); /* QUARK4_SPEED */
    func_8003799C(D_80094604, &D_800AF1F0[21].speed); /* TANK_SPEED */
    func_8003799C(D_80094610, &D_800AF1F0[22].speed); /* TANK2_SPEED */
    func_8003799C(D_8009461C, &D_800AF1F0[23].speed); /* TANK3_SPEED */
    func_8003799C(D_80094628, &D_800AF1F0[24].speed); /* TANK4_SPEED */
    func_8003799C(D_80094634, &D_800ACE58[5].speed); /* MMOM_SPEED */
    func_8003799C(D_80094640, &D_800ACE58[4].speed); /* MDAD_SPEED */
    func_8003799C(D_8009464C, &D_800ACE58[6].speed); /* MMIKEY_SPEED */
    func_8003799C(D_8009465C, &D_800ACE58[7].speed); /* MGRANPS_SPEED */
    func_8003799C(D_8009466C, &D_800B6FD0); /* MAX_NANOBYTES */
    func_8003799C(D_8009467C, &D_8009FC48); /* ATTRACTOR_LETHAL_COLLISION_PERCENTAGE */
    func_8003799C(D_800946A4, &D_800A3AD0); /* ATTRACTOR_FORCE */
    func_8003799C(D_800946B4, &D_800AC998[7].value58); /* BRAIN_MISSILE_DURATION */
    func_8003799C(D_800946CC, &D_800AC998[8].value58); /* BRAIN_MISSILE_DURATION */
    func_8003799C(D_800946E4, &D_800AC998[4].value58); /* ENFORCER_MISSILE_DURATION */
    func_8003799C(D_80094700, &D_800B6FE0); /* BODY_PART_DURATION */
    func_8003799C(D_80094714, &D_800ACE38); /* DEFAULT_RENDERLEVEL */
    func_8003799C(D_80094728, &D_8009CD0C); /* INIT_LIVES */
    func_8003799C(D_80094734, &D_8009EF90); /* CHEAT_CONTROL_SPEED */
    func_8003799C(D_80094748, &D_800AC990); /* RICOCHET_DURATION_TIME */
    func_8003799C(D_80094760, &D_800B1BDC); /* BASE_TANK_CREATE_TIME */
    func_8003799C(D_80094778, &D_800B6FD4); /* SPINNING_PICKUP_DURATION */
    func_8003799C(D_80094794, &D_800B6FDC); /* SPINNING_PICKUP_TURN_TIME */
    func_8003799C(D_800947B0, &D_800B6FE4); /* SPINNING_PICKUP_SCALE_RATE */
    func_8003799C(D_800947CC, &D_800AEE90); /* DEFAULT_CD_VOLUME */
    func_8003799C(D_800947E0, &D_800AEE94); /* DEFAULT_SOUND_VOLUME */
    func_8003799C(D_800947F8, &D_800ACE28); /* HUMAN_KILL_TIME */
    func_8003799C(D_80094808, &D_800ACE44); /* MUTANT_HUMAN_TRAILS */
    func_8003799C(D_8009481C, &D_800ACE4C); /* MUTANT_HUMAN_TRAIL_SEP */
    func_8003799C(D_80094834, &D_800ACE3C); /* HUMAN_DIE_FLASH_RATE */
    func_8003799C(D_8009484C, &D_800ACE30); /* HUMAN_DIE_FLASH_TIME */
    func_8003799C(D_80094864, &D_800ACE20); /* HUMAN_TURN_TIME */
    func_8003799C(D_80094874, &D_800ACE50); /* MUTANT_TRAIL_FRAME_GAP */
    func_8003799C(D_8009488C, &D_800ACE48); /* MUTANT_TRAIL_RENDER_LEVEL */
    func_8003799C(D_800948A8, &D_800AD118); /* COLLIDE_MULT */
    func_8003799C(D_800948B8, &D_8009CD14); /* STARTING_LEVEL */
    func_8003799C(D_800948C8, (int *)D_800B0090); /* GRUNT_SPEED_UP_TIME */
    func_8003799C(D_800948DC, &D_800B0094); /* GRUNT_TURN_TIME */
    func_8003799C(D_800948EC, &D_800B6FE8); /* GRUNT2_HOVER_PROP */
    func_8003799C(D_80094900, &D_800B6FF0); /* GRUNT2_HOVER_TIME */
    func_8003799C(D_80094914, &D_800B6FF4); /* GRUNT2_HOVER_MOVE_SPEED_MULT */
    func_8003799C(D_80094934, &D_800B8F60); /* GRUNT2_HOVER_HEIGHT */
    func_8003799C(D_80094948, &D_800B0098); /* NANOBYTE_TURN_TIME */
    func_8003799C(D_8009495C, &D_800BAE98); /* EXTRA_CONTINUOUS_GRUNTS */
    func_8003799C(D_80094974, &D_800B6FD8); /* MAX_TANKS */
    func_8003799C(D_80094980, &D_800B00A0); /* BASE_ENFORCER_CREATE_TIME */
    func_8003799C(D_8009499C, &D_800B00A4); /* SPHEROID_APPEAR_AT_EDGES_CHANCE */
    func_8003799C(D_800949BC, &D_800B00A8); /* SPHEROID_MOVE_DIAG_CHANCE */
    func_8003799C(D_800949D8, &D_800B00AC); /* SPHEROID_TURN_TIME */
    func_8003799C(D_800949EC, &D_800B00B0); /* NUM_ENFORCERS_TO_EJECT */
    func_8003799C(D_80094A04, &D_800B00B4); /* ENFORCER_TURN_TIME */
    func_8003799C(D_80094A18, &D_800B14A4); /* NUM_TANKS_TO_EJECT */
    func_8003799C(D_80094A2C, &D_800AC978); /* MAX_TANK_MISSILES */
    func_8003799C(D_80094A40, &D_800B14AC); /* TANK_TURN_TIME */
    func_8003799C(D_80094A50, (int *)D_800B6FC8); /* QUARK_TURN_TIME */
    func_8003799C(D_80094A60, &D_800B009C); /* HULK_TURN_TIME */
    func_8003799C(D_80094A70, &D_800AC974); /* BRAIN_MISSILE_CHANGE_DIR_TIME */
    func_8003799C(D_80094A90, &D_800AC97C); /* MAX_BRAIN_MISSILES */
    func_8003799C(D_80094AA4, &D_800AC980); /* BRAIN_MISSILE_TRAILS */
    func_8003799C(D_80094ABC, &D_800AC984); /* BRAIN_MISSILE_SEP */
    func_8003799C(D_80094AD0, &D_800B1BE4); /* BRAIN_TURN_TIME */
    func_8003799C(D_80094AE0, &laserRepeatRate); /* LASER_REPEAT_RATE */
    func_8003799C(D_80094AF4, &D_800AC988); /* MISSILE_DURATION_AFTER_HULK_COLLIDE */
    func_8003799C(D_80094B18, &D_800AC98C); /* MISSILE_START_VARIANCE */
    func_8003799C(D_80094B30, &D_8009D118); /* SHIELD_NUM_HITS */
    func_8003799C(D_80094B40, &D_8009AA00[0].value58); /* TWO_WAY_NUM_HITS */
    func_8003799C(D_80094B54, &D_8009AA00[1].value58); /* THREE_WAY_NUM_HITS */
    func_8003799C(D_80094B68, &D_8009AA00[2].value58); /* FOUR_WAY_NUM_HITS */
    func_8003799C(D_80094B7C, &D_8009AA00[4].value58); /* WAVE_NUM_HITS */
    func_8003799C(D_80094B8C, &D_8009AA00[3].value58); /* FLAME_NUM_HITS */
    func_8003799C(D_80094B9C, &D_800BAE94); /* ENABLE_POWERUPS */
    D_800AC9A8 = laserRepeatRate;
    func_800360B8(D_80094BAC);
}
