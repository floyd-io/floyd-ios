//
//  FLDViewController.m
//  Floyd
//
//  Created by Kado on 4/25/14.
//  Copyright (c) 2014 Kado. All rights reserved.
//

#import "FLDViewController.h"
#import <Social/SLRequest.h>
#import "unirest-obj-c-master/Unirest/UNIRest.h"



@interface FLDViewController ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;



@end

@implementation FLDViewController

@synthesize responseData = _responseData;

// Usando Streams/Sockets
-(void) initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"127.0.0.1", 1337, &readStream, &writeStream);
    
    _inputStream = (__bridge NSInputStream *)(readStream);
    [_inputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    

    
    _outputStream = (__bridge NSOutputStream *)(writeStream);
    [_outputStream setDelegate:self];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream open];
    
    
    
    //http Protocol
    //NSString *response  =  @"GET /part2.html HTTP/1.1\nHost:127.0.0.1:1337 \n\n";
    NSString *response  =  @"GET /part2.html HTTP/1.1\nHost:127.0.0.1 \n\n";
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[_outputStream write:[data bytes] maxLength:[data length]];
    
}
// ~Usando Streams/Sockets

- (IBAction)connectAction:(id)sender {
    NSString *ipString = self.ipTextField.text;
    NSString *urlString = [NSString stringWithFormat:@"http://%@:1337/part2.html", ipString];
    
    NSLog(urlString);
    
    self.chunkConnection = [SCVChunkURLConnection new];
    self.chunkConnection.delegate = self;
    
    [self.chunkConnection openWithURL:[NSURL URLWithString:urlString]];
    
    [self.view endEditing:YES];
}

-(void)chunkURLConnection:(SCVChunkURLConnection *)connection didReceiveChunk:(NSData *)data{
    NSString *chunk = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     NSLog(@"received: %@", chunk );
    _jsonSummary.numberOfLines = 0;
    _jsonSummary.text = chunk ;
    
}

-(void)chunkURLConnectionDidFinish:(SCVChunkURLConnection *)connection{
    NSLog(@"finished");
    
}
-(void)chunkURLConnection:(SCVChunkURLConnection *)connection didFailWithError:(NSError *)error{
    
     NSLog(@"error: %@", error);
    
}




- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewdidload");
    
    

    //Usando NSURLConnection
    /*
    self.responseData = [NSMutableData data];
    //http://www.servlets.com/jservlet2/examples/ch06/servlet/Countdown
    //http://127.0.0.1:1337/part2.html
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:1337/part2.html"]
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:120.0];
    
    NSURLConnection *myConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
     */
    
    
    // Usando Streams/Sockets
    //[self initNetworkCommunication];
    
    //unirest
    /*
    NSDictionary* headers = @{@"accept": @"application/json"};
    NSDictionary* parameters = @{@"parameter": @"value", @"foo": @"bar"};
    UNIHTTPStringResponse* response = [[UNIRest get:^(UNISimpleRequest * request) {
        [request setUrl:@"http://127.0.0.1:1337/part2.html"];
    }] asString];
    */
    
    
    /*
    NSDictionary* headers = @{@"GET": @"/part2.html"};
    [[UNIRest post:^(UNISimpleRequest* request) {
        [request setUrl:@"http://127.0.0.1:1337/part2.html"];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse* response, NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        } else {
            
            // here you do all the stuff you want to do with the data you got.
            // like launch any code that actually deals with the data :)
            
            NSDictionary *currencyResult = [NSJSONSerialization JSONObjectWithData:[response rawBody] options: 0 error: &error];
            NSLog(@"%@", currencyResult);
        }
    }];
    */
    
    
    /*
    //Creating HTTP Reference message for the Reference URL
    CFStringRef bodyData = CFSTR(""); // Usually used for POST data
    CFStringRef headerFieldName = CFSTR("Connection");
    CFStringRef headerFieldValue = CFSTR("close");
    CFStringRef url = CFSTR("http://127.0.0.1:1337/part2.html");
    CFURLRef myURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
    CFStringRef requestMethod = CFSTR("GET");
    CFHTTPMessageRef myRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL, kCFHTTPVersion1_1);
    CFHTTPMessageSetBody(myRequest, bodyData);
    CFHTTPMessageSetHeaderFieldValue(myRequest, headerFieldName, headerFieldValue);
    // Creating Read Stream for the Refernce message URL
    CFReadStreamRef myReadStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, myRequest);
    // CFDateRef serializedRequest = CFHTTPMessageCopySerializedMessage(myURL);
    //Open the Socket
    CFReadStreamOpen(myReadStream);
    
    //Getting the Response
    CFDataRef data = CFHTTPMessageCopyBody(myRequest);
    if (CFHTTPMessageIsHeaderComplete(data)) {
        
    // Perform processing.

        NSString *messageString = [NSString stringWithCString:CFDataGetBytePtr(data)];
     
        NSLog(messageString);
    }
    */
    
    
    /*
    CFStringRef bodyString = CFSTR(""); // Usually used for POST data
    CFDataRef bodyData = CFStringCreateExternalRepresentation(kCFAllocatorDefault,
                                                              bodyString, kCFStringEncodingUTF8, 0);
    
    
    CFStringRef headerFieldName = CFSTR("X-My-Favorite-Field");
    CFStringRef headerFieldValue = CFSTR("Dreams");
    
    CFStringRef url = CFSTR("http://127.0.0.1:1337/part2.html");
    CFURLRef myURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
    
    CFStringRef requestMethod = CFSTR("GET");
    CFHTTPMessageRef myRequest =
    CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, myURL,
                               kCFHTTPVersion1_1);
    
    //CFDataRef bodyDataExt = CFStringCreateExternalRepresentation(kCFAllocatorDefault, bodyData, kCFStringEncodingUTF8, 0);
    //CFHTTPMessageSetBody(myRequest, bodyDataExt);
    CFHTTPMessageSetHeaderFieldValue(myRequest, headerFieldName, headerFieldValue);
    CFDataRef mySerializedRequest = CFHTTPMessageCopySerializedMessage(myRequest);
   */
    
    
    
    
    
   // NSLog(response);
}


// Usando NSURLConnection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    /*
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&myError];
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted error:&myError];
    
    _jsonSummary.numberOfLines = 0;
    _jsonSummary.text = [[NSString alloc] initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];
    */
    [self.responseData appendData:data];
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    if (!error) {
        NSLog(@"recibí json: %@", dictionary);
        
    }else{
        NSLog(@"received: %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding ]);
    }
    //[self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    /*
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&myError];
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary 
                                                       options:NSJSONWritingPrettyPrinted error:&myError];
    
    _jsonSummary.numberOfLines = 0;
    _jsonSummary.text = [[NSString alloc] initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];
     */
}


// ~Usando NSURLConnection


// Usando Streams/Sockets
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent{
    
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            if (aStream == _inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            //NSLog(@"server said: %@", output);
                            _jsonSummary.numberOfLines = 0;
                            _jsonSummary.text = output;
                        }
                    }
                }
            }

			break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Has Space Available");
            break;
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            NSLog(@"Event End Encountered");
			break;
            
		default:
			NSLog(@"Unknown event");
    }
}
//~ Usando Streams/Sockets

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
