#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

__attribute__((constructor)) static void init() {
    Class class = [UIDevice class];
    SEL originalSelector = @selector(uniqueIdentifier);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    IMP newImplementation = imp_implementationWithBlock(^NSString *(id _self) {
        return @"e98c463fa1774a048f7fd15b8aefefc7ea0c1366";
    });
    
    if (originalMethod) {
        method_setImplementation(originalMethod, newImplementation);
    }
}