#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

static char dummy_device_struct[1024] = {0};
static char dummy_context_struct[1024] = {0};

// --- OpenAL Hooks with Logging ---
static ALCdevice* my_alcOpenDevice(const ALCchar *devicename) {
    NSLog(@"[WirewayFix] alcOpenDevice called with devicename: %s", devicename ? devicename : "NULL");
    return (ALCdevice *)dummy_device_struct;
}

static ALCcontext* my_alcCreateContext(ALCdevice *device, const ALCint *attrlist) {
    NSLog(@"[WirewayFix] alcCreateContext called");
    return (ALCcontext *)dummy_context_struct;
}

static ALCboolean my_alcMakeContextCurrent(ALCcontext *context) {
    NSLog(@"[WirewayFix] alcMakeContextCurrent called");
    return ALC_TRUE;
}

static void my_alcGetIntegerv(ALCdevice *device, ALCenum param, ALCsizei size, ALCint *values) {
    NSLog(@"[WirewayFix] alcGetIntegerv called with param: 0x%X", param);
    if (values && size > 0) {
        for (int i = 0; i < size; i++) values[i] = 0;
    }
}

static ALCenum my_alcGetError(ALCdevice *device) {
    NSLog(@"[WirewayFix] alcGetError called");
    return ALC_NO_ERROR;
}

// --- AudioSession Hooks with Logging ---
static OSStatus my_AudioSessionSetActive(Boolean active) {
    NSLog(@"[WirewayFix] AudioSessionSetActive called: %d", active);
    return 0;
}

static OSStatus my_AudioSessionInitialize(CFRunLoopRef inRunLoop, CFStringRef inRunLoopMode, AudioSessionInterruptionListener inInterruptionListener, void *inClientData) {
    NSLog(@"[WirewayFix] AudioSessionInitialize called");
    return 0;
}

static OSStatus my_AudioSessionGetProperty(AudioSessionPropertyID inID, UInt32 *ioDataSize, void *outData) {
    NSLog(@"[WirewayFix] AudioSessionGetProperty called for ID: 0x%X", (unsigned int)inID);
    if (!outData) return 0;
    if (inID == kAudioSessionProperty_CurrentHardwareSampleRate) {
        if (ioDataSize) *ioDataSize = sizeof(Float64);
        *(Float64 *)outData = 44100.0;
        NSLog(@"[WirewayFix] -> Spoofed HardwareSampleRate to 44100.0");
    }
    return 0;
}

// --- Render Loop / Display Hooks ---
%hook CADisplayLink
- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSString *)mode {
    NSLog(@"[WirewayFix] CADisplayLink addToRunLoop called for mode: %@", mode);
    %orig;
    [self setPaused:NO];
}
- (void)setPaused:(BOOL)paused {
    NSLog(@"[WirewayFix] CADisplayLink setPaused called: %d", paused);
    %orig(NO); // Force unpaused
}
%end

%hook UIApplication
- (void)applicationDidBecomeActive:(id)application {
    NSLog(@"[WirewayFix] applicationDidBecomeActive triggered");
    %orig;
}
%end

%ctor {
    NSLog(@"[WirewayFix] === WirewayAudioFix Tweak Loaded Successfully ===");

    MSHookFunction((void *)alcOpenDevice, (void *)my_alcOpenDevice, NULL);
    MSHookFunction((void *)alcCreateContext, (void *)my_alcCreateContext, NULL);
    MSHookFunction((void *)alcMakeContextCurrent, (void *)my_alcMakeContextCurrent, NULL);
    MSHookFunction((void *)alcGetIntegerv, (void *)my_alcGetIntegerv, NULL);
    MSHookFunction((void *)alcGetError, (void *)my_alcGetError, NULL);

    MSHookFunction((void *)AudioSessionSetActive, (void *)my_AudioSessionSetActive, NULL);
    MSHookFunction((void *)AudioSessionInitialize, (void *)my_AudioSessionInitialize, NULL);
    MSHookFunction((void *)AudioSessionGetProperty, (void *)my_AudioSessionGetProperty, NULL);
}
