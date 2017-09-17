( function _Coursera_s_( ) {

'use strict';

// dependencies

if( typeof module !== 'undefined' )
{
  if( typeof wDownloaderOfCourses === 'undefined' )
  require( './Abstract.s' );

  if( typeof wParameterVariator === 'undefined' )
  require( '../../../atop/variator/ParameterVariator.s' );
}

// constructor

var _ = wTools;
var Parent = wDownloaderOfCourses;
var Self = function wDownloaderOfCoursesCoursera( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'DownloaderOfCoursesCoursera';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

function _makeAct()
{
  var self = this;

  self.config.payload[ 'webrequest' ] =  true;
  self.config.options.json = true;
  self.config.options.body = self.config.payload;

}

//

function _makePrepareHeadersForLogin()
{
  var self = this;
  var con = Parent.prototype._makePrepareHeadersForLogin.call( self );

  /* */

  var randomstring = require( 'randomstring' );
  var csrftoken = randomstring.generate( 20 );
  var csrf2cookie = 'csrf2_token_' + randomstring.generate( 8 );
  var csrf2token = randomstring.generate( 24 )
  var cookies = `csrftoken=${csrftoken}; csrf2cookie=${csrf2cookie}; csrf2token=${csrf2token};`

  self.config.options.headers =
  {
    'Cookie' : cookies,
    'X-CSRFToken' : csrftoken,
    'X-CSRF2-Cookie' : csrf2cookie,
    'X-CSRF2-Token' : csrf2token,
    'Connection' : 'keep-alive'
  }

  return con;
}

//

function _coursesListAct()
{
  var self = this;

  _.assert( arguments.length === 0 );

  return self._request( self.config.getUserCoursesUrl )
  .doThen( function( err, got )
  {

    if( !err )
    if( got.response.statusCode !== 200 )
    {
      debugger;
      err = _.err( 'Failed to get resources list. StatusCode : ', got.response.statusCode, 'Server response : ', got.body );
    }

    if( err )
    return con.error( _.err( err ) );

    if( !self._courses )
    self._courses = [];

    self._coursesData = JSON.parse( got.body );

    // logger.log( 'self._coursesData',_.toStr( self._coursesData,{ levels : 4 } ) );

    self._coursesData[ 'linked' ][ 'courses.v1' ].forEach( function( courseData )
    {
      var course = {};
      course.name = courseData.name;
      course.id = courseData.id;
      course.url = _.strReplaceAll( self.config.courseUrl,'{class_name}', courseData.slug );
      course.raw = courseData;
      self._courses.push( course );
    });

    return self._courses;
  });

}

//

function _resourcesListAct()
{
  var self = this;
  var con = new wConsequence();

  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( self.currentCourse ) );

  // if( self._resources[ self.currentCourse.name ] )
  // return con.give( self._resources[ self.currentCourse.name ] );

  var postUrl = _.strReplaceAll( self.config.courseMaterials,'{class_name}', self.currentCourse.raw.slug );

  /* */

  con = self._request( postUrl )
  .doThen( function( err, got )
  {

    if( !err )
    if( got.response.statusCode !== 200 )
    err = _.err( 'Failed to get resources list. StatusCode : ', got.response.statusCode, 'Server response : ', got.body );

    if( err )
    return con.error( _.err( err ) );

    var data = JSON.parse( got.body );

    self._resourcesData = data;

  })
  .ifNoErrorThen(function ()
  {
    return self._resourcesListRefineAct( );
  })
  .ifNoErrorThen(function ()
  {
    // !!! here was error
    // then returns message to consequence automaitcally
    // give gives duplicate message
    // that's wrong
    // con.give( self._resources );
    return self._resources;
  })

  /* */

  // !!! common for all classes should be in base class
  // verbose output is commong

  // if( self.verbosity )
  // {
  //   con.ifNoErrorThen( function( resources )
  //   {
  //     logger.log( 'Resources:\n', _.toStr( resources, { levels : 3 } ) );
  //     con.give( resources );
  //   });
  // }

  return con;
}

//

function _resourcePageUrlGet( resource )
{
  var self = this;

  if( resource.kind === self.ResourceKindMapper.valueFor( 'week' ) )
  {
    var urlOptions =
    {
      dst : self.config.weekUrl,
      dictionary :
      {
        '{class_name}' : self.currentCourse.raw.slug,
      }
    }
  }
  else
  {
    var urlOptions =
    {
      dst : self.config.resourcePageUrl,
      dictionary:
      {
        '{class_name}' : self.currentCourse.raw.slug,
        '{type}' : resource.raw.content.typeName,
        '{id}' : resource.id,
      }
    }
  }

  return  _.strReplaceAll( urlOptions );
}

//

function _resourcesListRefineAct()
{
  var self = this;
  var con = new wConsequence().give();

  var elements = self._resourcesData.courseMaterial.elements;

  if( !self._resources )
  self._resources = [];

  var weekCounter = 0;


  function _makeList( element,parent )
  {
    if( element.content )
    {
      var type = element.content.typeName;
      var kind = self.ResourceKindMapper.valueFor( type );

      var page = {};
      page.name = element.name;
      page.id  = element.id;
      page.kind = kind;
      page.raw =  element;
      page.elements = [];
      page.pageUrl = self._resourcePageUrlGet( page );
      parent.elements.push( page.id );
      self._resources.push( page );

      if( type === 'lecture' )
      {
        con.doThen( _.routineSeal( self,self._resourceVideoUrlGet, [ { element : element, parent : page, subtitles : 'ru' } ] ) );

        var assets = element.content.definition.assets;
        if( assets.length )
        con.doThen( _.routineSeal( self,self._resourceAssetUrlGet, [ element,page ] ) );
      }

      if( type === 'supplement' )
      {
        con.doThen( _.routineSeal( self,self._resourceHtmlGet,[ element,page ] ) );
      }
    }

    if( element.elements )
    {
      var resource = {};
      resource.name = element.name;
      resource.id  = element.id;
      resource.raw =  element;
      resource.elements = [];

      if( element.description )
      {
        resource.kind = self.ResourceKindMapper.valueFor( 'week' );
        ++weekCounter;
        resource.pageUrl = self._resourcePageUrlGet( resource ) + weekCounter;
      }
      else
      {
        resource.kind = self.ResourceKindMapper.valueFor( 'section' );
        parent.elements.push( resource.id );
      }



      self._resources.push( resource );

      element.elements.forEach( function( element )
      {
        _makeList( element, resource );
      });
    }

  }

  //

  elements.forEach( function ( element )
  {
    _makeList( element );
  });

  return con;
}

//

function _resourceVideoUrlGet( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { element : arguments[ 0 ], parent : arguments[ 1 ] };
  }

  _.routineOptions( _resourceVideoUrlGet,o );

  var urlOptions =
  {
    dst : self.config.getVideoApi,
    dictionary:
    {
      '{course_id}' : self.currentCourse.raw.id,
      '{element_id}' : o.element.id,
    }
  }

  var getUrl = _.strReplaceAll( urlOptions );
  var data,video,resolutions,selectedResolutions;

  return self._request( getUrl )
  .doThen( function( err, got )
  {

    if( got.response.statusCode !== 200 )
    err = _.err( 'Failed to get video url. StatusCode: ', got.response.statusCode, 'Server response: ', got.body );

    if( err )
    throw _.errLogOnce( err );

    data = JSON.parse( got.body );

    /*video*/
    video = _.entitySearch({ src : data, ins : 'byResolution'});
    var videoKeys = Object.keys( video );

    video = video[ videoKeys[ 0 ] ];

    resolutions = Object.keys( video );
    selectedResolutions = [];

    function onAttemptResolution( variant )
    {
      var i = resolutions.indexOf( variant );
      if( i != -1 )
      {
        selectedResolutions.push( variant );
        return true;
      }

      return false;
    }

    var videoResolutionVariator = _.ParameterVariator
    ({
      target : self,
      allowedName : 'allowedVideoResolutions',
      prefferedName :'prefferedVideoResolutions',
      knownName : 'knownVideoResolutions',
      onAttempt : onAttemptResolution,
    });

    videoResolutionVariator.make()
    .thenDo( function( err, got )
    {
      if( err )
      throw _.errLogOnce( err );

      var dataUrl = [];

      selectedResolutions.forEach( function ( resolution )
      {
        dataUrl.push( video[ resolution ][ 'mp4' + 'VideoUrl' ] )
      });

      var resource = {};

      resource.name = o.element.name;
      resource.id  = o.element.content.definition.videoId;
      resource.kind = self.ResourceKindMapper.valueFor( 'video' );
      resource.dataUrl = dataUrl;
      resource.raw =  data;

      self._resources.push( resource );
      o.parent.elements.push( resource.id );
    });

    /*subtitles*/
    if( o.subtitles )
    {
      var sub = _.entitySearch({ src : data, ins : 'subtitles' });
      var subKeys = Object.keys( sub );

      sub = sub[ subKeys[ 0 ] ];

      var subtitlesLangs = Object.keys( sub );
      var selectedSubtitlesLangs = [];
      var dataUrl = [];

      function onAttemptSubtitles( variant )
      {
        var i = subtitlesLangs.indexOf( variant );
        if( i != -1 )
        {
          selectedSubtitlesLangs.push( variant );
          return true;
        }

        return false;
      }

      var subtitlesLangVariator = _.ParameterVariator
      ({
        target : self,
        allowedName : 'allowedSubtitlesLangs',
        prefferedName :'prefferedSubtitlesLangs',
        knownName : 'knownSubtitlesLangs',
        onAttempt : onAttemptSubtitles,
      });

      subtitlesLangVariator.make()
      .thenDo( function( err, got )
      {
        if( err )
        throw _.errLogOnce( err );

        selectedSubtitlesLangs.forEach( function ( language )
        {
          dataUrl.push( self.config.site + sub[ language ] );
        });

        var resource = {};
        resource.name = '[subtitles] ' + o.element.name;
        resource.id  = o.element.content.definition.videoId;
        resource.kind = self.ResourceKindMapper.valueFor( 'subtitles' );
        resource.dataUrl = dataUrl;
        resource.raw =  data;

        self._resources.push( resource );
      });
    }
  });
}

_resourceVideoUrlGet.defaults =
{
  element : null,
  parent : null,
  subtitles : true
}

//

function _resourceHtmlGet( element, parent )
{
  var self = this;
  var urlOptions =
  {
    dst : self.config.getSupplementUrl,
    dictionary:
    {
      '{course_id}' : self.currentCourse.raw.id,
      '{element_id}' : element.id,
    }
  }
  var getUrl = _.strReplaceAll( urlOptions );

  return self._request( getUrl )
  .doThen( function( err, got )
  {
    if( err )
    err = _.err( err );

    if( got.response.statusCode !== 200 )
    err = _.err( 'Failed to get resource data. StatusCode: ', got.response.statusCode, 'Server response: ', got.body );

    if( err )
    throw _.errLogOnce( err );

    var data = JSON.parse( got.body );
    var result = _.entitySearch({ src : data, ins : 'value', searchingValue : 0, searchingSubstring : 0 });
    var keys = Object.keys( result );

    var resource = {};
    resource.name = element.name;
    resource.id  = element.id;
    resource.kind = self.ResourceKindMapper.valueFor( element.content.definition.assetTypeName );
    resource.raw =  element;
    resource.pageUrl = self._resourcePageUrlGet( resource );
    resource.raw.data =  result[ keys[ 0 ] ];

    self._resources.push( resource );
    parent.elements.push( resource.id );

    return self._resources;

  });
}

//

function _resourceAssetUrlGet( element, parent )
{
  var self = this;
  var con = new wConsequence().give();


  var assets = element.content.definition.assets;

  var ids = [];
  var getUrl;

  assets.forEach( function( asset )
  {
    var id = asset.substr( 0, asset.lastIndexOf('@') );
    getUrl = _.strReplaceAll( self.config.getAssetIdUrl, '{id}', id );

    con.doThen( _.routineSeal( self,self._request,[ getUrl ] ) )
    .doThen( function( err, got )
    {
      if( err )
      err = _.err( err );

      if( got.response.statusCode !== 200 )
      err = _.err( 'Failed to get resource data. StatusCode: ', got.response.statusCode, 'Server response: ', got.body );

      if( err )
      throw _.errLogOnce( err );

      var data = JSON.parse( got.body );
      var result = _.entitySearch({ src : data, ins : 'assetId', searchingValue : 0, searchingSubstring : 0 });
      var keys = Object.keys( result );
      return result[ keys[ 0 ] ];
    })
    .doThen( function( err, got )
    {
      ids.push( got );
      if( ids.length === assets.length )
      return ids;
    });

  });

  var resources = [];

  con.doThen( function( err, got )
  {
    var getUrl = _.strReplaceAll( self.config.getAssetsUrl, '{ids}', ids.join( ',' ) );

    return self._request( getUrl )
    .doThen( function( err, got )
    {
      if( !err )
      if( got.response.statusCode !== 200 )
      {
        debugger;
        err = _.err( 'Failed to get resources list. StatusCode : ', got.response.statusCode, 'Server response : ', got.body );
      }

      if( err )
      return con.error( _.err( err ) );

      var data = JSON.parse( got.body );
      var counter = 0;
      data.elements.forEach( function( asset )
      {
        var resource = {};
        resource.name = element.name;
        resource.id  = asset.id;
        resource.kind = self.ResourceKindMapper.valueFor( 'asset' );
        resource.dataUrl = asset.url;
        resource.raw =  asset;

        self._resources.push( resource );
        parent.elements.push( resource.id );
        ++counter;

        if( counter === data.elements.length )
        return self._resources;
      })
    });
  });

  return con;
}

//



//

var ResourceKindMapper = wNameMapper({ droppingDuplicate : 1 }).set
({

  /* terminal */
  'discussion' : 'discussion',
  'exam' : 'problem',
  'quiz' : 'problem',
  'asset' : 'downloadable',
  'subtitles' : 'downloadable',
  'cml' : 'hypertext',/*Coursera Markup Language*/
  'video' : 'video',

  /* non-terminal */

  'lecture' : 'page',
  'supplement' : 'page',
  'section' : 'section',
  'week' : 'chapter',
  'course' : 'course',

});

// --
// relationships
// --

var Composes =
{
  currentPlatform : 'Coursera',
}

var Aggregates =
{
  prefferedVideoFormats : [ 'mp4' ],
  allowedVideoFormats : [ 'mp4','webm' ],
  knownVideoFormats : [ 'mp4','webm' ],

  prefferedVideoResolutions : [ '720p' ],
  allowedVideoResolutions : [ '720p', '360p', '540p' ],
  knownVideoResolutions : [ '720p', '360p', '540p' ],


  prefferedSubtitlesLangs : [ 'en' ],
  allowedSubtitlesLangs : [ 'en' ],
  knownSubtitlesLangs : [ 'en' ],
}

var Associates =
{
}

var Restricts =
{
}

var Statics =
{
  ResourceKindMapper : ResourceKindMapper
}

// --
// proto
// --

var Proto =
{

  init : init,

  _makeAct : _makeAct,
  _makePrepareHeadersForLogin : _makePrepareHeadersForLogin,

  //

  _coursesListAct : _coursesListAct,

  //

  _resourcesListAct : _resourcesListAct,
  _resourcesListRefineAct : _resourcesListRefineAct,

  _resourceVideoUrlGet : _resourceVideoUrlGet,
  _resourceHtmlGet : _resourceHtmlGet,
  _resourceAssetUrlGet : _resourceAssetUrlGet,
  _resourcePageUrlGet : _resourcePageUrlGet,

  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

};

// define

_.classMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

Parent.registerClass( Self );

// accessor

_.accessor( Self.prototype,
{
});

// readonly

_.accessorReadOnly( Self.prototype,
{
});

// subtitlesFormatPreffered : [ 'txt','srt','vtt',null ],
// subtitlesFormatNeeded : 'txt',
//
// titleFormat : wPrefferedArray
// ({
//   preffered : [ 'txt','srt','vtt',null ],
//   needed : 'txt',
// });
//
// var dc = _.DownloaderOfCourses.Loader( 'Edx' );
// dc.copy
// ({
//   subtitlesFormat :
//   {
//     preffered : [ 'txt','srt','vtt',null ],
//     needed : [ 'txt' ],
//   }
// });
//
// var dc = _.DownloaderOfCourses.Loader( 'Edx' );
// dc.copy
// ({
//   subtitlesFormat : 'txt'
// });

})();
