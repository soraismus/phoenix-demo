defmodule AssessmentWeb.Router do
  use AssessmentWeb, :router
  alias Assessment.Accounts

  pipeline :browser do
    plug :accepts, ["html"]
    plug ProperCase.Plug.SnakeCaseParams
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.Pipeline,
            module: AssessmentWeb.Guardian,
            error_handler: AssessmentWeb.AuthErrorHandler
    plug Guardian.Plug.VerifySession
    plug :check_for_login
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AssessmentWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/administrators", AdministratorController, except: [:edit, :update]
    resources "/couriers", CourierController, except: [:edit, :update]
    resources "/orders", OrderController
    resources "/patients", PatientController, except: [:edit, :update]
    resources "/pharmacies", PharmacyController, except: [:edit, :update]

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", AssessmentWeb do
  #   pipe_through :api
  # end

  defp authenticate_agent(conn, _) do
    case AssessmentWeb.Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> clear_session()
        |> put_flash(:error, "Login required")
        |> redirect(to: "/")
        |> halt()
      resource ->
        conn
        |> assign(:current_user, resource)
    end
  end

  defp check_for_login(conn, _) do
    token_result =
      conn
        |> AssessmentWeb.Guardian.Plug.current_token()
        |> AssessmentWeb.Guardian.resource_from_token()
    case token_result do
      {:ok, resource, _claims} ->
        conn
        |> assign(:logged_in?, !is_nil(resource))
      {:error, _} ->
        conn
        |> assign(:logged_in?, false)
    end
  end
end
