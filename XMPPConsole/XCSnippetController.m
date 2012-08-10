//
//  XCSnippetController.m
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetController.h"

#import "XCSnippet_Private.h"
#import "XCUUID.h"


NSURL *XCURLForSnippets()
{
    NSURL *directory = [[NSFileManager defaultManager] applicationSupportDirectory];
    directory = [directory URLByAppendingPathComponent:@"Snippets" isDirectory:YES];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    return directory;
}


@implementation XCSnippetController {
    NSMutableArray *_snippets;
}

static XCSnippetController *sharedInstance;


#pragma mark - Properties

- (NSArray *)snippets
{
    return [_snippets copy];
}

- (NSUInteger)countOfSnippets
{
    return _snippets.count;
}

- (XCSnippet *)objectInSnippetsAtIndex:(NSUInteger)index
{
    return _snippets[index];
}

- (void)getSnippets:(XCSnippet * __unsafe_unretained *)buffer range:(NSRange)inRange
{
    [_snippets getObjects:buffer range:inRange];
}

- (void)insertObject:(XCSnippet *)snippet inSnippetsAtIndex:(NSUInteger)index
{
    [_snippets insertObject:snippet atIndex:index];
    
    [snippet addObserver:self forKeyPath:@"tags" options:0 context:NULL];
    [self _saveSnippet:snippet];
    [self _save];
}

- (void)removeObjectFromSnippetsAtIndex:(NSUInteger)index
{
    XCSnippet *snippet = _snippets[index];
    [_snippets removeObjectAtIndex:index];
    
    [snippet removeObserver:self forKeyPath:@"tags"];
    [[NSFileManager defaultManager] removeItemAtURL:snippet._fileURL error:NULL];
    
    [self _save];
}

- (NSArray *)tags
{
    return [self valueForKeyPath:@"snippets.@distinctUnionOfArrays.tags.lowercaseString"];
}

+ (NSSet *)keyPathsForValuesAffectingTags
{
    return [NSSet setWithObject:@"snippets"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"tags"] && [object isKindOfClass:[XCSnippet class]]) {
        [self willChangeValueForKey:@"tags"];
        [self didChangeValueForKey:@"tags"];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark - Initialization

+ (void)initialize
{
    static dispatch_once_t done;
	dispatch_once(&done, ^{
		sharedInstance = [[super alloc] init];
        
        sharedInstance->_snippets = [NSMutableArray new];
        
        [sharedInstance _load];
	});
}

+ (XCSnippetController *)sharedController
{
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	if (sharedInstance != nil) {
		return sharedInstance;
	}
	
	return [super allocWithZone:zone];
}

- (id)copy
{
	return self;
}

- (id)init
{
    return self;
}


#pragma mark - Saving

- (void)_load
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOOL exists = [self _loadSavedSnippets];
        
        if (!exists) {
            [self _loadDefaultSnippets];
        }
        
        for (XCSnippet *snippet in _snippets) {
            [snippet addObserver:self forKeyPath:@"tags" options:0 context:NULL];
        }
    });
}

- (BOOL)_loadSavedSnippets
{
    NSURL *snippetDirectory = XCURLForSnippets();
    NSURL *indexURL = [snippetDirectory URLByAppendingPathComponent:@"Index.plist" isDirectory:NO];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[indexURL path]]) {
        NSData *data = [NSData dataWithContentsOfURL:indexURL];
        NSArray *index = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
        
        if ([index isKindOfClass:[NSArray class]]) {
            [self willChangeValueForKey:@"snippets"];
            
            for (NSString *path in index) {
                XCSnippet *snippet = [[XCSnippet alloc] _initWithURL:[NSURL fileURLWithPath:path]];
                
                [_snippets addObject:snippet];
            }
            
            [self didChangeValueForKey:@"snippets"];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)_loadDefaultSnippets
{
    NSURL *defaultSnippetsURL = [[NSBundle mainBundle] URLForResource:@"DefaultSnippets" withExtension:@"plist"];
    NSData *data = [NSData dataWithContentsOfURL:defaultSnippetsURL];
    NSArray *snippetsInfo = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
    
    [self willChangeValueForKey:@"snippets"];
    
    for (NSDictionary *snippetInfo in snippetsInfo) {
        XCSnippet *snippet = [XCSnippet snippetWithTitle:snippetInfo[XCSnippetTitleKey] summary:snippetInfo[XCSnippetSummaryKey] body:snippetInfo[XCSnippetBodyKey]];
        
        [_snippets addObject:snippet];
        [self _saveSnippet:snippet];
    }
    
    [self didChangeValueForKey:@"snippets"];
    
    [self _save];
}

- (void)_save
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSURL *snippetDirectory = XCURLForSnippets();
        NSURL *indexURL = [snippetDirectory URLByAppendingPathComponent:@"Index.plist" isDirectory:NO];
        
        NSData *data = [NSPropertyListSerialization dataWithPropertyList:[[self.snippets valueForKey:@"_fileURL"] valueForKey:@"path"] format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
        [data writeToURL:indexURL atomically:YES];
    });
}

- (void)_saveSnippet:(XCSnippet *)snippet
{
    if (snippet._fileURL == nil) {
        NSURL *snippetDirectory = XCURLForSnippets();
        BOOL directoryExists = YES;
        if (![[NSFileManager defaultManager] fileExistsAtPath:snippetDirectory.path isDirectory:&directoryExists]) {
            directoryExists = [[NSFileManager defaultManager] createDirectoryAtPath:snippetDirectory.path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        if (directoryExists) {
            NSString *fileName = [NSString stringWithFormat:@"%@.plist", XCUUIDString()];
            NSURL *snippetURL = [snippetDirectory URLByAppendingPathComponent:fileName isDirectory:NO];
            snippet._fileURL = snippetURL;
        }
    }
    
    [snippet _save];
}

@end
