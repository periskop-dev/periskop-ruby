module Periskop
    module Client
        class ExceptionInstance
            attr_accessor :class, :message, :stacktrace, :cause

            def initialize(cls, message, stacktrace, cause)
                @class = cls
                @message = message
                @stacktrace = stacktrace
                @cause = cause
            end
        end

        class HTTPContext
            def initialize(request_method, request_url, request_headers, request_body)
            @request_method = request_method
            @request_url = request_url
            @request_headers = request_headers
            @request_body = request_body
            end
        end


        class ExceptionWithContext
            def initialize(error, http_context, severity)
            @error = error
            @http_context = http_context
            @severity = severity
            @uuid = 1
            @timestamp = 1
            end
        end
    end
end
