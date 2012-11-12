//
//  NSURLConnection+Blocks.m
//  
//
//  Created by Navi Singh on 11/11/12.
//
//

#import "NSURLConnection+Blocks.h"
#import <objc/runtime.h>

static char COMPLETION_BLOCK_IDENTIFIER;
static char ERROR_BLOCK_IDENTIFIER;
static char UPLOAD_BLOCK_IDENTIFIER;
static char DOWNLOAD_BLOCK_IDENTIFIER;

static char REQUEST_IDENTIFIER;
static char DATA_IDENTIFIER;
static char RESPONSE_IDENTIFIER;
static char DOWNLOAD_IDENTIFIER;


@interface NSURLConnection (BlockData)

@property (nonatomic, copy) NSURLConnectionCompletionBlock completionBlock;
@property (nonatomic, copy) NSURLConnectionErrorBlock errorBlock;
@property (nonatomic, copy) NSURLConnectionUploadProgressBlock uploadBlock;
@property (nonatomic, copy) NSURLConnectionDownloadProgressBlock downloadBlock;
@property (nonatomic, strong) NSURLRequest    *request;
@property (nonatomic, strong) NSMutableData   *data;
@property (nonatomic, strong) NSURLResponse   *response;
@property (nonatomic, strong) NSNumber        *downloadSize;
@end

@implementation NSURLConnection (BlockData)

@dynamic completionBlock;
- (void) setCompletionBlock:(NSURLConnectionCompletionBlock)completionBlock
{
    objc_setAssociatedObject(self, &COMPLETION_BLOCK_IDENTIFIER, completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSURLConnectionCompletionBlock)completionBlock
{
    return objc_getAssociatedObject(self, &COMPLETION_BLOCK_IDENTIFIER);
}

@dynamic errorBlock;
- (void) setErrorBlock:(NSURLConnectionErrorBlock)errorBlock
{
    objc_setAssociatedObject(self, &ERROR_BLOCK_IDENTIFIER, errorBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSURLConnectionErrorBlock)errorBlock
{
    return objc_getAssociatedObject(self, &ERROR_BLOCK_IDENTIFIER);
}

@dynamic uploadBlock;
- (void) setUploadBlock:(NSURLConnectionUploadProgressBlock)uploadBlock
{
    objc_setAssociatedObject(self, &UPLOAD_BLOCK_IDENTIFIER, uploadBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSURLConnectionUploadProgressBlock)uploadBlock
{
    return objc_getAssociatedObject(self, &UPLOAD_BLOCK_IDENTIFIER);
}

@dynamic downloadBlock;
- (void) setDownloadBlock:(NSURLConnectionDownloadProgressBlock)downloadBlock
{
    objc_setAssociatedObject(self, &DOWNLOAD_BLOCK_IDENTIFIER, downloadBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSURLConnectionDownloadProgressBlock)downloadBlock
{
    return objc_getAssociatedObject(self, &DOWNLOAD_BLOCK_IDENTIFIER);
}

@dynamic request;
- (void) setRequest:(NSURLRequest *)request
{
    objc_setAssociatedObject(self, &REQUEST_IDENTIFIER, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSURLRequest *)request
{
    return objc_getAssociatedObject(self, &REQUEST_IDENTIFIER);
}

@dynamic data;
- (void) setData:(NSMutableData *)data
{
    objc_setAssociatedObject(self, &DATA_IDENTIFIER, data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableData *)data
{
    return objc_getAssociatedObject(self, &DATA_IDENTIFIER);
}

@dynamic response;
- (void) setResponse:(NSURLResponse *)response
{
    objc_setAssociatedObject(self, &RESPONSE_IDENTIFIER, response, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSURLResponse *)response
{
    return objc_getAssociatedObject(self, &RESPONSE_IDENTIFIER);
}

@dynamic downloadSize;
- (void) setDownloadSize:(NSNumber *)downloadSize
{
    objc_setAssociatedObject(self, &DOWNLOAD_IDENTIFIER, downloadSize, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)downloadSize
{
    return objc_getAssociatedObject(self, &DOWNLOAD_IDENTIFIER);
}

@end

@implementation NSURLConnection (Blocks)

+ (NSURLConnection *)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(NSURLConnectionCompletionBlock)completionBlock
                        errorBlock:(NSURLConnectionErrorBlock)errorBlock
               uploadPorgressBlock:(NSURLConnectionUploadProgressBlock)uploadBlock
             downloadProgressBlock:(NSURLConnectionDownloadProgressBlock)downloadBlock
{
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                       completionBlock:completionBlock
                                                            errorBlock:errorBlock
                                                   uploadPorgressBlock:uploadBlock
                                                 downloadProgressBlock:downloadBlock];
    [connection start];
    return connection;
}

+ (NSURLConnection *)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(NSURLConnectionCompletionBlock)completionBlock
                        errorBlock:(NSURLConnectionErrorBlock)errorBlock
{
    return [NSURLConnection asyncConnectionWithRequest:request
                              completionBlock:completionBlock
                                   errorBlock:errorBlock
                          uploadPorgressBlock:nil
                        downloadProgressBlock:nil];
}

+ (NSURLConnection *)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(NSURLConnectionCompletionBlock)completionBlock
                          errorBlock:(NSURLConnectionErrorBlock)errorBlock
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    return [NSURLConnection asyncConnectionWithRequest:request
                              completionBlock:completionBlock
                                   errorBlock:errorBlock];
}

- (id)initWithRequest:(NSURLRequest *)_request
      completionBlock:(NSURLConnectionCompletionBlock)_completionBlock
           errorBlock:(NSURLConnectionErrorBlock)_errorBlock
  uploadPorgressBlock:(NSURLConnectionUploadProgressBlock)_uploadBlock
downloadProgressBlock:(NSURLConnectionDownloadProgressBlock)_downloadBlock {
    
    self = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (self) {
        self.request =           _request;
        self.data =              [[NSMutableData alloc] init];
        self.completionBlock =   [_completionBlock copy];
        self.errorBlock =        [_errorBlock copy];
        self.uploadBlock =       [_uploadBlock copy];
        self.downloadBlock =     [_downloadBlock copy];
    }
    return self;
}

#pragma mark NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
    if(self.completionBlock)
        self.completionBlock(self.data, self.response);
}

- (void)connection:(NSURLConnection *)_connection  didFailWithError:(NSError *)error
{
    if(self.errorBlock)
        self.errorBlock(error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)_response
{
    self.response = _response;
    self.downloadSize = [NSNumber numberWithLongLong:[_response expectedContentLength]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
    [self.data appendData:_data];
    
    if ([self.downloadSize longLongValue] != -1) {
        float progress = (float)self.data.length / (float)self.downloadSize.longLongValue;
        if(self.downloadBlock)
            self.downloadBlock(progress);
    }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    float progress= (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    if (self.uploadBlock)
        self.uploadBlock(progress);
}



@end
