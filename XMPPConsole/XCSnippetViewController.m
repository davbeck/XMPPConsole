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
    NSUInteger _sourceDraggingIndex;
}
@synthesize defaultDestination = _defaultDestination;

- (void)setTableView:(NSTableView *)tableView
{
    _tableView = tableView;
    
    [_tableView registerForDraggedTypes:[XCSnippet readableTypesForPasteboard:nil]];
    [_tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
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

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[XCSnippetRowView alloc] init];
}

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

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes
{
    if (rowIndexes.count == 1) {
        _sourceDraggingIndex = [rowIndexes lastIndex];
    }
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    info.animatesToDestination = YES;
    
    if (info.draggingSource == tableView) {
        return NSDragOperationMove;
    }
    
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    __block NSUInteger insertionIndex = row;
    __block NSUInteger sourceIndex = 0;
    
    [tableView beginUpdates];
    
    [info enumerateDraggingItemsWithOptions:0 forView:tableView classes:@[ [XCSnippet class] ] searchOptions:nil usingBlock:
     ^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
         XCSnippet *snippet = draggingItem.item;
         
         if (info.draggingSource == tableView && info.draggingSourceOperationMask | NSDragOperationMove) {
             NSMutableArray *snippets = [[XCSnippetController sharedController] mutableArrayValueForKey:@"snippets"];
             
             if (_sourceDraggingIndex != NSUIntegerMax) {
                 [snippets removeObjectAtIndex:_sourceDraggingIndex];
                 [snippets insertObject:snippet atIndex:insertionIndex];
                 
                 [tableView moveRowAtIndex:_sourceDraggingIndex toIndex:insertionIndex];
             } else {
                 NSUInteger oldIndex = [snippets indexOfObject:snippet];
                 [snippets removeObjectAtIndex:oldIndex];
                 [snippets insertObject:snippet atIndex:insertionIndex];
                 
                 [tableView moveRowAtIndex:_sourceDraggingIndex toIndex:insertionIndex];
             }
             
             draggingItem.draggingFrame = [tableView frameOfCellAtColumn:0 row:insertionIndex];\
         } else if (info.draggingSourceOperationMask | NSDragOperationCopy) {
             [[XCSnippetController sharedController] insertObject:snippet inSnippetsAtIndex:insertionIndex];
             
             draggingItem.draggingFrame = [tableView frameOfCellAtColumn:0 row:insertionIndex];
         }
         
         insertionIndex++;
         sourceIndex++;
     }];
    
    [tableView endUpdates];
    
    _sourceDraggingIndex = NSUIntegerMax;
    
    return YES;
}

@end
