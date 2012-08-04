//
//  XCSnippetController.m
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetController.h"


@implementation XCSnippetController
{
    NSMutableArray *_snippets;
}

- (NSArray *)snippets
{
    return [_snippets copy];
}

- (id)init
{
    self = [super init];
    if (self) {
        _snippets = [[NSMutableArray alloc] init];
        
        [_snippets addObjectsFromArray:@[
         [XCSnippet snippetWithTitle:@"Presence" summary:@"The most basic presence update." body:@"<presence></presence>"],
         [XCSnippet snippetWithTitle:@"Status update" summary:@"A presence update with a status." body:@"<presence>\n\t<status>Debugging with XMPP</status>\n</presence>"],
         ]];
    }
    
    return self;
}

@end
