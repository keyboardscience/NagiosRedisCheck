module Nagios
    module RedisCheck
        class Sidekiq  < Nagios::Plugin
            attr_reader :argv

            def initialized(argv = [])
                @argv = argv
            end

            def options
                @options ||= Slop.parse do |o|
                    o.string '-u', '--uri', 'Redis type connection string. E.g. redis://:auth@localhost:6379/0'
                    o.string '-m', '--mode', 'Mode to check. Possible modes: schedule, dead, retry'
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
                key = ''
                case options[:mode]
                when 'schedule'
                  key = 'sidekiq:schedule'
                when 'dead'
                  key = 'sidekiq:dead'
                when 'retry'
                  key = 'sidekiq:retry'
                else
                  puts "SIDEKIQ UNKNOWN: missing parameter for mode."
                  exit 3
                end

                begin
                  @value = client.zcard(key)
                rescue Exception => e
                  p e
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
                "#{@value} jobs in #{options[:mode]} set"
            end

            private
            def client
              begin
                if options[:uri] == nil
                  puts "SIDEKIQ UNKNOWN: missing parameter for uri. No default provided."
                  exit 3
                end

                @client = Redis.new(:url => options[:uri])
              rescue Exception => e
                p e
                exit 3
              end
            end
        end
    end
end
