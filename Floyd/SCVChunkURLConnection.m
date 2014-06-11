//
//  SCVChunkURLConnection.m
//  Chunk
//
//  Created by Emanuel Andrada on 06/05/14.
//  Copyright (c) 2014 SCV Soft. All rights reserved.
//

#import "SCVChunkURLConnection.h"

#define BUFFER_SIZE 1024
#define UNSUPPORTED @"NotSupported"

@interface SCVChunkURLConnection() <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, assign) BOOL responseRead;

@end

@implementation SCVChunkURLConnection

- (BOOL)openWithURL:(NSURL *)url
{
    return [self openWithURLRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:1]];
}

- (BOOL)openWithURLRequest:(NSURLRequest *)urlRequest
{
    return [self openWithURLRequest:urlRequest runLoop:[NSRunLoop currentRunLoop] mode:NSRunLoopCommonModes];
}

- (BOOL)openWithURLRequest:(NSURLRequest *)urlRequest runLoop:(NSRunLoop *)runLoop mode:(NSString *)mode
{
    if (self.inputStream) {
        return NO;
    }
    // Create Stream
    self.inputStream = [self createReadStreamWithURLRequest:urlRequest];
    if (self.inputStream.streamError) {
        [self performSelector:@selector(didFailWithError:) withObject:self.inputStream.streamError afterDelay:0.];
        return YES;
    }
    self.inputStream.delegate = self;
    // Schedule Stream
    [self.inputStream scheduleInRunLoop:runLoop forMode:mode];
    [self.inputStream open];
    return self.inputStream != nil;
}

- (void)close
{
    if (self.inputStream) {
        [self inputStreamDidEnd:self.inputStream];
    }
}

- (void)dealloc
{
    [self close];
}

#pragma mark - CoreFoundation conversions

- (NSInputStream *)createReadStreamWithURLRequest:(NSURLRequest *)urlRequest
{
    CFHTTPMessageRef request =
    CFHTTPMessageCreateRequest(kCFAllocatorDefault, (__bridge CFStringRef)urlRequest.HTTPMethod, (__bridge CFURLRef)(urlRequest.URL), kCFHTTPVersion1_1);
    // Add headers
    NSDictionary *headers = [urlRequest allHTTPHeaderFields];
    for (NSString *header in headers) {
        CFHTTPMessageSetHeaderFieldValue(request, (__bridge CFStringRef)header, (__bridge CFStringRef)headers[header]);
    }
    // Create request based on body type
    CFReadStreamRef readStream;
    if (urlRequest.HTTPBodyStream) {
        readStream = CFReadStreamCreateForStreamedHTTPRequest(kCFAllocatorDefault, request, (__bridge CFReadStreamRef)(urlRequest.HTTPBodyStream));
    }
    else {
        if (urlRequest.HTTPBody) {
            CFHTTPMessageSetBody(request, (__bridge CFDataRef)(urlRequest.HTTPBody));
        }
        readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, request);
    }
    CFRelease(request);
    if (urlRequest.URL) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyHTTPAttemptPersistentConnection, kCFBooleanTrue);
        CFReadStreamSetProperty(readStream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);
    }
    return CFBridgingRelease(readStream);
}

- (NSHTTPURLResponse *)httpResponseWithMessageRef:(CFHTTPMessageRef)message
{
    NSURL *url = CFBridgingRelease(CFHTTPMessageCopyRequestURL(message));
    NSInteger statusCode = CFHTTPMessageGetResponseStatusCode(message);
    NSString *httpVersion = CFBridgingRelease(CFHTTPMessageCopyVersion(message));
    NSDictionary *headerFields = CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(message));
    return [[NSHTTPURLResponse alloc] initWithURL:url
                                       statusCode:statusCode
                                      HTTPVersion:httpVersion
                                     headerFields:headerFields];
}

#pragma mark - InputStream Delegate

- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            [self inputStreamDidOpen:stream];
            break;
        case NSStreamEventHasBytesAvailable:
            [self inputStreamHasBytesAvailable:stream];
            break;
        case NSStreamEventErrorOccurred:
            [self inputStreamDidFail:stream];
            break;
        case NSStreamEventEndEncountered:
            [self inputStreamDidEnd:stream];
            break;
        default:
            break;
    }
}

- (void)inputStreamDidOpen:(NSInputStream *)stream
{
    self.responseRead = NO;
}

- (void)inputStreamHasBytesAvailable:(NSInputStream *)stream
{
    if (!self.responseRead) {
        CFHTTPMessageRef response = (CFHTTPMessageRef)CFReadStreamCopyProperty((__bridge CFReadStreamRef)stream, kCFStreamPropertyHTTPResponseHeader);
        // Check response
        if ([self.delegate respondsToSelector:@selector(chunkURLConnection:didReceiveResponse:)]) {
            if (![self.delegate chunkURLConnection:self didReceiveResponse:[self httpResponseWithMessageRef:response]]) {
                [self close];
                return;
            }
        }
        CFRelease(response);
        self.responseRead = YES;
    }
    // Read data
    CFIndex numBytesRead = 0;
    UInt8 *buffer = NULL;
    while ([stream hasBytesAvailable]) {
        buffer = realloc(buffer, numBytesRead + BUFFER_SIZE);
        numBytesRead += [stream read:buffer + numBytesRead maxLength:BUFFER_SIZE];
    }
    if (numBytesRead) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesRead freeWhenDone:YES];
        [self performSelectorOnMainThread:@selector(didReceiveChunk:) withObject:data waitUntilDone:YES];
    }
    else if (buffer) {
        free(buffer);
    }
}

- (void)inputStreamDidEnd:(NSInputStream *)stream
{
    [self performSelectorOnMainThread:@selector(didFinish) withObject:nil waitUntilDone:YES];
    [stream close];
    self.inputStream = nil;
}

- (void)inputStreamDidFail:(NSInputStream *)stream
{
    [self performSelectorOnMainThread:@selector(didFailWithError:) withObject:stream.streamError waitUntilDone:YES];
    [stream close];
    self.inputStream = nil;
}

#pragma mark - Delegate

- (void)didReceiveChunk:(NSData *)data
{
    [self.delegate chunkURLConnection:self didReceiveChunk:data];
}

- (void)didFinish
{
    [self.delegate chunkURLConnectionDidFinish:self];
}

- (void)didFailWithError:(NSError *)error
{
    [self.delegate chunkURLConnection:self didFailWithError:error];
}

@end
