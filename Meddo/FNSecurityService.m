//
//  FNSecurityService.m
//  Meddo
//
//  Created by John Shimek on 9/14/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNSecurityService.h"
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

@interface FNSecurityService ()

- (void) installHelper;
- (void) uninstallHelper;
- (bool) isCurrentVersion;
- (NSInteger) getInstalledHelperVersion;
- (NSInteger) getCurrentHelperVersion;
- (NSInteger) getBundleVersion:(NSURL *)bundleUrl;

@end

@implementation FNSecurityService

+ (FNSecurityService *) sharedInstance {
    static FNSecurityService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FNSecurityService alloc] init];
    });
    return sharedInstance;
}

- (void) sendMessage:(NSString *)message {
    [self installHelper];
    NSLog(@"Message to send: %@", message);
}

- (void) installHelper {
    
    if ([self isCurrentVersion]) {
        return; // Bug out, we have the current version
    }
    
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
	AuthorizationFlags flags		=	kAuthorizationFlagDefaults				|
                                        kAuthorizationFlagInteractionAllowed	|
                                        kAuthorizationFlagPreAuthorize			|
                                        kAuthorizationFlagExtendRights;
    
	AuthorizationRef authRef = NULL;
    CFErrorRef error = NULL;
	
	OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
	if (status == errAuthorizationSuccess) {
		SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)kHelper, authRef, &error);
	} else {
        NSLog(@"Failed to authorize the helper");
	}
    
    if (error != NULL) {
        NSLog(@"Error installing the helper: %@", error);
    } else {
        NSLog(@"Helper has been installed");
    }
}

- (void) uninstallHelper {
    NSLog(@"Uninstalling helper");
    // TODO: Implement
}

/*
 * Returns whether the installed helper is the current version.
 */
- (bool) isCurrentVersion {
    NSInteger installedVersion = [self getInstalledHelperVersion];
    NSInteger currentVersion = [self getCurrentHelperVersion];
    bool isCurrent = installedVersion == currentVersion;
    NSLog(@"Helper is current: %d", isCurrent);
    return isCurrent;
}

/*
 * Returns the version of the installed helper.
 * If the helper is not installed, returns 0 (Version 0)
 */
- (NSInteger) getInstalledHelperVersion {
    NSDictionary *installedHelperData = (__bridge NSDictionary *)SMJobCopyDictionary(kSMDomainSystemLaunchd, (CFStringRef)kHelper);
    NSString *installedHelperPath = [[installedHelperData objectForKey:@"ProgramArguments"] objectAtIndex:0];
    NSURL *installedHelperUrl = [NSURL fileURLWithPath:installedHelperPath];
    NSInteger installedVersion = [self getBundleVersion:installedHelperUrl];

    NSLog(@"Installed helper version: %ld", installedVersion);
    return installedVersion;
}

/*
 * Returns the current version of the helper in the app bundle
 */
- (NSInteger) getCurrentHelperVersion {
    NSURL *currentHelperUrl = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:kHelperLocation];
    NSInteger currentVersion = [self getBundleVersion:currentHelperUrl];
    
    NSLog(@"Current helper version: %ld", currentVersion);
    return currentVersion;
}

- (NSInteger) getBundleVersion:(NSURL *)bundleUrl {
    NSDictionary *plist = (__bridge NSDictionary*)CFBundleCopyInfoDictionaryForURL( (__bridge CFURLRef)bundleUrl);
    NSString *bundleVersion = [plist objectForKey:@"CFBundleVersion"];
    NSInteger version = [bundleVersion integerValue];
    return version;
}




@end
