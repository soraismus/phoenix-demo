defmodule AssessmentWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use AssessmentWeb, :controller
      use AssessmentWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: AssessmentWeb
      import Plug.Conn
      import AssessmentWeb.Router.Helpers
      import AssessmentWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/assessment_web/templates",
                        namespace: AssessmentWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import AssessmentWeb.Router.Helpers
      import AssessmentWeb.ErrorHelpers
      import AssessmentWeb.Gettext

      def is_administrator?(agent) do
        !is_nil(agent) && agent.account_type == "administrator"
      end

      def is_courier?(agent) do
        !is_nil(agent) && agent.account_type == "courier"
      end

      def is_pharmacy?(agent) do
        !is_nil(agent) && agent.account_type == "pharmacy"
      end
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import AssessmentWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
