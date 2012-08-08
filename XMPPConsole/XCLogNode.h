//
//  XCLogNode.h
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCLogNode : NSObject <NSCoding>

@property (copy) NSString *body;
@property BOOL fromServer;

+ (id)nodeWithBody:(NSString *)body fromServer:(BOOL)fromServer;

@end
