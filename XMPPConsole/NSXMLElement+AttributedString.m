//
//  NSXMLElement+AttributedString.m
//  XMPPConsole
//
//  Created by David Beck on 8/3/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "NSXMLElement+AttributedString.h"


#define NSXMLElementMaxSingleLineLenght 30


@implementation NSXMLElement (AttributedString)

- (NSColor *)_tagColor
{
    return [NSColor colorWithCalibratedRed:0.725 green:0.200 blue:0.631 alpha:1.000];
}

- (NSColor *)_attributeNameColor
{
    return [NSColor colorWithCalibratedRed:0.584 green:0.490 blue:0.227 alpha:1.000];
}

- (NSColor *)_attributeValueColor
{
    return [NSColor colorWithCalibratedRed:0.812 green:0.192 blue:0.145 alpha:1.000];
}

- (NSColor *)_textColor
{
    return [NSColor blackColor];
}

- (NSColor *)_commentColor
{
    return [NSColor colorWithCalibratedRed:0.000 green:0.510 blue:0.071 alpha:1.000];
}

- (NSAttributedString *)_closingTagAttributedString
{
    NSString *string = [NSString stringWithFormat:@"</%@>", self.name];
    
    return [[NSAttributedString alloc] initWithString:string attributes:@{ NSForegroundColorAttributeName : [self _tagColor] }];
}

- (NSAttributedString *)_attributeAttributedString:(NSXMLNode *)attribute
{
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    
    NSString *name = attribute.name;
    if (name.length <= 0 && attribute.kind == NSXMLNamespaceKind) {
        name = @"xmlns";
    }
    
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:name attributes:@{ NSForegroundColorAttributeName : [self _attributeNameColor] }]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"=" attributes:@{ NSForegroundColorAttributeName : [self _tagColor] }]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\"%@\"", attribute.stringValue] attributes:@{ NSForegroundColorAttributeName : [self _attributeValueColor] }]];
    
    return string;
}

- (NSAttributedString *)XMLAttributedString
{
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"<" attributes:@{ NSForegroundColorAttributeName : [self _tagColor] }]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.name attributes:@{ NSForegroundColorAttributeName : [self _tagColor] }]];
    
    for (NSXMLNode *namespace in self.namespaces) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [string appendAttributedString:[self _attributeAttributedString:namespace]];
    }
    
    for (NSXMLNode *attribute in self.attributes) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [string appendAttributedString:[self _attributeAttributedString:attribute]];
    }
    
    if (self.childCount <= 0) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"/>" attributes:@{ NSForegroundColorAttributeName : [self _tagColor] }]];
    } else if (self.childCount == 1 && [[self.children lastObject] kind] == NSXMLTextKind && [[self.children lastObject] XMLString].length < NSXMLElementMaxSingleLineLenght) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@">" attributes:@{ NSForegroundColorAttributeName : [self _tagColor] }]];
        
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[[self.children lastObject] XMLString] attributes:@{ NSForegroundColorAttributeName : [self _textColor] }]];
        
        [string appendAttributedString:[self _closingTagAttributedString]];
    } else {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:@">\n" attributes:@{ NSForegroundColorAttributeName : [self _tagColor] }]];
        
        for (NSXMLNode *child in self.children) {
            if ([child isKindOfClass:[NSXMLElement class]]) {
                NSMutableAttributedString *childString = (NSMutableAttributedString *)[(NSXMLElement *)child XMLAttributedString];
                
                [childString insertAttributedString:[[NSAttributedString alloc] initWithString:@"\t"] atIndex:0];
                
                NSRange nextNewLine = [childString.string rangeOfString:@"\n"];
                
                while (nextNewLine.location != NSNotFound) {
                    if (nextNewLine.location + nextNewLine.length != childString.length) {
                        [childString insertAttributedString:[[NSAttributedString alloc] initWithString:@"\t"] atIndex:nextNewLine.location + nextNewLine.length];
                    }
                    
                    NSRange remainingRange = NSMakeRange(nextNewLine.location + nextNewLine.length, childString.string.length - nextNewLine.location - nextNewLine.length);
                    nextNewLine = [childString.string rangeOfString:@"\n" options:0 range:remainingRange];
                }
                
                [string appendAttributedString:childString];
            } else if ([child kind] == NSXMLTextKind) {
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t"]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:child.XMLString attributes:@{ NSForegroundColorAttributeName : [self _textColor] }]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            } else if ([child kind] == NSXMLCommentKind) {
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t"]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:child.XMLString attributes:@{ NSForegroundColorAttributeName : [self _commentColor] }]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            } else {
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t"]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:child.XMLString]];
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }
        }
        
        [string appendAttributedString:[self _closingTagAttributedString]];
    }
    
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    
    
    NSLog(@"   xml: %@", self);
    NSLog(@"string: %@", string.string);
    
    return string;
}

@end
