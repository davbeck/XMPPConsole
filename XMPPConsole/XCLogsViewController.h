//
//  XCLogsViewController.h
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

@class XMPPStream;
@class XCLogsController;
@class XCLog;


@interface XCLogsViewController : NSObject <XMPPStreamDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *logView;
@property (weak) IBOutlet NSPopUpButton *logPopUp;

@property (nonatomic, strong) XMPPStream *stream;
@property (strong) XCLogsController *logsController;
@property (readonly) XCLog *currentLog;
@property (strong) XCLog *selectedLog;
@property BOOL canEditLog;

- (IBAction)changeLog:(NSPopUpButton *)sender;

@end
