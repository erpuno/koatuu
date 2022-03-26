use Mix.Config

config :kvs,
  dba: :kvs_rocks,
  dba_st: :kvs_st,
  schema: [:kvs, :kvs_stream]

config :koatuu,
  logger_level: :debug,
  logger: [
    {:handler, :synrc, :logger_std_h,
     %{
       level: :debug,
       id: :synrc,
       max_size: 2000,
       module: :logger_std_h,
       config: %{type: :file, file: 'koatuu.log'},
       formatter:
         {:logger_formatter,
          %{
            template: [:time, ' ', :pid, ' ', :module, ' ', :msg, '\n'],
            single_line: true
          }}
     }}
  ]

