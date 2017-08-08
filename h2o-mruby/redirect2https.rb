lambda do |env|
    if env["HTTP_HOST"] == "localhost:8080"
        return [399, {}, []]
    end

    # p env

    # https://github.com/kubernetes/ingress/blob/master/controllers/gce/README.md#redirecting-http-to-https
    if env["HTTP_X_FORWARDED_PROTO"] == "http"
        location_url = "https://#{env['HTTP_HOST']}#{env['PATH_INFO']}"
        if env["QUERY_STRING"] != ""
            location_url += "?#{env['QUERY_STRING']}"
        end
        return [301, {"Location" => location_url}, []]
    end

    return [399, {}, []]
end
