"String" useModule

"Mref" useModule

File: [{
  name: String;
  text: String;
  debugId: Int32;
  rootBlock: [BlockSchema] Mref;
}];

schema FileSchema: File;
