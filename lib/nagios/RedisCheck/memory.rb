module Nagios
    module RedisCheck
        class Memory  < Nagios::Plugin
            attr_reader :argv

            def initialized(argv = [])
                @argv = argv
            end

            def options
                @options ||= Slop.parse do |o|
                    o.string '-u', '--uri', 'Redis type connection string. E.g. redis://:auth@localhost:6379/0'
                    o.integer '-c', '--critical', 'Critical threshold value'
                    o.integer '-w', '--warning', 'Warning threshold value'
                    o.string '-m', '--mode', 'Check command mode. Possible modes: cmem, pmem, lmem'
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
                case options[:mode]
                when 'cmem'
                    @value = client.info["used_memory"].to_i
                when 'pmem'
                    @value = client.info["used_memory_peak"].to_i
                when 'lmem'
                    @value = client.info["used_memory_lua"].to_i
                end
            end

            def critical?
                if @value > options[:critical].to_i
                    return true
                end
            end

            def warning?
                if @value > options[:warning].to_i
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
                "#{@value} bytes #{messageMap[options[:mode]]} memory consumed"
            end

            def messageMap
                { "cmem" => "current", "pmem" => "peak historical", "lmem" => "current lua scripting" }
            end

            private
            def client
                @client = Redis.new(:url => options[:uri])
            end
        end
    end
end
