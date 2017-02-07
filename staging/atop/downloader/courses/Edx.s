( function _Edx_s_( ) {

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
var Self = function wDownloaderOfCoursesEdx( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'DownloaderOfCoursesEdx';

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

  self.config.options.form = self.config.payload;

}

//

function _makePrepareHeadersForLogin()
{
  var self = this;
  var con = Parent.prototype._makePrepareHeadersForLogin.call( self );

  function _getCSRF3( cookies )
  {
    console.log(cookies);
    var src =  cookies[ 0 ];
    src = src.split( ';' )[ 0 ];
    src = src.split( '=' );

    var token = src.pop();

    self.config.options.headers =
    {
      'Referer' : self.config.loginPageUrl,
      'X-CSRFToken' : token
    }

    con.give();
  }

  con.thenDo( _.routineSeal( self,self._request,[ self.config.loginPageUrl ] ) )
  .thenDo( function( err, got )
  {
    if( err )
    err = _.err( err );

    if( got.response.statusCode !== 200 )
    err = _.err( 'Failed to get resources list. StatusCode: ', got.response.statusCode, 'Server response: ', got.body );

    if( err )
    return con.error( err );

    return _getCSRF3( got.response.headers[ 'set-cookie' ] );

  });

  return con;
}

//

function _coursesListAct( )
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

    self._coursesData.forEach( function( courseData )
    {
      var course = {};
      var course_details = courseData.course_details;
      course.name = course_details.course_name;
      course.id = course_details.course_id;
      course.url = _.strReplaceAll( self.config.courseUrl,'{course_id}', course.id );
      course.username = courseData.user;
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

  var urlOptions =
  {
    dst : self.config.courseBlocksUrl,
    dictionary :
    {
      '{course_id}' : encodeURIComponent( self.currentCourse.id ),
      '{username}' : self.currentCourse.username
    }
  }

  var getUrl = _.strReplaceAll( urlOptions );

  /* */

  con = self._request( getUrl )
  .thenDo( function( err, got )
  {

    if( !err )
    if( got.response.statusCode !== 200 )
    err = _.err( 'Failed to get resources list. StatusCode : ', got.response.statusCode, 'Server response : ', got.body );

    if( err )
    return con.error( _.err( err ) );

    var data = JSON.parse( got.body );

    self._resourcesData = data;

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

  // !!! common for all classes should be in base class
  // verbose output is commong

  // /* */
  //
  // if( self.verbosity )
  // {
  //   con.ifNoErrorThen( function( resources )
  //   {
  //     logger.log( 'Resources:\n', _.toStr( resources, { json : 3 } ) );
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

  function parseBlockChilds( block )
  {
   //parse each child block here
   //
  }

  if( !self._resources )
  self._resources = [];

  self._resourcesData.forEach( function( data )
  {

    // if( data.type === 'chapter' )
    {
      var resource = {};
      resource.name = data.display_name;
      resource.id  = data.block_id;
      resource.dataUrl = data.student_view_url;
      resource.pageUrl = data.lms_web_url;
      resource.kind = self.ResourceKindMapper.valueFor( data.type );
      //resource.elements = [];
      resource.elements = data.children || [];
      resource.raw =  data;
      // currentBlock.elements.push( parseBlockChilds( data ) )

      self._resources.push( resource );
    }

  });

  return con;
}

// --
// type
// --

var ResourceKindMapper = wNameMapper
({

  /* terminal */

  'discussion' : 'discussion',
  'problem' : 'problem',
  'html' : 'html',
  'video' : 'video',

  /* non-terminal */

  'vertical' : 'page',
  'sequential' : 'section',
  'chapter' : 'chapter',
  'course' : 'course',

});

// --
// relationships
// --

var Composes =
{
  currentPlatform : 'Edx',
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
  ResourceKindMapper : ResourceKindMapper,
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
