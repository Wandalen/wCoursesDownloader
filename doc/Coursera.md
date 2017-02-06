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

Asset id can be found in `courseMaterial` property [see here](#get-course-materials-class_name-is-equal-to-slug)
For "typeName": "generic":

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
For typeName : "supplement":

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

<!-- https://www.coursera.org/api/courses.v1?fields=display%2CpartnerIds%2CphotoUrl%2CstartDate%2Cpartners.v1(homeLink%2Cname)&includes=partnerIds&q=watchlist&start=0 -->
