"String.String" use
"control.Int32" use

"Block.BlockSchema" use
"Mref.Mref" use

File: [{
  name: String;
  text: String;
  debugId: Int32;
  rootBlock: [BlockSchema] Mref;
}];

schema FileSchema: File;
