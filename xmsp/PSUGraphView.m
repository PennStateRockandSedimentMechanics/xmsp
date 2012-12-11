//
//  PSUGraphView.m
//  PSUPlot
//
//  Created by Ryan Martell on 12/3/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#define SPACING_BETWEEN_LABEL_AND_AXIS (3)
#define HEIGHT_FUDGE_FACTOR (2)

#import "PSUGraphView.h"
@interface PSUGraphView ()
@property (nonatomic, strong) NSDictionary *labelAttributes;
@property (nonatomic, strong) NSDictionary *titleAttributes;
@property (nonatomic, strong) NSArray *plotColors;
@end

@implementation PSUGraphView

-(void)setData:(struct xmsp_file_data *)data
{
    _data= data;
    [self setNeedsDisplay:YES];
    
//    NSLog(@"%@", [[NSFontManager sharedFontManager] availableFontFamilies]);
//    NSLog(@"%@", [[NSFontManager sharedFontManager] availableMembersOfFontFamily:@"Lucida Sans"]);
    self.labelAttributes= [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSFont fontWithName:@"LucidaSans" size:12], NSFontAttributeName,
                           nil];
    self.titleAttributes= [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSFont fontWithName:@"LucidaSans" size:14], NSFontAttributeName,
                           nil];
    
    self.plotColors= [NSArray arrayWithObjects:
                      [NSColor blackColor],
                      [NSColor greenColor],
                      [NSColor blueColor],
                      [NSColor brownColor],
                      [NSColor redColor],
                      [NSColor magentaColor],
                      [NSColor orangeColor],
                      [NSColor purpleColor],
                      [NSColor yellowColor],
                      nil];
}

-(BOOL)isFlipped
{
    return YES;
}

-(void)drawRect:(NSRect)dirtyRect
{
    // Erase the window to white.
    if(self.data)
    {
        // Calculate the "scale"
        float diffx= self.data->maxx-self.data->minx;
        float diffy=self.data->maxy-self.data->miny;
        
        int canvas_width= (int) self.bounds.size.width;
        int canvas_height= (int) self.bounds.size.height;


#if false
        int start_xaxis = (int)canvas_width/10*1.5;
        int end_xaxis = canvas_width - (int)canvas_width/10*1.5;

        int start_yaxis = canvas_height - (int)canvas_height*0.1;
        int end_yaxis = (int)canvas_height*0.2;
        
        int start_x = (int)canvas_width/5;  /* starts at 0.2 width  */
        int end_x = canvas_width - (int)canvas_width/5;  /* ends at 0.2 width */
        
        int start_y = canvas_height - (int)canvas_height*0.15;  /* starts at 0.15 */
        int end_y = (int)(canvas_height*0.25); /* ends at 0.75 */
#else
#define X_INSET (50)
#define TOP_INSET (30)
#define BOTTOM_INSET (90) // this is really top
#define START_X_INSET (X_INSET+5+(canvas_height*0.02))
#define START_Y_TOP_INSET (TOP_INSET+10)
#define START_Y_BOTTOM_INSET (BOTTOM_INSET+10)
        
        int start_xaxis = X_INSET;
        int end_xaxis = canvas_width - X_INSET;
        
        int start_yaxis = canvas_height - TOP_INSET;
        int end_yaxis = BOTTOM_INSET;
        
        int start_x = START_X_INSET;  /* starts at 0.2 width  */
        int end_x = canvas_width - START_X_INSET;  /* ends at 0.2 width */
        
        int start_y = canvas_height - START_Y_TOP_INSET;  /* starts at 0.15 */
        int end_y = START_Y_BOTTOM_INSET; /* ends at 0.75 */
#endif
        
        self.data->scale_x = (float)((float)end_x - (float)start_x)/diffx;
        self.data->scale_y = (float)((float)start_y - (float)end_y)/diffy;

        
        /* x-axis  */
        [NSBezierPath strokeLineFromPoint:NSMakePoint(start_xaxis, start_yaxis)
                                  toPoint:NSMakePoint(end_xaxis, start_yaxis)];
        
        /* left y-axis  */
        [NSBezierPath strokeLineFromPoint:NSMakePoint(start_xaxis, start_yaxis)
                                  toPoint:NSMakePoint(start_xaxis, end_yaxis)];
        
        /* right y-axis  */
        [NSBezierPath strokeLineFromPoint:NSMakePoint(end_xaxis, start_yaxis)
                                  toPoint:NSMakePoint(end_xaxis, end_yaxis)];

        int ticky=(int)canvas_width*0.02;
        int tickx=(int)canvas_height*0.02;
        
        float stop_xmax = self.data->maxx + diffx/20;
        float stop_ymax = self.data->maxy + diffy/20;
        
        float stop_xmin = self.data->minx - diffx/20;
        float stop_ymin = self.data->miny - diffy/20;

        
        /* figure out where to round scales so ticks come out as a factor of 10 or 5*/
        
        /* take min=101 max = 154 diff=53,      round 101 to 110 by dividing 101 by*/
        /*                                      10 raised to (floor(log10(53))=1) */
        /*                                      i.e. 101/10 = 10.1 round to 11 using*/
        /*                                      ceil.  then get back to 110 with 11 */
        /*                                      times 10 to the one                */
        
        /*      decx = (double)floor(log10(diffx));     i.e. return -2 for -1.5, 1 for 1.5*/
        
        
        double decx=(double)floor(log10(diffx));
        double decy=(double)floor(log10(diffy));
        double ten= 10.0;
        
        float big_tickx= floor(self.data->minx*pow(ten,-decx)) * pow(ten, decx);
        float big_ticky= floor(self.data->miny*pow(ten,-decy)) * pow(ten, decy);
        /*fprintf(stderr, "diffx = %f, maxx=%f, minx=%f, diffy=%f, maxy=%f, miny=%f\n",diffx, maxx, minx, diffy, maxy, miny);
         fprintf(stderr,"decx= %f\t big_tickx=%f decy=%f big_ticky=%f\n",decx,big_tickx,decy,big_ticky);
         fprintf(stderr,"start_y=%f, start_x=%f, scale_y=%f, scale_x=%f\n",start_y, start_x, scale_y, scale_x);*/
        
        
        /* y axis big tick marks  */
        int a;
        for (a=0;big_ticky<=stop_ymax;++a)
        {
            int where_y = start_y-(int)((big_ticky-self.data->miny)*self.data->scale_y);
            
            /*because of the way we set "big_tick"s and "start_y" it's possible
             for the first tick to fall outside the plot*/
            if(where_y < start_yaxis)
            {
                [NSBezierPath strokeLineFromPoint:NSMakePoint(start_xaxis, where_y)
                                          toPoint:NSMakePoint(start_xaxis+ticky, where_y)];

                [NSBezierPath strokeLineFromPoint:NSMakePoint(end_xaxis, where_y)
                                          toPoint:NSMakePoint(end_xaxis-ticky, where_y)];

                NSString *string= [NSString stringWithFormat:@"%.5g", big_ticky];
                CGSize size= [string sizeWithAttributes:self.labelAttributes];
                [string drawAtPoint:NSMakePoint(
                                                start_xaxis - (size.width + SPACING_BETWEEN_LABEL_AND_AXIS),
                                                where_y - (size.height/2 + HEIGHT_FUDGE_FACTOR)) withAttributes:self.labelAttributes];
            }
            big_ticky += pow(ten, decy);
            
        }
        
        /* y axis small tick mrks */
        if (a<2)
        {
            big_ticky -= 1.5 * pow(ten, decy);
            
            if (big_ticky < stop_ymin) big_ticky += pow(ten, decy);
            while (big_ticky < stop_ymax)
            {
                int where_y = start_y-(int)((big_ticky-self.data->miny)*self.data->scale_y);

                [NSBezierPath strokeLineFromPoint:NSMakePoint(start_xaxis, where_y)
                                          toPoint:NSMakePoint(start_xaxis+ticky, where_y)];
                
                [NSBezierPath strokeLineFromPoint:NSMakePoint(end_xaxis, where_y)
                                          toPoint:NSMakePoint(end_xaxis-ticky, where_y)];
                

                NSString *string= [NSString stringWithFormat:@"%.5g", big_ticky];
                CGSize size= [string sizeWithAttributes:self.labelAttributes];
                [string drawAtPoint:NSMakePoint(
                                                start_xaxis - (size.width + SPACING_BETWEEN_LABEL_AND_AXIS),
                                                where_y - (size.height/2 + HEIGHT_FUDGE_FACTOR)) withAttributes:self.labelAttributes];

                big_ticky += pow(ten, decy);
            }
        }
        
        
        /*  x axis big tick marks  */
        for (a=0;big_tickx<=stop_xmax;++a)
        {
            int where_x=start_x + (int)((big_tickx-self.data->minx)*self.data->scale_x);
            
            if(where_x >= start_xaxis)
            {
                [NSBezierPath strokeLineFromPoint:NSMakePoint(where_x, start_yaxis)
                                          toPoint:NSMakePoint(where_x, start_yaxis - tickx)];
                
                NSString *string= [NSString stringWithFormat:@"%.5g", big_tickx];
                CGSize size= [string sizeWithAttributes:self.labelAttributes];
                [string drawAtPoint:NSMakePoint(
                                                where_x - (size.width/2),
                                                start_yaxis + SPACING_BETWEEN_LABEL_AND_AXIS)
                     withAttributes:self.labelAttributes];

                /*                sprintf(string, "%.5g", big_tickx);
                
                XDrawString(dpy, win, gctick,
                            where_x - tickfontwidth*stringlen/2,
                            start_yaxis + tickfontheight + 5,
                            string, stringlen);
 */
            }
            
            big_tickx += pow(ten, decx);
        }
        
        /* x axis small tick marks */
        if (a<2)
        {
            big_tickx -= 1.5 * pow(ten, decx);
            
            if (big_tickx < stop_xmin) big_tickx += pow(ten, decx);
            while (big_tickx < stop_xmax)
            {
                int where_x=start_x + (int)((big_tickx-self.data->minx)*self.data->scale_x);
                
                [NSBezierPath strokeLineFromPoint:NSMakePoint(where_x, start_yaxis)
                                          toPoint:NSMakePoint(where_x, start_yaxis - tickx)];
                
                NSString *string= [NSString stringWithFormat:@"%.5g", big_tickx];
                CGSize size= [string sizeWithAttributes:self.labelAttributes];
                [string drawAtPoint:NSMakePoint(
                                                where_x - size.width/2,
                                                start_yaxis + SPACING_BETWEEN_LABEL_AND_AXIS)
                     withAttributes:self.labelAttributes];

/*                sprintf(string, "%.5g", big_tickx);

                XDrawString(dpy, win, gctick,
                            where_x - tickfontwidth*stringlen/2,
                            start_yaxis + tickfontheight + 5,
                            string, stringlen);
*/                
                big_tickx += pow(ten, decx);
            }
        }
        
  
        {
            if(strcmp(self.data->heading, "")==1) strcpy(self.data->heading, "Test Plot\n");
            NSString *heading = [NSString stringWithFormat:@"%s", self.data->heading];
            CGSize size= [heading sizeWithAttributes:self.titleAttributes];
            [heading drawAtPoint:NSMakePoint(
                                            start_xaxis,
                                            end_yaxis - 4*size.height)
                 withAttributes:self.titleAttributes];
        }
        
        // put up to 50 chars on each line
        {
            int j, i;
            int tmp;
            char string[512];
            
            for(i= tmp=0;i<strlen(self.data->n_head)/90;i++)
            {
                for(j=0;j<90;j++)
                {
                    string[j] = self.data->n_head[tmp++];
                }
                string[j] = '\0';

//                XDrawString(dpy, win, gctitle, start_xaxis, (end_yaxis+(-3+i)*titlefontheight), string, strlen(string));
                NSString *heading = [NSString stringWithFormat:@"%s", string];
                CGSize size= [heading sizeWithAttributes:self.titleAttributes];
                [heading drawAtPoint:NSMakePoint(
                                                 start_xaxis,
                                                 end_yaxis + (-3+i)*size.height)
                      withAttributes:self.titleAttributes];
            }
            j=0;
            while(tmp<=strlen(self.data->n_head))
                string[j++] = self.data->n_head[tmp++];
            {
                NSString *heading = [NSString stringWithFormat:@"%s", string];
                CGSize size= [heading sizeWithAttributes:self.titleAttributes];
                [heading drawAtPoint:NSMakePoint(
                                                 start_xaxis,
                                                 end_yaxis + (-3+i)*size.height)
                      withAttributes:self.titleAttributes];
            }
//            XDrawString(dpy, win, gctitle, start_xaxis, (end_yaxis+(-3+i)*titlefontheight), string, strlen(string));
        }

        /*
        if (strcmp(heading, "")==1) strcpy(heading, "Test Plot\n");
 
         XDrawString(dpy, win, gctitle,
             start_xaxis, end_yaxis-4*titlefontheight,
             heading, strlen(heading));
 
        // put up to 50 chars on each line
        for(i=tmp=0;i<strlen(n_head)/90;i++)
        {
            for(j=0;j<90;j++)
                string[j] = n_head[tmp++];
            string[j] = '\0';
            XDrawString(dpy, win, gctitle, start_xaxis, (end_yaxis+(-3+i)*titlefontheight),
                        string, strlen(string));
        }
        j=0;
        while(tmp<=strlen(n_head))
            string[j++] = n_head[tmp++];
        XDrawString(dpy, win, gctitle, start_xaxis, (end_yaxis+(-3+i)*titlefontheight),
                    string, strlen(string));
*/
        
        for (int i=0; i<self.data->n_files; ++i)
        {
            // colors by file.
            NSColor *color= self.plotColors[i%self.plotColors.count];
            
            [color set];
            
            for (int col=1; col<self.data->n_cols[i]; col++)
            {
                for (int row=1; row<self.data->n_rows[i]; row++)
                {
                    float x1 = (self.data->data_ptr[i][0][row-1] - self.data->minx);
                    float y1 = (self.data->data_ptr[i][col][row-1] - self.data->miny);

                    float x2 = (self.data->data_ptr[i][0][row] - self.data->minx);
                    float y2 = (self.data->data_ptr[i][col][row] - self.data->miny);
                    
                    NSPoint pt1= NSMakePoint((int)start_x + (int)(x1*self.data->scale_x), (int)start_y - (int)(y1*self.data->scale_y));
                    NSPoint pt2= NSMakePoint((int)start_x + (int)(x2*self.data->scale_x), (int)start_y - (int)(y2*self.data->scale_y));
                    
                    if(pt1.x != pt2.x || pt1.y != pt2.y)
                    {
                        [NSBezierPath strokeLineFromPoint:pt1 toPoint:pt2];
                    }
                }
            }
        }
    }
}

#if false
#pragma mark --- Printing information
// Return the number of pages available for printing
- (BOOL)knowsPageRange:(NSRangePointer)range {
    NSRect bounds = [self bounds];
    float printHeight = [self calculatePrintHeight];
    
    range->location = 1;
//    range->length = NSHeight(bounds) / printHeight + 1;
    range->length= 1;
    
    return YES;
}

// Return the drawing rectangle for a particular page number
- (NSRect)rectForPage:(int)page {
#if false
    NSRect bounds = [self bounds];

    float pageHeight = [self calculatePrintHeight];
    return NSMakeRect( NSMinX(bounds),
                      NSMinY(bounds), // NSMaxY(bounds) - page * pageHeight,
                      NSWidth(bounds), pageHeight );
#endif
    NSPrintInfo *pi = [[NSPrintOperation currentOperation] printInfo];
    
    // Calculate the page height in points
    NSSize paperSize = [pi paperSize];
    float pageHeight = paperSize.height - [pi topMargin] - [pi bottomMargin];
    float pageWidth = paperSize.width - [pi leftMargin] - [pi rightMargin];

    return NSMakeRect(0, 0, pageWidth, pageHeight );
}

// Calculate the vertical size of the view that fits on a single page
- (float)calculatePrintHeight {
    // Obtain the print info object for the current operation
    NSPrintInfo *pi = [[NSPrintOperation currentOperation] printInfo];
    
    // Calculate the page height in points
    NSSize paperSize = [pi paperSize];
    float pageHeight = paperSize.height - [pi topMargin] - [pi bottomMargin];
    
    // Convert height to the scaled view
    float scale = [[[pi dictionary] objectForKey:NSPrintScalingFactor]
                   floatValue];
    return pageHeight / scale;
}
#endif

/*
 
 NSString *NSFontAttributeName;
 NSString *NSParagraphStyleAttributeName;
 NSString *NSForegroundColorAttributeName;
 NSString *NSUnderlineStyleAttributeName;
 NSString *NSSuperscriptAttributeName;
 NSString *NSBackgroundColorAttributeName;
 NSString *NSAttachmentAttributeName;
 NSString *NSLigatureAttributeName;
 NSString *NSBaselineOffsetAttributeName;
 NSString *NSKernAttributeName;
 NSString *NSLinkAttributeName;
 NSString *NSStrokeWidthAttributeName;
 NSString *NSStrokeColorAttributeName;
 NSString *NSUnderlineColorAttributeName;
 NSString *NSStrikethroughStyleAttributeName;
 NSString *NSStrikethroughColorAttributeName;
 NSString *NSShadowAttributeName;
 NSString *NSObliquenessAttributeName;
 NSString *NSExpansionAttributeName;
 NSString *NSCursorAttributeName;
 NSString *NSToolTipAttributeName;
 NSString *NSMarkedClauseSegmentAttributeName;
 NSString *NSWritingDirectionAttributeName;
 NSString *NSVerticalGlyphFormAttributeName;
 NSString *NSTextAlternativesAttributeName;
*/
@end
