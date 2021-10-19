defmodule Link.Index do
  @moduledoc """
  The home screen.
  """
  use CoreWeb, :live_view
  use CoreWeb.Layouts.Website.Component, :index
  alias CoreWeb.Layouts.Website.Component, as: Website

  alias EyraUI.Card.PrimaryCTA
  alias EyraUI.Panel.USP
  alias EyraUI.Text.{Title1, Intro}
  alias EyraUI.Grid.{AbsoluteGrid}
  alias EyraUI.Hero.HeroLarge

  data(current_user, :any)

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> update_menus()
    }
  end

  def cta_title(nil) do
    dgettext("eyra-link", "member.card.title")
  end

  def cta_title(current_user) do
    dgettext("eyra-link", "member.profile.card.title", user: current_user.displayname)
  end

  @impl true
  def handle_event("menu-item-clicked", %{"action" => action}, socket) do
    # toggle menu
    {:noreply, push_redirect(socket, to: action)}
  end

  def primary_cta_button_label(current_user) do
    if current_user.researcher do
      dgettext("eyra-link", "dashboard-button")
    else
      dgettext("eyra-link", "marketplace.button")
    end
  end

  def primary_cta_path(socket, current_user) do
    if current_user.researcher do
      Routes.live_path(socket, Link.Dashboard)
    else
      Routes.live_path(socket, Link.Marketplace)
    end
  end

  def render(assigns) do
    ~H"""
      <Website
        user={{ @current_user}}
        user_agent={{ Browser.Ua.to_ua(@socket) }}
        menus={{ @menus }}
      >
        <template slot="hero">
          <HeroLarge
            title={{ dgettext("eyra-link", "welcome.title") }}
            subtitle={{ dgettext("eyra-link", "welcome.subtitle") }}
          />
        </template>
        <ContentArea>
          <MarginY id={{:page_top}} />
          <AbsoluteGrid>
            <div class="md:col-span-2">
              <Title1>
                {{ dgettext("eyra-link", "link.title") }}
              </Title1>
              <Intro>
                {{ dgettext("eyra-link", "link.message") }}
              </Intro>
              <Intro>
                {{ dgettext("eyra-link", "link.message.interested") }}
                <a href="mailto:info@researchpanl.eu" class="text-primary" >info@researchpanl.eu</a>.
              </Intro>
            </div>
            <div>
              <div :if={{ @current_user != nil }}>
                <PrimaryCTA
                  title={{ cta_title(@current_user) }}
                  button_label={{ primary_cta_button_label(@current_user) }}
                  to={{ primary_cta_path(@socket, @current_user) }} />
              </div>
              <div :if={{ @current_user == nil }}>
                <PrimaryCTA title={{ dgettext("eyra-link", "signup.card.title") }}
                  button_label={{ dgettext("eyra-link", "signup.card.button") }}
                  to={{ Routes.user_session_path(@socket, :new) }} />
              </div>
            </div>
            <USP title={{ dgettext("eyra-link", "usp1.title") }} description={{ dgettext("eyra-link", "usp1.description") }} />
            <USP title={{ dgettext("eyra-link", "usp2.title") }} description={{ dgettext("eyra-link", "usp2.description") }} />
            <USP title={{ dgettext("eyra-link", "usp3.title") }} description={{ dgettext("eyra-link", "usp3.description") }} />
          </AbsoluteGrid>
        </ContentArea>
    </Website>
    """
  end
end
