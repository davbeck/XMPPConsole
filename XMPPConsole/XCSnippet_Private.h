//
//  XCSnippet_Private.h
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippet.h"

#import "NSFileManager+DirectoryLocations.h"


#define XCSnippetTitleKey @"Title"
#define XCSnippetSummaryKey @"Summary"
#define XCSnippetBodyKey @"Body"


NSURL *XCURLForSnippets();


@interface XCSnippet ()

@property (nonatomic, strong) NSURL *_fileURL;

- (void)_save;
- (id)_initWithURL:(NSURL *)URL;

@end
