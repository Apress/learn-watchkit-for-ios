//
//  DarwinNotificationCenterBridge.m
//  DarwinBridge
//
//  Created by Kim Topley on 5/31/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

#import "DarwinNotificationCenterBridge.h"

static NSMutableDictionary *nameToObserversMap;

@implementation DarwinNotificationCenterBridge

+ (void)initialize {
    if (nameToObserversMap == NULL) {
        nameToObserversMap = [[NSMutableDictionary alloc] init];
    }
}

// Posts a notification for a given name.
+ (void)postNotificationForName:(NSString *)name {
    CFNotificationCenterPostNotificationWithOptions(
            CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge CFStringRef)name,
            NULL, NULL,
            kCFNotificationDeliverImmediately | kCFNotificationPostToAllSessions);
}

// Adds an observer for a notification with a given name.
+ (void)addObserver:(id<DarwinNotificationObserver>)observer forName:(NSString *)name {
    BOOL needRegister = NO;
    NSMutableSet *observers = (NSMutableSet *)[nameToObserversMap objectForKey:name];
    if (observers == nil) {
        observers = [[NSMutableSet alloc] init];
        [nameToObserversMap setObject:observers forKey:name];
        needRegister = YES;
    }
    [observers addObject:observer];
    
    if (needRegister) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        (const void *)self,
                                        onNotificationCallback,
                                        (__bridge CFStringRef)name,
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}
// Removes an observer for a notification with a given name.
+ (void)removeObserver:(id<DarwinNotificationObserver>)observer forName:(NSString *)name {
    BOOL needUnregister = NO;
    NSMutableSet *observers = (NSMutableSet *)[nameToObserversMap objectForKey:name];
    if ([observers containsObject:observer]) {
        [observers removeObject:observer];
        if (observers.count == 0) {
            [nameToObserversMap removeObjectForKey:name];
            needUnregister = YES;
        }
    }
    
    if (needUnregister) {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                           (const void *)self,
                                           (__bridge CFStringRef)name,
                                           NULL);
    }
}

// Callback from Darwin Notification Center.
void onNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString *notificationName = (__bridge NSString *)name;
    NSArray *observers = [nameToObserversMap objectForKey:notificationName];
    if (observers != NULL) {
        for (id<DarwinNotificationObserver> observer in observers) {
            [observer onNotificationReceived:notificationName];
        }
    }
    
}


@end
