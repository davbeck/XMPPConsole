//
//  XCSnippetViewController.m
//  XMPPConsole
//
//  Created by David Beck on 8/5/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetViewController.h"

#import "XCSnippetController.h"
#import "XCSnippet.h"
#import "XCSnippetRowView.h"


@interface XCSnippetViewController ()

@end

@implementation XCSnippetViewController
{
    BOOL _animateChanges;
}

- (void)setTableView:(NSTableView *)tableView
{
    _tableView = tableView;
    
    [_tableView registerForDraggedTypes:[XCSnippet readableTypesForPasteboard:nil]];
    [_tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
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
