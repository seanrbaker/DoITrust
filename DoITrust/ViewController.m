//
//  ViewController.m
//  DoITrust
//
//  Created by Sean Baker on 1/10/15.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()
@end

@implementation ViewController

@synthesize siteAddress, resultView, testButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    testButton.layer.borderWidth=1.0f;
    testButton.layer.borderColor=[[UIColor blackColor] CGColor];
    testButton.layer.cornerRadius = 5;
    testButton.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testSite:(id)sender {
    [self doTestCertificate];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doTestCertificate];
    return YES;
}

- (void)doTestCertificate {
    [resultView setText: [[@"Testing \"" stringByAppendingString: [siteAddress text]] stringByAppendingString: @"\"..."]];
    
    NSURL * siteURL = [NSURL URLWithString:[siteAddress text]];
    
    if(!(nil != siteURL)) {
        NSLog(@"URL was nil");
        return;
    }
    
    NSURLRequest * siteRequest = [NSURLRequest requestWithURL:siteURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f];
    
    if(!(nil != siteRequest)) {
        NSLog(@"Request was nil");
        return;
    }
    
    NSURLConnection * siteConnection = [[NSURLConnection alloc] initWithRequest:siteRequest delegate:self];
    
    if(!(nil != siteConnection)) {
        NSLog(@"Connect was nil");
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Received the response.  W00t.
    NSLog(@"Received response.");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Received data.  W00t.
    NSLog(@"Received data.");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //Oops.
    
    if ([error code] == -1012)
    {
        // This is expected since we're aborting the connection.  Could be something else, but not worth exploring here.
        return;
    }
    NSLog(@"Connection failed.  Error: %ld.", (long)[error code]);
    [resultView setText:[[@"There was a problem reaching \"" stringByAppendingString: [siteAddress text]] stringByAppendingString: @"\".  Please check the URL and try again."]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Yay
    NSLog(@"Connection finished loading.");
}

- (BOOL)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (![[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // Something strange.
        // In the neighborhood.
        NSLog(@"Server is doing something weird.  Aborting connection attempt.");
        return NO;
    }
    
    SecTrustRef trust = [[challenge protectionSpace] serverTrust];
    
    if (nil == trust) {
        NSLog(@"Trust was nil.  Aborting.");
        return NO;
    }
    
    SecTrustResultType trustResult = -1;
    
    OSStatus status = SecTrustEvaluate(trust, &trustResult);
    
    if (status != errSecSuccess) {
        NSLog(@"Error in STE.");
        return NO;
    }
    
    NSString * resultString;
    
    long certCount = SecTrustGetCertificateCount(trust);
    
    SecCertificateRef trustCert = SecTrustGetCertificateAtIndex(trust, (CFIndex) certCount - 1);
    
    NSString * serverName = (__bridge NSString *)SecCertificateCopySubjectSummary(trustCert);
    
    CFDataRef certData = SecCertificateCopyData(trustCert);
    
    NSString * rootLength = [NSString stringWithFormat: @"\n\nThe root has %ld bytes, and I was able to pull it from the trust object.", CFDataGetLength(certData)];
    
    NSString * shaHash = [[@"\n\nThe root certificate's SHA-1 hash is: " stringByAppendingString:[self sha1:(__bridge NSData *)certData] ] stringByAppendingString: @"."];
    
    UIColor *newBGColor;
    
    switch (trustResult) {
        case kSecTrustResultUnspecified:{
            resultString = [[[[@"The root certificate \"" stringByAppendingString: serverName ] stringByAppendingString:@"\" enables this device to trust the certificates offered by "] stringByAppendingString: [siteAddress text]] stringByAppendingString:@"."];
            newBGColor = [UIColor greenColor];
            break;
        }
        default:
        {
            resultString = [[[[@"This device cannot trust the server " stringByAppendingString:[siteAddress text]] stringByAppendingString:@", which needs the root certificate \""] stringByAppendingString: serverName] stringByAppendingString:@"\" in order to be trusted."];
            newBGColor = [UIColor redColor];
            break;
        }
    }
    
    [siteAddress setBackgroundColor:newBGColor];
    [resultView setText:[[resultString stringByAppendingString:rootLength] stringByAppendingString: shaHash]];
    
    // Shut it down -- we don't actually want to have a conversation.
    [[challenge sender] cancelAuthenticationChallenge:challenge];
    
    CFRelease(certData);
    return NO;
}

- (NSString*)sha1:(NSData*)certData {
    unsigned char sha1Buffer[CC_SHA1_DIGEST_LENGTH]; 
    CC_SHA1(certData.bytes, certData.length, sha1Buffer); 
    NSMutableString *fingerprint = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 3]; 
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; ++i) 
        [fingerprint appendFormat:@"%02x ",sha1Buffer[i]]; 
    return [fingerprint stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; 
}
@end
