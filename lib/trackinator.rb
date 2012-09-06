require 'trackinator/version'
require 'trackinator/google'
require 'trackinator/you_track'
require 'trackinator/importer'

module Trackinator

  ID = /^(?:\d+\.?)+$/

  TYPE = /^story$|^feature$|^task$|^bug$/

  PRIORITY = /^low$|^normal$|^high$|^show-stopper$/

  SUBSYSTEM = /^android$|^backend$|^ios$/

  REQUIRED = %w{
      project
      id
      subsystem
      summary
      description
      outcome
  }

  TRACKINATOR_RC = %w{
      youtrack_username
      youtrack_password
      google_username
      google_password
      host
      path_prefix
  }

end