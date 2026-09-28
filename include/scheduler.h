#ifndef ROBOTRON_SCHEDULER_H
#define ROBOTRON_SCHEDULER_H

typedef struct OSThread OSThread;
typedef struct OSMesgQueue OSMesgQueue;
typedef struct Scheduler Scheduler;
typedef struct SchedulerTask SchedulerTask;
typedef struct SchedulerClient SchedulerClient;
typedef void *OSMesg;

enum {
    TV_NTSC = 1,
    TV_MPAL = 2
};

enum {
    VI_GAMMA_OFF = 2,
    VI_DITHER_FILTER_ON = 0x40
};

enum {
    EVENT_SP = 4,
    EVENT_DP = 9,
    EVENT_PRENMI = 14
};

enum {
    SCHEDULER_RETRACE = 0x29A,
    SCHEDULER_SP = 0x29B,
    SCHEDULER_DP = 0x29C,
    SCHEDULER_PRENMI = 0x29D
};

/* Register offsets are read by the retail context restore at 0x800671D4. */
typedef struct OSThreadContext {
    unsigned long long at, v0, v1, a0, a1, a2, a3;
    unsigned long long t0, t1, t2, t3, t4, t5, t6, t7;
    unsigned long long s0, s1, s2, s3, s4, s5, s6, s7;
    unsigned long long t8, t9, gp, sp, s8, ra, lo, hi;
    unsigned int status;
    unsigned int pc;
    unsigned int unknown120;
    unsigned int unknown124;
    unsigned int rcpMask;
    unsigned int fpcsr;
    unsigned long long fp[16];
} OSThreadContext;

struct OSThread {
    OSThread *next;
    int priority;
    OSThread **queue;
    OSThread *activeNext;
    unsigned short state;
    unsigned short flags;
    int id;
    int fpUsed;
    unsigned int unknown1C;
    OSThreadContext context;
};

typedef char OSThreadContextMustBe400Bytes[sizeof(OSThreadContext) == 0x190 ? 1 : -1];
typedef char OSThreadMustBe432Bytes[sizeof(OSThread) == 0x1B0 ? 1 : -1];

struct OSMesgQueue {
    OSThread *receivers;
    OSThread *senders;
    int count;
    int first;
    int capacity;
    OSMesg *messages;
};

struct Scheduler {
    short unknown00;
    short unknown02;
    OSMesgQueue queue04;
    OSMesg messages1C[8];
    OSMesgQueue queue3C;
    OSMesg messages54[8];
    OSMesgQueue retraceQueue;
    OSMesg retraceMessages[8];
    OSMesgQueue spQueue;
    OSMesg spMessages[8];
    OSMesgQueue dpQueue;
    OSMesg dpMessages[8];
    OSMesgQueue queue11C;
    OSMesg messages134[8];
    OSThread thread158;
    OSThread thread308;
    OSThread thread4B8;
    SchedulerClient *clients;
    SchedulerTask *graphicsTask;
    SchedulerTask *audioTask;
    SchedulerTask *waitingGraphicsTask;
    unsigned int firstGraphicsTask;
};

/* The target indexes this table with an 80-byte stride. */
typedef struct VideoMode {
    unsigned char type;
    unsigned int control;
    unsigned int width;
    unsigned int unknown0C[5];
    unsigned int xScale;
    unsigned int unknown24;
    unsigned int field0Origin;
    unsigned int unknown2C[9];
} VideoMode;

extern VideoMode D_8008E400[];
extern Scheduler D_801378D0;

void osCreateMesgQueue(OSMesgQueue *, OSMesg *, int);
int func_80062240(OSMesgQueue *, OSMesg *, int);
int func_800635A0(OSMesgQueue *, OSMesg, int);
void osCreateThread(OSThread *, int, void (*)(void *), void *, void *, int);
void osStartThread(OSThread *);
void osViSetSpecialFeatures(unsigned int);
void osCreateViManager(int);
void osViSetMode(VideoMode *);
void osViBlack(unsigned char);
void osViSetEvent(OSMesgQueue *, OSMesg, unsigned int);
void osSetEventMesg(int, OSMesgQueue *, OSMesg);
void func_80050440(Scheduler *, unsigned char, unsigned char);
OSMesgQueue *func_80050620(Scheduler *);
OSMesgQueue *func_80050628(Scheduler *);

#endif
