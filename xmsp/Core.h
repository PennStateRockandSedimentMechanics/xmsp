//
//  Core.h
//  PSUPlot
//
//  Created by Ryan Martell on 12/3/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#ifndef PSUPlot_Core_h
#define PSUPlot_Core_h

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

#define  ROW_SIZE 500000
#define  MAX_FILES 20
#define  MAX_COLS 2000
#define OUT 0
#define IN 1
#define BUF_SZ 1000
#define GC_TICK 1
#define GC_TITLE 2

struct xmsp_file_data {
    int     n_cols[MAX_FILES], n_rows[MAX_FILES];
    
    float   *data_ptr[MAX_FILES][MAX_COLS];
    char    heading[BUF_SZ];
    char    n_head[BUF_SZ];
    
    char    string[100],skip[15],new_file[20];
//    int file_num;
    int     n_files;
    char	set_x_range;
    char	set_y_range;
    float   scale_x, scale_y;
    float   maxx,minx,maxy,miny;
};

struct xmsp_file_data *new_file_data();

void load_files(struct xmsp_file_data *obj, const char *files[], int n_files);
#endif
