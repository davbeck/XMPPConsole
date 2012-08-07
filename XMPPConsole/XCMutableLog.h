//
//  XCMutableLog.h
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCLog.h"

@interface XCMutableLog : XCLog

- (void)addText:(NSString *)string fromServer:(BOOL)fromServer;
- (void)addXML:(NSXMLElement *)element fromServer:(BOOL)fromServer;

@end
