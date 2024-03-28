defmodule Systems.Assignment.TemplateDataDonation do
  alias Systems.Assignment
  alias Systems.Workflow

  import CoreWeb.Gettext

  defstruct [:id]

  defimpl Assignment.Template do
    def title(t), do: Assignment.Templates.translate(t.id)

    def content_flags(_t) do
      Map.merge(Assignment.ContentFlags.new(), %{
        participants: false
      })
    end

    def workflow(_t),
      do: %Workflow.Config{
        type: :many_optional,
        library: %Workflow.LibraryModel{
          render?: true,
          items: [
            %Workflow.LibraryItemModel{
              special: :donate,
              tool: :feldspar_tool,
              title: Assignment.WorkflowItemSpecials.translate(:donate),
              description: dgettext("eyra-assignment", "workflow_item.donate.description")
            },
            %Workflow.LibraryItemModel{
              special: :questionnaire,
              tool: :alliance_tool,
              title: Assignment.WorkflowItemSpecials.translate(:questionnaire),
              description: dgettext("eyra-assignment", "workflow_item.questionnaire.description")
            },
            %Workflow.LibraryItemModel{
              special: :request_manual,
              tool: :document_tool,
              title: Assignment.WorkflowItemSpecials.translate(:request_manual),
              description: dgettext("eyra-assignment", "workflow_item.request.description")
            },
            %Workflow.LibraryItemModel{
              special: :download_manual,
              tool: :document_tool,
              title: Assignment.WorkflowItemSpecials.translate(:download_manual),
              description: dgettext("eyra-assignment", "workflow_item.download.description")
            }
          ]
        },
        initial_items: []
      }
  end
end
