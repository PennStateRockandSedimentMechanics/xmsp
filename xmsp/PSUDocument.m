//
//  PSUDocument.m
//  PSUPlot
//
//  Created by Ryan Martell on 10/24/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#import "PSUDocument.h"

@implementation PSUDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self->data= new_file_data();
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"PSUDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    // copy the data across (in case we loaded)
    self.graphView.data= self->data;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (BOOL)readFromData:(NSData *)d ofType:(NSString *)typeName
               error:(NSError **)outError
{
    BOOL readSuccess = NO;
    
    if(d.length>=sizeof(struct xmsp_file_data))
    {
        if(self->data)
        {
            free(self->data);
        }
        
        self->data= (struct xmsp_file_data *) malloc(sizeof(struct xmsp_file_data));
        if(self->data)
        {
            memcpy(self->data, [d bytes], sizeof(struct xmsp_file_data));

            NSInteger bytesRemaining= 0;
            for(int file_index= 0; file_index<self->data->n_files; file_index++)
            {
                /* copy allocated bytes */
                for(int col=0;col<self->data->n_cols[file_index];++col)
                {
                    bytesRemaining += self->data->n_rows[file_index]*sizeof(float);
                }
            }
            
            NSInteger offset= sizeof(struct xmsp_file_data);
            if((d.length - offset)==bytesRemaining)
            {
                for(int file_index= 0; file_index<self->data->n_files; file_index++)
                {
                    /* copy allocated bytes */
                    for(int col=0;col<self->data->n_cols[file_index];++col)
                    {
                        NSInteger rowSizeBytes= self->data->n_rows[file_index]*sizeof(float);
                        self->data->data_ptr[file_index][col]= calloc(ROW_SIZE, sizeof(float));
                        if(self->data->data_ptr[file_index][col])
                        {
                            [d getBytes:self->data->data_ptr[file_index][col] range:NSMakeRange(offset, rowSizeBytes)];
                        }
                        offset+= rowSizeBytes;
                    }
                }
                
                NSAssert(offset==d.length, @"Offset != length!");
                
                readSuccess= YES;
            } else {
                *outError= [NSError errorWithDomain:NSCocoaErrorDomain
                                               code:NSFileReadUnknownError userInfo:nil];
            }
        }
    } else {
        if(outError)
        {
            *outError= [NSError errorWithDomain:NSCocoaErrorDomain
                                      code:NSFileReadUnknownError userInfo:nil];
        }
    }
    
    return readSuccess;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData *d= [NSMutableData dataWithBytes:self->data length:sizeof(struct xmsp_file_data)];

    if(d)
    {
        // we have to add in all the row pointers.
        for(int file_index= 0; file_index<self->data->n_files; file_index++)
        {
            /* copy allocated bytes */
            for(int col=0;col<self->data->n_cols[file_index];++col)
            {
                [d appendBytes:self->data->data_ptr[file_index][col] length:self->data->n_rows[file_index]*sizeof(float)];
            }
        }
    }
    if (!d && outError) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileWriteUnknownError userInfo:nil];
    }
    
    return d;
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    NSPrintOperation *operation= [NSPrintOperation printOperationWithView:self.graphView];
    
    operation.printInfo.horizontalPagination= NSFitPagination;
    operation.printInfo.verticalPagination= NSFitPagination;

    return operation;
}

-(void)loadRawFiles:(NSArray *)files
{
    const char *filePaths[MAX_FILES];
    
    if(files.count>ARRAY_SIZE(filePaths))
    {
        NSLog(@"More than %d files are not supported!", MAX_FILES);
    } else {
        for(int ii= 0; ii<files.count; ii++)
        {
            filePaths[ii]= [[files objectAtIndex:ii] cStringUsingEncoding:NSASCIIStringEncoding];
        }
        
        load_files(self->data, filePaths, (int)files.count);
    }
    
    self.graphView.data= self->data;
}
@end
