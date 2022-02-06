# JackAnalyzer

- Added TestBridingTarget for the reason below.
  - Test bundle didn't work in command line tool target.
    So added App aiming target(TestBridingTarget) and 
    include all the files in it as a workaround so that
    all the test works in that app host.   
