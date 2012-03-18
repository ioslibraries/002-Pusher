//
//  ILChatViewController.h
//  PusherChat
//
//  Created by jeremy Templier on 05/03/12.
//  Copyright (c) 2012 particulier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusher.h"

@class PTPusher, PTPusherChannel;
@interface ILChatViewController : UIViewController <UITextFieldDelegate, PTPusherDelegate> {
    NSInteger lastMessageOrigin_x;
    BOOL editing;
}

@property (weak, nonatomic) IBOutlet UIToolbar *messageToolbar;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *messagesScrollView;
@property (strong, nonatomic) PTPusher *client;
@property (strong, nonatomic) PTPusherChannel *channel;

- (IBAction)sendButtonPressed:(id)sender;
- (void)sendMessage;
- (void)onMessage:(NSString*)message sendedBy:(NSString*)username;

@end
