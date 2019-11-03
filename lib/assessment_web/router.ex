defmodule AssessmentWeb.Router do
  use AssessmentWeb, :router
  import Assessment.Utilities, only: [prohibit_nil: 1]
  alias Guardian.Plug.Pipeline, as: GuardianPipeline
  alias Guardian.Plug.VerifySession, as: Guardian_VerifySession
  alias AssessmentWeb.Guardian
  alias AssessmentWeb.Guardian.Plug, as: GuardianPlug
  alias AssessmentWeb.AuthErrorHandler

  pipeline :browser do
    plug :accepts, ["html"]
    plug ProperCase.Plug.SnakeCaseParams
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GuardianPipeline, module: Guardian, error_handler: AuthErrorHandler
    plug Guardian_VerifySession
    plug :authenticate_agent
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
    assign(conn, :agent, get_agent_or_nil(conn))
  end

  defp get_agent_or_nil(conn) do
    with {:ok, token} <- conn |> GuardianPlug.current_token() |> prohibit_nil(),
         {:ok, agent, _claims} <- Guardian.resource_from_token(token) do
      agent
    else
      _ -> nil
    end
  end
end
