### Coursera

### Login
Login URL : https://www.coursera.org/api/login/v3

Request method : POST

What we need to make request:

1. Create json payload:

  - { 'email' : your_email, 'password' : your_password, 'webrequest' : true }

2. Prepare cookies:

  - csrftoken - random string, length : 20
  - csrf2cookie - 'csrf2_token_' + random string with 8 symbols
  - csrf2token - random string, length : 24

3. Prepare Headers :
  - 'Cookie' : cookies
  - 'X-CSRFToken' : csrftoken,
  - 'X-CSRF2-Cookie' : csrf2cookie,
  - 'X-CSRF2-Token' : csrf2token,
  - 'Connection' : 'keep-alive'

Headers example:
```
headers :
{
  Cookie : "csrftoken=P6MoCuQx64kxAqHsdhYt; csrf2cookie=csrf2_token_MCOh2fZA; csrf2token=e725inBmEfiehfgUKbL1svl0;",
  X-CSRFToken : "P6MoCuQx64kxAqHsdhYt",
  X-CSRF2-Cookie : "csrf2_token_MCOh2fZA",
  X-CSRF2-Token : "e725inBmEfiehfgUKbL1svl0",
  Connection : "keep-alive"
},
```

On success server will return body:
```
{
"errorCode": "OK",
"message": null,
"details": null
}
```
Also after login server will return `Set-Cookie` header in response.
Values of `Set-Cookie` are used to perform calls to Coursera API, so
our `Cookie` header must be replaced with value of `Set-Cookie`.

### API

#### List of all courses : https://www.coursera.org/api/courses.v1?start={page}

Example : https://www.coursera.org/api/courses.v1?start=0

Part of Response:
```
{
"elements":
[

  {
  "courseType":"v2.ondemand",
  "id":"0HiU7Oe4EeWTAQ4yevf_oQ",
  "slug":"missing-data",
  "name":"Dealing With Missing Data"
  },

  ...
]
}
```

#### Get list of your courses:

Simple version:
```
https://www.coursera.org/api/memberships.v1?includes=courseId,courses.v1&q=me
```

Full version:
```
https://www.coursera.org/api/memberships.v1?fields=courseId,enrolledTimestamp,grade,id,lastAccessedTimestamp,onDemandSessionMembershipIds,onDemandSessionMemberships,role,v1SessionId,vc,vcMembershipId,courses.v1(courseStatus,display,partnerIds,photoUrl,specializations,startDate,v1Details,v2Details),partners.v1(homeLink,name),v1Details.v1(sessionIds),v1Sessions.v1(active,certificatesReleased,dbEndDate,durationString,hasSigTrack,startDay,startMonth,startYear),v2Details.v1(onDemandSessions,plannedLaunchDate,sessionsEnabledAt),specializations.v1(logo,name,partnerIds,shortName)&includes=courseId,onDemandSessionMemberships,vcMembershipId,courses.v1(partnerIds,specializations,v1Details,v2Details),v1Details.v1(sessionIds),v2Details.v1(onDemandSessions),specializations.v1(partnerIds)&q=me&showHidden=true&filter=current,preEnrolled
```


Sample of reply:

```
{  
  "elements":[  
    {  
      "role":"LEARNER",
      "id":"24039793~Qx-vkAocEeWAYyIACmGIdw",
      "userId":24039793,
      "courseId":"Qx-vkAocEeWAYyIACmGIdw"
    }
  ],
  "paging":{  
    "total":1
  },
  "linked":{  
    "courses.v1":[  
      {  
        "courseType":"v2.ondemand",
        "id":"Qx-vkAocEeWAYyIACmGIdw",
        "slug":"interactive-computer-graphics",
        "name":"Interactive Computer Graphics"
      }
    ]
  }
}
```

#### Get course materials, {class_name} is equal to `slug`:
```
https://www.coursera.org/api/opencourse.v1/course/{class_name}?showLockedItems=true
```

Example:
```
https://www.coursera.org/api/opencourse.v1/course/interactive-computer-graphics?showLockedItems=true
```
In the response materials are located in `courseMaterial` property.

Possible hierarchy:

`courseMaterial -> Modules -> Lectures -> Materials -> Content( typeName,definition )`

`typeName` : supplement,generic,lecture(video),quiz etc.

`definition` : contains info about asset: type,id( used to get url ).

Other way to get course materials using {class_name}(slug):
```
https://www.coursera.org/api/onDemandCourseMaterials.v1/?q=slug&slug={class_name}&includes=moduleIds%2ClessonIds%2CpassableItemGroups%2CpassableItemGroupChoices%2CpassableLessonElements%2CitemIds%2Ctracks&fields=moduleIds%2ConDemandCourseMaterialModules.v1(name%2Cslug%2Cdescription%2CtimeCommitment%2ClessonIds%2Coptional)%2ConDemandCourseMaterialLessons.v1(name%2Cslug%2CtimeCommitment%2CelementIds%2Coptional%2CtrackId)%2ConDemandCourseMaterialPassableItemGroups.v1(requiredPassedCount%2CpassableItemGroupChoiceIds%2CtrackId)%2ConDemandCourseMaterialPassableItemGroupChoices.v1(name%2Cdescription%2CitemIds)%2ConDemandCourseMaterialPassableLessonElements.v1(gradingWeight)%2ConDemandCourseMaterialItems.v1(name%2Cslug%2CtimeCommitment%2Ccontent%2CisLocked%2ClockableByItem%2CitemLockedReasonCode%2CtrackId)%2ConDemandCourseMaterialTracks.v1(passablesCount)&showLockedItems=true
```
Reply:
```
{  
  "elements":[  
    {  
      "moduleIds":[  ],
      "id":"Qx-vkAocEeWAYyIACmGIdw"
    }
  ],
  "paging":{  },
  "linked":{  
    "onDemandCourseMaterialTracks.v1":[  ],
    "onDemandCourseMaterialItems.v1":[  ],
    "onDemandCourseMaterialLessons.v1":[  ],
    "onDemandCourseMaterialPassableItemGroupChoices.v1":[  ],
    "onDemandCourseMaterialPassableItemGroups.v1":[  ],
    "onDemandCourseMaterialModules.v1":[  ],
    "onDemandCourseMaterialPassableLessonElements.v1":[  ]
  }
}
```

#### Video
Resolution | Supported formats |
--- | --- |
720p | mp4, webm
360p | mp4, webm
540p | mp4, webm

#### Subtitles
Languages:
all Coursera videos have subtitles in the primary language of the course. Some course videos also have translated subtitles.
In server response subtitles are placed in object `subtitles` with language shortcut as key and data url as value.

Example:
```
{
  "en":"some url"
}
```
Formats:
* txt - Transcript file for readonly
```
"subtitlesTxt":{
  "en":"some url"
}
```
* vtt - [WebVTT](https://w3c.github.io/webvtt/)
```
"subtitlesVtt":{
  "en":"some url"
}
```
* srt - [SRT Subtitles](https://matroska.org/technical/specs/subtitles/srt.html)
By default srt subtitles are located in `subtitles` property.
```
"subtitles":{
  "en":"some url"
}
```


#### How get video urls with subtitles:
```
'https://www.coursera.org/api/onDemandLectureVideos.v1/{course_id}~{element_id}?includes=video&fields=onDemandVideos.v1(sources%2Csubtitles%2CsubtitlesVtt%2CsubtitlesTxt)
```

Request parameters:
* `course_id` - course id from list of courses.

* `element_id` - id of element with `typeName` - lecture.

Part of reply:
```
"onDemandVideos.v1":[
      {
        "subtitles":{
          "en":"some url"
        },
        "sources":{
          "playlists":{
            "hls":"some url"
          },
          "byResolution":{
            "720p":{
              "webMVideoUrl": "some url",
              "mp4VideoUrl" : "some url",
              "previewImageUrl" : "some url"
            },
            "360p":{
              "webMVideoUrl": "some url",
              "mp4VideoUrl" : "some url",
              "previewImageUrl" : "some url"
            },
            "540p":{
              "webMVideoUrl": "some url",
              "mp4VideoUrl" : "some url",
              "previewImageUrl" : "some url"
            }
          }
        },
        "subtitlesTxt":{
          "en":"some url"
        },
        "subtitlesVtt":{
          "en":"some url"
        },
      }
    ]
```

#### How get video info using video_id finded in response for course materials:
```
https://www.coursera.org/api/opencourse.v1/video/{video_id}
```
Possible resolutions: 720p,360p,540p
Formats: mp4,webm
Reply:
```
{  
  "sources":[  
    {  
      "resolution":"540p",
      "formatSources":{  
        "video/mp4":"video_url_here",
        "video/webm":"video_url_here"
      }
    }
```

#### How get Assets:

Asset id can be found in `courseMaterial` property [see here.](#get-course-materials-class_name-is-equal-to-slug)

For `typeName`: "generic":

`https://www.coursera.org/api/assets.v1?ids={id}`

Example:

`https://www.coursera.org/api/assets.v1?ids=Vq8hwsdaEeWGlA7xclFASw`

Reply:

```
{
  "elements": [
    {
      "name": "1_Strategic_Interactions.pdf",
      "typeName": "generic",
      "id": "Vq8hwsdaEeWGlA7xclFASw",
      "url": {
        "expires": 1486166400000,
        "url": "url_to_file_here"
      }
    }
  ],
}
```
For `typeName` : "supplement" #1:

`https://www.coursera.org/api/openCourseAssets.v1/{assetId}`

Example:

`https://www.coursera.org/api/openCourseAssets.v1/vVFHCo8eEeaBsQ67BkAEvQ`

Reply:

```
{
  "elements": [
    {
      "typeName": "cml",
      "definition": {
        "dtdId": "supplement/1",
        "value": "some content here"
      },
      "id": "vVFHCo8eEeaBsQ67BkAEvQ"
    }
  ],
}
```

For `typename` : 'lecture':
* Take each id from `content->definition->assets`
Example:
```
"content" :
{
  "typeName" : "lecture",
  "definition" : { ... "assets" : [ 'giAxucdaEeWJTQ5WTi8YJQ@1',... ] }
}
```

All symbols before `@1` will be our id:
`giAxucdaEeWJTQ5WTi8YJQ`

* Get assetId using id from previous step:

API: `https://www.coursera.org/api/openCourseAssets.v1/{id}`

Example : `https://www.coursera.org/api/openCourseAssets.v1/giAxucdaEeWJTQ5WTi8YJQ`

Response:
```
{
  "elements":[
    {
      "typeName":"asset",
      "definition":{
        "assetId":"Vq8hwsdaEeWGlA7xclFASw",
        "name":""
      },
      "id":"giAxucdaEeWJTQ5WTi8YJQ"
    }
  ]
}
```

* Get assets urls:

API: `https://www.coursera.org/api/assetUrls.v1?ids={ids}`

Request parameters:

* `ids` - list of assetId's from previous step separated by ','

Example: `https://www.coursera.org/api/assetUrls.v1?ids=Vq8hwsdaEeWGlA7xclFASw,QIEA6KV5EeWXJQ4LAiyuNw`

Reply:
```
{
  "elements":[
    {
      "expires":1486771200000,
      "id":"Vq8hwsdaEeWGlA7xclFASw",
      "url":"url_here"
    },
    {
      "expires":1486771200000,
      "id":"QIEA6KV5EeWXJQ4LAiyuNw",
      "url":"url_here"
    }
  ]
}
```


<!-- https://www.coursera.org/api/courses.v1?fields=display%2CpartnerIds%2CphotoUrl%2CstartDate%2Cpartners.v1(homeLink%2Cname)&includes=partnerIds&q=watchlist&start=0 -->
