//
//  main.c
//  MeddoHelper
//
//  Created by John Shimek on 9/16/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#include <syslog.h>

int main(int argc, const char * argv[])
{
    syslog(LOG_NOTICE, "Meddo Helper is running");
 
    
    return 0;
}

