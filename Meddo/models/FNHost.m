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

- (void) setEnabled:(BOOL)enabled {
    for (FNHostLine *hostline in hostlines) {
        [hostline setEnabled:enabled];
    }
}

- (HostStatus) status {
    unsigned int enabledCount = 0;
    for (FNHostLine *hostline in [self hostlines]) {
        if ([hostline enabled]) {
            enabledCount++;
        }
    }
    unsigned long totalCount = [[self hostlines] count];
    if (enabledCount == 0) {
        return HostDisabled;
    } else if (enabledCount < totalCount) {
        return HostPartial;
    } else {
        return HostEnabled;
    }
}


- (NSString *) shortDescription {
    NSString *result = [self name];
    if ([[self hostlines] count] > 0) {
        FNHostLine *line = [hostlines objectAtIndex:0];
        if ([[line hostnames] count] > 0) {
            result = [NSString stringWithFormat:@"%@ %@", [line ip], [[line hostnames] objectAtIndex:0]];
        } else {
            result = [line ip];
        }
    }
    return result;
}


/*
 * Returns an NSString formatted correctly for the /ect/hosts file.
 */
- (NSString *) description {
    NSMutableString *formatted = [[NSMutableString alloc] init];
    [formatted appendString:[self.comments componentsJoinedByString:@"\n"]];
    [formatted appendString:@"\n"];
    [formatted appendString:[self.hostlines componentsJoinedByString:@"\n"]];
    return [NSString stringWithString:formatted];
}


@end
