//
//  Buto.h
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


#import <Foundation/Foundation.h>
#import "TBXML.h"

@class TBXML;

@interface Buto : NSObject 
{
	NSString *key;
}

@property (nonatomic, retain) NSString *key;

- (id) initWithKey:(NSString *)theKey;
- (NSMutableArray *) getLatestVideos:(int)numberToReturn;
- (NSMutableArray *) getSearchResultsForString:(NSString *)string;
- (NSMutableArray *) getVideos:(NSString *)url data:(NSString *)xml;
- (NSMutableArray *) getLiveCommentsForVideo:(NSString *) videoId;
- (BOOL) postComment:(NSString *) comment withName:(NSString *) name onVideo:(NSString *) videoId;
- (NSMutableArray *) parseVideosXML:(NSData *)data;
- (NSMutableArray *) parseCommentsXML:(NSData *)data;
- (NSMutableArray *) parseAdvertNode:(TBXMLElement *)node hotspots:(BOOL)hotspots;
- (NSString *) convertSecondsToTimecode:(int)seconds;

@end

@interface ButoVideo : NSObject
{
	NSString *videoId;
	NSString *title;
	NSString *desc;
	NSString *duration;
	int commentsCount;
	int interestingScore;
	NSString *pathToPoster;
	NSString *pathToThumb;
	NSString *pathToVideoCell;
	NSString *pathToVideoWifi;
	NSMutableArray *adverts;
}

@property (nonatomic, retain) NSString *videoId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *duration;
@property (nonatomic, retain) NSString *pathToPoster;
@property (nonatomic, retain) NSString *pathToThumb;
@property (nonatomic, retain) NSString *pathToVideoCell;
@property (nonatomic, retain) NSString *pathToVideoWifi;
@property (nonatomic, retain) NSMutableArray *adverts;
@property (nonatomic, assign) int commentsCount;
@property (nonatomic, assign) int interestingScore;

@end

@interface ButoComment : NSObject
{
	NSString *name;
	NSString *datePosted;
	NSString *body;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *datePosted;
@property (nonatomic, retain) NSString *body;

@end

@interface ButoLink : NSObject
{
	NSString *title;
	NSString *desc;
	NSString *linkText;
	NSURL *linkDest;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *linkText;
@property (nonatomic, retain) NSURL *linkDest;

@end


