//
//  XCSnippet.h
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCSnippet : NSObject <NSPasteboardWriting>

@property (copy) NSString *title;
@property (copy) NSString *summary;
@property (copy) NSString *body;

@property (readonly) NSAttributedString *attributedSummary;

+ (XCSnippet *)snippetWithTitle:(NSString *)title summary:(NSString *)summary body:(NSString *)body;

@end
