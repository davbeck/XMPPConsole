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
#import <objc/runtime.h>



@implementation XCConnectionDocument

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

- (id)init
{
    self = [super init];
    if (self) {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        _stream = [[XMPPStream alloc] init];
        
        self.stream.myJID = [XMPPJID jidWithString:@"dbeck.demo@gmail.com"];
        self.password = @"tRe4E3ru";
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"XCConnectionDocument";
}

- (void)awakeFromNib
{
    [[self.stanzasTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.stanzasTextView textContainer] setWidthTracksTextView:NO];
    [self.stanzasTextView setHorizontallyResizable:YES];
    
    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.stream addObserver:self forKeyPath:@"isConnected" options:0 context:NULL];
    
    [self connectOrDisconnect:nil];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (void)_addXMLString:(NSString *)string isServer:(BOOL)isServer
{
    string = [string stringByAppendingString:@"\n\n"];
    
    NSMutableDictionary *attributes = [@{
                                       NSFontAttributeName : [NSFont fontWithName:@"Menlo" size:14.0],
                                       } mutableCopy];
    if (isServer) {
        attributes[NSBackgroundColorAttributeName] = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
    }
    
    NSAttributedString *stanza = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [self.stanzasTextView.textStorage appendAttributedString:stanza];
}

- (void)_addXMLElement:(NSXMLElement *)element isServer:(BOOL)isServer
{
    NSString *string = [element XMLStringWithOptions:NSXMLNodePrettyPrint];
    
    [self _addXMLString:string isServer:isServer];
}


#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)stream
{
    [stream authenticateWithPassword:self.password error:NULL];
}

- (void)xmppStream:(XMPPStream *)sender didSendString:(NSString *)string
{
    [self _addXMLString:string isServer:NO];
}

- (void)xmppStream:(XMPPStream *)sender didSendElement:(NSXMLElement *)element
{
    [self _addXMLElement:element isServer:NO];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveElement:(NSXMLElement *)element
{
    [self _addXMLElement:element isServer:YES];
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
        NSLog(@"Error connecting: %@", error);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:NSLocalizedString(@"Error parsing XML Element:", nil)];
        [alert setInformativeText:error.localizedDescription];
        
        [alert beginSheetModalForWindow:[self.windowControllers[0] window]
                          modalDelegate:nil
                         didEndSelector:NULL
                            contextInfo:nil];
        NSBeep();
    }
}

- (IBAction)disconnect:(id)sender
{
    [self.stream disconnect];
}

- (IBAction)send:(id)sender
{
    NSError *error;
    NSXMLElement *stanza = [[NSXMLElement alloc] initWithXMLString:self.stanzaEditor.string error:&error];
    
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
        
        self.stanzaEditor.string = @"";
    }
}

@end
