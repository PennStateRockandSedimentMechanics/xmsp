//
//  Core.c
//  PSUPlot
//
//  Created by Ryan Martell on 12/3/12.
//  Copyright (c) 2012 Martell Ventures, LLC. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Core.h"


/* local prototypes */
static void read_data(struct xmsp_file_data *obj, const char *file, int file_num);

// straight C follows. Yay!

struct xmsp_file_data *new_file_data()
{
    struct xmsp_file_data *data= (struct xmsp_file_data *) malloc(sizeof(struct xmsp_file_data));
    if(data)
    {
        memset(data, 0, sizeof(struct xmsp_file_data));
        data->set_x_range= 'n';
        data->set_y_range= 'n';
    }
    
    return data;
}

void load_files(struct xmsp_file_data *obj, const char *files[], int n_files)
{
    int col, row;
    float tmp_xmin, tmp_xmax, tmp_ymin, tmp_ymax;
    
    for (int i=0; i<n_files;++i)
    {
        read_data(obj, files[i], i);
    }
    
    tmp_xmin = obj->minx; tmp_xmax = obj->maxx; tmp_ymin = obj->miny; tmp_ymax = obj->maxy;
    
    obj->maxx = obj->maxy = -1e20;
    obj->minx = obj->miny = 1e20;
    for (int i=0; i<n_files; ++i)
    {
        for (int row=0; row<obj->n_rows[i]; ++row)
        {
            if (obj->data_ptr[i][0][row] > obj->maxx)
                obj->maxx = obj->data_ptr[i][0][row];
            if (obj->data_ptr[i][0][row] < obj->minx)
                obj->minx = obj->data_ptr[i][0][row];
        }
        for (col=1; col<obj->n_cols[i]; ++col)
        {
            for (row=0; row<obj->n_rows[i]; ++row)
            {
                if (obj->data_ptr[i][col][row] > obj->maxy)
                    obj->maxy = obj->data_ptr[i][col][row];
                if (obj->data_ptr[i][col][row] < obj->miny)
                    obj->miny =  obj->data_ptr[i][col][row];
            }
        }
    }
    if(obj->set_x_range == 'y')
    {
        obj->minx = tmp_xmin;
        obj->maxx = tmp_xmax ;
    }
    if(obj->set_y_range == 'y')
    {
        obj->miny = tmp_ymin;
        obj->maxy = tmp_ymax ;
    }
    
    obj->n_files= n_files;
    fprintf(stderr,"min_x= %g, max_x= %g\tmin_y=%g, max_y=%g\n",obj->minx,obj->maxx,obj->miny,obj->maxy);
}

/* ------------------------ read_data -------------------------- */

static void read_data(struct xmsp_file_data *obj, const char *file, int file_num)
{
    FILE   *data;
    int    i, col, row, flag, state;
    char   c, buf[BUF_SZ];
    
    if ((data = fopen( file, "r")) == NULL )
    {
        fprintf( stderr, "can't open data file\n");
        exit( 10);
    }
    
    /* find out how many cols there are */
    /* do this first so that I can then just rewind back to beginning of file*/
    for(i=0;i<4;++i)
        fgets(buf,BUF_SZ,data);     /* look at the 4th line, assume this is past any header stuff */
    
    rewind(data);
    
    if(obj->skip[1] =='a' || (obj->skip[1]=='n' && file_num>0))
    {
        i=0;        /*do nothing, easier to read (think about...) */
    }
    else
    {
        flag=1;
        for(i=0;(c=fgetc(data))!=EOF && c!='\n'; i++)
        {
            if(flag)
            {
                obj->heading[i]=c;
                if(i>35 && (c==' ' || c=='\t'))
                {
                    obj->heading[++i]='\0';
                    flag=0;
                    fscanf(data,"%s",obj->n_head);
                    i=(int) strlen(obj->n_head)-1;
                }
            }
            else
                obj->n_head[i]=c;
        }
        obj->n_head[++i]='\0';
    }
    
    /*printf("nhead: %s\n", n_head);*/
    
    state=OUT;                    /* count the number of cols in each row */
    for(obj->n_cols[file_num]=i=0; buf[i] != '\0'; ++i)
    {
        if(buf[i] == ' ' || buf[i] == '\t' || buf[i] == '\n')
        {
            state=OUT;
        }
        else if(state==OUT)
        {
            state=IN;
            ++(obj->n_cols[file_num]);
        }
    }
    /*allocate space*/
    for(col=0;col<obj->n_cols[file_num];++col)
        obj->data_ptr[file_num][col] = (float*) calloc(ROW_SIZE, sizeof(float));
    
    
    /*read data*/
    col=row=0;
    while (fscanf(data, "%f", &(obj->data_ptr[file_num][0][row])) != EOF)
    {
        for(col=1;col<obj->n_cols[file_num];++col)
        {
            fscanf( data, "%f", &(obj->data_ptr[file_num][col][row]));
        }
        ++row;
    }
    obj->n_rows[file_num] = row;
    
    fclose(data);
    fprintf(stderr, "file %s has %d rows and %d cols \n", file, obj->n_rows[file_num], obj->n_cols[file_num]);
}
