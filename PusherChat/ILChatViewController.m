//
//  ILChatViewController.m
//  PusherChat
//
//  Created by jeremy Templier on 05/03/12.
//  Copyright (c) 2012 particulier. All rights reserved.
//

#import "ILChatViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "JSONKit.h"
#import "PTPusherAPI.h"

#define MEN_NICKNAME @"jayztemplier"
#define WOMEN_NICKNAME @"severine"

#define MESSAGE_VIEW_HEIGHT 60


@implementation ILChatViewController
@synthesize messageToolbar;
@synthesize messageTextField;
@synthesize messagesScrollView;
@synthesize client, channel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    lastMessageOrigin_x = -MESSAGE_VIEW_HEIGHT;
    
    [self onMessage:@"Hey" sendedBy:MEN_NICKNAME];
    [self onMessage:@"Salut" sendedBy:WOMEN_NICKNAME];
    [self onMessage:@"Ca va ?" sendedBy:MEN_NICKNAME];
    [self onMessage:@"Oui et toi ?" sendedBy:WOMEN_NICKNAME];
    [self onMessage:@"Très bien :D" sendedBy:MEN_NICKNAME];
    [self onMessage:@"On fait quoi aujourd'hui ?" sendedBy:WOMEN_NICKNAME];
    [self onMessage:@"Balade en bord de mer? " sendedBy:MEN_NICKNAME];
    [self onMessage:@"C'est parti !" sendedBy:WOMEN_NICKNAME];
    
    self.client = [PTPusher pusherWithKey:PUSHER_KEY delegate:self encrypted:NO];
    self.client.authorizationURL = [NSURL URLWithString:@"http://www.yourserver.com/authorise"];

    self.channel = [client subscribeToChannelNamed:@"ioslibs"];
    
    [channel bindToEventNamed:@"chat" handleWithBlock:^(PTPusherEvent *event) {
        // do something with channel event
        NSDictionary* data = event.data;
        [self onMessage:[data objectForKey:@"message"] sendedBy:[data objectForKey:@"username"]];
    }];
}

- (void)viewDidUnload
{
    [self setMessageToolbar:nil];
    [self setMessageTextField:nil];
    [self setMessagesScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)adjustMessageScrollViewContentSize {
    if (lastMessageOrigin_x + MESSAGE_VIEW_HEIGHT > self.messagesScrollView.contentSize.height) {
        [self.messagesScrollView setContentSize:CGSizeMake(320, lastMessageOrigin_x + MESSAGE_VIEW_HEIGHT)];
    }
}

- (IBAction)sendButtonPressed:(id)sender {
    [self textFieldShouldReturn:self.messageTextField];
}


#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!editing) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.messageToolbar.frame;
            frame.origin = CGPointMake(0, frame.origin.y - 215);
            [self.messageToolbar setFrame:frame];
            
            CGRect messagesFrame = self.messagesScrollView.frame;
            messagesFrame.size = CGSizeMake(320, messagesFrame.size.height - 215);
            self.messagesScrollView.frame = messagesFrame;   
        } completion:^(BOOL finished) {
            [self.messagesScrollView scrollRectToVisible:CGRectMake(0, lastMessageOrigin_x, 320, MESSAGE_VIEW_HEIGHT) animated:YES];
            editing = YES;
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessage];
    if (editing) {
        [self.messageTextField resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.messageToolbar.frame;
            frame.origin = CGPointMake(0, frame.origin.y + 215);
            [self.messageToolbar setFrame:frame];
            
            CGRect messagesFrame = self.messagesScrollView.frame;
            messagesFrame.size = CGSizeMake(320, messagesFrame.size.height + 215);
            self.messagesScrollView.frame = messagesFrame;
        } completion:^(BOOL finished) {
            [self.messagesScrollView scrollRectToVisible:CGRectMake(0, lastMessageOrigin_x, 320, MESSAGE_VIEW_HEIGHT) animated:YES];
            editing = NO;
        }];
    }
    return YES;
}


#pragma mark - New Message Management

- (void)onMessage:(NSString*)message sendedBy:(NSString*)username {
    UILabel* usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 7.5, 310, 13)];
    usernameLabel.numberOfLines = 0;
    usernameLabel.backgroundColor = [UIColor clearColor];
    [usernameLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    usernameLabel.text = username;
    [usernameLabel adjustsFontSizeToFitWidth];
    
    UILabel* messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    messageLabel.numberOfLines = 0;
    messageLabel.backgroundColor = [UIColor clearColor];
    [messageLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    messageLabel.text = message;
    
    lastMessageOrigin_x += MESSAGE_VIEW_HEIGHT;
    
    UIView* messageView = [[UIView alloc] initWithFrame:CGRectMake(0, lastMessageOrigin_x , 320, MESSAGE_VIEW_HEIGHT)];
    if ([username isEqualToString:MEN_NICKNAME]) {
        messageView.backgroundColor = [UIColor colorWithRed:178 green:203 blue:205 alpha:1.0];
        [usernameLabel setTextAlignment:UITextAlignmentLeft];
    } else {
        messageView.backgroundColor = [UIColor colorWithRed:217 green:203 blue:205 alpha:1.0];
        [usernameLabel setTextAlignment:UITextAlignmentRight];
    }
    [messageView addSubview:usernameLabel];
    [messageView addSubview:messageLabel];
    
    [self.messagesScrollView addSubview:messageView];
    [self adjustMessageScrollViewContentSize];
    [messageView.layer setCornerRadius:10.0f];
    [messageView.layer setBorderWidth:1.0f];
    [messageView.layer setBorderColor:[[UIColor darkGrayColor] CGColor] ];
}


#pragma mark - Message Network
- (void)sendMessage {
    NSLog(@"Send Message");
    if (![self.messageTextField.text isEqualToString:@""]) {
        PTPusherAPI *api = [[PTPusherAPI alloc] initWithKey:PUSHER_KEY appID:PUSHER_APP_ID secretKey:PUSHER_SECRET];
        NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:self.messageTextField.text, @"message", MEN_NICKNAME,  @"username" ,nil];
        [api triggerEvent:@"chat" onChannel:@"ioslibs" data:payload socketID:nil];
        [self.messageTextField setText:@""];
        
    }
}



@end
