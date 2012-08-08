//
//  XCMutableLog.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCMutableLog.h"
#import "XCLog_Private.h"

#import "XCLogNode.h"
#import "NSXMLElement+AttributedString.h"
#import "NSFont+CodeFont.h"


@implementation XCMutableLog
{
    NSMutableAttributedString *_mutableText;
    NSMutableArray *__mutableNodes;
}


#pragma mark - Properties

- (NSAttributedString *)text
{
    return [_mutableText copy];
}

- (void)_setText:(NSAttributedString *)text
{
    _mutableText = [text mutableCopy];
}

- (NSArray *)_nodes
{
    return __mutableNodes;
}

- (void)_setNodes:(NSArray *)_nodes
{
    __mutableNodes = [_nodes mutableCopy];
}

- (void)_addAttributedText:(NSAttributedString *)string fromServer:(BOOL)fromServer
{
    [self willChangeValueForKey:@"text"];
    
    
    //we only use this when we save
    [__mutableNodes addObject:[XCLogNode nodeWithBody:string.string fromServer:fromServer]];
    
    
    NSMutableAttributedString *stanza = [string mutableCopy];
    
    if (fromServer) {
        [stanza addAttributes:@{ NSBackgroundColorAttributeName : [NSColor colorWithCalibratedWhite:0.9 alpha:1.0] } range:NSMakeRange(0, stanza.length)];
    }
    
    [_mutableText appendAttributedString:stanza];
    
    [self didChangeValueForKey:@"text"];
}

- (void)addText:(NSString *)string fromServer:(BOOL)fromServer
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:@{ NSFontAttributeName : [NSFont codeFont] }];
    
    [self _addAttributedText:attributedString fromServer:fromServer];
}

- (void)addXML:(NSXMLElement *)element fromServer:(BOOL)fromServer
{
    NSAttributedString *string = [element XMLAttributedString];
    
    [self _addAttributedText:string fromServer:fromServer];
}


#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        _mutableText = [NSMutableAttributedString new];
        __mutableNodes = [NSMutableArray new];
    }
    return self;
}

- (id)copy
{
    return [[XCLog alloc] _initWithNodes:self._nodes];
}

- (id)mutableCopy
{
    return [[[self class] alloc] _initWithNodes:self._nodes];
}

@end
