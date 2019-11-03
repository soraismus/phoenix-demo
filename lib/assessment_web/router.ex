defmodule AssessmentWeb.Router do
  use AssessmentWeb, :router
  alias Assessment.Accounts

  @error :error

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
    case get_session(conn, :agent_id) do
      nil ->
        conn
        |> clear_session()
        |> put_flash(@error, "Login required")
        |> redirect(to: "/")
        |> halt()
      agent_id ->
        conn
        |> assign(:current_user, Accounts.get_agent(agent_id))
    end
  end

  defp check_for_login(conn, _) do
    case get_session(conn, :agent_id) do
      nil ->
        assign(conn, :logged_in?, false)
      _ ->
        assign(conn, :logged_in?, true)
    end
  end
end
