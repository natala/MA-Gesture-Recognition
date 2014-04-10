/*
MainViewController.m
 Interactex Designer
 
 Created by Juan Haladjian on 06/08/2013.
 
 Interactex Designer is a configuration tool to easily setup, simulate and connect e-Textile hardware with smartphone functionality. Interactex Client is an app to store and replay projects made with Interactex Designer.
 
 www.interactex.org
 
 Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
 
 Contacts:
 juan.haladjian@cs.tum.edu
 katharina.bredies@udk-berlin.de
 opensource@telekom.de
 
 
 The first version of the software was designed and implemented as part of "Wearable M2M", a joint project of UdK Berlin and TU Munich, which was founded by Telekom Innovation Laboratories Berlin. It has been extended with funding from EIT ICT, as part of the activity "Connected Textiles".
 
 Interactex is built using the Tango framework developed by TU Munich.
 
 In the Interactex software, we use the GHUnit (a test framework for iOS developed by Gabriel Handford) and cocos2D libraries (a framework for building 2D games and graphical applications developed by Zynga Inc.).
 www.cocos2d-iphone.org
 github.com/gabriel/gh-unit
 
 Interactex also implements the Firmata protocol. Its software serial library is based on the original Arduino Firmata library.
 www.firmata.org
 
 All hardware part graphics in Interactex Designer are reproduced with kind permission from Fritzing. Fritzing is an open-source hardware initiative to support designers, artists, researchers and hobbyists to work creatively with interactive electronics.
 www.frizting.org
 
 
 This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "MainViewController.h"
#import "NZGraphViewHelper.h"
#import "NZConstants.h"

@implementation MainViewController{

    BOOL isPaused;
}

@synthesize accelerometerView, accelerometerData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //CGRect frame = CGRectMake(kGraphViewPosition.origin.x, kGraphViewPosition.origin.y, kGraphViewPosition.size.width, kGraphViewPosition.size.height);
    //[accelerometerView lateInitWithFrame:frame maxAxisY:kMaxAxisY minAxisY:kMinAxisY];
    isPaused = NO;
	// Do any additional setup after loading the view.
    self.accelerometerData = [[SensorData alloc] initWithValueHeadersX:'x' Y:'y' Z:'z'];
    [BLEDiscovery sharedInstance].peripheralDelegate = self;
    [BLEDiscovery sharedInstance].discoveryDelegate = self;
    [[BLEDiscovery sharedInstance] startScanningForSupportedUUIDs];

    accelerometerView = [[NZGraphView alloc] initWithFrame:kGraphViewPosition maxAxisY:kMaxAxisY minAxisY:kMinAxisY];
	[accelerometerView setIsAccessibilityElement:YES];
	[accelerometerView setAccessibilityLabel:NSLocalizedString(@"unfliteredGraph", @"")];
    [self.view addSubview:accelerometerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) sendTapped:(id)sender {
    uint8_t buf[16];
    for (int i = 0; i < 15; i++) {
        buf[i] = (uint8_t)65+i;
        
    }
    buf[15] = '\n';
    
    BLEService * service = [BLEDiscovery sharedInstance].connectedService;
    if(!service){
        NSLog(@"no service!");
    }
    [service writeToTx:[NSData dataWithBytes:buf length:1]];
}

- (IBAction)recordTapped:(id)sender {

    UIButton *button;
    if ( [sender isKindOfClass: [UIButton class] ] ) {
        button = (UIButton *)sender;
    }

    if ( isPaused && button )
	{
		// If we're paused, then resume and set the title to "Pause"
        isPaused = NO;
        [button setTitle: kLocalizedPause  forState:UIControlStateNormal];
	}
	else if( button )
	{
		// If we are not paused, then pause and set the title to "Resume"
		isPaused = YES;
		[button setTitle: kLocalizedResume  forState:UIControlStateNormal];
	}
	
	// Inform accessibility clients that the pause/resume button has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

-(void) updateConnectedLabel{
    if([BLEDiscovery sharedInstance].connectedService){
        self.connectedLabel.text = @"CONNECTED";
    } else {
        self.connectedLabel.text = @"NOT CONNECTED";
    }
}
/*
-(int16_t) readAccelerometerValueFrom:(uint8_t *)buffer atIndex:(NSInteger)index andBufferLength:(NSInteger) length{
    
    if( index+4 >= length )
        return nil;
    uint8_t valuePart[4];
    int16_t value;
    for (int k = 0; k < 4; k++) {
        valuePart[k] = buffer[index+k];
        NSLog(@"%d", valuePart[k]);
    }
    value = (int16_t)((uint16_t)valuePart[0]) | ((uint16_t)valuePart[1] << 8);
    NSLog(@"value: %d", value);
    return (int)(value);
}*/

#pragma mark BleServiceDataDelegate

-(void) didReceiveData:(uint8_t *)buffer lenght:(NSInteger)length{

/*    for (int i = 0; i < length; i++) {
        NSLog(@"buffer[%d]: %d",i, buffer[i]);
    }
*/
    bool readPackage = true;
    // TODO move this to one method of the SensorData class
    if( [self.accelerometerData.x setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading X data!");
    } else readPackage = false;
    if( [self.accelerometerData.y setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading Y data!");
    } else readPackage = false;
    if( [self.accelerometerData.z setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading Z data!");
    } else readPackage = false;
   
    if (readPackage) {
        [self updateSensorDataText];
        // Update the accelerometer graph view
        if (!isPaused)
        {
            [accelerometerView addData:accelerometerData];
        }
    }

    
  /*  int16_t accData[3];
    //NSMutableArray *accelerometerData = [NSMutableArray arrayWithObjects:0,0,0, nil]; // the received accelerometer data
    NSString * text = @"";
        for (int i = 0 ; i < length ; i++) {
            uint8_t val = buffer[i];
            
            if((val == a) && (i+12 < length)){    // start reading accelerometer data
                NSLog(@"start");
                    i++;
                    accData[0] = [self readAccelerometerValueFrom:buffer atIndex:i andBufferLength:length];
                    i = i+4;
                    accData[1] = [self readAccelerometerValueFrom:buffer atIndex:i andBufferLength:length];
                    i = i+4;
                    accData[2] = [self readAccelerometerValueFrom:buffer atIndex:i andBufferLength:length];
                    i = i+4;
                    if( accData[0] && accData[1] && accData[2]);
                
                //val = buffer[i];
               // if( val == 'z' ){
                    NSLog(@"end of data");
                    text = [text stringByAppendingFormat:@"ax: %d \n ay: %d \n az: %d ",accData[0],accData[1],accData[2]];
               // }
             
   */
        // NSLog(@"uint16 %d", value);
           // NSLog(@"int16 %d", (int16_t)value);
           /* NSString *strTmp = @"";
            NSMutableString *str = [strTmp mutableCopy];
            for(NSInteger numberCopy = value; numberCopy > 0; numberCopy >>= 1)
            {
                // Prepend "0" or "1", depending on the bit
                [str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];
            }
            NSLog(@"in binary %@", str);
            */
                
            
           
           // }
      //  }
    
   // NSLog(@"**********");
    
    //NSLog(@"%@",text);
    //self.receivedLabel.text = text;
}

-(void)updateSensorDataText{
    self.receivedLabel.text = [[NSString alloc] initWithFormat:@"ax: %ld, ay: %ld, az: %ld", self.accelerometerData.x.value, self.accelerometerData.y.value, self.accelerometerData.z.value ];
}


#pragma mark BleDiscoveryDelegate

- (void) discoveryDidRefresh {
}

- (void) peripheralDiscovered:(CBPeripheral*) peripheral {
//    [BLEDiscovery sharedInstance].supportedServiceUUIDs
    if([BLEDiscovery sharedInstance].connectedService == nil){
        [[BLEDiscovery sharedInstance] connectPeripheral:peripheral];
    }
}

- (void) discoveryStatePoweredOff {
}

#pragma mark BleServiceProtocol

-(void) bleServiceDidConnect:(BLEService *)service{
    service.delegate = self;
    service.dataDelegate = self;
    [self updateConnectedLabel];
}

-(void) bleServiceDidDisconnect:(BLEService *)service{
    [self updateConnectedLabel];
}

-(void) bleServiceIsReady:(BLEService *)service{
    
}

-(void) bleServiceDidReset {
}

-(void) reportMessage:(NSString*) message{
}

@end
