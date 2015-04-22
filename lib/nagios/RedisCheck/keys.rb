module Nagios
    module RedisCheck
        class Keys  < Nagios::Plugin
            attr_reader :argv

            def initialized(argv = [])
                @argv = argv
            end

            def options
                @options ||= Slop.parse do |o|
                    o.string '-u', '--uri', 'Redis type connection string. E.g. redis://:auth@localhost:6379/0'
                    o.integer '-c', '--critical', 'Critical threshold value'
                    o.integer '-w', '--warning', 'Warning threshold value'
                    o.on '-v', '--version' do
                        puts '0.0a'
                        exit
                    end
                    o.on '-h', '--help' do
                        puts o
                        exit
                    end
                end
            end

            def check
                begin
                  @value = client.dbsize
                rescue Exception => e
                  #puts "KEYS UNKNOWN: #{e.message}"
                  exit 3
                end
            end

            def critical?
                if @value > options[:critical].to_i
                    return true
                end
            end

            def warning?
                if @value.to_i > options[:warning]
                    return true
                end
            end

            def ok?
                if self.critical? || self.warning?
                    return false
                else
                    return true
                end
            end

            def message
                "#{@value}"
            end

            private
            def client
                begin
                  if options[:uri] == nil
                    raise 'Missing URI parameter. No default is provided.'
                  end

                  @client = Redis.new(:url => options[:uri])
                rescue Exception => e
                  puts "KEYS UNKNOWN: #{e.message}"
                  exit 3
                end
            end
        end
    end
end
