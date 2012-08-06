//
//  XCSnippet.m
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippet.h"

#import "XCSnippet_Private.h"
#import "NSXMLElement+AttributedString.h"
#import "NSFont+CodeFont.h"


@implementation XCSnippet
{
    id __element;
    BOOL _okToSave;
    BOOL _needsSave;
}

@synthesize _element = __element;

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    [self _setNeedsSave];
}

- (void)setSummary:(NSString *)summary
{
    _summary = summary;
    
    [self _setNeedsSave];
}

- (void)setBody:(NSString *)body
{
    __element = nil;
    _body = body;
    
    [self _setNeedsSave];
}

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

- (NSAttributedString *)attributedBody
{
    NSAttributedString *XMLString = [self._element XMLAttributedString];
    if (XMLString != nil) {
        return XMLString;
    }
    
    if (self.body != nil) {
        return [[NSAttributedString alloc] initWithString:self.body attributes:@{ NSFontAttributeName : [NSFont codeFont] }];
    }
    
    return nil;
}

- (void)setAttributedBody:(NSAttributedString *)attributedBody
{
    self.body = attributedBody.string;
}

+ (NSSet *)keyPathsForValuesAffectingAttributedBody
{
    return [NSSet setWithObject:@"body"];
}

- (NSImage *)icon
{
    if ([self._element.name isEqualToString:@"iq"]) {
        return [NSImage imageNamed:@"Snippet-IQ"];
    }
    if ([self._element.name isEqualToString:@"message"]) {
        return [NSImage imageNamed:@"Snippet-Message"];
    }
    if ([self._element.name isEqualToString:@"presence"]) {
        return [NSImage imageNamed:@"Snippet-Presence"];
    }
    
    return [NSImage imageNamed:@"Snippet"];
}

- (NSXMLElement *)_element
{
    if (__element == nil && self.body != nil) {
        __element = [[NSXMLElement alloc] initWithXMLString:self.body error:NULL];
        if (__element == nil) {
            //we don't want to try and generate XML over and over again if it just ain't going to happen
            __element = [NSNull null];
        }
    }
    
    if (__element == [NSNull null]) {
        return nil;
    }
    
    return __element;
}

+ (NSSet *)keyPathsForValuesAffectingIcon
{
    return [NSSet setWithObject:@"body"];
}


#pragma mark - Initialization

+ (XCSnippet *)snippetWithTitle:(NSString *)title summary:(NSString *)summary body:(NSString *)body
{
    XCSnippet *snippet = [[[self class] alloc] init];
    
    snippet.title = title;
    snippet.summary = summary;
    snippet.body = body;
    
    snippet->_okToSave = YES;
    
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
        
        _okToSave = YES;
    }
    
    return self;
}


#pragma mark - Saving

- (void)_setNeedsSave
{
    if (!_needsSave) {
        _needsSave = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            if (_okToSave) {
                [self _save];
            }
        });
    }
}

- (void)_save
{
    if (self._fileURL) {
        _okToSave = YES;
        _needsSave = NO;
        
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        if (_title != nil) {
            dictionary[XCSnippetTitleKey] = _title;
        }
        if (_summary != nil) {
            dictionary[XCSnippetSummaryKey] = _summary;
        }
        if (_body != nil) {
            dictionary[XCSnippetBodyKey] = _body;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
            
            [data writeToURL:self._fileURL atomically:YES];
        });
    }
}

- (id)_initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        __fileURL = URL;
        _okToSave = NO;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:__fileURL];
            NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
            
            if ([dictionary isKindOfClass:[NSDictionary class]]) {
                self.title = dictionary[XCSnippetTitleKey];
                self.summary = dictionary[XCSnippetSummaryKey];
                self.body = dictionary[XCSnippetBodyKey];
            }
            
            [self _save];
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
