//
//  XCLog_Private.h
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCLog.h"
#import "XCLog_Private.h"

@interface XCLog ()

@property (copy, readwrite, setter = _setText:) NSAttributedString *text;
@property (copy, setter = _setNodes:) NSArray *_nodes;

- (id)_initWithNodes:(NSArray *)nodes;

- (NSAttributedString *)_generateText;

@end
