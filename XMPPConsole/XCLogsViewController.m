//
//  XCLogsViewController.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCLogsViewController.h"

#import "XCLogsController.h"
#import "XCMutableLog.h"
#import "XCLogInfo.h"


@implementation XCLogsViewController
{
    XCMutableLog *_currentLog;
}
@synthesize logPopUp = _logPopUp;

#pragma mark - Properties

@synthesize currentLog = _currentLog;

- (void)setLogView:(NSTextView *)logView
{
    _logView = logView;
    
    [[_logView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[_logView textContainer] setWidthTracksTextView:NO];
    [_logView setHorizontallyResizable:YES];
}

- (void)setStream:(XMPPStream *)stream
{
    _stream = stream;
    
    [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        _logsController = [XCLogsController new];
        _currentLog = [XCMutableLog new];
        
        _canEditLog = NO;
    }
    
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)_scrollToBottom;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSScrollView *scrollView = self.logView.enclosingScrollView;
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


#pragma mark - XMPPStream

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    [self.logPopUp selectItemWithTag:2];
    [self changeLog:self.logPopUp];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	XCLogInfo *info = [self.logsController addLog:[self.currentLog copy]];
    [self.logPopUp selectItemAtIndex:[self.logPopUp indexOfItemWithRepresentedObject:info]];
    [self changeLog:self.logPopUp];
    
    [self willChangeValueForKey:@"currentLog"];
    _currentLog = [XCMutableLog new];
    [self didChangeValueForKey:@"currentLog"];
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

- (IBAction)changeLog:(NSPopUpButton *)sender
{
    XCLogInfo *info = sender.selectedItem.representedObject;
    NSLog(@"selected: %@", info);
    
    if (sender.selectedItem.representedObject == nil) {
        self.selectedLog = self.currentLog;
        [self _scrollToBottom];
    } else {
        self.selectedLog = info.log;
    }
}

@end
