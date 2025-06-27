defmodule StoicBardWeb.ReflectionLive do
  use StoicBardWeb, :live_view

  @questions [
    %{
      id: 1,
      question: "What challenge weighs most heavily upon thy mind today?",
      placeholder: "Speak freely of what troubles thee..."
    },
    %{
      id: 2,
      question: "How didst thou respond when last faced with frustration or setback?",
      placeholder: "Reflect upon thy recent trials..."
    },
    %{
      id: 3,
      question:
        "What task or conversation dost thou avoid, though thou knowest it must be faced?",
      placeholder: "What duties call to thee unheeded..."
    },
    %{
      id: 4,
      question: "Where did gratitude find thee in yesterday's hours?",
      placeholder: "Recall thy moments of thankfulness..."
    },
    %{
      id: 5,
      question: "What relationship in thy life seeketh thy greater attention?",
      placeholder: "Consider thy bonds with others..."
    }
  ]

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_step, :landing)
      |> assign(:current_question_index, 0)
      |> assign(:questions, @questions)
      |> assign(:answers, %{})
      |> assign(:loading, false)
      |> assign(:advice, nil)
      |> assign(:error, nil)

    {:ok, socket}
  end

  def handle_event("start_reflection", _params, socket) do
    {:noreply, assign(socket, :current_step, :questions)}
  end

  def handle_event("answer_question", %{"answer" => answer}, socket) do
    current_index = socket.assigns.current_question_index
    current_question = Enum.at(socket.assigns.questions, current_index)

    # Store the answer
    answers = Map.put(socket.assigns.answers, current_question.id, answer)

    # Check if this is the last question
    if current_index + 1 >= length(socket.assigns.questions) do
      # All questions answered, generate advice
      socket =
        socket
        |> assign(:answers, answers)
        |> assign(:current_step, :loading)
        |> assign(:loading, true)

      send(self(), :generate_advice)
      {:noreply, socket}
    else
      # Move to next question
      {:noreply,
       socket
       |> assign(:answers, answers)
       |> assign(:current_question_index, current_index + 1)}
    end
  end

  def handle_event("previous_question", _params, socket) do
    current_index = socket.assigns.current_question_index

    if current_index > 0 do
      {:noreply, assign(socket, :current_question_index, current_index - 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("start_over", _params, socket) do
    socket =
      socket
      |> assign(:current_step, :landing)
      |> assign(:current_question_index, 0)
      |> assign(:answers, %{})
      |> assign(:loading, false)
      |> assign(:advice, nil)
      |> assign(:error, nil)

    {:noreply, socket}
  end

  def handle_info(:generate_advice, socket) do
    case StoicBard.ClaudeAPI.generate_advice(socket.assigns.answers) do
      {:ok, advice} ->
        {:noreply,
         socket
         |> assign(:current_step, :advice)
         |> assign(:advice, advice)
         |> assign(:loading, false)}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:current_step, :error)
         |> assign(:error, reason)
         |> assign(:loading, false)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-parchment">
      <%= case @current_step do %>
        <% :landing -> %>
          <.landing_page />
        <% :questions -> %>
          <.question_flow
            questions={@questions}
            current_index={@current_question_index}
            answers={@answers}
          />
        <% :loading -> %>
          <.loading_screen />
        <% :advice -> %>
          <.advice_display advice={@advice} />
        <% :error -> %>
          <.error_display error={@error} />
      <% end %>
    </div>
    """
  end

  defp landing_page(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 text-center">
      <div class="max-w-4xl mx-auto">
        <h1 class="text-6xl font-serif text-royal-blue mb-6">
          The Bard's Wisdom
        </h1>
        <p class="text-xl text-charcoal mb-8 leading-relaxed">
          Where Marcus Aurelius's stoic wisdom meets Shakespeare's eloquent verse.
          Answer five reflective questions and receive personalized guidance
          written in a voice both philosophical and poetic.
        </p>
        <button
          phx-click="start_reflection"
          class="btn btn-primary bg-royal-blue hover:bg-blue-800 text-white px-8 py-4 text-lg rounded-lg shadow-lg transition-all"
        >
          Begin Today's Reflection
        </button>
      </div>
    </div>
    """
  end

  defp question_flow(assigns) do
    current_question = Enum.at(assigns.questions, assigns.current_index)
    current_answer = Map.get(assigns.answers, current_question.id, "")

    assigns = assign(assigns, :current_question, current_question)
    assigns = assign(assigns, :current_answer, current_answer)

    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-3xl mx-auto">
        <!-- Progress indicator -->
        <div class="mb-8">
          <div class="flex justify-between text-sm text-charcoal mb-2">
            <span>Question {@current_index + 1} of {length(@questions)}</span>
            <span>{round((@current_index + 1) / length(@questions) * 100)}% Complete</span>
          </div>
          <div class="progress progress-primary w-full bg-gray-200">
            <div
              class="progress-bar bg-royal-blue h-2 rounded"
              style={"width: #{(@current_index + 1) / length(@questions) * 100}%"}
            >
            </div>
          </div>
        </div>
        
    <!-- Question -->
        <div class="card bg-white shadow-xl">
          <div class="card-body p-8">
            <h2 class="text-3xl font-serif text-royal-blue mb-6">
              {@current_question.question}
            </h2>

            <form phx-submit="answer_question" class="space-y-6">
              <textarea
                name="answer"
                placeholder={@current_question.placeholder}
                class="textarea textarea-bordered w-full h-32 text-lg"
                phx-hook="AutoFocus"
                id={"question-#{@current_question.id}"}
                required
              ><%= @current_answer %></textarea>

              <div class="flex justify-between">
                <%= if @current_index > 0 do %>
                  <button
                    type="button"
                    phx-click="previous_question"
                    class="btn btn-outline btn-secondary"
                  >
                    Previous
                  </button>
                <% else %>
                  <div></div>
                <% end %>

                <button type="submit" class="btn btn-primary bg-royal-blue hover:bg-blue-800">
                  {if @current_index + 1 >= length(@questions), do: "Receive Wisdom", else: "Continue"}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp loading_screen(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 text-center">
      <div class="max-w-2xl mx-auto">
        <div class="loading loading-spinner loading-lg text-royal-blue mb-8"></div>
        <h2 class="text-3xl font-serif text-royal-blue mb-4">
          The Bard considers thy words...
        </h2>
        <p class="text-lg text-charcoal">
          Wisdom is being prepared, woven with care and contemplation.
        </p>
      </div>
    </div>
    """
  end

  defp advice_display(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-4xl mx-auto">
        <div class="card bg-white shadow-xl">
          <div class="card-body p-8">
            <h2 class="text-4xl font-serif text-royal-blue mb-8 text-center">
              Wisdom for Thy Journey
            </h2>

            <div class="prose prose-lg max-w-none">
              <div class="advice-text whitespace-pre-line">
                {@advice}
              </div>
            </div>

            <div class="flex justify-center space-x-4 mt-8">
              <button phx-click="start_over" class="btn btn-primary bg-royal-blue hover:bg-blue-800">
                Reflect Again
              </button>
              <button
                onclick="navigator.share ? navigator.share({title: 'Wisdom from The Bard', text: document.querySelector('.prose div').innerText}) : alert('Sharing not supported')"
                class="btn btn-outline btn-secondary"
              >
                Share Wisdom
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp error_display(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 text-center">
      <div class="max-w-2xl mx-auto">
        <div class="alert alert-error mb-8">
          <h2 class="text-2xl font-serif text-white mb-2">
            Alas, wisdom eludes us for now
          </h2>
          <p class="text-white">
            {@error}
          </p>
        </div>

        <button phx-click="start_over" class="btn btn-primary bg-royal-blue hover:bg-blue-800">
          Try Again
        </button>
      </div>
    </div>
    """
  end
end
