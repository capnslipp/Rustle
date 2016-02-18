// Rustle
// @author: Slipp Douglas Thompson

#import <UIKit/UIKit.h>



@interface TitleViewController : UIViewController <UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property(retain, nonatomic) IBOutlet UIButton *twitterLoginButton;

@property(copy, nonatomic) NSString *twitterPopoverSequeID;
@property(copy, nonatomic) NSString *twitterPopoverTableCellReuseID;

- (IBAction)openTwitterLogin:(id)sender;

@end
