//
//  PSUDocumentController.h
//  xmsp
//
//  Created by Ryan Martell on 12/11/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PSUDocumentController : NSDocumentController
- (NSArray *)URLsFromRunningOpenPanel;
@end
