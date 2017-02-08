( function _Coursera_s_( ) {

'use strict';

// dependencies

if( typeof module !== 'undefined' )
{
  if( typeof wDownloaderOfCourses === 'undefined' )
  require( './Abstract.s' );
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
  .thenDo( function( err, got )
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
  .thenDo( function( err, got )
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
    var resource = {};

    resource.name = element.name;
    resource.id  = element.id;
    resource.raw =  element;


    if( parent )
    {
      resource.path = 'Week ' + weekCounter + '/' + parent.name;

      parent.elements.push( resource.id )
    }

    if( element.description )
    {
      resource.kind = self.ResourceKindMapper.valueFor( 'week' );
      ++weekCounter;
      var urlOptions =
      {
        dst : self.config.weekUrl,
        dictionary :
        {
          '{class_name}' : self.currentCourse.raw.slug,
          '{weekCounter}' : '' + weekCounter,
        }
      }
    }

    if( element.content )
    {
      resource.kind = self.ResourceKindMapper.valueFor( element.content.typeName );

      var urlOptions =
      {
        dst : self.config.resourcePageUrl,
        dictionary:
        {
          '{class_name}' : self.currentCourse.raw.slug,
          '{type}' : element.content.typeName,
          '{id}' : resource.id,
        }
      }

      if( resource.kind === 'video' )
      {
        con.thenDo( _.routineSeal( self,self._resourceVideoUrlGet,[ element.id ] ) );
      }
      if( resource.kind === 'html' )
      {
        con.thenDo( _.routineSeal( self,self._resourceHtmlGet,[ element.id ] ) );
      }

      con.thenDo( function ( err, got )
      {
        if( resource.kind === 'html' )
        resource.raw.data = got;
        else
        resource.dataUrl = got;
      });
    }

    if( urlOptions )
    resource.pageUrl = _.strReplaceAll( urlOptions );

    self._resources.push( resource );

    if( element.elements )
    {
      if( !resource.kind )
      resource.kind = self.ResourceKindMapper.valueFor( 'section' );

      if( !resource.elements )
      resource.elements = [];

      element.elements.forEach( function ( element )
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

  if( _.strIs( o ) )
  o = { id : o };

  _.routineOptions( _resourceVideoUrlGet,o );

  var urlOptions =
  {
    dst : self.config.getVideoApi,
    dictionary:
    {
      '{course_id}' : self.currentCourse.raw.id,
      '{element_id}' : o.id,
    }
  }

  var getUrl = _.strReplaceAll( urlOptions );

  return self._request( getUrl )
  .thenDo( function( err, got )
  {
    if( err )
    err = _.err( err );

    if( got.response.statusCode !== 200 )
    err = _.err( 'Failed to get video url. StatusCode: ', got.response.statusCode, 'Server response: ', got.body );

    if( err )
    throw _.errLogOnce( err );

    var data = JSON.parse( got.body );

    /*video*/
    var video = _.entitySearch({ src : data, ins : 'byResolution'});
    var videoKeys = Object.keys( video );

    video = video[ videoKeys[ 0 ] ];

    var resolutions = Object.keys( video );

    if( resolutions.indexOf( o.resolution ) === -1 )
    throw _.err( 'Unavailable video resolution: ', o.resolution, ',available are:', resolutions );

    var formats = Object.keys( video[ o.resolution ] );

    if( formats.indexOf( o.format + 'VideoUrl' ) === -1 )
    throw _.err( 'Unavailable video format: ', o.format );

    var videoUrl = video[ o.resolution ][ o.format + 'VideoUrl' ];

    /*subtitles*/
    if( !o.videoOnly )
    {
      var sub = _.entitySearch({ src : data, ins : 'subtitles' });
      var subKeys = Object.keys( sub );

      sub = sub[ subKeys[ 0 ] ];

      var subtitlesLangs = Object.keys( sub );

      if( subtitlesLangs.indexOf( o.subtitles ) === -1 )
      throw _.err( 'Unavailable subtitles language: ', o.subtitles, ',available are:', subtitlesLangs );

      var subUrl = self.config.site + sub[ o.subtitles ];
    }

    if( o.videoOnly )
    {
      return videoUrl;
    }

    return { videoUrl : videoUrl, subUrl  : subUrl };
  });
}

_resourceVideoUrlGet.defaults =
{
  id : null,
  resolution : '720p',
  format : 'mp4',
  subtitles : 'en',

  videoOnly : true
}

//

function _resourceHtmlGet( id )
{
  var self = this;
  var urlOptions =
  {
    dst : self.config.getSupplementUrl,
    dictionary:
    {
      '{course_id}' : self.currentCourse.raw.id,
      '{element_id}' : id,
    }
  }
  var getUrl = _.strReplaceAll( urlOptions );

  return self._request( getUrl )
  .thenDo( function( err, got )
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
    return result[ keys[ 0 ] ];

  });
}

//

var ResourceKindMapper = wNameMapper
({

  /* terminal */

  'discussion' : 'discussion',
  'quiz' : 'problem',
  'exam' : 'page',/*!!!cant set two same types*/
  'supplement' : 'html',
  'lecture' : 'video',

  /* non-terminal */

  // 'vertical' : 'page',
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


  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

};

// define

_.protoMake
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

})();
