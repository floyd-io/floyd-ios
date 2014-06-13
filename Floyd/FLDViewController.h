//
//  FLDViewController.h
//  Floyd
//
//  Created by Kado on 4/25/14.
//  Copyright (c) 2014 Kado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVChunkURLConnection.h"

@interface FLDViewController : UIViewController <NSStreamDelegate, SCVChunkURLConnectionDelegate, UITextFieldDelegate>

@property (nonatomic,strong) IBOutlet UILabel *titulo;
@property (nonatomic,strong) NSMutableData *receivedData;
@property (nonatomic,strong) IBOutlet UILabel* jsonSummary;
@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;
@property SCVChunkURLConnection *chunkConnection;




@end
