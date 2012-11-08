//
//  XCLogsController.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCLogsController.h"

#import "XCLog.h"
#import "XCLogInfo.h"


#define XCLogInfoFileName @"LogInfo"


@implementation XCLogsController {
    NSMutableArray *_logInfo;
}

- (void)setFileWrapper:(NSFileWrapper *)fileWrapper
{
    _fileWrapper = fileWrapper;
    
    NSData *infoData = [_fileWrapper.fileWrappers[XCLogInfoFileName] regularFileContents];
    if (infoData != nil) {
        NSArray *logInfo = [NSKeyedUnarchiver unarchiveObjectWithData:infoData];
        for (XCLogInfo *info in logInfo) {
            info.fileWrapper = _fileWrapper.fileWrappers[info.UUID];
        }
        
        [self willChangeValueForKey:@"infoData"];
        _logInfo = [logInfo mutableCopy];
        [self didChangeValueForKey:@"infoData"];
    }
}

- (XCLogInfo *)addLog:(XCLog *)log
{
    XCLogInfo *logInfo = [[XCLogInfo alloc] initWithLog:[log copy]];
    
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_logInfo.count];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"logInfo"];
    
    [_logInfo insertObject:logInfo atIndex:indexSet.firstIndex];
    
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"logInfo"];
    
    
    return logInfo;
}

- (NSArray *)logInfo
{
    return [_logInfo copy];
}


#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        _fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        _logInfo = [NSMutableArray new];
    }
    
    return self;
}

- (void)save
{
    NSArray *logInfo = self.logInfo;
    
    for (XCLogInfo *info in logInfo) {
        if (self.fileWrapper.fileWrappers[info.UUID] == nil && info.fileWrapper != nil) {
            [self.fileWrapper addFileWrapper:info.fileWrapper];
        }
    }
    
    NSData *infoData = [NSKeyedArchiver archivedDataWithRootObject:logInfo];
    NSFileWrapper *infoWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:infoData];
    infoWrapper.preferredFilename = XCLogInfoFileName;
    [self.fileWrapper removeFileWrapper:self.fileWrapper.fileWrappers[XCLogInfoFileName]];
    [self.fileWrapper addFileWrapper:infoWrapper];
}

@end
