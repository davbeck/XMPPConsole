//
//  XCSnippetDetailViewController.h
//  XMPPConsole
//
//  Created by David Beck on 8/6/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XCSnippetDetailViewController : NSViewController

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *bodyView;
@property (weak) IBOutlet NSLayoutConstraint *infoHeight;

@property (nonatomic) BOOL editing;

@end
