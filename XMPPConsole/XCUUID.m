//
//  NSObject+XCUUID.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCUUID.h"

@implementation NSObject (XCUUID)

NSString *XCUUIDString()
{
    if (NSClassFromString(@"NSUUID") != nil) {
        return [[NSClassFromString(@"NSUUID") UUID] UUIDString];
    }
    
    CFUUIDRef UUID = CFUUIDCreate(NULL);
    NSString *UUIDString = CFBridgingRelease(CFUUIDCreateString(NULL, UUID));
    CFRelease(UUID);
    
    return UUIDString;
}

@end
