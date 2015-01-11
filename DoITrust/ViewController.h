//
//  ViewController.h
//  DoITrust
//
//  Created by Sean Baker on 1/10/15.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *siteAddress;
@property (weak, nonatomic) IBOutlet UITextView *resultView;
@property (weak, nonatomic) IBOutlet UIButton *testButton;

- (IBAction)testSite:(id)sender;

@end

