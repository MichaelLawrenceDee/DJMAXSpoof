#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>

// Hook legacy C-function for setting Audio Session Active
static OSStatus (*orig_AudioSessionSetActive)(Boolean active);

static OSStatus my_AudioSessionSetActive(Boolean active) {
    // Return 0 (noErr) immediately so Wireway skips the hanging iOS 10 audio thread
    return 0; 
}

// Hook legacy C-function for initializing the Audio Session
static OSStatus (*orig_AudioSessionInitialize)(CFRunLoopRef inRunLoop, CFStringRef inRunLoopMode, AudioSessionInterruptionListener inInterruptionListener, void *inClientData);

static OSStatus my_AudioSessionInitialize(CFRunLoopRef inRunLoop, CFStringRef inRunLoopMode, AudioSessionInterruptionListener inInterruptionListener, void *inClientData) {
    // Trigger the listener callback if provided, then return success
    return 0;
}

%ctor {
    // Intercept both C-functions in AudioToolbox framework
    MSHookFunction((void *)AudioSessionSetActive, 
                   (void *)my_AudioSessionSetActive, 
                   (void **)&orig_AudioSessionSetActive);

    MSHookFunction((void *)AudioSessionInitialize, 
                   (void *)my_AudioSessionInitialize, 
                   (void **)&orig_AudioSessionInitialize);
}
