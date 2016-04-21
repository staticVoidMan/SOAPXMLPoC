//
//  MainVC.m
//  SOAPXMLPoC
//
//  Created by staticVoidMan on 15/02/16.
//  Copyright © 2016 svmLogics. All rights reserved.
//

#import "MainVC.h"

#import "AFHTTPRequestOperation.h"
#import "XMLReader.h"
#import "ProgressHUD.h"

@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startSOAP];
}

-(void)startSOAP {
    [ProgressHUD show:@"Started" Interaction:NO];
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<CelsiusToFahrenheit xmlns=\"http://www.w3schools.com/xml/\">"
                             "<Celsius>37.0</Celsius>"
                             "</CelsiusToFahrenheit>"
                             "</soap:Body>"
                             "</soap:Envelope>"];
    
    NSData *soapData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.w3schools.com/xml/tempconvert.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    
    [theRequest addValue:@"www.w3schools.com" forHTTPHeaderField:@"Host"];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://www.w3schools.com/xml/CelsiusToFahrenheit" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:soapData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:theRequest];
    
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //parse NSXMLParser object here if request successfull
        if ([responseObject isKindOfClass:[NSXMLParser class]]) {
            NSXMLParser *parser = (NSXMLParser *)responseObject;
            NSError *error;
            NSDictionary *dict = [XMLReader dictionaryForNSXMLParser:parser error:&error];
            NSLog(@"JSON: %@ : %@", responseObject, dict);
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Error: %@", error);
                                     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

@end
