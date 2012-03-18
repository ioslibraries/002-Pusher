//
//  ILAppDelegate.h
//  PusherChat
//
//  Created by jeremy Templier on 05/03/12.
//  Copyright (c) 2012 particulier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ILChatViewController;
@interface ILAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ILChatViewController *viewController;
@end
