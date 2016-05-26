//
//  ShareSDKCDV.h
//  imageshare
//
//  Created by Marlon Chan on 16/5/24.
//
//

#import <Cordova/CDV.h>

@interface ShareSDKCDV : CDVPlugin

-(void) dispatcher:(CDVInvokedUrlCommand *)command;
@end
