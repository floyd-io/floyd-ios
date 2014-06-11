//
//  SCVChunkURLConnection.h
//  Chunk
//
//  Created by Emanuel Andrada on 06/05/14.
//  Copyright (c) 2014 SCV Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCVChunkURLConnection;

@protocol SCVChunkURLConnectionDelegate <NSObject>

@optional
- (BOOL)chunkURLConnection:(SCVChunkURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response;

@required
- (void)chunkURLConnection:(SCVChunkURLConnection *)connection didReceiveChunk:(NSData *)data;
- (void)chunkURLConnectionDidFinish:(SCVChunkURLConnection *)connection;
- (void)chunkURLConnection:(SCVChunkURLConnection *)connection didFailWithError:(NSError *)error;

@end

@interface SCVChunkURLConnection : NSObject

@property (nonatomic, weak) id<SCVChunkURLConnectionDelegate> delegate;

- (BOOL)openWithURL:(NSURL *)url;
- (BOOL)openWithURLRequest:(NSURLRequest *)urlRequest;
- (BOOL)openWithURLRequest:(NSURLRequest *)urlRequest runLoop:(NSRunLoop *)runLoop mode:(NSString *)mode;

- (void)close;

@end
