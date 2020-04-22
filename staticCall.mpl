"control.assert" use

staticCall: [
  staticCallBody:;
  copy staticCallLast:;   # required to be static
  copy staticCallFirst:;  # required to be static
  copy staticCallIndex:;  # can be dynamic


  [
    staticCallIndex staticCallFirst < ~ staticCallIndex staticCallLast < and r:;
    r ~ [
      (
        "index=" makeStringView staticCallIndex 0 cast
        "; first=" makeStringView staticCallFirst 0 cast
        "; last=" makeStringView staticCallLast 0 cast) addLog
    ] when
    r
  ] "Index of static call is out of range" assert

  staticCallFirst 2 staticCallFirst cast + staticCallLast > [ # static condition or die
    staticCallFirst @staticCallBody call
  ] [
    staticCallFirst 17 staticCallFirst cast + staticCallLast > [ # static condition or die
      [
        staticCallFirst staticCallLast < [
          staticCallIndex staticCallFirst = [ # dynamic condition in loop
            staticCallFirst @staticCallBody call # dont break, loop must be static
          ] when

          staticCallFirst 1 + @staticCallFirst set
          TRUE static
        ] [
          FALSE static
        ] if
      ] loop
    ] [
      staticCallMiddle: staticCallFirst staticCallLast + 2 staticCallFirst cast /;
      staticCallIndex staticCallMiddle < [
        staticCallIndex staticCallFirst staticCallMiddle @staticCallBody staticCall
      ] [
        staticCallIndex staticCallMiddle staticCallLast @staticCallBody staticCall
      ] if
    ] if
  ] if
];
