//
//  XCSnippetController.h
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XCSnippet.h"


@interface XCSnippetController : NSObject

+ (XCSnippetController *)sharedController;

@property (strong, readonly) NSArray *snippets;
- (NSUInteger)countOfSnippets;
- (XCSnippet *)objectInSnippetsAtIndex:(NSUInteger)index;
- (void)getSnippets:(XCSnippet * __unsafe_unretained *)buffer range:(NSRange)inRange;
- (void)insertObject:(XCSnippet *)object inSnippetsAtIndex:(NSUInteger)index;
- (void)removeObjectFromSnippetsAtIndex:(NSUInteger)index;

@property (strong, readonly) NSArray *tags;
- (NSArray *)snippetsForTag:(NSString *)tag;
- (NSArray *)snippetsForElementName:(NSString *)elementName;
- (NSArray *)snippetsForElementNamesNotIn:(NSArray *)elementNames;

@end
