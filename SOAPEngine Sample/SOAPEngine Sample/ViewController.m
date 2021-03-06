//
//  ViewController.m
//  SOAPEngine Sample
//
//  Created by Danilo Priore on 20/11/12.
//  Copyright (c) 2012 Prioregorup.com. All rights reserved.
//
#define ALERT(msg) {UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"SOAPEngine Sample" message:msg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];[alert show];}

#import "ViewController.h"
#import "MyObject.h"

@implementation ViewController

static UILabel *label;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    list = nil;
    
    soap = [[SOAPEngine alloc] init];
    soap.userAgent = @"SOAPEngine";
    soap.actionNamespaceSlash = YES;
    soap.delegate = self;
    
    // WFC basicHttpBinding
    //soap.actionNamespaceSlash = NO;
    //soap.version = VERSION_WCF_1_1;

    // extra envelope definitions
    //soap.envelope = @"xmlns:tmp=\"http://tempuri.org/\"";
    
    // autenthication
    //soap.authorizationMethod = SOAP_AUTH_BASIC;
    //soap.username = @"my-username";
    //soap.password = @"my-password";
    
    // parameters with user-defined objects
    /*
    MyObject *myObject = [[MyObject alloc] init];
    myObject.name = @"Dan";
    myObject.reminder = [[MyRemider alloc] init];
    myObject.reminder.date = [NSDate date];
    myObject.reminder.description = @"support email: support@prioregroup.com";
    [soap setValue:myObject forKey:nil]; // forKey must be nil value
    */

    // SOAP service (asmx)
    [soap setValue:@"Genesis" forKey:@"BookName"];
    [soap setIntegerValue:1 forKey:@"chapter"];
    [soap requestURL:@"http://www.prioregroup.com/services/americanbible.asmx"
          soapAction:@"http://www.prioregroup.com/GetVerses"];
    
    // SOAP WFC service (svc)
    //[soap requestURL:@"http://www.prioregorup.com/services/AmericanBible.svc"
    //      soapAction:@"http://www.prioregroup.com/IAmericanBible/GetVerses"];
    
}

#pragma mark - SOPAEngine delegates

- (void)soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:@"ERROR: %@", error.localizedDescription];
    ALERT(msg);
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    
    NSDictionary *result = [soapEngine dictionaryValue];
    list = [[NSMutableArray alloc] initWithArray:[result valueForKey:@"BibleBookChapterVerse"]];
    
    if (list.count > 0) {
        [self.tableView reloadData];
        
        label = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 320, 50}];
        label.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:label];
        [label setText:[[list firstObject] valueForKey:@"BookTitle"]];
    } else {
        
        NSLog(@"%@", stringXML);
        ALERT(@"No verses founded!");
        
    }
}

- (BOOL)soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(NSInteger)statusCode {

    // 200 is response Ok, 500 Server error
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    // for more response codes
    if (statusCode != 200 && statusCode != 500) {
        NSString *msg = [NSString stringWithFormat:@"ERROR: received status code %li", (long)statusCode];
        ALERT(msg);
        
        return NO;
    }
    
    return YES;
}

- (NSMutableURLRequest*)soapEngine:(SOAPEngine *)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest *)request {
    
    NSLog(@"%@", [request allHTTPHeaderFields]);

    NSString *xml = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    NSLog(@"%@", xml);
    
    return request;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"The Bible - Genesis";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row < list.count) {

        NSDictionary *data = [list objectAtIndex:indexPath.row];
        
        NSString *chapter_verse = [NSString stringWithFormat:@"Chapter %@ Verse %@", [data objectForKey:@"Chapter"], [data objectForKey:@"Verse"]];
        cell.textLabel.text = chapter_verse;
        
        cell.detailTextLabel.text = [data objectForKey:@"Text"];
    }
    
    return cell;
}

@end
