//
//  Tracker.m
//  Buto
//
//
// LICENSE
// ================================================================================
// Buto iOS SDK Copyright (C) 2010 Big Button Media Limited.
// 
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
//
// 


#import "Tracker.h"
#import "ASIHTTPRequest.h"
#import "TBXML.h"

#define BUTO_PING_BASE_URL @"http://ping.buto.tv/";
#define	APP_URL_VALUE @"Buto iPhone App";

@implementation Tracker
@synthesize uvid;

#pragma mark -
#pragma mark Init and cleanup

- (id) init
{
	self			= [super init];
	return self;
}

- (void) dealloc
{
	[uvid release];
	[super dealloc];
}

#pragma mark -
#pragma mark Requests

- (void) updateStartedPing:(NSString *) videoId
{
	NSString *urlVal			= APP_URL_VALUE;
	NSString *xml				= [NSString stringWithFormat:@"<request><video_id>%@</video_id><type>%@</type><url>%@</url></request>", 
																		videoId, @"playback_started", urlVal];
	[self sendPingWithXML:xml];
}

- (void) updateDurationPing:(int) percentage
{
	NSString *xml				= [NSString stringWithFormat:@"<request><view_id>%@</view_id><type>%@</type><percentage_watched>%d</percentage_watched></request>", 
																							uvid, @"playback_update", percentage];
	[self sendPingWithXML:xml];
}

#pragma mark -
#pragma mark ASIHTTPRequest

- (void) sendPingWithXML:(NSString *)xml
{
	//Create the request object
	
	NSString *url							= BUTO_PING_BASE_URL;
	ASIHTTPRequest *request					= [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
	
	//Set the XML data
	
	[request appendPostData:(NSMutableData*)[xml dataUsingEncoding:NSUTF8StringEncoding]]; 
	
	//Set the headers
	
	[request addRequestHeader:@"Content-Type" value:@"application/xml"];
	[request addRequestHeader:@"Accept" value:@"application/xml"];
	
	//Make the request
	
	[request setDelegate:self];
	
	[request setDidFinishSelector:@selector(requestComplete:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	
	[request startAsynchronous];
}

- (void) requestComplete:(ASIHTTPRequest *)request
{	
	//Check the status code
	
	if ([request responseStatusCode] >= 400)
	{
		return;
	}
	
	//Look for a uvid in the returned XML
	
	TBXML *tbxml						= [TBXML tbxmlWithXMLData:[request responseData]];
	TBXMLElement *rootElement			= tbxml.rootXMLElement;
	TBXMLElement *uvidNode				= [TBXML childElementNamed:@"view_id" parentElement:rootElement];
	
	if (uvidNode)
	{
		NSString *theUvid				= [TBXML textForElement:uvidNode];
		self.uvid						= theUvid;
		
		[self updateDurationPing:100];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
	self.uvid								= nil;
}

@end
