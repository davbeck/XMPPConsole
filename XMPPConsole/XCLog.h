//
//  XCLog.h
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCLog : NSObject <NSCoding>

@property (copy, readonly) NSAttributedString *text;

@end
