#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

// --- 1. AudioToolbox C-API Hooks ---
static OSStatus my_AudioSessionSetActive(Boolean active) { return 0; }
static OSStatus my_AudioSessionInitialize(CFRunLoopRef inRunLoop, CFStringRef inRunLoopMode, AudioSessionInterruptionListener inInterruptionListener, void *inClientData) { return 0; }

static OSStatus my_AudioSessionGetProperty(AudioSessionPropertyID inID, UInt32 *ioDataSize, void *outData) {
    if (!outData) return 0;
    
    // Fake 44.1kHz sample rate to satisfy game engine checks
    if (inID == kAudioSessionProperty_CurrentHardwareSampleRate) {
        if (ioDataSize) *ioDataSize = sizeof(Float64);
        *(Float64 *)outData = 44100.0;
        return 0;
    }
    return 0;
}

static OSStatus my_AudioSessionSetProperty(AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData) {
    return 0;
}

// --- 2. System Sound Hooks ---
static void my_AudioServicesPlaySystemSound(SystemSoundID inSystemSoundID) {}

// --- 3. OpenAL Engine Hooks (Safe Null Engine) ---
// Return NULL for device creation so OpenAL safely operates in a silent/disabled state
static ALCdevice* my_alcOpenDevice(const ALCchar *devicename) { return NULL; }
static ALCcontext* my_alcCreateContext(ALCdevice *device, const ALCint *attrlist) { return NULL; }
static ALCboolean my_alcMakeContextCurrent(ALCcontext *context) { return ALC_FALSE; }
static ALCenum my_alcGetError(ALCdevice *device) { return ALC_NO_ERROR; }

// --- 4. AVFoundation Class Hooks ---
%hook AVAudioSession
- (BOOL)setActive:(BOOL)active error:(NSError **)outError { return YES; }
- (BOOL)setCategory:(NSString *)category error:(NSError **)outError { return YES; }
%end

%hook AVAudioPlayer
- (BOOL)play { return YES; }
- (BOOL)prepareToPlay { return YES; }
%end

%ctor {
    // Intercept AudioToolbox
    MSHookFunction((void *)AudioSessionSetActive, (void *)my_AudioSessionSetActive, NULL);
    MSHookFunction((void *)AudioSessionInitialize, (void *)my_AudioSessionInitialize, NULL);
    MSHookFunction((void *)AudioSessionGetProperty, (void *)my_AudioSessionGetProperty, NULL);
    MSHookFunction((void *)AudioSessionSetProperty, (void *)my_AudioSessionSetProperty, NULL);
    MSHookFunction((void *)AudioServicesPlaySystemSound, (void *)my_AudioServicesPlaySystemSound, NULL);

    // Intercept OpenAL
    MSHookFunction((void *)alcOpenDevice, (void *)my_alcOpenDevice, NULL);
    MSHookFunction((void *)alcCreateContext, (void *)my_alcCreateContext, NULL);
    MSHookFunction((void *)alcMakeContextCurrent, (void *)my_alcMakeContextCurrent, NULL);
    MSHookFunction((void *)alcGetError, (void *)my_alcGetError, NULL);
}
