# Copyright (C) 2021 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"Array"     use
"String"    use
"Variant"   use
"algorithm" use
"control"   use

"Var" use

makeVariableSchema: [
  refToVar: processor: ;;
  var: refToVar getVar;

  varSchema: VariableSchema;
  var.data.getTag (
    VarImport [
      VariableSchemaTags.FUNCTION_SCHEMA @varSchema.@data.setTag
      functionSchema: VariableSchemaTags.FUNCTION_SCHEMA @varSchema.@data.get;
      functionId: VarImport var.data.get;
      node: functionId processor.blocks.at.get;
      signature: node.csignature;
      signature.inputs.size @functionSchema.@inputSchemaIds.resize
      signature.inputs.size [
        i signature.inputs.at getVar.mplSchemaId i @functionSchema.@inputSchemaIds.at set
      ] times

      signature.outputs.size @functionSchema.@outputSchemaIds.resize
      signature.outputs.size [
        i signature.outputs.at getVar.mplSchemaId i @functionSchema.@outputSchemaIds.at set
      ] times

      signature.variadic new @functionSchema.!variadic
      signature.convention new @functionSchema.!convention
    ]
    VarRef [
      VariableSchemaTags.REF_SCHEMA @varSchema.@data.setTag
      refSchema: VariableSchemaTags.REF_SCHEMA @varSchema.@data.get;
      ref: VarRef var.data.get.refToVar;
      pointee: ref getVar;
      ref.mutable @refSchema.!mutable
      pointee.mplSchemaId new @refSchema.!pointeeSchemaId
    ]
    VarStruct [
      VariableSchemaTags.STRUCT_SCHEMA @varSchema.@data.setTag
      structSchema: VariableSchemaTags.STRUCT_SCHEMA @varSchema.@data.get;
      struct: VarStruct var.data.get.get;
      struct.fields.size @structSchema.@data.resize
      struct.fields.size [
        field: i struct.fields.at;
        fieldSchema: FieldSchema;
        field.refToVar getVar.mplSchemaId @fieldSchema.@valueSchemaId set
        field.nameInfo new @fieldSchema.!nameInfo
        @fieldSchema i @structSchema.@data.at set
      ] times
    ]
    [
      VariableSchemaTags.BUILTIN_TYPE_SCHEMA @varSchema.@data.setTag
      builtinTypeSchema: VariableSchemaTags.BUILTIN_TYPE_SCHEMA @varSchema.@data.get;
      var.data.getTag @builtinTypeSchema.@tag set
    ]
  ) case

  refToVar isVirtual [
    schemaId: @varSchema @processor getVariableSchemaId;
    VariableSchemaTags.VIRTUAL_VALUE_SCHEMA @varSchema.@data.setTag
    virtualValueSchema: VariableSchemaTags.VIRTUAL_VALUE_SCHEMA @varSchema.@data.get;
    schemaId new @virtualValueSchema.!schemaId
    refToVar getVirtualValue @virtualValueSchema.!virtualValue
  ] when

  @varSchema
];

getVariableSchemaId: [
  processor:;
  varSchema:;
  findResult: varSchema processor.schemaTable.find;
  findResult.success [
    findResult.value new
  ] [
    schemaId: processor.schemaBuffer.size;
    varSchema schemaId @processor.@schemaTable.insert
    @varSchema @processor.@schemaBuffer.append
    schemaId new
  ] if
];

VariableSchema: [{
  VARIABLE_SCHEMA: ();
  irTypeId: -1;
  dbgTypeId: -1;
  dbgTypeDeclarationId: -1;
  nilVar: RefToVar;
  data: (
    BuiltinTypeSchema
    FunctionSchema
    RefSchema
    StructSchema
    VirtualValueSchema
  ) Variant;

  equal: [
    other:;
    data.getTag other.data.getTag = ~ [FALSE] [
      data.getTag (
        VariableSchemaTags fieldCount [
          i new i new [
            tag:;
            tag data.get
            tag other.data.get =
          ] bind
        ] times

        [
          "invalid tag in VariableSchema" failProc
          FALSE
        ]
      ) case
    ] if
  ];

  hash: [
    variableSchema: data;
    seed: 0n32;
    @seed variableSchema.getTag hashCombine
    variableSchema [value:; @seed value hashSchema] visit
    @seed
  ];
}];

VariableSchemaTags: (
  "BUILTIN_TYPE_SCHEMA"
  "FUNCTION_SCHEMA"
  "REF_SCHEMA"
  "STRUCT_SCHEMA"
  "VIRTUAL_VALUE_SCHEMA"
) Int32 enum;

BuiltinTypeSchema: [{
  BUILTIN_TYPE_SCHEMA: ();
  tag: Int32;

  equal: [other:; tag other.tag =];
}];

RefSchema: [{
  REF_SCHEMA: ();
  pointeeSchemaId: Int32;
  mutable: Cond;

  equal: [other:; pointeeSchemaId other.pointeeSchemaId = [mutable other.mutable =] &&];
}];

FieldSchema: [{
  FIELD_SCHEMA: ();
  nameInfo: Int32;
  valueSchemaId: Int32;

  equal: [other:; nameInfo other.nameInfo = [valueSchemaId other.valueSchemaId =] &&];
}];

FunctionSchema: [{
  FUNCTION_SCHEMA: ();
  inputSchemaIds:  Int32 Array;
  outputSchemaIds: Int32 Array;
  convention: String;
  variadic: Cond;

  equal: [
    other:;
    convention other.convention = [
      variadic other.variadic = [
        inputSchemaIds other.inputSchemaIds = [
          outputSchemaIds other.outputSchemaIds =
        ] &&
      ] &&
    ] &&
  ];
}];

VirtualValueSchema: [{
  VIRTUAL_VALUE_SCHEMA: ();
  schemaId: Int32;
  virtualValue: String;

  equal: [other:; schemaId other.schemaId = [virtualValue other.virtualValue =] &&];
}];

StructSchema: [{
  STRUCT_SCHEMA: ();
  data: FieldSchema Array;

  equal: [other:; data other.data =];
}];

twoWith: [
  predicate:;
  x:y:;;
  @x predicate
  @y predicate and
];

hashSchema: ["FIELD_SCHEMA" has] [
  fieldSchema:;
  seed:;
  @seed fieldSchema.nameInfo hashCombine
  @seed fieldSchema.valueSchemaId hashCombine
] pfunc;

hashSchema: ["REF_SCHEMA" has] [
  refSchema:;
  seed:;
  @seed refSchema.pointeeSchemaId hashCombine
  @seed refSchema.mutable hashCombine
] pfunc;

hashSchema: ["FUNCTION_SCHEMA" has] [
  functionSchema:;
  seed:;
  functionSchema.inputSchemaIds [
    value:;
    @seed value hashCombine
  ] each

  functionSchema.outputSchemaIds [
    value:;
    @seed value hashCombine
  ] each

  @seed functionSchema.convention.hash hashCombine
  @seed functionSchema.variadic hashCombine
] pfunc;

hashSchema: ["VIRTUAL_VALUE_SCHEMA" has] [
  virtualValueSchema:;
  seed:;
  @seed virtualValueSchema.schemaId hashCombine
  @seed virtualValueSchema.virtualValue.hash hashCombine
] pfunc;

hashSchema: ["STRUCT_SCHEMA" has] [
  structSchema: .data;
  seed:;
  structSchema [
    value:;
    @seed value hashSchema
  ] each
] pfunc;

hashSchema: ["BUILTIN_TYPE_SCHEMA" has] [.tag Nat32 cast hashCombine] pfunc;

visit: [
  variant:callback:;;
  variant.getTag (
    variant.typeList fieldCount [
      i new i new [@variant.get callback] bind
    ] times

    ["invalid tag in variant" failProc]
  ) case
];

hashCombine: [
  seed:value:;;
  value hashValue 0x9e3779b9n32 + seed 6n32 lshift + seed 2n32 rshift + @seed set
];

hashValue: [Int8 same] [Nat32 cast] pfunc;
hashValue: [Int16 same] [Nat32 cast] pfunc;
hashValue: [Int32 same] [Nat32 cast] pfunc;
hashValue: [Int64 same] [Nat64 cast Nat32 cast] pfunc;
hashValue: [Intx same] [Nat64 cast Nat32 cast] pfunc;
hashValue: [Nat8 same] [Nat32 cast] pfunc;
hashValue: [Nat16 same] [Nat32 cast] pfunc;
hashValue: [Nat32 same] [Nat32 cast] pfunc;
hashValue: [Nat32 same] [Nat32 cast] pfunc;
hashValue: [Nat64 same] [Nat32 cast] pfunc;
hashValue: [Natx same] [Nat32 cast] pfunc;
hashValue: [Cond same] [[1n32] [0n32] if] pfunc;
