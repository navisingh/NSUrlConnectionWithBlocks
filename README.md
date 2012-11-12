NSUrlConnectionWithBlocks
=========================
Is a simple category for NSUrlConnection to add blocks for implementing asyncConnectionWithRequest.

Forget about dealing with the delegate methods:

- (void)connectionDidFinishLoading:(NSURLConnection *)
- (void)connection:(NSURLConnection *)_connection  didFailWithError:(NSError *)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)
- (void)connection:(NSURLConnection *)connection
             didSendBodyData:(NSInteger)bytesWritten
           totalBytesWritten:(NSInteger)totalBytesWritten
   totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite

Instead, use blocks for a cleaner implementation.  
All you need is to create a NSURLConnection object as follows:

NSUrlConnection *connection = [NSUrlConnection initWithRequest:(NSURLRequest *)request
      completionBlock:completionBlock
           errorBlock:errorBlock
  uploadPorgressBlock:uploadBlock
downloadProgressBlock:downloadBlock];

Provide your blocks, and call
[connection start];

The following class methods make it even easier. You don't even need to call start.

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
 