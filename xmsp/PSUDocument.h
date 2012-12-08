//
//  PSUDocument.h
//  PSUPlot
//
//  Created by Ryan Martell on 10/24/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Core.h"
#import "PSUGraphView.h"


@interface PSUDocument : NSDocument
{
@public
    struct xmsp_file_data *data;
}
@property (weak) IBOutlet PSUGraphView *graphView;

-(void)loadRawFiles:(NSArray *)files;
@end
