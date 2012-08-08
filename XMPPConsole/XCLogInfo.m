//
//  XCLogProxy.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCLogInfo.h"

#import "XCUUID.h"


#define XCLogInfoDateKey @"Date"
#define XCLogInfoUUIDKey @"UUID"


@implementation XCLogInfo

- (XCLog *)log
{
    if (_log == nil && self.fileWrapper.regularFileContents != nil) {
        _log = [NSKeyedUnarchiver unarchiveObjectWithData:self.fileWrapper.regularFileContents];
    }
    
    return _log;
}

- (NSFileWrapper *)fileWrapper
{
    if (_fileWrapper == nil && _log != nil) {
        NSData *logData = [NSKeyedArchiver archivedDataWithRootObject:_log];
        _fileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:logData];
        _fileWrapper.preferredFilename = self.UUID;
    }
    
    return _fileWrapper;
}

- (NSString *)UUID
{
    if (_UUID == nil) {
        _UUID = XCUUIDString();
    }
    
    return _UUID;
}


#pragma mark - Initialization

- (id)initWithLog:(XCLog *)log
{
    self = [super init];
    if (self) {
        _log = log;
        _date = [NSDate date];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _date = [coder decodeObjectForKey:XCLogInfoDateKey];
        _UUID = [coder decodeObjectForKey:XCLogInfoUUIDKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_date forKey:XCLogInfoDateKey];
    [aCoder encodeObject:_UUID forKey:XCLogInfoUUIDKey];
}

@end
