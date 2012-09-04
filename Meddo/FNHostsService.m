//
//  FNHostsController.m
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNHostsService.h"

@implementation FNHostsService

@synthesize _hosts = hosts;

+ (FNHostsService *) sharedInstance {
    static FNHostsService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FNHostsService alloc] init];
    });
    return sharedInstance;
}


- (void) write {
    
}

- (void) read {
    NSArray *hostLines = [NSArray arrayWithContentsOfFile:kHostFile];

    for (NSString *hostLine in hostLines) {
        NSString *trimmed = [hostLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        FNHost *host = Nil;
        if ([trimmed hasPrefix:@"#"]) {
            // Is a comment, maybe commented out entry
            
        } else {
            // Should be a valid entry
            
        }
        
    }
}

@end
