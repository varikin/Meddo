//
//  FNLaunchAtLoginController.m
//  Meddo
//
//  Created by John Shimek on 10/30/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNLaunchAtLoginController.h"

@interface FNLaunchAtLoginController ()

- (NSURL *)appUrl;
- (LSSharedFileListItemRef)findItemForApp:(LSSharedFileListRef)loginItems;

@end

@implementation FNLaunchAtLoginController

- (NSURL*) appUrl {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (LSSharedFileListItemRef)findItemForApp:(LSSharedFileListRef)loginItems {
    
    NSURL *appUrl = [self appUrl];
    
    // No user interaction and do not mount volumes during resolution
    UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;

    // Get the list of user login items and put into an array
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems, NULL);


    LSSharedFileListItemRef result = NULL;
    CFIndex count = CFArrayGetCount(loginItemsArray);
    CFIndex i = 0;
    while (i < count && result == NULL) {
        // Get the item for i, since it is just a "Get" we don't own so we don't release
        LSSharedFileListItemRef item = (LSSharedFileListItemRef) CFArrayGetValueAtIndex(loginItemsArray, i);
        
        // Get the URL to the current item
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
        
        // THE MAGICAL COMPARE!
        if (currentItemURL && CFEqual(currentItemURL, (__bridge CFTypeRef)(appUrl))) {
            result = item;
            CFRetain(result);
        }
        
        if (currentItemURL) {
            CFRelease(currentItemURL);
            currentItemURL = NULL;
        }

        i++;
    }
    
    if (loginItemsArray) {
        CFRelease(loginItemsArray);
        loginItemsArray = NULL;
    }
    return result;
}

#pragma mark Launch At Login property methods

- (void)setLaunchAtLogin:(BOOL)enabled {
    
    @synchronized(self) {        
        // Get login items and find app in list
        LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        LSSharedFileListItemRef appItem = [self findItemForApp:loginItems];
        
        if (enabled && !appItem) {
            // If we want to set it it enabled
            // and it isn't already in the list
            // then add it
            NSURL *appUrl = [self appUrl];
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, (__bridge CFURLRef)appUrl, NULL, NULL);
        } else if (!enabled && appItem) {
            // If we don't want to set launch at login
            // and it is in the list,
            // remove it
            LSSharedFileListItemRemove(loginItems, appItem);
        }
        if (loginItems) {
            CFRelease(loginItems);
            loginItems = NULL;
        }
        if (appItem) {
            CFRelease(appItem);
            appItem = NULL;
        }
    }
}

- (BOOL)launchAtLogin {
    // Get login items and find app in list
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    LSSharedFileListItemRef appItem = [self findItemForApp:loginItems];
    BOOL willLaunchAtLogin = appItem != NULL;
    if (loginItems) {
        CFRelease(loginItems);
        loginItems = NULL;
    }
    if (appItem) {
        CFRelease(appItem);
        appItem = NULL;
    }
    
    return willLaunchAtLogin;
}

@end

