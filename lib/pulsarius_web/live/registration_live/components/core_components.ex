# defmodule PulsariusWeb.CoreComponents do
#   use Phoenix.Component

#   import PulsariusWeb.ErrorHelpers

#  @doc """
#   Renders a simple form.

#   ## Examples

#       <.simple_form for={@form} phx-change="validate" phx-submit="save">
#         <.input field={@form[:email]} label="Email"/>
#         <.input field={@form[:username]} label="Username" />
#         <:actions>
#           <.button>Save</.button>
#         </:actions>
#       </.simple_form>
#   """
#   attr :for, :any, required: true, doc: "the datastructure for the form"
#   attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

#   attr :rest, :global,
#     include: ~w(autocomplete name rel action enctype method novalidate target multipart),
#     doc: "the arbitrary HTML attributes to apply to the form tag"

#   slot :inner_block, required: true
#   slot :actions, doc: "the slot for form actions, such as a submit button"

#   def simple_form(assigns) do
#     ~H"""
#     <.form :let={f} for={@for} as={@as} {@rest}>
#       <div class="mt-10 space-y-8 bg-white">
#         <%= render_slot(@inner_block, f) %>
#         <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
#           <%= render_slot(action, f) %>
#         </div>
#       </div>
#     </.form>
#     """
#   end

#    @doc """
#   Renders a button.

#   ## Examples

#       <.button>Send!</.button>
#       <.button phx-click="go" class="ml-2">Send!</.button>
#   """
#   attr :type, :string, default: nil
#   attr :class, :string, default: nil
#   attr :rest, :global, include: ~w(disabled form name value)

#   slot :inner_block, required: true

#   def button(assigns) do
#     ~H"""
#     <button
#       type={@type}
#       class={[
#         "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
#         "text-sm font-semibold leading-6 text-white active:text-white/80",
#         @class
#       ]}
#       {@rest}
#     >
#       <%= render_slot(@inner_block) %>
#     </button>
#     """
#   end

#   @doc """
#   Renders an input with label and error messages.

#   A `Phoenix.HTML.FormField` may be passed as argument,
#   which is used to retrieve the input name, id, and values.
#   Otherwise all attributes may be passed explicitly.

#   ## Types

#   This function accepts all HTML input types, considering that:

#     * You may also set `type="select"` to render a `<select>` tag

#     * `type="checkbox"` is used exclusively to render boolean values

#     * For live file uploads, see `Phoenix.Component.live_file_input/1`

#   See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
#   for more information.

#   ## Examples

#       <.input field={@form[:email]} type="email" />
#       <.input name="my-input" errors={["oh no!"]} />
#   """
#   attr :id, :any, default: nil
#   attr :name, :any
#   attr :label, :string, default: nil
#   attr :value, :any

#   attr :type, :string,
#     default: "text",
#     values: ~w(checkbox color date datetime-local email file hidden month number password
#                range radio search select tel text textarea time url week)

#   attr :field, Phoenix.HTML.FormField,
#     doc: "a form field struct retrieved from the form, for example: @form[:email]"

#   attr :errors, :list, default: []
#   attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
#   attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
#   attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
#   attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

#   attr :rest, :global,
#     include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
#                 multiple pattern placeholder readonly required rows size step)

#   slot :inner_block

#   def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
#     assigns
#     |> assign(field: nil, id: assigns.id || field.id)
#     |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
#     |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
#     |> assign_new(:value, fn -> field.value end)
#     |> input()
#   end

#   def input(%{type: "checkbox", value: value} = assigns) do
#     assigns =
#       assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

#     ~H"""
#     <div phx-feedback-for={@name}>
#       <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
#         <input type="hidden" name={@name} value="false" />
#         <input
#           type="checkbox"
#           id={@id}
#           name={@name}
#           value="true"
#           checked={@checked}
#           class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
#           {@rest}
#         />
#         <%= @label %>
#       </label>
#       <.error :for={msg <- @errors}><%= msg %></.error>
#     </div>
#     """
#   end

#   def input(%{type: "select"} = assigns) do
#     ~H"""
#     <div phx-feedback-for={@name}>
#       <.label for={@id}><%= @label %></.label>
#       <select
#         id={@id}
#         name={@name}
#         class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
#         multiple={@multiple}
#         {@rest}
#       >
#         <option :if={@prompt} value=""><%= @prompt %></option>
#         <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
#       </select>
#       <.error :for={msg <- @errors}><%= msg %></.error>
#     </div>
#     """
#   end

#   def input(%{type: "textarea"} = assigns) do
#     ~H"""
#     <div phx-feedback-for={@name}>
#       <.label for={@id}><%= @label %></.label>
#       <textarea
#         id={@id}
#         name={@name}
#         class={[
#           "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
#           "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
#           @errors == [] && "border-zinc-300 focus:border-zinc-400",
#           @errors != [] && "border-rose-400 focus:border-rose-400"
#         ]}
#         {@rest}
#       ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
#       <.error :for={msg <- @errors}><%= msg %></.error>
#     </div>
#     """
#   end

#   # All other inputs text, datetime-local, url, password, etc. are handled here...
#   def input(assigns) do
#     ~H"""
#     <div phx-feedback-for={@name}>
#       <.label for={@id}><%= @label %></.label>
#       <input
#         type={@type}
#         name={@name}
#         id={@id}
#         value={Phoenix.HTML.Form.normalize_value(@type, @value)}
#         class={[
#           "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
#           "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
#           @errors == [] && "border-zinc-300 focus:border-zinc-400",
#           @errors != [] && "border-rose-400 focus:border-rose-400"
#         ]}
#         {@rest}
#       />
#       <.error :for={msg <- @errors}><%= msg %></.error>
#     </div>
#     """
#   end

#   @doc """
#   Renders a label.
#   """
#   attr :for, :string, default: nil
#   slot :inner_block, required: true

#   def label(assigns) do
#     ~H"""
#     <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
#       <%= render_slot(@inner_block) %>
#     </label>
#     """
#   end

# #   @doc """
# #   Generates a generic error message.
# #   """
# #   slot :inner_block, required: true

# #   def error(assigns) do
# #     ~H"""
# #     <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
# #       <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
# #       <%= render_slot(@inner_block) %>
# #     </p>
# #     """
# #   end

#   @doc """
#   Renders a header with title.
#   """
#   attr :class, :string, default: nil

#   slot :inner_block, required: true
#   slot :subtitle
#   slot :actions

#   def header(assigns) do
#     ~H"""
#     <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
#       <div>
#         <h1 class="text-lg font-semibold leading-8 text-zinc-800">
#           <%= render_slot(@inner_block) %>
#         </h1>
#         <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
#           <%= render_slot(@subtitle) %>
#         </p>
#       </div>
#       <div class="flex-none"><%= render_slot(@actions) %></div>
#     </header>
#     """
#   end
# end
