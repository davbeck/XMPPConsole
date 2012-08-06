//
//  XCSnippetViewController.h
//  XMPPConsole
//
//  Created by David Beck on 8/5/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XCSnippetViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *defaultDestination;

- (IBAction)insertSelectedSnippet:(id)sender;
- (IBAction)addOrRemove:(NSSegmentedControl *)sender;

@end
