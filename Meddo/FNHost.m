//
//  FNHost.m
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNHost.h"

@implementation FNHost

@synthesize name;
@synthesize comments;
@synthesize hostlines;

- (id) init {
    self = [super init];
    if (self) {
        [self setComments:[NSMutableArray array]];
        [self setHostlines:[NSMutableArray array]];
    }
    return self;
}

- (BOOL) isEmpty {
    BOOL result = NO;
    if ([self.comments count] == 0 && [self.hostlines count] == 0) {
        result = YES;
    }
    return result;
}

- (void) addComment:(NSString *)comment {
    if ([comment length] > 0) {
        [[self comments] addObject:comment];
    }
}

- (void) addHostline:(FNHostLine *)hostline {
    if (hostline != nil) {
        [[self hostlines] addObject:hostline];
    }
}

@end
