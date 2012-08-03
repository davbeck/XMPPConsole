//
//  XCConnectionDocument.h
//  XMPPConsole
//
//  Created by David Beck on 8/3/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMPPStream;

@interface XCConnectionDocument : NSDocument

@property (strong) XMPPStream *stream;

@property (unsafe_unretained) IBOutlet NSTextView *stanzasTextView;
@property (unsafe_unretained) IBOutlet NSTextView *stanzaEditor;

@property (copy) NSString *password;

- (IBAction)send:(id)sender;

@end
