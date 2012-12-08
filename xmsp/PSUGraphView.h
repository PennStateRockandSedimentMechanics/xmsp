//
//  PSUGraphView.h
//  PSUPlot
//
//  Created by Ryan Martell on 12/3/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Core.h"

@interface PSUGraphView : NSView
@property (nonatomic, assign) struct xmsp_file_data *data;
@end
