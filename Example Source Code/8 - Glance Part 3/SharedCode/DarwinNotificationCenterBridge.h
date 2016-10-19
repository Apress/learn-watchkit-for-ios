//
//  DarwinNotificationCenterBridge.h
//  DarwinBridge
//
//  Created by Kim Topley on 5/31/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DarwinNotificationObserver

- (void)onNotificationReceived:(NSString *)name;

@end

@interface DarwinNotificationCenterBridge : NSObject

+ (void)postNotificationForName:(NSString *)name;
+ (void)addObserver:(id<DarwinNotificationObserver>)receiver
                     forName:(NSString *)name;
+ (void)removeObserver:(id<DarwinNotificationObserver>)receiver
                        forName:(NSString *)name;

@end
