require 'trackinator/version'
require 'trackinator/google'
require 'trackinator/you_track'


module Trackinator

  ID = /^(?:\d+\.?)+$/

  TYPE = /^story$|^feature$|^task$|^bug$/

  PRIORITY = /^low$|^normal$|^high$|^show-stopper$/

  REQUIRED = %w{
      project
      id
      summary
      description
      outcome
  }

end
