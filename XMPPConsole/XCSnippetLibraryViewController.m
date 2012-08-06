//
//  XCSnippetViewController.m
//  XMPPConsole
//
//  Created by David Beck on 8/5/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetLibraryViewController.h"

#import "XCSnippetController.h"
#import "XCSnippet.h"
#import "XCSnippetRowView.h"


#define XCSnippetViewMaximumMovement 3.0


@interface XCSnippetLibraryViewController ()

@end

@implementation XCSnippetLibraryViewController
{
    BOOL _animateChanges;
    BOOL _popoverMoved;
}
@synthesize infoPopover = _infoPopover;

- (void)setTableView:(NSTableView *)tableView
{
    _tableView = tableView;
    
    [_tableView registerForDraggedTypes:[XCSnippet readableTypesForPasteboard:nil]];
    [_tableView setDraggingSourceOperationMask:NSDragOperationCopy | NSDragOperationGeneric | NSDragOperationMove forLocal:NO];
    
    [_tableView setDoubleAction:@selector(showInfo:)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"snippets"] && object == [XCSnippetController sharedController]) {
        if (_animateChanges) {
            switch ([change[NSKeyValueChangeKindKey] unsignedIntegerValue]) {
                case NSKeyValueChangeInsertion:;
                    [self.tableView insertRowsAtIndexes:change[NSKeyValueChangeIndexesKey] withAnimation:NSTableViewAnimationEffectGap];
                    break;
                    
                case NSKeyValueChangeRemoval:;
                    [self.tableView removeRowsAtIndexes:change[NSKeyValueChangeIndexesKey] withAnimation:NSTableViewAnimationEffectGap];
                    break;
                    
                default:
                    [self.tableView reloadData];
                    break;
            }
        }
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (nibNameOrNil == nil) {
        nibNameOrNil = @"XCSnippetLibraryViewController";
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _animateChanges = YES;
        [[XCSnippetController sharedController] addObserver:self forKeyPath:@"snippets" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _animateChanges = YES;
        [[XCSnippetController sharedController] addObserver:self forKeyPath:@"snippets" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _animateChanges = YES;
        [[XCSnippetController sharedController] addObserver:self forKeyPath:@"snippets" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}


#pragma mark - Actions

- (IBAction)insertSelectedSnippet:(id)sender;
{
    XCSnippet *snippet = [[[self.tableView rowViewAtRow:self.tableView.selectedRow makeIfNecessary:YES] viewAtColumn:0] objectValue];
    
    if ([self.defaultDestination respondsToSelector:@selector(insertText:)] && snippet.body != nil) {
        [self.defaultDestination insertText:snippet.body];
    }
}

- (IBAction)showInfo:(id)sender
{
    NSInteger selectedRow = [self.tableView selectedRow];
    
    if (selectedRow != -1) {
        [self.tableView scrollRowToVisible:selectedRow];
        NSView *rowView = [self.tableView rowViewAtRow:selectedRow makeIfNecessary:YES];
        
        self.infoPopover.contentViewController.representedObject = [[XCSnippetController sharedController].snippets objectAtIndex:selectedRow];
        [self.infoPopover showRelativeToRect:rowView.bounds ofView:rowView preferredEdge:NSMaxXEdge];
    }
}

- (IBAction)addOrRemove:(NSSegmentedControl *)sender
{
    if (sender.selectedSegment == 0) {//add
        
    } else if (sender.selectedSegment == 1) {//remove
        [self.tableView beginUpdates];
        NSIndexSet *indexes = [self.tableView selectedRowIndexes];
        [[[XCSnippetController sharedController] mutableArrayValueForKey:@"snippets"] removeObjectsAtIndexes:indexes];
        [self.tableView endUpdates];
    }
}

- (IBAction)tableViewClicked:(id)sender
{
    NSPoint startLocation = [NSEvent mouseLocation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        NSPoint currentLocation = [NSEvent mouseLocation];
        
        if (!fabs(startLocation.x - currentLocation.x) < XCSnippetViewMaximumMovement && fabs(startLocation.y - currentLocation.y) < XCSnippetViewMaximumMovement) {
            [self showInfo:self];
        }
    });
}


#pragma mark - NSPopoverDelegate

- (BOOL)popoverShouldClose:(NSPopover *)popover
{
    if (_popoverMoved) {
        _popoverMoved = NO;
        return NO;
    }
    return YES;
}


#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[XCSnippetController sharedController] countOfSnippets];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[XCSnippetController sharedController] objectInSnippetsAtIndex:row];
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[XCSnippetRowView alloc] init];
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
    if (self.infoPopover.shown) {
        [self showInfo:self];
        _popoverMoved = YES;
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (self.tableView.selectedRow == -1) {
        [self.infoPopover close];
    }
}


#pragma mark - Dragging

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    XCSnippet *snippet = [[[tableView rowViewAtRow:row makeIfNecessary:YES] viewAtColumn:0] objectValue];
    
    return snippet;
}

- (void)tableView:(NSTableView *)tableView updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo
{
    NSTableCellView *snippetCell = [tableView makeViewWithIdentifier:@"Snippet" owner:self];
    NSRect cellFrame = NSMakeRect(0.0, 0.0, [[tableView tableColumns][0] width], tableView.rowHeight);
    
    [draggingInfo enumerateDraggingItemsWithOptions:0 forView:tableView classes:@[ [XCSnippet class] ] searchOptions:nil usingBlock:
     ^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
         XCSnippet *snippet = draggingItem.item;
         
         if (snippet.title != nil || snippet.summary != nil) {
             draggingItem.draggingFrame = cellFrame;
             draggingItem.imageComponentsProvider = ^(void) {
                 snippetCell.objectValue = draggingItem.item;
                 snippetCell.frame = cellFrame;
                 return [snippetCell draggingImageComponents];
             };
         }
     }];
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    info.animatesToDestination = info.draggingSource != tableView;
    
    //this disables the "drop on" behavior
    [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
    
    if (info.draggingSource == tableView) {
        return NSDragOperationMove;
    }
    
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    __block NSUInteger insertionIndex = row;
    NSMutableArray *snippets = [[XCSnippetController sharedController] mutableArrayValueForKey:@"snippets"];
    
    _animateChanges = NO;
    [tableView beginUpdates];
    
    [info enumerateDraggingItemsWithOptions:0 forView:tableView classes:@[ [XCSnippet class] ] searchOptions:nil usingBlock:
     ^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
         XCSnippet *snippet = draggingItem.item;
         
         if (info.draggingSource == tableView) {
             NSUInteger oldIndex = [snippets indexOfObject:snippet];
             if (oldIndex < insertionIndex) {
                 insertionIndex--;
             }
             
             [snippets removeObject:snippet];
             [snippets insertObject:snippet atIndex:insertionIndex];
             NSUInteger newIndex = [snippets indexOfObject:snippet];
             
             [tableView moveRowAtIndex:oldIndex toIndex:newIndex];
         } else {
             [snippets insertObject:snippet atIndex:insertionIndex];
             
             [tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] withAnimation:NSTableViewAnimationEffectGap];
         }
         
         draggingItem.draggingFrame = [tableView frameOfCellAtColumn:0 row:insertionIndex];
         
         insertionIndex++;
     }];
    
    [tableView endUpdates];
    _animateChanges = YES;
    
    return YES;
}

@end
