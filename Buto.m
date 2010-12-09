//
//  Buto.m
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


#import "Buto.h"
#import "ASIHTTPRequest.h"
#import "TBXML.h"

#define BUTO_API_BASE_URL @"http://api.buto.tv";
#define BUTO_API_TAG_NAME @"iphoneapp"; //The tag of the videos wished to return
#define BUTO_API_KEY @"API_KEY_HERE"; //Enter your API key

@implementation Buto
@synthesize key;

#pragma mark -
#pragma mark Init / Cleanup

- (id) initWithKey:(NSString *)theKey
{
	self				= [super init];
	self.key			= theKey;
	
	return self;
}

- (void) dealloc
{
	[key release];
	[super dealloc];
}

#pragma mark -
#pragma mark Video

- (NSMutableArray *) getLatestVideos:(int)numberToReturn
{
	//Set up the URL for the req, and the XML to post
	
	NSString *baseURL			= BUTO_API_BASE_URL;
	NSString *tagName			= BUTO_API_TAG_NAME;
	NSString *urlReq			= [NSString stringWithFormat:@"%@/videos/search/", baseURL];
	NSString *xml				= [NSString stringWithFormat:@"<request><tags><tag>%@</tag></tags></request>", tagName];
	
	//Make the request and return
	
	return [self getVideos:urlReq data:xml];
}

- (NSMutableArray *) getSearchResultsForString:(NSString *)string
{
	NSLog(@"Searching for %@", string);
	
	NSString *baseURL			= BUTO_API_BASE_URL;
	NSString *tagName			= BUTO_API_TAG_NAME;
	NSString *urlReq			= [NSString stringWithFormat:@"%@/videos/search/", baseURL];
	NSString *xml				= [NSString stringWithFormat:@"<request><text>%@</text><tags><tag>%@</tag></tags></request>", string, tagName];

	//Make the request and return
	
	return [self getVideos:urlReq data:xml];
}

- (NSMutableArray *) getVideos:(NSString *)url data:(NSString *)xml
{
	ASIHTTPRequest *request		= [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
	
	//Attach the xml
	
	[request appendPostData:(NSMutableData*)[xml dataUsingEncoding:NSUTF8StringEncoding]]; 
	
	//Set the key
	
	NSString *apiKey			= BUTO_API_KEY;
	
	[request setUsername:apiKey];
	[request setPassword:@"x"]; 
	
	//Set the headers
	
	[request addRequestHeader:@"Content-Type" value:@"application/xml"];
	[request addRequestHeader:@"Accept" value:@"application/xml"];
	
	//Make the request
	
	[request startSynchronous]; //Must use within a thread
	
	
	//Check the status code for 400+ errors
	
	if ([request responseStatusCode] >= 400)
	{
		return nil;
	}
	
	//Parse the XML and return array
	
	return [self parseVideosXML:[request responseData]];
}

#pragma mark -
#pragma mark Comments

- (NSMutableArray *) getLiveCommentsForVideo:(NSString *) videoId
{
	NSString *baseURL				= BUTO_API_BASE_URL;
	NSString *reqURL				= [NSString stringWithFormat:@"%@/comments/video/%@/approved", baseURL, videoId];
	ASIHTTPRequest *request			= [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:reqURL]];
	
	[request startSynchronous];
	
	if ([request responseStatusCode] >= 400)
	{
		return nil;
	}
	
	return [self parseCommentsXML:[request responseData]];
}

- (BOOL) postComment:(NSString *) comment withName:(NSString *) name onVideo:(NSString *) videoId
{	
	NSString *baseURL				= BUTO_API_BASE_URL;
	NSString *reqURL				= [NSString stringWithFormat:@"%@/comments/create/", baseURL];
	ASIHTTPRequest *request			= [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:reqURL]];
	
	//Create the XML needed
	
	NSString *xml					= [NSString stringWithFormat:@"<comment><video_id>%@</video_id><name>%@</name><body>%@</body></comment>", 
																												videoId, name, comment];
	//Attach the xml
	
	[request appendPostData:(NSMutableData*)[xml dataUsingEncoding:NSUTF8StringEncoding]]; 
	
	//Set the headers
	
	[request addRequestHeader:@"Content-Type" value:@"application/xml"];
	[request addRequestHeader:@"Accept" value:@"application/xml"];
	
	//Make the request
	
	[request startSynchronous];
	
	//Check status code for completion
	
	return YES;
}

#pragma mark -
#pragma mark XML Parsing

- (NSMutableArray *) parseVideosXML:(NSData *)data
{
	NSMutableArray *tmpArray		= [[NSMutableArray alloc] init];
	
	TBXML *tbxml					= [[TBXML tbxmlWithXMLData:data] retain];
	TBXMLElement *rootElement		= tbxml.rootXMLElement;
	TBXMLElement *videoNode			= [TBXML childElementNamed:@"video" parentElement:rootElement];
	
	while (videoNode)
	{
		[tmpArray addObject:[self parseVideoNode:videoNode]];
		
		//Move to the next node
		
		videoNode					= [TBXML nextSiblingNamed:@"video" searchFromElement:videoNode];
	}
	
	[tbxml release];
	
	return tmpArray;
}

- (NSMutableArray *) parseCommentsXML:(NSData *)data
{
	NSMutableArray *tmpArray		= [[NSMutableArray alloc] init];
	
	TBXML *tbxml					= [[TBXML tbxmlWithXMLData:data] retain];
	TBXMLElement *rootElement		= tbxml.rootXMLElement;
	TBXMLElement *commentNode		= [TBXML childElementNamed:@"comment" parentElement:rootElement];
	
	while (commentNode)
	{
		TBXMLElement *nameNode		= [TBXML childElementNamed:@"name" parentElement:commentNode];
		TBXMLElement *dateNode		= [TBXML childElementNamed:@"date_posted" parentElement:commentNode];
		TBXMLElement *bodyNode		= [TBXML childElementNamed:@"body" parentElement:commentNode];
		
		//Local vars
		
		NSString *theName			= [TBXML textForElement:nameNode];
		NSString *theDate			= [TBXML textForElement:dateNode];
		NSString *theBody			= [TBXML textForElement:bodyNode];
		
		//Crate the comment
		
		ButoComment *comment		= [[ButoComment alloc] init];
		comment.name				= theName;
		comment.datePosted			= theDate;
		comment.body				= theBody;
		
		//Add to the array
		
		[tmpArray addObject:comment];
		
		commentNode					= [TBXML nextSiblingNamed:@"comment" searchFromElement:commentNode];
	}
	
	[tbxml release];
	
	return tmpArray;
}

- (ButoVideo *) parseVideoNode:(TBXMLElement *)node
{
	ButoVideo *aVideo				= [[ButoVideo alloc] init];
	
	//Grab the elements we need
	
	TBXMLElement *idNode			= [TBXML childElementNamed:@"id" parentElement:node];
	TBXMLElement *nameNode			= [TBXML childElementNamed:@"name" parentElement:node];
	TBXMLElement *descNode			= [TBXML childElementNamed:@"description" parentElement:node];
	TBXMLElement *durNode			= [TBXML childElementNamed:@"length" parentElement:node];
	TBXMLElement *commentsCountNode	= [TBXML childElementNamed:@"comments_count" parentElement:node];
	TBXMLElement *posterNode		= [TBXML childElementNamed:@"poster_large" parentElement:node];
	TBXMLElement *thumbNode			= [TBXML childElementNamed:@"poster_small" parentElement:node];
	TBXMLElement *videoCellNode		= [TBXML childElementNamed:@"video_m4v_256" parentElement:node];
	TBXMLElement *videoWifiNode		= [TBXML childElementNamed:@"video_m4v_1024" parentElement:node];
	TBXMLElement *interestingNode	= [TBXML childElementNamed:@"interestingness_score" parentElement:node];
	TBXMLElement *advertsNode		= [TBXML childElementNamed:@"adverts" parentElement:node];
	TBXMLElement *hotspotsNode		= [TBXML childElementNamed:@"hotspots" parentElement:node];
	
	//Set to local vars
	
	NSString *theId					= [TBXML textForElement:idNode];
	NSString *theName				= [TBXML textForElement:nameNode];
	NSString *theDesc				= [TBXML textForElement:descNode];
	NSString *theDuration			= [self convertSecondsToTimecode:[[TBXML textForElement:durNode] intValue]];
	int theCommentsCount			= [[TBXML textForElement:commentsCountNode] intValue];
	NSString *thePoster				= [TBXML textForElement:posterNode];
	NSString *theThumb				= [TBXML textForElement:thumbNode];
	NSString *theVideoCell			= [TBXML textForElement:videoCellNode];
	NSString *theVideoWifi			= [TBXML textForElement:videoWifiNode];
	int interestingness				= [[TBXML textForElement:interestingNode] intValue];
	
	//Assign to the video object
	
	aVideo.videoId					= theId;
	aVideo.title					= theName;
	aVideo.desc						= theDesc;
	aVideo.duration					= theDuration;
	aVideo.commentsCount			= theCommentsCount;
	aVideo.pathToPoster				= thePoster;
	aVideo.pathToThumb				= theThumb;
	aVideo.pathToVideoCell			= theVideoCell;
	aVideo.pathToVideoWifi			= theVideoWifi;
	aVideo.interestingScore			= interestingness;
	
	//Check for adverts / hotspots
	
	if (hotspotsNode)
	{
		aVideo.adverts				= [self parseAdvertNode:hotspotsNode hotspots:YES];
	}
	else if (advertsNode)
	{
		aVideo.adverts				= [self parseAdvertNode:advertsNode hotspots:NO];
	}
	
	return aVideo;
}

- (NSMutableArray *) parseAdvertNode:(TBXMLElement *)node hotspots:(BOOL)hotspots
{
	NSMutableArray *tmpArray		= [[NSMutableArray alloc] init];
	
	if (hotspots) 
	{
		TBXMLElement *innerNode			= [TBXML childElementNamed:@"hotspot" parentElement:node];
		
		while (innerNode) 
		{
			TBXMLElement *advertNode	= [TBXML childElementNamed:@"advert" parentElement:innerNode];
			
			if (advertNode == nil)
			{
				innerNode					= [TBXML nextSiblingNamed:@"hotspot" searchFromElement:innerNode];
				continue;
			}
			
			//Add the object to the array
			
			[tmpArray addObject:[self parseSingleAdvert:advertNode]];
			innerNode					= [TBXML nextSiblingNamed:@"hotspot" searchFromElement:innerNode];
		}
	}
	else
	{
		TBXMLElement *advertNode	= [TBXML childElementNamed:@"advert" parentElement:node];
		
		while (advertNode != nil)
		{
			[tmpArray addObject:[self parseSingleAdvert:advertNode]];
			advertNode				= [TBXML nextSiblingNamed:@"advert" searchFromElement:advertNode];
		}
	}
	
	return tmpArray;
}

- (ButoLink *) parseSingleAdvert:(TBXMLElement *)advertNode
{
	TBXMLElement *nameNode		= [TBXML childElementNamed:@"name" parentElement:advertNode];
	TBXMLElement *descNode		= [TBXML childElementNamed:@"description" parentElement:advertNode];
	TBXMLElement *linkTextNode	= [TBXML childElementNamed:@"button_value" parentElement:advertNode];
	TBXMLElement *linkNode		= [TBXML childElementNamed:@"href" parentElement:advertNode];
	
	//Set to local vars
	
	NSString *theName			= [TBXML textForElement:nameNode];
	NSString *theDesc			= [TBXML textForElement:descNode];
	NSString *theLinkText		= [TBXML textForElement:linkTextNode];
	NSString *theLink			= [TBXML textForElement:linkNode];
	
	//Assign to object
	
	ButoLink *aLink				= [[ButoLink alloc] init];
	aLink.title					= theName;
	aLink.desc					= theDesc;
	aLink.linkText				= theLinkText;
	aLink.linkDest				= [NSURL URLWithString:theLink];
	
	return aLink;
}

#pragma mark -
#pragma mark Helpers

- (NSString *) convertSecondsToTimecode:(int)seconds
{
	int mins = 0;
	
	while (seconds >= 60)
	{
		//Remove 60 from seconds and add to mins
		
		seconds					= seconds - 60;
		mins					= mins + 1;
	}
	
	NSString *secsFormatted;
	NSString *minsFormatted;
	
	if (mins < 10)
	{
		minsFormatted			= [NSString stringWithFormat:@"0%d", mins];
	}
	else
	{
		minsFormatted			= [NSString stringWithFormat:@"%d", mins];
	}
	
	if (seconds < 10)
	{
		secsFormatted			= [NSString stringWithFormat:@"0%d", seconds];
	}
	else
	{
		secsFormatted			= [NSString stringWithFormat:@"%d", seconds];
	}
	
	return [NSString stringWithFormat:@"%@:%@", minsFormatted, secsFormatted];
}

@end

@implementation ButoVideo
@synthesize videoId, title, desc, duration, commentsCount, interestingScore, pathToPoster, pathToThumb, pathToVideoCell, pathToVideoWifi, adverts;

- (id) init
{
	self			= [super init];
	adverts			= [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc
{
	[videoId release];
	[title release];
	[desc release];
	[duration release];
	[pathToPoster release];
	[pathToThumb release];
	[pathToVideoCell release];
	[pathToVideoWifi release];
	[adverts release];
	[super dealloc];
}

@end

@implementation ButoComment
@synthesize name, datePosted, body;

- (id) init
{
	self			= [super init];
	return self;
}

- (void) dealloc
{
	[name release];
	[datePosted release];
	[body release];
	[super dealloc];
}

@end

@implementation ButoLink
@synthesize title, desc, linkText, linkDest;

- (id) init
{
	self		= [super init];
	return self;
}

- (void) dealloc
{
	[title release];
	[desc release];
	[linkText release];
	[linkDest release];
	[super dealloc];
}

@end


