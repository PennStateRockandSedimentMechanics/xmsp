//
//  PSUDocumentController.m
//  xmsp
//
//  Created by Ryan Martell on 12/11/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#import "PSUDocumentController.h"

@interface PSUDocumentController () <NSOpenSavePanelDelegate>
@end

@implementation PSUDocumentController
#if false
-(id)init {
    if(self= [super init])
    {
        
    }
    
    return self;
}
#endif

#if false
// This would have to completely override openDocument:, so it would know what to do.  I'm not going to do that right now.

// this is the "right" one, but it doesn't get called.
- (NSArray *)URLsFromRunningOpenPanel
{
    return nil;
}

// this is the one that gets called.
- (NSArray *)fileNamesFromRunningOpenPanel
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    NSButton *button = [[NSButton alloc] init];
    [button setButtonType:NSSwitchButton];
    button.title = NSLocalizedString(@"This file has headers", @"");
    [button sizeToFit];
    [openDlg setAccessoryView:button];
    openDlg.delegate = self;
//    openDlg.allowedFileTypes= [NSArray arrayWithObjects:@"*", "xmsp", nil];
    
    if([openDlg runModal]==NSFileHandlingPanelOKButton)
    {
        NSButton *button = (NSButton*)openDlg.accessoryView;
        
    }

    return nil;
}

- (void)panelSelectionDidChange:(id)sender {
    NSOpenPanel *panel = sender;
    NSButton *button = (NSButton*)panel.accessoryView;
    // Update button based on panel selection
}
#endif

@end
