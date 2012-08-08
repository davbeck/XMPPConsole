//
//  XCLog.m
//  XMPPConsole
//
//  Created by David Beck on 8/7/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCLog.h"
#import "XCMutableLog.h"
#import "XCLog_Private.h"

#import "XCLogNode.h"
#import "NSFont+CodeFont.h"
#import "NSXMLElement+AttributedString.h"


#define XCLogNodesKey @"Nodes"


@implementation XCLog

- (NSAttributedString *)_generateText
{
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    
    for (XCLogNode *node in self._nodes) {
        NSMutableAttributedString *attributedString;
        
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:node.body error:NULL];
        if (element != nil) {
            attributedString = [[element XMLAttributedString] mutableCopy];
        } else {
            attributedString = [[NSMutableAttributedString alloc] initWithString:node.body attributes:@{ NSFontAttributeName : [NSFont codeFont] }];
        }
        
        if (node.fromServer) {
            [attributedString addAttributes:@{ NSBackgroundColorAttributeName : [NSColor colorWithCalibratedWhite:0.9 alpha:1.0] } range:NSMakeRange(0, attributedString.length)];
        }
        
        [text appendAttributedString:attributedString];
    }
    
    return [text copy];
}

- (id)_initWithNodes:(NSArray *)nodes
{
    self = [super init];
    if (self != nil) {
        self._nodes = nodes;
        
        self.text = [self _generateText];
    }
    
    return self;
}

- (id)copy
{
    return self;
}

- (id)mutableCopy
{
    return [[XCMutableLog alloc] _initWithNodes:self._nodes];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self._nodes = [coder decodeObjectForKey:XCLogNodesKey];
        
        self.text = [self _generateText];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self._nodes forKey:XCLogNodesKey];
}

@end
