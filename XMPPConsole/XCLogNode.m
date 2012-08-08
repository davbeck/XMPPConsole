//
//  XCLogNode.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCLogNode.h"


#define XCLogNodeBodyKey @"Body"
#define XCLogNodeFromServerKey @"FromServer"


@implementation XCLogNode

+ (id)nodeWithBody:(NSString *)body fromServer:(BOOL)fromServer
{
    XCLogNode *node = [[XCLogNode alloc] init];
    
    node.body = body;
    node.fromServer = fromServer;
    
    return node;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.body = [coder decodeObjectForKey:XCLogNodeBodyKey];
        self.fromServer = [[coder decodeObjectForKey:XCLogNodeFromServerKey] boolValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.body forKey:XCLogNodeBodyKey];
    [aCoder encodeObject:@(self.fromServer) forKey:XCLogNodeFromServerKey];
}

@end
