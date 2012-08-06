//
//  XCConnectionDocument.h
//  XMPPConsole
//
//  Created by David Beck on 8/3/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMPPStream;
@class XCSnippetLibraryViewController;

@interface XCConnectionDocument : NSDocument

@property (strong) XMPPStream *stream;

@property (unsafe_unretained) IBOutlet NSTextView *stanzasTextView;
@property (unsafe_unretained) IBOutlet NSTextView *XMLEditor;
@property (unsafe_unretained) IBOutlet XCSnippetLibraryViewController *snippetLibraryViewController;
@property (weak) IBOutlet NSButton *connectButton;

@property (copy) NSString *password;

- (IBAction)connectOrDisconnect:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)clear:(id)sender;

@end
