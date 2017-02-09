### ResourceFormat
Makes list of avaible to download resource formats using two containers: list of allowed formats and list of formats preffered by user.

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
