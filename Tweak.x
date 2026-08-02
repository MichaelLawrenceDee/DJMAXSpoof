#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UIDevice
- (NSString *)uniqueIdentifier {
    return @"e98c463fa1774a048f7fd15b8aefefc7ea0c1366";
}
%end
