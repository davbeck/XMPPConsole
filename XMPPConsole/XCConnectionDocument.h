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
@class XCLogsController;
@class XCLog;


#define XCConnectionSavePasswordPreferenceKey @"SavePassword"


#define XCConnectionInfoFileName @"ConnectionInfo"

#define XCConnectionJIDKey @"JID"
#define XCConnectionPasswordKey @"Password"
#define XCConnectionServerKey @"Server"
#define XCConnectionPortKey @"Port"


@interface XCConnectionDocument : NSDocument

@property (strong) XMPPStream *stream;

@property (unsafe_unretained) IBOutlet NSTextView *stanzasTextView;
@property (unsafe_unretained) IBOutlet NSTextView *XMLEditor;
@property (unsafe_unretained) IBOutlet XCSnippetLibraryViewController *snippetLibraryViewController;
@property (weak) IBOutlet NSButton *connectButton;

@property (readonly) BOOL connecting;
@property (copy) NSString *password;

@property (strong) IBOutlet XCLogsController *logsController;
@property (readonly) XCLog *currentLog;
@property (strong) XCLog *selectedLog;
@property BOOL canEditLog;

- (IBAction)connectOrDisconnect:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)clear:(id)sender;

@end
