//
//  FNMeddoController.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNMenuController : NSObject

@property (nonatomic) NSMutableArray *_hosts;

- (id) initWithHosts:(NSMutableArray *)hosts;

@end
