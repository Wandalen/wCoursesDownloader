module.exports =
{
  getUserCoursesUrl : 'https://www.coursera.org/api/memberships.v1?fields=courseId,enrolledTimestamp,grade,id,lastAccessedTimestamp,onDemandSessionMembershipIds,onDemandSessionMemberships,role,v1SessionId,vc,vcMembershipId,courses.v1(courseStatus,display,partnerIds,photoUrl,specializations,startDate,v1Details,v2Details),partners.v1(homeLink,name),v1Details.v1(sessionIds),v1Sessions.v1(active,certificatesReleased,dbEndDate,durationString,hasSigTrack,startDay,startMonth,startYear),v2Details.v1(onDemandSessions,plannedLaunchDate,sessionsEnabledAt),specializations.v1(logo,name,partnerIds,shortName)&includes=courseId,onDemandSessionMemberships,vcMembershipId,courses.v1(partnerIds,specializations,v1Details,v2Details),v1Details.v1(sessionIds),v2Details.v1(onDemandSessions),specializations.v1(partnerIds)&q=me&showHidden=true&filter=current,preEnrolled',
  loginPageUrl : 'https://www.coursera.org/?authMode=login',
  loginApiUrl :'https://www.coursera.org/api/login/',
}
