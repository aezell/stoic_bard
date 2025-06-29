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
          class="bg-royal-blue hover:bg-blue-800 text-white px-8 py-4 text-lg rounded-lg shadow-lg transition-all font-semibold border-0 cursor-pointer inline-flex items-center justify-center"
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
          <div class="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
            <div
              class="bg-royal-blue h-full rounded-full transition-all duration-300"
              style={"width: #{(@current_index + 1) / length(@questions) * 100}%"}
            >
            </div>
          </div>
        </div>
        
    <!-- Question -->
        <div class="bg-white rounded-lg shadow-xl border border-gray-100">
          <div class="p-8">
            <h2 class="text-3xl font-serif text-royal-blue mb-6">
              {@current_question.question}
            </h2>

            <form phx-submit="answer_question" class="space-y-6">
              <textarea
                name="answer"
                placeholder={@current_question.placeholder}
                class="w-full h-32 text-lg p-4 border border-gray-300 rounded-md focus:ring-2 focus:ring-royal-blue focus:border-transparent resize-none font-serif leading-relaxed"
                phx-hook="AutoFocus"
                id={"question-#{@current_question.id}"}
                required
              ><%= @current_answer %></textarea>

              <div class="flex justify-between">
                <%= if @current_index > 0 do %>
                  <button
                    type="button"
                    phx-click="previous_question"
                    class="px-6 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors font-semibold cursor-pointer"
                  >
                    Previous
                  </button>
                <% else %>
                  <div></div>
                <% end %>

                <button
                  type="submit"
                  class="px-6 py-2 bg-royal-blue hover:bg-blue-800 text-white rounded-md font-semibold transition-colors cursor-pointer"
                >
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
        <div class="inline-block w-16 h-16 border-4 border-royal-blue border-t-warm-gold rounded-full animate-spin mb-8">
        </div>
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
    {wisdom, essence} = parse_advice(assigns.advice)
    assigns = assign(assigns, wisdom: wisdom, essence: essence)

    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-4xl mx-auto">
        <div class="bg-white rounded-lg shadow-xl border border-gray-100">
          <div class="p-8">
            <h2 class="text-4xl font-serif text-royal-blue mb-8 text-center">
              Wisdom for Thy Journey
            </h2>

            <div class="prose prose-lg max-w-none mb-8">
              <div class="advice-text whitespace-pre-line">
                {@wisdom}
              </div>
            </div>

            <div class="bg-gradient-to-r from-royal-blue/10 to-purple-100 p-6 rounded-lg mb-8">
              <h3 class="text-xl font-serif text-royal-blue mb-4 text-center">
                Essence to Share
              </h3>
              <div id="essence-quote" class="text-center text-lg italic font-medium text-gray-800">
                {@essence}
              </div>
            </div>

            <div class="flex justify-center space-x-4">
              <button
                phx-click="start_over"
                class="px-6 py-3 bg-royal-blue hover:bg-blue-800 text-white rounded-md font-semibold transition-colors cursor-pointer"
              >
                Reflect Again
              </button>
              <button
                onclick="navigator.share ? navigator.share({title: 'Wisdom from The Bard', text: document.getElementById('essence-quote').innerText}) : alert('Sharing not supported')"
                class="px-6 py-3 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors font-semibold cursor-pointer"
              >
                Share Essence
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp parse_advice(advice) do
    # Split advice into WISDOM and ESSENCE sections
    case String.split(advice, ["ESSENCE", "\nESSENCE"], parts: 2) do
      [wisdom_part, essence_part] ->
        # Clean up the wisdom section by removing "WISDOM" header if present
        wisdom =
          wisdom_part
          |> String.replace(~r/^WISDOM\s*\n?/m, "")
          |> String.trim()

        # Clean up the essence section
        essence =
          essence_part
          |> String.trim()
          # Remove opening quotes (regular and smart quotes)
          |> String.replace(~r/^["'"]*/, "")
          # Remove closing quotes (regular and smart quotes)
          |> String.replace(~r/["'"]*$/, "")

        {wisdom, essence}

      [full_advice] ->
        # Fallback: if no ESSENCE section found, use full advice as wisdom
        # and extract a meaningful quote as essence
        wisdom = String.trim(full_advice)
        essence = extract_essence_fallback(wisdom)
        {wisdom, essence}
    end
  end

  defp extract_essence_fallback(wisdom) do
    # Try to extract a meaningful sentence as essence if parsing fails
    sentences = String.split(wisdom, ~r/[.!?]+/)

    # Find a sentence with stoic or Shakespearean keywords
    meaningful_sentence =
      Enum.find(sentences, fn sentence ->
        String.contains?(String.downcase(sentence), [
          "thou",
          "thy",
          "virtue",
          "wisdom",
          "heart",
          "soul",
          "life"
        ])
      end)

    case meaningful_sentence do
      nil -> "Virtue is the highest good, and wisdom thy truest guide."
      sentence -> String.trim(sentence) <> "."
    end
  end

  defp error_display(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 text-center">
      <div class="max-w-2xl mx-auto">
        <div class="bg-red-100 border border-red-400 text-red-700 px-6 py-4 rounded-md mb-8">
          <h2 class="text-2xl font-serif text-red-800 mb-2">
            Alas, wisdom eludes us for now
          </h2>
          <p class="text-red-700">
            {@error}
          </p>
        </div>

        <button
          phx-click="start_over"
          class="px-6 py-3 bg-royal-blue hover:bg-blue-800 text-white rounded-md font-semibold transition-colors cursor-pointer"
        >
          Try Again
        </button>
      </div>
    </div>
    """
  end
end
