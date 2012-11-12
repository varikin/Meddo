//
//  FNHost.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNHostLine.h"

@interface FNHost : NSObject

typedef enum {
    HostEnabled,
    HostPartial,
    HostDisabled
} HostStatus;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) NSMutableArray *hostlines;

- (BOOL)isEmpty;
- (void)addComment:(NSString *)comment;
- (void)addHostline:(FNHostLine *)hostline;
- (void)setEnabled:(BOOL) enabled;
- (HostStatus)status;
- (NSString *)shortDescription;

@end
