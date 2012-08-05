//
//  XCSnippet.m
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippet.h"

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


#pragma mark - NSPasteboardWriting

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return [self.body writableTypesForPasteboard:pasteboard];
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    return [self.body pasteboardPropertyListForType:type];
}


#pragma mark - NSPasteboardReading

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return [NSString readableTypesForPasteboard:pasteboard];
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type
{
    self = [super init];
    if (self != nil) {
        self.body = [[NSString alloc] initWithPasteboardPropertyList:propertyList ofType:type];
    }
    
    return self;
}

@end