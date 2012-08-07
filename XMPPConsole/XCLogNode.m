//
//  XCLogNode.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCLogNode.h"

@implementation XCLogNode

+ (id)nodeWithBody:(NSString *)body fromServer:(BOOL)fromServer
{
    XCLogNode *node = [[XCLogNode alloc] init];
    
    node.body = body;
    node.fromServer = fromServer;
    
    return node;
}

@end
