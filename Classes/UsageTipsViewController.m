//
//  UsageTipsViewController.m
//  Curbside
//
//  Created by Greg Walker on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UsageTipsViewController.h"
#import "Constants.h"


@implementation UsageTipsViewController

@synthesize usageWebView;

#pragma mark - Methods

-(id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
    return [self init];
}

-(id) init {
    self = [super initWithNibName: @"UsageTipsView" bundle: nil];
    if (self) {
        // Custom initialization.
        self.title = @"Usage Tips";
    }
    return self;
}

- (void)dealloc {
    self.usageWebView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    //TODO:
}

#pragma mark UIViewController Methods

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
-(void) loadView {
    [super viewDidLoad];     
}
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void) viewDidLoad {
    [super viewDidLoad];
    
    // Resize the view if it is being shown in an iPhone 5.
    if (IS_IPHONE5) {
        self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height + AdditionalVerticalSpace);
    }
    
    // Set the background image.
    self.usageWebView.backgroundColor = [UIColor clearColor];
    
    // Load the usage tips HTML page into the WebView.
    NSString *urlAddress = [[NSBundle mainBundle] pathForResource: rsrcUsageTipsHtml ofType: @"html"];
    NSURL *url = [NSURL fileURLWithPath: urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    [self.usageWebView loadRequest: request];
}

-(void) viewDidDisappear: (BOOL)animated {
    [super viewDidDisappear: animated];
    
    // Scroll to top using a hook to execute javascript in the document.
    NSString *jScript = @"scrollTo(0, 0)";
    [usageWebView stringByEvaluatingJavaScriptFromString: jScript];
}

-(void) viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //TODO:
}

@end

