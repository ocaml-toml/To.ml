val decode : 'a CConv.Decode.decoder -> TomlTypes.value TomlTypes.Table.t -> 'a CConv.or_error
val decode_exn : 'a CConv.Decode.decoder -> TomlTypes.value TomlTypes.Table.t -> 'a
