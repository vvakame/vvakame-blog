def is_require_redirect(env)
    if env["HTTP_HOST"] == "localhost:8080"
        false
    elsif env["HTTP_X_FORWARDED_PROTO"] == "http"
        true
    else
        false
    end
end

def get_location_url(env)
    # https://github.com/kubernetes/ingress/blob/master/controllers/gce/README.md#redirecting-http-to-https
    if !is_require_redirect(env)
        return
    end

    location_url = "https://#{env['HTTP_HOST']}#{env['PATH_INFO']}"
    if env["QUERY_STRING"] != ""
        location_url += "?#{env['QUERY_STRING']}"
    end
    location_url
end
