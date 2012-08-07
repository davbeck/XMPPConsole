//
//  XCConnectionDocument.m
//  XMPPConsole
//
//  Created by David Beck on 8/3/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCConnectionDocument.h"

#import "XMPP.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "NSXMLElement+AttributedString.h"
#import "NSFont+CodeFont.h"
#import "XCSnippetLibraryViewController.h"
#import "XCDefaultAccount.h"
#import "XCLogsController.h"
#import "XCMutableLog.h"




@interface XCConnectionDocument ()

@property (strong) NSFileWrapper *_fileWrapper;

@end



@implementation XCConnectionDocument {
    BOOL _needsToScroll;
    XCMutableLog *_currentLog;
}

@synthesize currentLog = _currentLog;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isConnected"] && object == self.stream) {
        if (self.stream.isConnected) {
            self.connectButton.title = NSLocalizedString(@"Disconnect", nil);
        } else {
            self.connectButton.title = NSLocalizedString(@"Connect", nil);
        }
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)dealloc
{
    [self.stream removeObserver:self forKeyPath:@"isConnected"];
}

+ (void)initialize
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
     XCConnectionSavePasswordPreferenceKey : @YES,
     }];
}

- (id)init
{
    self = [super init];
    if (self) {
#ifdef DEBUG
//        [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
        
        _currentLog = [XCMutableLog new];
        
        _stream = [XMPPStream new];
        
        _canEditLog = NO;
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"XCConnectionDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [[self.stanzasTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.stanzasTextView textContainer] setWidthTracksTextView:NO];
    [self.stanzasTextView setHorizontallyResizable:YES];
    
    [self.XMLEditor setFont:[NSFont codeFont]];
    self.snippetLibraryViewController.defaultDestination = self.XMLEditor;
    
    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.stream addObserver:self forKeyPath:@"isConnected" options:0 context:NULL];
    
	
#ifdef DEBUG
    if (self._fileWrapper == nil) {
        self.stream.myJID = [XMPPJID jidWithString:XCDefaultJID];
        self.password = XCDefaultPassword;
        self.stream.hostName = XCDefaultServer;
        self.stream.hostPort = XCDefaultPort;
        [self connect:nil];
    }
#endif
}


#pragma mark - Saving

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
    self._fileWrapper = fileWrapper;
    
    NSFileWrapper *connectionInfoWrapper = fileWrapper.fileWrappers[XCConnectionInfoFileName];
    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:connectionInfoWrapper.regularFileContents options:0 format:NULL error:NULL];
    if (connectionInfoWrapper != nil) {
        self.stream.myJID = [XMPPJID jidWithString:dictionary[XCConnectionJIDKey]];
        self.password = dictionary[XCConnectionPasswordKey];
        self.stream.hostName = dictionary[XCConnectionServerKey];
        self.stream.hostPort = [dictionary[XCConnectionPortKey] shortValue];
    }
    
    
    
    return YES;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
    if (self._fileWrapper == nil) {
        self._fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
    }
    
    
    
    NSMutableDictionary *connectionInfo = [NSMutableDictionary new];
    if (self.stream.myJID != nil) {
        connectionInfo[XCConnectionJIDKey] = self.stream.myJID.full;
    }
    if (self.password != nil && [[NSUserDefaults standardUserDefaults] boolForKey:XCConnectionSavePasswordPreferenceKey]) {
        connectionInfo[XCConnectionPasswordKey] = self.password;
    }
    if (self.stream.hostName != nil) {
        connectionInfo[XCConnectionServerKey] = self.stream.hostName;
    }
    connectionInfo[XCConnectionPortKey] = @(self.stream.hostPort);
    
    NSData *connectionData = [NSPropertyListSerialization dataWithPropertyList:connectionInfo format:NSPropertyListBinaryFormat_v1_0 options:0 error:outError];
    if (connectionData == nil) {
        return nil;
    }
    
    NSFileWrapper *connectionWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:connectionData];
    [connectionWrapper setPreferredFilename:XCConnectionInfoFileName];
    [self._fileWrapper addFileWrapper:connectionWrapper];
    
    
    
    return self._fileWrapper;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (BOOL)_shouldLockStanzasTextViewToBottom
{
    NSScrollView *scrollView = self.stanzasTextView.enclosingScrollView;
    
    return NSMaxY(scrollView.contentView.bounds) >= NSMaxY([scrollView.documentView frame]);
}

- (void)_setNeedsToScroll
{
    // When you update the text in a NSTextView it doesn't update it's size until the next run loop, so we need to wait to sroll until after that
    // By using dispatch_async on the main queue it will run after everything that is queued on the run loop thus far
    // However, if you then update the text again before we get a chance to scroll, we will scroll and then the size will change again
    // So until we get our chance to scroll, we keep adding on to the end of the run loop
    
    _needsToScroll = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _scrollToBottom];
    });
}

- (void)_scrollToBottom;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _needsToScroll = NO;
        
        NSScrollView *scrollView = self.stanzasTextView.enclosingScrollView;
        NSPoint newScrollOrigin;
        
        // assume that the scrollview is an existing variable
        if ([[scrollView documentView] isFlipped]) {
            newScrollOrigin = NSMakePoint(scrollView.contentView.bounds.origin.x, NSMaxY([scrollView.documentView frame]) - NSHeight(scrollView.contentView.bounds));
        } else {
            newScrollOrigin = NSMakePoint(scrollView.contentView.bounds.origin.x, 0.0);
        }
        
        [[scrollView documentView] scrollPoint:newScrollOrigin];
    });
}

- (void)_showAlertWithTitle:(NSString *)title error:(NSError *)error
{
	if (error != nil) {
		NSLog(@"_showAlertWithTitle: %@ error: %@", title, error);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:title];
        [alert setInformativeText:error.localizedDescription];
        
        [alert beginSheetModalForWindow:[self.windowControllers[0] window]
                          modalDelegate:nil
                         didEndSelector:NULL
                            contextInfo:nil];
        NSBeep();
	}
}


#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)stream
{
	NSError *error = nil;
    if (![stream authenticateWithPassword:self.password error:&error]) {
		[self _showAlertWithTitle:NSLocalizedString(@"Error authenticating:", nil) error:error];
	}
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
	NSLog(@"didNotRegister: %@", error);
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	NSLog(@"didNotAuthenticate: %@", error);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
	NSLog(@"didReceiveError: %@", error);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	if (error != nil) {
		[self _showAlertWithTitle:NSLocalizedString(@"Stream disconnected with error:", nil) error:error];
	}
}

- (void)xmppStream:(XMPPStream *)sender didSendString:(NSString *)string
{
    [_currentLog addText:string fromServer:NO];
    
    [self _scrollToBottom];
}

- (void)xmppStream:(XMPPStream *)sender didSendElement:(NSXMLElement *)element
{
    [_currentLog addXML:element fromServer:NO];
    
    [self _scrollToBottom];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveElement:(NSXMLElement *)element
{
    [_currentLog addXML:element fromServer:YES];
    
    [self _scrollToBottom];
}


#pragma mark - Actions

- (IBAction)connectOrDisconnect:(id)sender
{
    if (self.stream.isConnected) {
        [self disconnect:nil];
    } else {
        [self connect:nil];
    }
}

- (IBAction)connect:(id)sender
{
    NSError *error = nil;
    if (![self.stream connect:&error]) {
		[self _showAlertWithTitle:NSLocalizedString(@"Error connecting:", nil) error:error];
    }
}

- (IBAction)disconnect:(id)sender
{
    [self.stream disconnect];
}

- (IBAction)send:(id)sender
{
    NSError *error;
    NSXMLElement *stanza = [[NSXMLElement alloc] initWithXMLString:self.XMLEditor.string error:&error];
    
    if (stanza == nil) {
        NSLog(@"Error parsing XML Element: %@", error);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:NSLocalizedString(@"Error parsing XML Element:", nil)];
        [alert setInformativeText:error.localizedDescription];
        
        [alert beginSheetModalForWindow:[self.windowControllers[0] window]
                          modalDelegate:nil
                         didEndSelector:NULL
                            contextInfo:nil];
        NSBeep();
    } else {
        [self.stream sendElement:stanza];
        
        [self clear:self];
    }
}

- (IBAction)clear:(id)sender
{
    self.XMLEditor.string = @"";
}

@end
