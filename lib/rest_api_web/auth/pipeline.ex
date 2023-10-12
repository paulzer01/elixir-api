defmodule RestApiWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :rest_api,
    module: RestApiWeb.Auth.Guardian,
    error_handler: RestApiWeb.Auth.GuardianErrorHandler

  # look for the token in the session first, then in the "Authorization" header
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
