//
//  FNMeddoController.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNMenuController : NSObject

@property (nonatomic, retain) NSMutableArray *hosts;

- (id) initWithHosts:(NSMutableArray *)hosts;

@end
