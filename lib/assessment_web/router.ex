defmodule AssessmentWeb.Router do
  use AssessmentWeb, :router
  import Assessment.Utilities, only: [nilify_error: 1]
  alias Guardian.Plug.LoadResource, as: Guardian_LoadResource
  alias Guardian.Plug.Pipeline, as: Guardian_Pipeline
  alias Guardian.Plug.VerifyHeader, as: Guardian_VerifyHeader
  alias Guardian.Plug.VerifySession, as: Guardian_VerifySession
  alias AssessmentWeb.Guardian
  alias AssessmentWeb.AuthErrorHandler
  alias AssessmentWeb.GuardianController

  pipeline :browser do
    plug :accepts, ["html"]
    plug ProperCase.Plug.SnakeCaseParams
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian_Pipeline, module: Guardian, error_handler: AuthErrorHandler
    plug Guardian_VerifySession
    plug :authenticate_agent
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

  pipeline :api do
    plug :accepts, ["json", "csv"]
    plug ProperCase.Plug.SnakeCaseParams
    plug Guardian_Pipeline,
      error_handler: AssessmentWeb.SessionController,
      module: AssessmentWeb.Guardian
    plug Guardian_VerifyHeader, realm: "Token"
    plug Guardian_LoadResource, allow_blank: true
  end

  scope "/api", AssessmentWeb.Api do
    pipe_through :api

    get "/administrators",     AdministratorController, :index
    get "/administrators/:id", AdministratorController, :show
    post "/administrators",    AdministratorController, :create

    get "/couriers",           CourierController,       :index
    get "/couriers/:id",       CourierController,       :show

    get "/orders",             OrderController,         :index
    get "/orders/:id",         OrderController,         :show

    get "/patients",           PatientController,       :index
    get "/patients/:id",       PatientController,       :show

    get "/pharmacies",         PharmacyController,      :index
    get "/pharmacies/:id",     PharmacyController,      :show
  end

  defp authenticate_agent(conn, _) do
    assign(conn, :agent, GuardianController.identify_agent(conn) |> nilify_error())
  end
end
