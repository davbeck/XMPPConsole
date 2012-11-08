//
//  XCJIDFormatter.m
//  XMPPConsole
//
//  Created by David Beck on 8/3/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCJIDFormatter.h"

#import "XMPP.h"

@implementation XCJIDFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:[XMPPJID class]]) {
        return [(XMPPJID *)obj full];
    }
    
    return [obj description];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
    XMPPJID *JID = [XMPPJID jidWithString:string];
    
    *anObject = JID;
    
    return YES;
}

@end
