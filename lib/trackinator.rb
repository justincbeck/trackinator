require 'trackinator/version'
require 'trackinator/google'
require 'trackinator/you_track'
require 'trackinator/importer'

module Trackinator

  ID = /^(?:\d+\.?)+$/

  TYPE = /^story$|^feature$|^task$|^bug$/

  PRIORITY = /^low$|^normal$|^high$|^show-stopper$/

  SUBSYSTEM = /^android$|^backend$|^ios$|^web$|^roku$/

  GOOGLE_REQUIRED = %w{
      project
      id
      subsystem
      summary
      description
      outcome
  }

  YOU_TRACK_REQUIRED = [
      "Type",
      "Subsystem",
      "Import Identifier"
  ]

  TRACKINATOR_RC = %w{
      youtrack_username
      youtrack_password
      google_username
      google_password
      host
      path_prefix
  }

end