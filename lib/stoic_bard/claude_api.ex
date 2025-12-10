defmodule StoicBard.ClaudeAPI do
  @moduledoc """
  Module for interacting with Claude API to generate Shakespearean Stoic advice.
  """

  require Logger

  @api_url "https://api.anthropic.com/v1/messages"
  @model "claude-haiku-4-5"
  @max_tokens 1000

  @system_prompt """
  You are the Shakespearean Stoic, a wise philosopher who combines the practical wisdom of Marcus Aurelius with the eloquent language of William Shakespeare. You provide life advice that is:

  Grounded in stoic principles: acceptance, focus on what one can control, impermanence, duty, inner peace, rational thinking, and virtue as the highest good
  Expressed in Shakespearean language: rich metaphors, iambic rhythm, archaic terms (thou, thy, dost, hath, etc.), poetic imagery, and theatrical references
  Compassionate yet firm: offering both comfort and challenge, never dismissive but always encouraging growth
  Relevant to modern life: addressing contemporary struggles while maintaining the classical voice
  Actionable: providing concrete guidance, not just abstract philosophy

  Draw upon themes from Shakespeare's plays (especially Hamlet, King Lear, The Tempest, Macbeth) and Marcus Aurelius's Meditations. Use period language naturally and include metaphors from nature, theater, seasons, and life's journey.

  Response Format:
  Provide two sections:
  WISDOM (200-300 words): Personalized advice addressing their specific situations while maintaining the philosophical voice. Begin with acknowledging their current state, then offer stoic guidance through Shakespearean expression.
  ESSENCE (25-35 words): A distilled, shareable quote that captures the core wisdom in beautiful, memorable language. This should stand alone as an inspiring snippet perfect for social media sharing.

  Example format:
  WISDOM
  [Full personalized response...]

  ESSENCE
  "The tempest of thy troubles shall pass, dear soul. Thou art the captain of thy ship, not the mercy of every wind that blows."
  """

  def generate_advice(answers) when is_map(answers) do
    case get_api_key() do
      nil ->
        {:error, "Claude API key not configured. Please set CLAUDE_API_KEY environment variable."}

      api_key ->
        user_content = format_user_answers(answers)

        body = %{
          model: @model,
          max_tokens: @max_tokens,
          system: @system_prompt,
          messages: [
            %{
              role: "user",
              content: user_content
            }
          ]
        }

        Logger.debug("Making request to Claude API")

        case Req.post(@api_url,
               json: body,
               headers: [
                 {"x-api-key", api_key},
                 {"anthropic-version", "2023-06-01"}
               ],
               receive_timeout: 30_000
             ) do
          {:ok, %Req.Response{status: 200, body: %{"content" => [%{"text" => advice}]}}} ->
            {:ok, advice}

          {:ok, %Req.Response{status: 200, body: response}} ->
            Logger.error("Unexpected Claude API response format: #{inspect(response)}")
            {:error, "Unexpected response format from Claude API"}

          {:ok, %Req.Response{status: status_code, body: body}} ->
            Logger.error("Claude API error - Status: #{status_code}, Body: #{inspect(body)}")
            handle_api_error(status_code, body)

          {:error, reason} ->
            Logger.error("HTTP request failed: #{inspect(reason)}")
            {:error, "Failed to connect to Claude API. Please try again."}
        end
    end
  end

  defp get_api_key do
    api_key =
      System.get_env("CLAUDE_API_KEY") || Application.get_env(:stoic_bard, :claude_api_key)

    Logger.debug(
      "API key present: #{if api_key, do: "yes (#{String.length(api_key)} chars)", else: "no"}"
    )

    api_key
  end

  defp format_user_answers(answers) do
    questions = [
      "What challenge weighs most heavily upon thy mind today?",
      "How didst thou respond when last faced with frustration or setback?",
      "What task or conversation dost thou avoid, though thou knowest it must be faced?",
      "Where did gratitude find thee in yesterday's hours?",
      "What relationship in thy life seeketh thy greater attention?"
    ]

    formatted_answers =
      questions
      |> Enum.with_index(1)
      |> Enum.map(fn {question, index} ->
        answer = Map.get(answers, index, "No response provided")
        "#{index}. #{question}\nAnswer: #{answer}"
      end)
      |> Enum.join("\n\n")

    """
    Here are my reflections on the five questions:

    #{formatted_answers}

    Please provide me with personalized Shakespearean Stoic advice based on these reflections.
    """
  end

  defp handle_api_error(status_code, body) do
    case status_code do
      400 ->
        {:error, "Invalid request sent to Claude API. Please try again."}

      401 ->
        {:error, "Authentication failed. Please check your Claude API key."}

      403 ->
        {:error, "Access forbidden. Please check your Claude API permissions."}

      429 ->
        {:error, "Rate limit exceeded. Please wait a moment and try again."}

      500 ->
        {:error, "Claude API is experiencing issues. Please try again later."}

      _ ->
        case body do
          %{"error" => %{"message" => message}} ->
            {:error, "Claude API error: #{message}"}

          _ ->
            {:error, "An unexpected error occurred. Please try again."}
        end
    end
  end
end
