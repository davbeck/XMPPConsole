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
#import "XCSnippet.h"
#import "XCSnippetRowView.h"



@implementation XCConnectionDocument {
    BOOL _needsToScroll;
}

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

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [[self.stanzasTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.stanzasTextView textContainer] setWidthTracksTextView:NO];
    [self.stanzasTextView setHorizontallyResizable:YES];
    
    [self.XMLEditor setFont:[NSFont fontWithName:@"Menlo" size:14.0]];
    
    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.stream addObserver:self forKeyPath:@"isConnected" options:0 context:NULL];
    
    [self connect:nil];
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

- (void)_addXMLString:(NSAttributedString *)string isServer:(BOOL)isServer
{
    BOOL shouldLock = [self _shouldLockStanzasTextViewToBottom];
    
    NSMutableAttributedString *stanza = [string mutableCopy];
    
    NSMutableDictionary *attributes = [@{
                                       NSFontAttributeName : [NSFont fontWithName:@"Menlo" size:14.0],
                                       } mutableCopy];
    if (isServer) {
        attributes[NSBackgroundColorAttributeName] = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
    }
    [stanza addAttributes:attributes range:NSMakeRange(0, stanza.length)];
    
    [self.stanzasTextView.textStorage appendAttributedString:stanza];
    
    if (shouldLock || _needsToScroll) {
        [self _setNeedsToScroll];
    }
}

- (void)_addXMLElement:(NSXMLElement *)element isServer:(BOOL)isServer
{
    NSAttributedString *string = [element XMLAttributedString];
    
    [self _addXMLString:string isServer:isServer];
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
}


#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)stream
{
    [stream authenticateWithPassword:self.password error:NULL];
}

- (void)xmppStream:(XMPPStream *)sender didSendString:(NSString *)string
{
    [self _addXMLString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", string]] isServer:NO];
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

- (IBAction)insertSelectedSnippet:(id)sender;
{
    XCSnippet *snippet = [[[self.snippetTableView rowViewAtRow:self.snippetTableView.selectedRow makeIfNecessary:YES] viewAtColumn:0] objectValue];
    
    [self.XMLEditor insertText:snippet.body];
}

- (IBAction)clear:(id)sender
{
    self.XMLEditor.string = @"";
}


#pragma mark - NSTableViewDelegate

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[XCSnippetRowView alloc] init];
}

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    XCSnippet *snippet = [[[self.snippetTableView rowViewAtRow:row makeIfNecessary:YES] viewAtColumn:0] objectValue];
    
    return snippet;
}

@end
