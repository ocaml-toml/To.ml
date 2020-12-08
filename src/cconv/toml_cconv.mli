val decode :
     'a CConv.Decode.decoder
  -> Toml.Types.value Toml.Types.Table.t
  -> 'a CConv.or_error

val decode_exn :
  'a CConv.Decode.decoder -> Toml.Types.value Toml.Types.Table.t -> 'a
