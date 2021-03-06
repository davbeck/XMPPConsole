//
//  XCLogsController.h
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCLogInfo;
@class XCLog;


@interface XCLogsController : NSObject

@property (nonatomic, strong) NSFileWrapper *fileWrapper;

@property (readonly) NSArray *logInfo;
- (XCLogInfo *)addLog:(XCLog *)log;

- (void)save;

@end
