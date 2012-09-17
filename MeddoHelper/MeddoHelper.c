//
//  main.c
//  MeddoHelper
//
//  Created by John Shimek on 9/16/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#include <stdio.h>
#include <syslog.h>
#include <unistd.h>

int main(int argc, const char * argv[])
{
    syslog(LOG_NOTICE, "Meddo: Hello world! uid = %d, euid = %d, pid = %d", getuid(), geteuid(), getpid());
    return 0;
}

