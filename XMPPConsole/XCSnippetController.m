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
    NSMutableDictionary *_snippetsByTag;
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
    return [_snippets objectAtIndex:index];
}

- (void)getSnippets:(XCSnippet * __unsafe_unretained *)buffer range:(NSRange)inRange
{
    [_snippets getObjects:buffer range:inRange];
}

- (void)insertObject:(XCSnippet *)snippet inSnippetsAtIndex:(NSUInteger)index
{
    [_snippets insertObject:snippet atIndex:index];
    
    [snippet addObserver:self forKeyPath:@"tags" options:0 context:NULL];
    [self _updateTagsForSnippet:snippet];
    [self _saveSnippet:snippet];
    [self _save];
}

- (void)removeObjectFromSnippetsAtIndex:(NSUInteger)index
{
    XCSnippet *snippet = [_snippets objectAtIndex:index];
    [_snippets removeObjectAtIndex:index];
    
    [snippet removeObserver:self forKeyPath:@"tags"];
    [self _cleanUpTags];
    [[NSFileManager defaultManager] removeItemAtURL:snippet._fileURL error:NULL];
    
    [self _save];
}

- (NSDictionary *)snippetsByTag
{
    return [_snippetsByTag copy];
}

- (NSArray *)tags
{
    return [_snippetsByTag allKeys];
}

+ (NSSet *)keyPathsForValuesAffectingTags
{
    return [NSSet setWithObject:@"snippetsByTag"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"tags"] && [object isKindOfClass:[XCSnippet class]]) {
        XCSnippet *snippet = object;
        
        [self willChangeValueForKey:@"snippetsByTag"];
        
        [self _updateTagsForSnippet:snippet];
        [self _cleanUpTags];
        
        [self didChangeValueForKey:@"snippetsByTag"];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)_updateTagsForSnippet:(XCSnippet *)snippet
{
    for (NSString *tag in snippet.tags) {
        if (_snippetsByTag[tag] == nil) {
            _snippetsByTag[tag] = [NSMutableArray new];
        }
        
        if (![_snippetsByTag[tag] containsObject:snippet]) {
            [_snippetsByTag[tag] addObject:snippet];
        }
    }
}

- (void)_cleanUpTags
{
    NSDictionary *snippetsByTag = [_snippetsByTag copy];
    
    [self willChangeValueForKey:@"snippetsByTag"];
    
    [snippetsByTag enumerateKeysAndObjectsUsingBlock:^(NSString *tag, NSArray *tagSnippets, BOOL *stop) {
        //remove old snippets from tag array
        for (XCSnippet *snippet in tagSnippets) {
            if (![snippet.tags containsObject:tag]) {
                [_snippetsByTag[tag] removeObject:snippet];
                
                if ([_snippetsByTag[tag] count] <= 0) {
                    [_snippetsByTag removeObjectForKey:tag];
                }
            }
        }
    }];
    
    [self didChangeValueForKey:@"snippetsByTag"];
}


#pragma mark - Initialization

+ (void)initialize
{
    static dispatch_once_t done;
	dispatch_once(&done, ^{
		sharedInstance = [[super alloc] init];
        
        sharedInstance->_snippets = [NSMutableArray new];
        sharedInstance->_snippetsByTag = [NSMutableDictionary new];
        
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (XCSnippet *snippet in _snippets) {
                [self _updateTagsForSnippet:snippet];
            }
        });
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
                
                [snippet addObserver:self forKeyPath:@"tags" options:0 context:NULL];
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
        [snippet addObserver:self forKeyPath:@"tags" options:0 context:NULL];
        
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
