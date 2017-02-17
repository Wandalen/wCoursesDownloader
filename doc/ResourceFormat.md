### ResourceFormat
Helps to select first avaible to download resource format or formats combination.Each format is specified by two containers: list of allowed formats and list of formats preffered by user.
Takes each variant and checks it avaibility by calling `onAttempt` callback, if variant is avaible stops search and returns true, otherwise continues until end and returns false if nothing founded.
Variant - single format or combination of several formats with relationships specified by 'dependsOf' property.
### Options

* allowedName - name of variable that holds list of [resource allowed formats.]( #resourceFormatAllowed - list-of-resource-allowed-formats )
* prefferedName - name of variable that holds list of [resource formats preffered by user.](#resourceFormatPreffered - list-of-resource-formats-preffered-by-user)
* target - reference to object that stores variables with names specified in `allowedName` and `prefferedName`.
* onAttempt - callback function that checks if passed format or combination of formats can be downloaded, returns answer as true/false directly or through [wConsequence](https://github.com/Wandalen/wConsequence).
* dependsOf - map that specifies leading-dependent relationship between formats. Format specified inside `dependsOf` becomes leading and will vary first. Must contain allowedName,prefferedName and callback onAttempt. Format specified in parent scope becomes dependent and it onAttempt callback is ignored.
To create more relationships add dependsOf property inside of previous.
```
dependsOf :
{
  allowedName : '...'
  prefferedName : '...',
  dependsOf :
  {
    allowedName : '...'
    prefferedName : '...',
  }
}
```

Example for single format:
```
allowedName : 'resourceFormatAllowed',
prefferedName : 'resourceFormatPreffered',
target : object,
onAttempt : callback function,
```

Example for two formats:
```
allowedName : 'allowedName of dependent',
prefferedName : 'prefferedName of dependent',
target : object,
dependsOf :
{
  allowedName : 'allowedName of leading'
  prefferedName : 'prefferedName of leading',
  onAttempt : callback function
}
```


#### resourceFormatAllowed - list of resource allowed formats

All items in list except `null` will be considered as allowed resource formats.
`null` - means try to use any of available formats that is not described in `resourceFormatAllowed`, its useful for recently added formats that not exist in the list.
If end of `resourceFormatAllowed` is reached and any format from list or from new formats is not selected yet - algorithm will throw error.
```
subtitlesFormatAllowed : [ 'txt','srt','vtt',null ]
```

#### resourceFormatPreffered - list of resource formats preffered by user

All items in list except `null` will be considered as resource formats selected by user.
Usage of `null` in this list have several variants:
* Empty list  - don't download resource at all.
```
subtitlesFormatAllowed : does not matter
subtitlesFormatPreffered : []
```
* Single `null` in the list - try to select all available formats from `resourceFormatAllowed` or some new formats if nothing selected from `resourceFormatAllowed` list.
```
subtitlesFormatAllowed : [ 'vtt','srt',null ]
subtitlesFormatPreffered : [ null ]
```
* List that have `null` anywhere in the list - if no one allowed format from `resourceFormatPreffered` is available then don't throw error but try to choose some formats from rest of `resourceFormatAllowed`.
```
subtitlesFormatAllowed : [ 'vtt','srt',null ]
subtitlesFormatPreffered : [ 'txt',null ]
```
```
subtitlesFormatAllowed : [ 'vtt','srt',null ]
subtitlesFormatPreffered : [ null,'txt' ]
```
```
subtitlesFormatAllowed : [ 'vtt','srt',null ]
subtitlesFormatPreffered : [ null, null ]
```
* List without `null` - try to select all preffered formats that are in allowed list and throw error if nothing is available.
```
subtitlesFormatAllowed : [ 'vtt','srt' ]
subtitlesFormatPreffered : [ 'txt' ]
```

#### Example #1 Assume server provide only one format : '720p'
``` javascript
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '720p','540p' ];
var rf = _.ResourceFormat( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//returns [ '720p' ]
```
#### Example #2 Assume server provide all allowed formats
``` javascript
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '100p', null ];
var rf = _.ResourceFormat( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//returns [ '720p', '540p' ]
```

#### Example #3 Not allowed format is preffered
``` javascript
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '100p' ];
var rf = _.ResourceFormat( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//will throw error
```
#### Example #4 Assume server provide only new format : '1080p'
``` javascript
var resourceFormatAllowed =  [ '720p', '540p', null ];
var resourceFormatPreffered = [ '100p',null ];
var rf = _.ResourceFormat( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//return [ '1080p' ]
```
