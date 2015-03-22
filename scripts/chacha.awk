#!/usr/bin/gawk
BEGIN	{
}
{
  #u = match( $0, /[[:alnum:]]{8}(-[[:alnum:]]{4}){3}-[[:alnum:]]{12}/ )
  h = match( $0, /\"hostname\": \".*[^\"]\", /)

  if( h > 0 ) {
    print substr( $0, RSTART, RLENGTH )
  }
}
END	{
}
