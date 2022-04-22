defmodule Systems.Pool.StudentsView do
  use CoreWeb.UI.LiveComponent

  alias Core.Accounts
  alias Core.Enums.StudyProgramCodes
  alias Core.Pools.CriteriaFilters

  alias Frameworks.Pixel.Text.Title2
  alias Frameworks.Pixel.Selector.Selector
  alias CoreWeb.UI.ContentList

  prop(props, :map, required: true)

  data(students, :map)
  data(filtered_students, :map)
  data(filter_labels, :list)

  # Handle Selector Update
  def update(%{active_item_ids: active_filters, selector_id: :filters}, socket) do
    {
      :ok,
      socket
      |> assign(active_filters: active_filters)
      |> prepare_students()
    }
  end

  def update(%{id: id} = _params, socket) do
    students = Accounts.list_students([:profile, :features])
    filter_labels = CriteriaFilters.labels([])

    {
      :ok,
      socket
      |> assign(
        id: id,
        active_filters: [],
        students: students,
        filter_labels: filter_labels
      )
      |> prepare_students()
    }
  end

  defp filter(students, nil), do: students
  defp filter(students, []), do: students

  defp filter(students, filters) do
    students |> Enum.filter(&CriteriaFilters.include?(&1.features.study_program_codes, filters))
  end

  defp prepare_students(
         %{assigns: %{students: students, active_filters: active_filters}} = socket
       ) do
    socket
    |> assign(
      filtered_students:
        students
        |> filter(active_filters)
        |> Enum.map(&to_view_model(&1, socket))
    )
  end

  defp to_view_model(
         %{
           email: email,
           inserted_at: inserted_at,
           profile: %{
             fullname: fullname,
             photo_url: photo_url
           },
           features: features
         },
         socket
       ) do
    subtitle =
      [email | get_study_programs(features)]
      |> Enum.join(" ▪︎ ")

    tag = get_tag(features)
    photo_url = get_photo_url(photo_url, features)
    image = %{type: :avatar, info: photo_url}

    quick_summery =
      inserted_at
      |> CoreWeb.UI.Timestamp.apply_timezone()
      |> CoreWeb.UI.Timestamp.humanize()

    %{
      path: Routes.live_path(socket, Systems.Pool.OverviewPage),
      title: fullname,
      subtitle: subtitle,
      quick_summary: quick_summery,
      tag: tag,
      image: image
    }
  end

  defp get_study_programs(%{study_program_codes: study_program_codes})
       when is_list(study_program_codes) and study_program_codes != [] do
    study_program_codes
    |> Enum.map(&StudyProgramCodes.translate(&1))
  end

  defp get_study_programs(_) do
    []
  end

  def get_tag(%{study_program_codes: [_ | _]}) do
    %{type: :success, text: dgettext("link-studentpool", "student.tag.complete")}
  end

  def get_tag(_) do
    %{type: :delete, text: dgettext("link-studentpool", "student.tag.incomplete")}
  end

  def get_photo_url(nil, %{gender: :man}), do: "/images/profile_photo_default_male.svg"
  def get_photo_url(nil, %{gender: :woman}), do: "/images/profile_photo_default_female.svg"
  def get_photo_url(nil, _), do: "/images/profile_photo_default.svg"
  def get_photo_url(photo_url, _), do: photo_url

  def render(assigns) do
    ~F"""
      <ContentArea>
        <MarginY id={:page_top} />
        <Empty :if={@students == []}
          title={dgettext("link-studentpool", "students.empty.title")}
          body={dgettext("link-studentpool", "students.empty.description")}
          illustration="members"
        />
        <div :if={not Enum.empty?(@students)}>
          <div class="flex flex-row gap-3 items-center">
            <div class="font-label text-label">Filter:</div>
            <Selector id={:filters} items={@filter_labels} parent={%{type: __MODULE__, id: @id}} />
          </div>
          <Spacing value="L" />
          <Title2>{dgettext("link-studentpool", "tabbar.item.students")}: <span class="text-primary">{Enum.count(@filtered_students)}</span></Title2>
          <ContentList items={@filtered_students} />
        </div>
      </ContentArea>
    """
  end
end
