//
//  FNHostsController.m
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNHostsService.h"

@interface FNHostsService()

typedef enum {
    comment,
    hostline,
    blank
} LineType;

- (NSArray *) tokenize:(NSString *)line;
- (FNHostLine *) parseHostLine:(NSArray *)tokens;
- (BOOL) isIPAddress:(NSString *)string;
- (LineType) getLineType:(NSArray *)tokens;
- (FNHost *) addHost:(FNHost *)host;

@end

@implementation FNHostsService

@synthesize hosts;

#pragma mark -
+ (FNHostsService *) sharedInstance {
    static FNHostsService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FNHostsService alloc] init];
    });
    return sharedInstance;
}


- (void) write {
    // TODO: Implement!
}

#pragma mark - Parse methods

- (void) read {
    NSError *error;
    NSString *allTheLines = [NSString stringWithContentsOfFile:kHostFile
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if (error != nil) {
        NSLog(@"Some freaking error: %@", error);
        return;
    }

    NSArray *lines = [allTheLines componentsSeparatedByCharactersInSet:
                      [NSCharacterSet newlineCharacterSet]];
    
    
    [self setHosts:[NSMutableArray arrayWithCapacity:[lines count]]];
    FNHost *host = [[FNHost alloc] init];
    LineType lastType = blank;
    LineType currentType;
    
    for (NSString *line in lines) {
        NSArray *tokens = [self tokenize:line];
        currentType = [self getLineType:tokens];
        switch (currentType) {
            case blank:
                host = [self addHost:host];
                break;
            case comment:
                if (lastType == hostline) {
                    host = [self addHost:host];
                }
                [host addComment:line];
                break;
            case hostline:
                [host addHostline:[self parseHostLine:tokens]];
        }
        
    }
    [self addHost:host];
}

- (NSArray *) tokenize:(NSString *)line {
    // Trimming
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Bug out early!
    if ([line length] == 0) {
        return nil;
    }
    
    // Splitting into tokens
    NSArray *tokens = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Removing any empty tokesn
    tokens = [tokens filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.length > 0"]];
    
    // Should NEVER happen since there was something in the line, but why take chances
    if ([tokens count] == 0) {
        return nil;
    }
    
    // Separate first token into two if it starts with a octothrope
    NSString *first = [tokens objectAtIndex:0];
    if ([first length] > 1 && [first characterAtIndex:0] == '#') {
        // Create the new first and second tokens
        NSString *second = [first substringFromIndex:1];
        first = @"#";
        
        // Create a new array for said tokens
        NSMutableArray *validTokens = [NSMutableArray arrayWithCapacity:[tokens count] + 1];
        [validTokens addObject:first];
        [validTokens addObject:second];
        
        // Slice the first token off the original array
        NSRange range = NSMakeRange(1, [tokens count] - 1);
        [validTokens addObjectsFromArray:[tokens subarrayWithRange:range]];
        
        // Remake the array
        tokens = [NSArray arrayWithArray:validTokens];
    }
    
    return tokens;
}

- (FNHostLine *) parseHostLine:(NSArray *)tokens {
    return nil;
}

#pragma mark - Helper methods

- (BOOL) isIPAddress:(NSString *)string {
    
    // Using the awesome ARPANET!
    // Some BSD library that needs cStrings
    const char *cString = [string UTF8String];
    int success;
    
    // Check for ipv4 address
    struct in_addr ipv4;
    success = inet_pton(AF_INET, cString, &ipv4);
    
    // Check for ipv6 address
    if (success != 1) {
        struct in6_addr ipv6;
        success = inet_pton(AF_INET6, cString, &ipv6);
    }
    
    return success == 1;
}

// Helper to check the 
- (LineType) getLineType:(NSArray *)tokens {
    if ([tokens count] == 0) {
        return blank;
    }
    
    NSString *first = [tokens objectAtIndex:0];
    if ([self isIPAddress:first]) {
        return hostline;
    }
    
    // The complicated one, either a comment or disabled hostline
    if ([first characterAtIndex:0] == '#') {
        if ([tokens count] > 1) {
            NSString *second = [tokens objectAtIndex:1];
            if ([self isIPAddress:second]) {
                return hostline;
            }
        }
        return comment; 
    }
    
    // WTF is this?! Not a comment, not a host line
    // Lets ignore it as a blank line
    return blank;
}

// Helper to add the host to the list if not empty
// Returns a new (or current empty) host
- (FNHost *) addHost:(FNHost *)host {
    if (![host isEmpty]) {
        [self.hosts addObject:host];
        host = [[FNHost alloc] init];
    }
    return host;
    
}

@end
