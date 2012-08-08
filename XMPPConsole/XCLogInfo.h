//
//  XCLogProxy.h
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCLog;


@interface XCLogInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSFileWrapper *fileWrapper;
@property (nonatomic, strong) XCLog *log;
@property (strong) NSDate *date;
@property (nonatomic, strong) NSString *UUID;

- (id)initWithLog:(XCLog *)log;

@end
