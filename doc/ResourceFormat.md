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
Usage of in this list `null` have several variants:
* Empty list  - this resource will be skipped in download process.
```
subtitlesFormatPreffered : []
```
* Single `null` in the list - try to select all available formats from `resourceFormatAllowed` or some new formats if nothing selected from `resourceFormatAllowed` list.
```
subtitlesFormatPreffered : [ null ]
```
* List that have `null` anywhere in the list - if no one allowed format from `resourceFormatPreffered` is not available then don't throw error but try to choose some formats from rest of `resourceFormatAllowed`.
```
subtitlesFormatPreffered : [ 'txt',null ]
subtitlesFormatPreffered : [ null,'vtt' ]
subtitlesFormatPreffered : [ null, null ]
```
* List without `null` - try to select all preffered formats that are in allowed list and throw error if nothing is available.
```
subtitlesFormatPreffered : [ 'txt','vtt' ]
```

#### Example #1
``` javascript

// only one allowed format are avaible - '720p'
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '720p','540p' ];
var rf = _.ResourceFormat( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//returns [ '720p' ]

// all allowed formats are avaible
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '100p', null ];
var rf = _.ResourceFormat( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//returns [ '720p', '540p' ]

// not allowed format is preffered
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '100p' ];
var rf = _.ResourceFormat( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//will throw error

// '720p', '540p' not avaible but some new format exists - '1080p'
var resourceFormatAllowed =  [ '720p', '540p', null ];
var resourceFormatPreffered = [ '100p',null ];
var rf = _.ResourceFormat( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//return [ '1080p' ]

```
