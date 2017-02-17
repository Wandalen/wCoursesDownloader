### ParameterVariator
Helps to select first avaible variant for single parameter or combination of several parameters.Each parameter is specified by two containers: list of allowed parameters and list of parameters preffered by user.
Algorithm takes each variant and checks it avaibility by calling `onAttempt` callback, if variant is avaible stops search and returns true, otherwise continues until end and returns false if nothing found.
### Glossary
* Variant - single parameter value or combination of values from several parameters with relationships specified by 'dependsOf' property. Example: video resolution,format,subtitles format,language and combinations: video resolution + format, subtitles format + language.

* Variant is avaible - means that user can perform some operations using it,for example,download file with format as variant value.

* allowedName - name of variable that holds list of [allowed parameters.](  )

* prefferedName - name of variable that holds list of [parameters preffered by user.]()

* target - reference to object that stores variables with names specified in `allowedName` and `prefferedName`.

* onAttempt - callback function that checks if passed variant is avaible,must be responsible to get current value of dependent parameter by it self,returns answer as true/false directly or through [wConsequence](https://github.com/Wandalen/wConsequence). Also can perform additional operations, for example download file if current format variant exists or add this variant to some list.

* dependsOf - map that specifies leading-dependent relationship between parameters.Must contain allowedName,prefferedName and callback onAttempt. Parameter specified inside `dependsOf` becomes leading and parameter in parent scope becomes dependent and it onAttempt callback is ignored. Algorithm varies values of leading parameter then varies dependent.To create more relationships add dependsOf property inside of previous:
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

Example for single parameter:
```
var o =
{
  allowedName : 'resourceFormatAllowed',
  prefferedName : 'resourceFormatPreffered',
  target : object,
  onAttempt : callback function,
}
```

Example for two parameters:
```
var something =
{
  allowedName : 'allowedName of leading'
  prefferedName : 'prefferedName of leading',
  onAttempt : callback function
}

var o =  
{
  allowedName : 'allowedName of dependent',
  prefferedName : 'prefferedName of dependent',
  target : object,
  dependsOf : something
}
```


#### parameterAllowed - list of allowed variants

All items in list except `null` will be considered as allowed variants for current parameter.
`null` - means try to use any variant from available list that is not described in `parameterAllowed`, for example, its useful for recently added file formats that not exist in the list.
If end of `parameterAllowed` is reached and any variant from current or available list is not selected yet - algorithm will throw error.
```
subtitlesFormatAllowed : [ 'txt','srt','vtt',null ]
```

#### parameterPreffered - list of parameter variants preffered by user

All items in list except `null` will be considered as parameter variants selected by user.
Usage of `null` in this list have several variants:
* Empty list  - don't try to select any variant at all.
```
subtitlesFormatAllowed : does not matter
subtitlesFormatPreffered : []
```
* Single `null` in the list - try to select any of available variants from `parameterAllowed` or some new variants from available list if nothing selected from `parameterAllowed`.
```
subtitlesFormatAllowed : [ 'vtt','srt',null ]
subtitlesFormatPreffered : [ null ]
```
* List that have `null` anywhere in the list - if no one allowed variant from `parameterPreffered` is available then don't throw error but try to choose some variant from rest of `parameterAllowed`.
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
* List without `null` - try to select any of preffered formats that are in allowed list and throw error if nothing is available.
```
subtitlesFormatAllowed : [ 'vtt','srt' ]
subtitlesFormatPreffered : [ 'txt' ]
```

#### Example #1 Assume server provide only one format : '720p'
``` javascript
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '720p','540p' ];
var rf = _.wParameterVariator( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//returns [ '720p' ]
```
#### Example #2 Assume server provide all allowed formats
``` javascript
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '100p', null ];
var rf = _.wParameterVariator( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//returns [ '720p', '540p' ]
```

#### Example #3 Not allowed format is preffered
``` javascript
var resourceFormatAllowed =  [ '720p', '540p' ];
var resourceFormatPreffered = [ '100p' ];
var rf = _.wParameterVariator( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//will throw error
```
#### Example #4 Assume server provide only new format : '1080p'
``` javascript
var resourceFormatAllowed =  [ '720p', '540p', null ];
var resourceFormatPreffered = [ '100p',null ];
var rf = _.wParameterVariator( { allowedName : resourceFormatAllowed, prefferedName : resourceFormatPreffered } );
rf.make();
//return [ '1080p' ]
```
