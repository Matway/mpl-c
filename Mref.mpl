Mref: [{
  ObjectSchema:;
  data: 0nx dynamic;

  CALL: [
    data ObjectSchema addressToReference @closure isConst [const] [] uif
  ];

  set: [
    ref: 0nx ObjectSchema addressToReference;
    !ref
    ref storageAddress !data
  ];
}];
