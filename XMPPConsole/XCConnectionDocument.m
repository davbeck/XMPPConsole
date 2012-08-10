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
#import "NSFont+CodeFont.h"
#import "XCSnippetLibraryViewController.h"
#import "XCDefaultAccount.h"
#import "XCLogsViewController.h"
#import "XCLogsController.h"


#define XCConnectionInfoFileName @"ConnectionInfo"
#define XCLogsFolderName @"Logs"

#define XCConnectionJIDKey @"JID"
#define XCConnectionPasswordKey @"Password"
#define XCConnectionServerKey @"Server"
#define XCConnectionPortKey @"Port"

const UInt8 XCDocumentChangedContext;



@interface XCConnectionDocument ()

@property (strong) NSFileWrapper *_fileWrapper;

@end



@implementation XCConnectionDocument

- (void)setLogsViewController:(XCLogsViewController *)logsViewController
{
    _logsViewController = logsViewController;
    
    _logsViewController.stream = self.stream;
    
    if (self._fileWrapper.fileWrappers[XCLogsFolderName] != nil) {
        _logsViewController.logsController.fileWrapper = self._fileWrapper.fileWrappers[XCLogsFolderName];
    }
}

- (BOOL)connecting
{
    return !self.stream.connected && !self.stream.disconnected;
}

+ (NSSet *)keyPathsForValuesAffectingConnecting
{
    return [NSSet setWithArray:@[ @"stream.connected", @"stream.disconnected" ]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &XCDocumentChangedContext) {
        [self updateChangeCount:NSChangeDone];
    } else if ([keyPath isEqualToString:@"connected"] && object == self.stream) {
        if (self.stream.isConnected) {
            self.connectButton.title = NSLocalizedString(@"Disconnect", nil);
            self.connectButton.keyEquivalent = @"";
        } else {
            self.connectButton.title = NSLocalizedString(@"Connect", nil);
            self.connectButton.keyEquivalent = @"\r";
        }
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)dealloc
{
    [self.stream removeObserver:self forKeyPath:@"connected"];
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
        
        _stream = [XMPPStream new];
        
        [self setHasUndoManager:NO];
        
        [self addObserver:self forKeyPath:@"password" options:0 context:(void *)&XCDocumentChangedContext];
        [self addObserver:self forKeyPath:@"stream.myJID" options:0 context:(void *)&XCDocumentChangedContext];
        [self addObserver:self forKeyPath:@"stream.hostName" options:0 context:(void *)&XCDocumentChangedContext];
        [self addObserver:self forKeyPath:@"stream.hostPort" options:0 context:(void *)&XCDocumentChangedContext];
        [self addObserver:self forKeyPath:@"logsViewController.logsController.logInfo" options:0 context:(void *)&XCDocumentChangedContext];
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
    
    [self.XMLEditor setFont:[NSFont codeFont]];
    self.snippetLibraryViewController.defaultDestination = self.XMLEditor;
    
    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.stream addObserver:self forKeyPath:@"connected" options:0 context:NULL];
    
	
#ifdef DEBUG
    if (self._fileWrapper == nil) {
        self.stream.myJID = [XMPPJID jidWithString:XCDefaultJID];
        self.password = XCDefaultPassword;
        self.stream.hostName = XCDefaultServer;
        self.stream.hostPort = XCDefaultPort;
        [self connect:nil];
    }
#endif
    
    [self updateChangeCount:NSChangeCleared];
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
    
    
    if (self._fileWrapper.fileWrappers[XCLogsFolderName] != nil) {
        _logsViewController.logsController.fileWrapper = self._fileWrapper.fileWrappers[XCLogsFolderName];
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
    
    [self unblockUserInteraction];
    
    NSData *connectionData = [NSPropertyListSerialization dataWithPropertyList:connectionInfo format:NSPropertyListBinaryFormat_v1_0 options:0 error:outError];
    if (connectionData == nil) {
        return nil;
    }
    
    NSFileWrapper *connectionWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:connectionData];
    [connectionWrapper setPreferredFilename:XCConnectionInfoFileName];
    [self._fileWrapper addFileWrapper:connectionWrapper];
    
    
    
    [_logsViewController.logsController save];
    if (_logsViewController.logsController.fileWrapper != self._fileWrapper.fileWrappers[XCLogsFolderName]) {
        [self._fileWrapper removeFileWrapper:self._fileWrapper.fileWrappers[XCLogsFolderName]];
        _logsViewController.logsController.fileWrapper.preferredFilename = XCLogsFolderName;
        [self._fileWrapper addFileWrapper:_logsViewController.logsController.fileWrapper];
    }
    
    
    return self._fileWrapper;
}

- (BOOL)canAsynchronouslyWriteToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation
{
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

+ (BOOL)preservesVersions
{
    return NO;
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
