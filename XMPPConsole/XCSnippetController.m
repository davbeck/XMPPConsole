//
//  XCSnippetController.m
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetController.h"


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
    return [_snippets objectAtIndex:index];
}

- (void)getSnippets:(XCSnippet * __unsafe_unretained *)buffer range:(NSRange)inRange
{
    [_snippets getObjects:buffer range:inRange];
}

- (void)insertObject:(XCSnippet *)object inSnippetsAtIndex:(NSUInteger)index
{
    [_snippets insertObject:object atIndex:index];
}

- (void)removeObjectFromSnippetsAtIndex:(NSUInteger)index
{
    [_snippets removeObjectAtIndex:index];
}

- (void)replaceObjectInSnippetsAtIndex:(NSUInteger)index withObject:(id)object
{
    [_snippets replaceObjectAtIndex:index withObject:object];
}


#pragma mark - Initialization

+ (void)initialize
{
    static dispatch_once_t done;
	dispatch_once(&done, ^{
		sharedInstance = [[super alloc] init];
        
        sharedInstance->_snippets = [[NSMutableArray alloc] init];
        
        [sharedInstance->_snippets addObjectsFromArray:@[
         [XCSnippet snippetWithTitle:@"Presence" summary:@"The most basic presence update." body:@"<presence></presence>"],
         [XCSnippet snippetWithTitle:@"Status update" summary:@"A presence update with a status." body:@"<presence>\n\t<status>Debugging with XMPP</status>\n</presence>"],
         
         [XCSnippet snippetWithTitle:@"Presence" summary:@"The most basic presence update." body:@"<presence></presence>"],
         [XCSnippet snippetWithTitle:@"Status update" summary:@"A presence update with a status." body:@"<presence>\n\t<status>Debugging with XMPP</status>\n</presence>"],
         [XCSnippet snippetWithTitle:@"Presence" summary:@"The most basic presence update." body:@"<presence></presence>"],
         [XCSnippet snippetWithTitle:@"Status update" summary:@"A presence update with a status." body:@"<presence>\n\t<status>Debugging with XMPP</status>\n</presence>"],
         [XCSnippet snippetWithTitle:@"Presence" summary:@"The most basic presence update." body:@"<presence></presence>"],
         [XCSnippet snippetWithTitle:@"Status update" summary:@"A presence update with a status." body:@"<presence>\n\t<status>Debugging with XMPP</status>\n</presence>"],
         ]];
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

@end
