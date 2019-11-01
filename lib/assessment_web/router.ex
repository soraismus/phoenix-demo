defmodule AssessmentWeb.Router do
  use AssessmentWeb, :router

  alias AssessmentWeb.AdministratorController
  alias AssessmentWeb.CourierController
  alias AssessmentWeb.OrderController
  alias AssessmentWeb.PatientController
  alias AssessmentWeb.PharmacyController

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AssessmentWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/administrators", AdministratorController
    resources "/couriers", CourierController
    resources "/orders", OrderController
    resources "/patients", PatientController
    resources "/pharmacies", PharmacyController
  end

  # Other scopes may use custom stacks.
  # scope "/api", AssessmentWeb do
  #   pipe_through :api
  # end
end
