//
//  XCSnippet.m
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippet.h"

#import "XCSnippet_Private.h"


@implementation XCSnippet

- (NSAttributedString *)attributedSummary
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    if (self.title != nil) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.title attributes:@{ NSFontAttributeName : [NSFont boldSystemFontOfSize:11.0] }]];
    }
    if (self.title != nil & self.summary != nil) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" - " attributes:@{ NSFontAttributeName : [NSFont systemFontOfSize:11.0] }]];
    }
    if (self.summary != nil) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.summary attributes:@{ NSFontAttributeName : [NSFont systemFontOfSize:11.0] }]];
    }
    
    return string;
}

+ (NSSet *)keyPathsForValuesAffectingAttributedSummary
{
    return [NSSet setWithObjects:@"title", @"summary", nil];
}

+ (XCSnippet *)snippetWithTitle:(NSString *)title summary:(NSString *)summary body:(NSString *)body
{
    XCSnippet *snippet = [[[self class] alloc] init];
    
    snippet.title = title;
    snippet.summary = summary;
    snippet.body = body;
    
    return snippet;
}

- (id)copy
{
    return [[self class] snippetWithTitle:_title summary:_summary body:_body];
}

- (BOOL)isEqual:(XCSnippet *)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self._fileURL isEqual:object._fileURL];
    }
    
    return NO;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_title forKey:XCSnippetTitleKey];
    [aCoder encodeObject:_summary forKey:XCSnippetSummaryKey];
    [aCoder encodeObject:_body forKey:XCSnippetBodyKey];
    
    [aCoder encodeObject:self._fileURL forKey:XCSnippetURLKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:XCSnippetTitleKey];
        _summary = [aDecoder decodeObjectForKey:XCSnippetSummaryKey];
        _body = [aDecoder decodeObjectForKey:XCSnippetBodyKey];
        
        __fileURL = [aDecoder decodeObjectForKey:XCSnippetURLKey];
    }
    
    return self;
}


#pragma mark - Saving

- (void)_save
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (_title != nil) {
        dictionary[XCSnippetTitleKey] = _title;
    }
    if (_title != nil) {
        dictionary[XCSnippetSummaryKey] = _summary;
    }
    if (_title != nil) {
        dictionary[XCSnippetBodyKey] = _body;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
        
        [data writeToURL:self._fileURL atomically:YES];
    });
}

- (id)_initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        __fileURL = URL;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:__fileURL];
            NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
            
            if ([dictionary isKindOfClass:[NSDictionary class]]) {
                self.title = dictionary[XCSnippetTitleKey];
                self.summary = dictionary[XCSnippetSummaryKey];
                self.body = dictionary[XCSnippetBodyKey];
            }
        });
    }
    
    return self;
}


#pragma mark - NSPasteboardWriting

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableArray *types = [NSMutableArray arrayWithObject:XCSnippetUTI];
    
    [types addObjectsFromArray:[self.body writableTypesForPasteboard:pasteboard]];
    
    return types;
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:XCSnippetUTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    return [self.body pasteboardPropertyListForType:type];
}


#pragma mark - NSPasteboardReading

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableArray *types = [NSMutableArray arrayWithObject:XCSnippetUTI];
    
    [types addObjectsFromArray:[NSString readableTypesForPasteboard:pasteboard]];
    
    return types;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type
{
    if ([type isEqualToString:XCSnippetUTI] && [propertyList isKindOfClass:[NSData class]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:propertyList];
    }
    
    self = [super init];
    if (self != nil) {
        self.body = [[NSString alloc] initWithPasteboardPropertyList:propertyList ofType:type];
    }
    
    return self;
}

@end
