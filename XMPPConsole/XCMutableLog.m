//
//  XCMutableLog.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCMutableLog.h"

#import "XCLogNode.h"
#import "NSXMLElement+AttributedString.h"
#import "NSFont+CodeFont.h"


@implementation XCMutableLog
{
    NSMutableAttributedString *_text;
    NSMutableArray *_nodes;
}


#pragma mark - Properties

- (NSAttributedString *)text
{
    return [_text copy];
}

- (void)_addAttributedText:(NSAttributedString *)string fromServer:(BOOL)fromServer
{
    [self willChangeValueForKey:@"text"];
    
    
    //we only use this when we save
    [_nodes addObject:[XCLogNode nodeWithBody:string.string fromServer:fromServer]];
    
    
    NSMutableAttributedString *stanza = [string mutableCopy];
    
    if (fromServer) {
        [stanza addAttributes:@{ NSBackgroundColorAttributeName : [NSColor colorWithCalibratedWhite:0.9 alpha:1.0] } range:NSMakeRange(0, stanza.length)];
    }
    
    [_text appendAttributedString:stanza];
    
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
        _text = [NSMutableAttributedString new];
        _nodes = [NSMutableArray new];
    }
    return self;
}

@end
