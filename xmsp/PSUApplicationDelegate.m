//
//  PSUApplicationDelegate.m
//  PSUPlot
//
//  Created by Ryan Martell on 12/3/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#import "PSUApplicationDelegate.h"
#import "PSUDocument.h"

@implementation PSUApplicationDelegate
-(void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    
}

// don't open an untitled new file.
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSLog(@"Arguments: %@", arguments);

    if(arguments.count==1)
    {
        NSString *usage= [NSString stringWithFormat:@"usage: %@ (-naxy) filename filename ...\n"
            @"default is for all files to have a first line header\n"
            @"-n only first file has first line heading\n"
            @"-a no file has a first line heading\n"
            @"-x#t# set x plot scale, first val. is min, second is max\n"
            @"-y#t# set y plot scale, first val is min, second is max\n"
            @"  NOTE: for x and y scales, the letter t separates the min & max\n",
                          [arguments objectAtIndex:0]];
        NSLog(@"%@", usage);
    } else {
        
        // create a document here.  Set the properties (based on the -n, -a, -x, -y flags), then
        // load the files into it.
        
        NSDocumentController *controller= [NSDocumentController sharedDocumentController];
        NSError *error;
        
        PSUDocument *doc= [controller openUntitledDocumentAndDisplay:YES error:&error];
        NSMutableArray *filePaths= [NSMutableArray arrayWithCapacity:4];
        for(NSInteger argc= 1; argc<arguments.count; argc++)
        {
            NSString *arg= [arguments objectAtIndex:argc];

            if([[arg substringToIndex:1] isEqualToString:@"-"])
            {
                if([arg isEqualToString:@"-a"])
                {
                    doc->data->skip[1]= 'a';
                }
                else if([arg isEqualToString:@"-n"])
                {
                    doc->data->skip[1]= 'n';
                }
                else if([[arg substringToIndex:2] isEqualToString:@"-x"])
                {
                    NSString *strippedFlag= [arg substringFromIndex:2];
                    NSArray *parts= [strippedFlag componentsSeparatedByString:@"t"];
                    
                    if(parts.count==2)
                    {
                        doc->data->set_x_range= 'y';
                        doc->data->minx= [[parts objectAtIndex:0] floatValue];
                        doc->data->maxx= [[parts objectAtIndex:1] floatValue];
                    } else {
                        NSLog(@"Could not parse: %@ (Parts: %@)", arg, parts);
                    }
                }
                else if([[arg substringToIndex:2] isEqualToString:@"-y"])
                {
                    NSString *strippedFlag= [arg substringFromIndex:2];
                    NSArray *parts= [strippedFlag componentsSeparatedByString:@"t"];
                    
                    if(parts.count==2)
                    {
                        doc->data->set_y_range= 'y';
                        doc->data->miny= [[parts objectAtIndex:0] floatValue];
                        doc->data->maxy= [[parts objectAtIndex:1] floatValue];
                    } else {
                        NSLog(@"Could not parse: %@ (Parts: %@)", arg, parts);
                    }
                } else {
                    NSLog(@"Unknown flag: %@", arg);
                }
            } else {
                if([[NSFileManager defaultManager] fileExistsAtPath:arg])
                {
                    // it's a filename...
                    [filePaths addObject:arg];
                } else {
                    NSLog(@"Invalid path or file doesn't exist there: %@", arg);
                }
            }
        }
        
        if(filePaths.count)
        {
            [doc loadRawFiles:filePaths];
        } else {
            // close this document...
            [doc close];
        }
    }
}
@end
