#ifndef ROBOTRON_SCHEDULER_H
#define ROBOTRON_SCHEDULER_H

typedef struct OSThread OSThread;
typedef struct OSMesgQueue OSMesgQueue;
typedef struct Scheduler Scheduler;
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

/* Thread fields are opaque here; scheduler storage slots are 0x1B0 bytes. */
struct OSThread {
    unsigned long long unknown[54];
};

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
    unsigned int unknown668;
    unsigned int unknown66C;
    unsigned int unknown670;
    unsigned int unknown674;
    unsigned int unknown678;
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
