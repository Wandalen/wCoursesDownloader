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

function _coursesListAct( data )
{
  var self = this;
  var con;

  con = Parent.prototype._coursesListAct.call( self );

  con.thenDo( function()
  {
    self._coursesData = JSON.parse( data ).linked[ 'courses.v1' ];

    self._coursesData.forEach( function( courseData )
    {
      var course = {};
      course.name = courseData.name;
      course.id = courseData.id;
      course.url = _.strReplaceAll( self.config.courseUrl,'{class_name}', courseData.slug );
      course.raw = courseData;
      self._courses.push( course );
    });

    con.give( self._courses );
  });

  return con;
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

  var chapters = self._resourcesData.courseMaterial.elements;

  if( !self._resources )
  self._resources = [];

  chapters.forEach( function ( chapter )
  {
    chapter.elements.forEach( function ( lecture )
    {
      lecture.elements.forEach( function ( element )
      {
        if( element.content.typeName === 'lecture' )
        {
          var videoId = element.content.definition.videoId;

          con.thenDo( _.routineSeal( self,self.getVideoUrl,[ videoId, '720p' ] ) )
          .ifNoErrorThen( function ( url )
          {
            var resource = {};
            resource.name = element.name;
            // resource.id  = ;
            resource.url = url;
            resource.type = element.content.typeName;
            resource.raw =  element;
            self._resources.push( resource );
          });
        }
      })
    });

  });

  return con;
}

//

function getVideoUrl( videoId, resolution )
{
  var self = this;
  var getUrl = _.strReplaceAll( self.config.getVideoApi,'{id}', videoId );

  var con = new wConsequence();

  self._request( getUrl )
  .thenDo( function( err, got )
  {
    if( err )
    err = _.err( err );

    if( got.response.statusCode !== 200 )
    err = _.err( 'Failed to get resources list. StatusCode: ', got.response.statusCode, 'Server response: ', got.body );

    if( err )
    return con.error( err );

    var data = JSON.parse( got.body );

    data.sources.forEach( function( source )
    {
      if( source.resolution == resolution )
      {
        var url = source.formatSources[ 'video/mp4' ];
        return con.give( url );
      }
    })

  });

  return con;
}

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
}

// --
// proto
// --

var Proto =
{

  init : init,

  _makeAct : _makeAct,
  _makePrepareHeadersForLogin : _makePrepareHeadersForLogin,

  _coursesListAct : _coursesListAct,

  _resourcesListAct : _resourcesListAct,
  _resourcesListRefineAct : _resourcesListRefineAct,

  getVideoUrl : getVideoUrl,


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
