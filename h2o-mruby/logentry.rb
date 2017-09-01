def pre_log_entry(env)
    # for access log
    # https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry
    req_url = "#{env['HTTP_X_FORWARDED_PROTO'] || 'http'}://#{env['HTTP_HOST']}#{env['PATH_INFO']}"
    if env["QUERY_STRING"] != ""
        req_url += "?#{env['QUERY_STRING']}"
    end
    input = env["rack.input"] ? env["rack.input"].read : ""
    req_size = input.size

    headers = {
        :LOG_NAME => "project/vvakame-host/logs/blog-container",
        # :TIMESTAMP => nil,
        :SEVERITY => "INFO",
        :HTTP_REQ_URL => req_url,
        :HTTP_REQ_SIZE => req_size,
        :HTTP_SERVER_IP => env["SERVER_ADDR"],
        :TRACE => (env["HTTP_X_CLOUD_TRACE_CONTEXT"] || "").split("/")[0],
    }
    # Time.now.to_i

    headers
        .select { |k, v| !v.nil? }
        .map{|k, v| ["x-fallthru-set-#{k}", v]}
        .to_h
end
