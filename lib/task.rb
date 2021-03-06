module Mandy
  class Task
    JSON_PAYLOAD_KEY = "json"
    KEY_VALUE_SEPERATOR = "\t" unless defined?(KEY_VALUE_SEPERATOR)
    NUMERIC_PADDING = 16

    def initialize(input=STDIN, output=STDOUT)
      @input, @output = input, output
    end

    def emit(key, value=nil)
      key = 'nil' if key.nil?
      @output.puts(value.nil? ? key.to_s : "#{serialize_key(key)}\t#{serialize_value(value)}")
    end

    def get(store, key)
      Mandy.stores[store].get(key)
    end

    def put(store, key, values)
      Mandy.stores[store].put(key, values)
    end

    private
    def pad(key)
      key_parts = key.to_s.split(".")
      key_parts[0] = key_parts.first.rjust(NUMERIC_PADDING, '0')
      key_parts.join('.')
    end
    
    def parameter(name)
      return find_json_param(name) if json_provided?
      ENV[name.to_s]
    end
    
    def find_json_param(name)
      @json_args ||= JSON.parse(URI.decode(ENV[JSON_PAYLOAD_KEY]))
      @json_args[name.to_s]
    end
    
    def json_provided?
      !ENV[JSON_PAYLOAD_KEY].nil?
    end
    
    def deserialize_key(key)
      key
    end
    
    def deserialize_value(value)
      value
    end
    
    def serialize_key(key)
      key = pad(key) if key.is_a?(Numeric) && key.to_s.length < NUMERIC_PADDING
      key
    end

    def serialize_value(value)
      value = ArraySerializer.new(value) if value.is_a?(Array)
      value.to_s
    end
  end
end