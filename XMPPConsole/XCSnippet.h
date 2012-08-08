//
//  XCSnippet.h
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Foundation/Foundation.h>


#define XCSnippetUTI @"co.DavidBeck.XCSnippet"


@interface XCSnippet : NSObject <NSPasteboardWriting, NSPasteboardReading, NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSArray *tags;

@property (nonatomic, readonly) NSAttributedString *attributedSummary;
@property (nonatomic, copy) NSAttributedString *attributedBody;

@property (nonatomic, readonly) NSImage *icon;

+ (XCSnippet *)snippetWithTitle:(NSString *)title summary:(NSString *)summary body:(NSString *)body;

@end
