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
    
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.title attributes:@{ NSFontAttributeName : [NSFont boldSystemFontOfSize:11.0] }]];
    
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" - %@", self.summary] attributes:@{ NSFontAttributeName : [NSFont systemFontOfSize:11.0] }]];
    
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

@end
