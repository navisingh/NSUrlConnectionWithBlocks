//
//  NSURLConnection+Blocks.h
//  
//
//  Created by Navi Singh on 11/11/12.
//
//

#import <Foundation/Foundation.h>

typedef void (^NSURLConnectionCompletionBlock)        (NSData *data, NSURLResponse *response);
typedef void (^NSURLConnectionErrorBlock)              (NSError *error);
typedef void (^NSURLConnectionUploadProgressBlock)     (float progress);
typedef void (^NSURLConnectionDownloadProgressBlock)   (float progress);

@interface NSURLConnection (Blocks)

- (id)initWithRequest:(NSURLRequest *)request
      completionBlock:(NSURLConnectionCompletionBlock)completionBlock
           errorBlock:(NSURLConnectionErrorBlock)errorBlock
  uploadPorgressBlock:(NSURLConnectionUploadProgressBlock)uploadBlock
downloadProgressBlock:(NSURLConnectionDownloadProgressBlock)downloadBlock;

//The following messages also invoke start on the connection.
+ (NSURLConnection *)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(NSURLConnectionCompletionBlock)completionBlock
                        errorBlock:(NSURLConnectionErrorBlock)errorBlock
               uploadPorgressBlock:(NSURLConnectionUploadProgressBlock)uploadBlock
             downloadProgressBlock:(NSURLConnectionDownloadProgressBlock)downloadBlock;

+ (NSURLConnection *)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(NSURLConnectionCompletionBlock)completionBlock
                        errorBlock:(NSURLConnectionErrorBlock)errorBlock;

+ (NSURLConnection *)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(NSURLConnectionCompletionBlock)completionBlock
                          errorBlock:(NSURLConnectionErrorBlock)errorBlock;

@end
