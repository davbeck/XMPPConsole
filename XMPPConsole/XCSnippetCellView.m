//
//  XCSnippetCellView.m
//  XMPPConsole
//
//  Created by David Beck on 8/5/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetCellView.h"

#import "XCSnippet.h"


@implementation XCSnippetCellView

- (NSImage *)icon
{
    XCSnippet *snippet = self.objectValue;
    
    if (snippet.body != nil) {
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:snippet.body error:NULL];
        
        if ([element.name isEqualToString:@"iq"]) {
            return [NSImage imageNamed:@"Snippet-IQ"];
        }
        if ([element.name isEqualToString:@"message"]) {
            return [NSImage imageNamed:@"Snippet-Message"];
        }
        if ([element.name isEqualToString:@"presence"]) {
            return [NSImage imageNamed:@"Snippet-Presence"];
        }
    }
    
    return [NSImage imageNamed:@"Snippet"];
}

+ (NSSet *)keyPathsForValuesAffectingIcon
{
    return [NSSet setWithObject:@"objectValue.body"];
}

@end
