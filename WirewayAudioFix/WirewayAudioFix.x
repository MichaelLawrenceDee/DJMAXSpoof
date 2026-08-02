#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

// 1. Hook Legacy AudioSession C-APIs
static OSStatus my_AudioSessionSetActive(Boolean active) { return 0; }
static OSStatus my_AudioSessionInitialize(CFRunLoopRef inRunLoop, CFStringRef inRunLoopMode, AudioSessionInterruptionListener inInterruptionListener, void *inClientData) { return 0; }

// 2. Hook OpenAL Device & Context initialization to prevent hanging
static ALCdevice* (*orig_alcOpenDevice)(const ALCchar *devicename);
static ALCdevice* my_alcOpenDevice(const ALCchar *devicename) {
    return (ALCdevice *)0x12345678;
}

static ALCcontext* (*orig_alcCreateContext)(ALCdevice *device, const ALCint *attrlist);
static ALCcontext* my_alcCreateContext(ALCdevice *device, const ALCint *attrlist) {
    return (ALCcontext *)0x87654321;
}

static ALCboolean (*orig_alcMakeContextCurrent)(ALCcontext *context);
static ALCboolean my_alcMakeContextCurrent(ALCcontext *context) {
    return ALC_TRUE;
}

%ctor {
    // Intercept AudioToolbox
    MSHookFunction((void *)AudioSessionSetActive, (void *)my_AudioSessionSetActive, NULL);
    MSHookFunction((void *)AudioSessionInitialize, (void *)my_AudioSessionInitialize, NULL);

    // Intercept OpenAL
    MSHookFunction((void *)alcOpenDevice, (void *)my_alcOpenDevice, (void **)&orig_alcOpenDevice);
    MSHookFunction((void *)alcCreateContext, (void *)my_alcCreateContext, (void **)&orig_alcCreateContext);
    MSHookFunction((void *)alcMakeContextCurrent, (void *)my_alcMakeContextCurrent, (void **)&orig_alcMakeContextCurrent);
}
