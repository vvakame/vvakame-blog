require "./h2o-mruby/logentry"
require "./h2o-mruby/redirect2https"

lambda do |env|
    # p env

    headers = pre_log_entry(env) || {}

    if is_require_redirect(env)
        headers["Location"] = get_location_url(env)
        return [301, headers, []]
    end

    return [399, headers, []]
end
