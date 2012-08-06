//
//  XCSnippetViewController.h
//  XMPPConsole
//
//  Created by David Beck on 8/5/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XCSnippetLibraryViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *defaultDestination;
@property (weak) IBOutlet NSPopover *infoPopover;

- (IBAction)insertSelectedSnippet:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)addOrRemove:(NSSegmentedControl *)sender;
- (IBAction)tableViewClicked:(id)sender;

@end
