# Trackinator

This gem, when used correctly, will import a Google spreadsheet
into YouTrack as tickets.  The spreadsheet is a test plan which
defines features (and how to use them).  There are numerous
benefits to this approach:

- Scope is defined up front which reduces scope creep
- Creating the test plan forces developers to be appropriately familiar
  with the project
- A test plan is written up front (TDD at a macro level)

The format of the spreadsheet is as follows (columns can be in any order):

####project
The abbreviation for the project in YouTrack.  The project must
exist in YouTrack already, this gem will not create the project for you

####id
Similar to a version number.  Must be unique in this test plan.  Follows
the format x.y.z (this example is 3 levels deep) and there is no limit
to nesting depth.  Each level denotes sub-tickets that will be created
and associated to the level above.

####type
"Story" for top level items, "Features" and "Tasks" for items one or more
levels below "Story".  “Features” are user facing and "Tasks" are
implementation details.  "Tasks" will not be acceptance tested.

####summary
A one-line summarizing of the feature.

####description
A description of the feature including steps to use the feature.

####outcome
The expected outcome if the feature is used per the steps in the description.

####notes
Any additional notes (which will show up as a comment) that might be useful
for the developer or tester.

####references
A reference to the design document.  The format should be wf/c-<page>-<screen
(or range)>.  E.g. wf-12-5 or c-9-2-3 (where "wf" refers to wireframe and "c"
refers to composition)

####platform
This is usually one of iOS, iPhone, iPad, Android, Desktop Web, Mobile Web

####priority
One of Low, Normal, High, Show-stopper

## Installation

Add this line to your application's Gemfile:

    gem 'trackinator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install trackinator

## Usage

<pre>
Options:
     --youtrack-username, -y <s>:   Your YouTrack username
     --youtrack-password, -p <s>:   Your YouTrack password
       --google-username, -g <s>:   Your Google username
       --google-password, -a <s>:   Your Google password
         --youtrack-host, -o <s>:   YouTrack host
         --youtrack-port, -r <i>:   YouTrack port (default: 80)
  --youtrack-path-prefix, -e <s>:   YouTrack path prefix (e.g. '/youtrack/') (default: /)
                      --help, -h:   Show this message
                        filename:   File name in Google Docs
</pre>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
